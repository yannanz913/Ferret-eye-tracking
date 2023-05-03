function camera_pts = cameraview_calibration_obj(C)
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

world_points1 = eyet.systems.calibration_obj3_left();
camera_pts1 = C.worldpt2camera(world_points1);
world_points2 = eyet.systems.calibration_obj3_right();
camera_pts2 = C.worldpt2camera(world_points2);
plot(camera_pts1(1, :), camera_pts1(2, :), '*');
plot(camera_pts2(1, :), camera_pts2(2, :), '*');
hold on;
plot(camera_pts1(1,[4 5 7 6 4]),camera_pts1(2,[4 5 7 6 4]),'b-');
plot(camera_pts2(1,[4 5 7 6 4]),camera_pts2(2,[4 5 7 6 4]),'b-');
plot(camera_pts1(1,[2 3]),camera_pts1(2,[2 3]),'b-');
plot(camera_pts2(1,[2 3]),camera_pts2(2,[2 3]),'b-');
axis equal
