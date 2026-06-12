import re
import asyncio
import aiohttp
from difflib import SequenceMatcher

ANILIST_URL = "https://graphql.anilist.co"


# =========================
# HTTP CLIENT HELPERS
# =========================

async def anilist_search(session, query: str):
    gql = """
    query ($search: String) {
      Page(perPage: 5) {
        media(search: $search, type: ANIME) {
          id
          title { romaji english }
          season
          seasonYear
          episodes
          format
          relations {
            edges {
              node {
                id
              }
            }
          }
        }
      }
    }
    """

    payload = {"query": gql, "variables": {"search": query}}

    async with session.post(ANILIST_URL, json=payload) as resp:
        data = await resp.json()

    return data["data"]["Page"]["media"]


async def anilist_get_media_batch(session, ids: list[int]):
    gql = """
    query ($ids: [Int]) {
      Page(page: 1, perPage: 50) {
        media(id_in: $ids) {
          id
          title { romaji english native }
          season
          seasonYear
          episodes
          format
          relations {
            edges {
              node { 
                id 
              }
            }
          }
        }
      }
    }
    """

    payload = {"query": gql, "variables": {"ids": ids}}

    async with session.post(ANILIST_URL, json=payload) as resp:
        data = await resp.json()

    return data["data"]["Page"]["media"]


# =========================
# UTILITIES
# =========================

def pick_title(media):
    t = media.get("title", {})
    return t.get("romaji") or t.get("english") or "Unknown"


NORMALIZE_RE = re.compile(r"[:.!]")
def normalize(s):
    return NORMALIZE_RE.sub("", s).lower().strip()

def similarity(a, b):
    return int(SequenceMatcher(None, a, b).ratio() * 100)

SANITIZE_RE = re.compile(r"[:.!]")
def sanitize(name: str) -> str:
    return SANITIZE_RE.sub("", name).strip()


# =========================
# SERIES BUILDER (FIXED)
# =========================

def is_skippable(media):
    if not media:
        return True

    fmt = (media.get("format") or "").upper()
    title = (media.get("title", {}).get("romaji") or "").lower()

    is_ova = fmt == "OVA"
    is_special = fmt in ("SPECIAL", "TV_SPECIAL")

    # optional fallback title detection (AniList sometimes lies)
    if "ova" in title:
        is_ova = True

    if "special" in title and "tv special" not in title:
        is_special = True

    is_wrong_type = fmt not in ("TV", "ONA", "MOVIE", "TV_SPECIAL", "")

    is_single_episode = (media.get("episodes") == 1 and fmt != "MOVIE")

    return is_ova or is_special or is_wrong_type or is_single_episode


PART_RE = re.compile(r"\bpart\s*\d+\b")
SPACE_RE = re.compile(r"\s+")
def base_series_key(media):
    title = media.get("title", {})
    name = title.get("romaji") or title.get("english") or ""
    name = normalize(name)

    # remove "part X"
    name = PART_RE.sub("", name)
    name = SPACE_RE.sub(" ", name).strip()

    return name

async def build_series(session, root_media):
    # 1. fetch root fully
    root_full = await anilist_get_media_batch(session, [root_media["id"]])
    root_full = root_full[0]

    cache = {root_full["id"]: root_full}

    # 2. extract ALL related IDs (NO BFS)
    ids = {
        edge["node"]["id"]
        for edge in root_full.get("relations", {}).get("edges", [])
        if edge.get("node")
    }

    ids.add(root_full["id"])

    # 3. single batch fetch
    media_list = await anilist_get_media_batch(session, list(ids))

    cache = {m["id"]: m for m in media_list}

    # 4. grouping
    grouped = {}

    for media in cache.values():
        if is_skippable(media):
            continue

        key = base_series_key(media)
        eps = media.get("episodes") or 0

        if key not in grouped:
            grouped[key] = media
            grouped[key]["_episode_sum"] = eps
        else:
            grouped[key]["_episode_sum"] += eps

    series = list(grouped.values())

    series.sort(key=lambda x: (
        x.get("seasonYear") or 0,
        {"WINTER": 0, "SPRING": 1, "SUMMER": 2, "FALL": 3}.get(x.get("season"), 99)
    ))

    return series


def rebase_series(series, start_season):
    start_index = max(start_season - 1, 0)
    return series[start_index:]


# =========================
# RESOLVE TITLE
# =========================

def get_all_titles(media):
    t = media.get("title", {})
    return [
        t.get("romaji"),
        t.get("english"),
        t.get("native")
    ]

async def resolve_title(session, title: str):
    results = await anilist_search(session, title)

    if not results:
        return title, None, None

    best = None
    best_score = -1

    for m in results:
        titles = [x for x in get_all_titles(m) if x]

        score = max(
            similarity(normalize(t), normalize(title))
            for t in titles
        )

        if score > best_score:
            best_score = score
            best = m
    return best

# =========================
# EPISODE MAPPING
# =========================

def resolve_episode(series, episode_number, start_season=1):
    season = start_season
    print("Starting season:", season)

    for media in series:
        print("Checking media:", media.get("title", {}).get("romaji"))
        eps = media.get("episodes")

        if eps is None:
            return season, episode_number, None

        if episode_number > eps:
            episode_number -= eps
            print("Episode number:", episode_number)

            season += 1
        else:
            return season, episode_number, eps

    return season, episode_number, None
