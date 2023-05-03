function out = simpleshiftalt
% SIMPLE - simulate a simple system where the eye is not at the origin
%
% OUT = eyet.test.simpleshiftalt()
%
% Creates a simple system with an eye ball ellipse with axis dimensions [1 2 1] and
% two light sources, and a camera. The eye is centered at [40;-30;10].
%
% OUT contains all of the simulated model variables.
%

eye_center = [40;-30;10];

E = eyet.EyeModel('eye_rotation',[25;10;0],'eye_center',eye_center,'pupil_azimuth_angle',25); 

[L,C] = eyet.systems.led_2camera_arrayBalt([10;0;0]+eye_center,250,1);

out = eyet.compute_model(C,E,L,1);


