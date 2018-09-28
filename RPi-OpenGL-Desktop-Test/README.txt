Raspberry Pi OpenGL Desktop Test
Copyright (c) 2016 Geeks3D, All rights reserved.
http://www.geeks3d.com


***************************************************
THIS SOFTWARE IS PROVIDED 'AS-IS', WITHOUT ANY 
EXPRESS OR IMPLIED WARRANTY. IN NO EVENT WILL 
THE AUTHOR BE HELD LIABLE FOR ANY DAMAGES ARISING 
FROM THE USE OF THIS SOFTWARE.
***************************************************


This test allows to check the OpenGL 2.1 support of your Raspberry Pi.

How to run it?

Just launch OpenGL21_Test, that's all.

This test requires a Raspberry Pi 2 and  Raspbian Feb 2016 
with OpenGL desktop support.

If the hardware OpenGL acceleration is enabled, the demo should run
at around 150 FPS and the GL_RENDERER can be something like 
Gallium 0.4 on VC4. If the hardware acceleration is disabled, the will
run at around 3 FPS and the GL_RENDERER will be Software Rasterizer.


This demo has been coded with the demotool GeeXLab. 
The source code (Lua + GLSL) is available in the opengl21-test/ folder.

More information about GeeXLab is available here:
- http://www.geexlab.com
- http://www.geeks3d.com/geexlab/
- http://www.geeks3d.com/hacklab/
