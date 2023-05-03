function [world_points] = calibration_obj3_right(varargin)
% CALIBRATION_OBJ3_RIGHT - return real-world coordinates of the LEGO calibration object
%
% [world_points] = eyet.calibration_obj3_right(origin, l, d1, d2, h1, h2)
%
% Return real-world coordinates of 14 points on the LEGO calibration object based on
% the image:
% https://github.com/VH-Lab/vhlab-eyetracking-matlab/blob/main/calibration_images/lego_calibration.jpg
%
% These points on the cube are returned:
% world_points(:,1) - the center of the reflective round piece from the front view;
% world_points(:,2) - the upper left corner of the cube from the front view;
% world_points(:,3) - the upper right corner of the cube from the front view;
% world_points(:,4) - the upper point on the cube's bottom extended part from the left view;
% world_points(:,5) - the upper point on the cube's bottom extended part from the right view;
% world_points(:,6) - the lower point on the cube's bottom extended part from the left view;
% world_points(:,7) - the lower point on the cube's bottom extended part from the right view;
% Coordinates are in cm.
%
% This function also takes name/value pairs that modify the default
% behavior:
% |--------------------------------------|---------------------------------------|
% |Parameter (default)                   | Description                           |
% |--------------------------------------|---------------------------------------|
% | origin ([0;0;0])                     | Origin location                       |
% | l (0.8)                              | Cube length                           |
% | d1 (0.5)                             | Perpendicular distance from tip of    | 
% |                                      |   reflective round piece to cube front|
% | d2 (0.16)                            | Perpendicular distance from the tip of|
% |                                      | bottom extended part to cube's front  |
% |                                      |   surface                             |
% | h1 (0.8)                             | Cube height                           |
% | h2 (0.16)                            | Height of cube "bottom shelf"         |
% |--------------------------------------|---------------------------------------|
%
% Example:
% [world_points] = eyet.systems.calibration_obj3_right()

origin = [0;0;0];
l = 0.8;
d1 = 0.5;
d2 = 0.16;
h1 = 0.8;
h2 = 0.16;

origin = [0;l;0];
mark8 = origin;
mark9 = [origin(1)-d1; origin(2)-l/2; origin(3)+h1/2];
mark10 = [origin(1)-d1; origin(2)+l/2; origin(3)+h1/2];
mark11 = [origin(1)-d1+d2; origin(2)-l/2; origin(3)-h1/2];
mark12 = [origin(1)-d1+d2; origin(2)+l/2; origin(3)-h1/2];
mark13 = [origin(1)-d1+d2; origin(2)-l/2; origin(3)-h1/2-h2];
mark14 = [origin(1)-d1+d2; origin(2)+l/2; origin(3)-h1/2-h2];

world_points = [mark8 mark9 mark10 mark11 mark12 mark13 mark14];
