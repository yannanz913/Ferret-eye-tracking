function camera_pts = cameraview_calibration_obj2(C)
% eyet.plot.cameraview_calibration_obj - plot the projection of the
% calibration object on an eyet.CameraModel object
%
% camera_pts = eyet.cameraview_calibration_obj()
%
% Returns the projection points of the calibration object onto the 
% eyet.CameraModel C.
% The calibration object is plotted in the current axes.
%
%
% Example:
% eyet.plot.cameraview_calibration_obj(C)

world_points = eyet.systems.calibration_obj2();
camera_pts = C.worldpt2camera(world_points);
plot(camera_pts(1, :), camera_pts(2, :), '*')
hold on;
plot(camera_pts(1,[4 3 5 6]),camera_pts(2,[4 3 5 6]),'b-');
axis equal
