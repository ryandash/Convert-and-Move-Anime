import vapoursynth as vs
import sys
import os
from fractions import Fraction
from importlib.machinery import SourceFileLoader

core = vs.core
os.environ["CUDA_MODULE_LOADING"] = "LAZY"

user_directory = os.environ['UserDirectory']
vsmlrt = SourceFileLoader('vsmlrt', user_directory + '/Documents/vapoursynth-portable/vs-plugins/vsmlrt.py').load_module()

input_video = globals()["source"]
clip = core.lsmas.LWLibavSource(source=input_video, format="YUV444P16", cache=0, fpsnum=24000, fpsden=1001, prefer_hw=1)

clip = core.placebo.Shader(clip, width=3840, height=2160, shader=user_directory + "/Documents/vapoursynth-portable/shaders/Anime4K_ModeA.glsl")

clip = core.misc.SCDetect(clip=clip, threshold=0.100)
clip = core.std.AddBorders(clip=clip, left=0, right=0, top=8, bottom=8)
clip = core.resize.Bicubic(clip=clip, format=vs.RGBH, matrix_in_s="709", range_s="limited")

clip = vsmlrt.RIFE(clip, multi=Fraction(2), model=425, backend=vsmlrt.Backend.TRT(fp16=True, device_id=0, use_cuda_graph=True, num_streams=2, builder_optimization_level=5, engine_folder=user_directory +"/ConvertedVideos"))

clip = core.std.Crop(clip=clip, left=0, right=0, top=8, bottom=8)
clip = core.resize.Bicubic(clip=clip, format=vs.YUV420P10, matrix_s="709", range_s="limited", dither_type="error_diffusion")

clip = core.std.AssumeFPS(clip=clip, fpsnum=48000, fpsden=1001)

clip.set_output()