import vapoursynth as vs
import sys
import os
from fractions import Fraction
from importlib.machinery import SourceFileLoader
from vsdrba import drba_rife

core = vs.core
os.environ["CUDA_MODULE_LOADING"] = "LAZY"
os.environ["CUDA_CACHE_DISABLE"] = "0"

user_directory = os.environ['UserDirectory']

plugins_dir = os.path.join(user_directory, "Documents", "vapoursynth-portable", "vs-plugins")

for file in os.listdir(plugins_dir):
    if file.lower().endswith(".dll"):
        try:
            core.std.LoadPlugin(os.path.join(plugins_dir, file))
            print("Loaded:", file)
        except Exception as e:
            print("Failed:", file, e)

input_video = globals()["source"]
clip = core.lsmas.LWLibavSource(
    source=input_video, 
    format="YUV444P16", 
    cache=0,
    fpsnum=24000, 
    fpsden=1001, 
    prefer_hw=3
)

clip = core.std.AddBorders(clip=clip, left=0, right=0, top=4, bottom=4)
clip = core.resize.Bicubic(
    clip=clip, 
    format=vs.RGBH, 
    matrix_in_s="709", 
    range_s="limited"
)

clip = drba_rife(
    clip, 
    model="4.25",
    scale=1.0,
    sc=True,
    sc_threshold=0.15,
    trt=True, 
    trt_optimization_level=5, 
    trt_cache_dir=user_directory + "/ConvertedVideos"
)

clip = core.std.Crop(clip=clip, left=0, right=0, top=4, bottom=4)

clip = core.resize.Bicubic(
    clip=clip,
    format=vs.YUV444P16,
    matrix_s="709",
    range_s="limited"
)

clip = core.placebo.Shader(
    clip, 
    width=clip.width * 2, 
    height=clip.height * 2, 
    shader=user_directory + "/Documents/vapoursynth-portable/shaders/Anime4K_ModeA.glsl"
)

clip = core.resize.Bicubic(
    clip=clip,
    format=vs.YUV420P10,
    matrix_s="709",
    range_s="limited"
)

clip = core.std.AssumeFPS(
    clip=clip,
    fpsnum=48000,
    fpsden=1001
)

clip.set_output()