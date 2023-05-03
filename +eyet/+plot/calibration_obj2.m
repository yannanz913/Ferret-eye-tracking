function h = calibration_obj2(varargin)
% eyet.plot.calibration_obj2 - plot the calibration object in the current axes
%
% h = eyet.calibration_obj2()
%
% Returns line handles to the plotted points.
%
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
% h = eyet.plot.calibration_obj2()

[world_points,marble] = eyet.systems.calibration_obj2();



hold on;
h1 = plot3(world_points(1,[4 3 5 6]),world_points(2,[4 3 5 6]),world_points(3,[4 3 5 6]),'m-');
figure(gcf)
axis equal
h2 = plot3(0,0,0,'mo','MarkerSize', 6);
h3 = plot3(-0.5000,-0.3920, 0.4000,'mo','MarkerSize', 6);
h4 = plot3(0.0525,1.0620, 0.9560,'mo','MarkerSize', 6);

h = [ h1 h2 h3 h4];

[xe,ye,ze] = marble.plotpoints();
h(end+1) = plot3(xe,ye,ze,'ko');


