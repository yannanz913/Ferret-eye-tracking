function h = calibration_obj3(a)
% eyet.plot.calibration_obj3 - plot the calibration object in the current axes
%
% h = eyet.calibration_obj3()
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
% h = eyet.plot.calibration_obj3()

world_points = eyet.systems.calibration_obj3_left();
x_origin = 0;
y_origin = 0;
z_origin = 0;

if a == 1,
    world_points = eyet.systems.calibration_obj3_right();
    x_origin = 0;
    y_origin = 0.8;
    z_origin = 0;
end;

hold on;
h1 = plot3(world_points(1,[4 5 7 6 4]),world_points(2,[4 5 7 6 4]),world_points(3,[4 5 7 6 4]),'b-');
figure(gcf)
axis equal
h2 = plot3(x_origin,y_origin,z_origin,'o');
h3 = plot3(world_points(1,[2 3]),world_points(2,[2 3]),world_points(3,[2 3]),'b-');

h = [ h1 h2 h3];
