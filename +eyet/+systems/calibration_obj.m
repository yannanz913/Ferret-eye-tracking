function [world_points] = calibration_obj(varargin)
% CALIBRATION_OBJ - return real-world coordinates of the LEGO calibration object
%
% [world_points] = eyet.calibration_obj(origin, l, d1, d2, h1, h2)
%
% Return real-world coordinates of 7 points on the LEGO calibration object based on
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
% world_points(:,8) - the cube with marble (on the right to the original one): the upper right corner
% world_points(:,9) - the cube with marble (on the right to the original one): the upper right point on the cube's bottom extended part
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
% [world_points] = eyet.systems.calibration_obj()

origin = [0;0;0];
l = 0.8;
d1 = 0.5;
d2 = 0.16;
h1 = 0.8;
h2 = 0.16;

vlt.data.assign(varargin{:});

mark1 = origin;
mark2 = [origin(1)-d1; origin(2)-l/2; origin(3)+h1/2];
mark3 = [origin(1)-d1; origin(2)+l/2; origin(3)+h1/2];
mark4 = [origin(1)-d1+d2; origin(2)-l/2; origin(3)-h1/2];
mark5 = [origin(1)-d1+d2; origin(2)+l/2; origin(3)-h1/2];
mark6 = [origin(1)-d1+d2; origin(2)-l/2; origin(3)-h1/2-h2];
mark7 = [origin(1)-d1+d2; origin(2)+l/2; origin(3)-h1/2-h2];
% mark8 = [origin(1)-d1; origin(2)+l/2+0.15+l; origin(3)+h1/2];
% mark9 = [origin(1)-d1+d2; origin(2)+l/2+0.15+l; origin(3)-h1/2];

world_points = [mark1 mark2 mark3 mark4 mark5 mark6 mark7];


