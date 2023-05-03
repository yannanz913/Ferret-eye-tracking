function out = simple
% SIMPLE - simulate a simple system
%
% OUT = eyet.test.simple()
%
% Creates a simple system with an eye ball ellipse with axis dimensions [1 2 1] and
% two light sources, and a camera. 
%
% OUT contains all of the workspace variables.
%


E = eyet.EyeModel('eye_rotation',[25;10;0]); 

[L,C] = eyet.systems.led_2camera_arrayB([10;0;0],[0 0 0],250,1);

out = eyet.compute_model(C,E,L,1);
