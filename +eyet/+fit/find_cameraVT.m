function [cameraModelObj,reconstructionError, cameraModelObj_guess] = find_cameraVT(intrinsics, w_pt,c_pt,initial_position_guess, initial_angle_guess, varargin)
% find_camera - search for the orientation and location of a calibrated 
% camera in a world coordinate system
%
% [cameraModelObj,reconstructionError,cameraModelObj_guess] = eyet.find_camera(intrinsics, w_pt,c_pt,...
%    initial_position_guess,initial_angle_guess, ...)
%
% Given the real-world coordinates of more than 4 points on the
% calibration object and their corresponding image points (x,y
% coordinates) on a camera, return the eyet.CameraModel object that
% fits the points with the least squared error.
% This function also returns cameraModelObj_guess, which is the initial
% camera guess provided by the user.
% 
% Inputs:
% intrinsics - the intrinsic parameters for the camera from Matlab Vision Toolbox
% w_pt - Coordinates of world points, specified as an M-by-3 array of [x,y,z] coordinates
% landmarks - Points on object in xy coordinates on image plane
% initial_position_guess - an initial guess of the position of the camera
%    in real world coordinates, needs to be accurate within a couple of centimeters
% initial_angle_guess - an initial guess of the rotation angles of the
%    camera [az el theta] (see also help eyet.CameraModel.CameraModelAlt)
%
% Outputs:
% cameraModelObj - the eyet.CameraModelVT object that is the best least-squares fit to the data
% reconstructionError - the reconstruction error (in camera pixel
%    coordinates) for each point in the calibration image
% cameraModelObj_guess - the eyet.CameraModelVT object of the initial guess
%
% This function can also take extra arguments as name/value pairs that
% modify the default behavior:
% |----------------------------------|------------------------------------|
% | Parameter(default)               | Description                        |
% |----------------------------------|------------------------------------|
% | number_of_starts (25)            | Number of random search starting   |
% |                                  |   positions                        |
% | pixelsX (100)                    | Number of pixels in x dimension    |
% | pixelsY (100)                    | Number of pixels in y dimension    |
% | position_search_range_x (2)      | Range to search for camera nodal   |
% |                                  |    point in X                      |
% | position_search_range_y (2)      | Range to search for camera nodal   |
% |                                  |    point in Y                      |
% | position_search_range_z (2)      | Range to search for camera nodal   |
% |                                  |    point in Z                      |
% | azimuth_search_range             | Search range for azimuth           |
% |   (vlt.math.deg2rad(10))         |                                    |
% | elevation_search_range           | Search range for elevation         |
% |   (vlt.math.deg2rad(10))         |                                    |
% | camerarotation_search_range      | Range to search for camera rotation|
% |   (vlt.math.deg2rad(20))         |                                    |
% |----------------------------------|------------------------------------| 
%
%

  % let's set up

number_of_starts = 25;
pixelsX = 100;
pixelsY = 100;
% position_search_range_x = 6;
% position_search_range_y = 4;
% position_search_range_z = 4;
% azimuth_search_range = vlt.math.deg2rad(20);
% elevation_search_range = vlt.math.deg2rad(20);
% camerarotation_search_range = vlt.math.deg2rad(40);

position_search_range_x = 40;
position_search_range_y = 40;
position_search_range_z = 40;
azimuth_search_range = vlt.math.deg2rad(80);
elevation_search_range = vlt.math.deg2rad(80);
camerarotation_search_range = vlt.math.deg2rad(80);

vlt.data.assign(varargin{:});

x_rng = position_search_range_x / 2;
y_rng = position_search_range_y / 2;
z_rng = position_search_range_z / 2;
az_rng = azimuth_search_range/2;
el_rng = elevation_search_range/2;
camrot_rng = camerarotation_search_range / 2;

% Step 1: make an initial guess of the camera

initial_position_guess = initial_position_guess(:);
initial_angle_guess = initial_angle_guess(:);

%camera_parameters = [ nodal_pt_x nodal_pt_y nodal_pt_z az el theta ]
camera_parameters_guess = [ initial_position_guess(:, 1); initial_angle_guess(:, 1)];

cameraModelObj_guess = eyet.CameraModelVT.CameraModelAlt(intrinsics,[camera_parameters_guess([1;2;3])],[camera_parameters_guess([4 5 6])]);

initalerror = sum( ( c_pt-cameraModelObj_guess.worldpt2camera(w_pt) ).^2 );

X0 = camera_parameters_guess;

options = optimoptions('lsqnonlin','Display','iter','algorithm','trust-region-reflective');

lower = [ initial_position_guess(1)-x_rng;initial_position_guess(2)-y_rng;initial_position_guess(3)-z_rng; ...
    initial_angle_guess(1)-az_rng;initial_angle_guess(2)-el_rng;initial_angle_guess(3)-camrot_rng];
upper = [ initial_position_guess(1)+x_rng;initial_position_guess(2)+y_rng;initial_position_guess(3)+z_rng; ...
    initial_angle_guess(1)+az_rng;initial_angle_guess(2)+el_rng;initial_angle_guess(3)+camrot_rng];

bestErr = Inf;
X_best = [];
for i=1:number_of_starts,
    X0 = [camera_parameters_guess(1:3) + 2*randn(3,1); camera_parameters_guess(4:6) + vlt.math.deg2rad(10)*randn(3,1);];
	[X_1,fval,exitflag,output] = lsqnonlin(@(X) ...
                eyet.fit.camera_error(eyet.CameraModelVT.CameraModelAlt(intrinsics, X([1;2;3]),[X([4 5 6])]),w_pt,c_pt), ...
		[ X0 ],lower, upper, options);

	if sum(fval)<bestErr, % did we beat our best?
		bestErr = sum(fval); 
		X_best = X_1;
	end;
end;

X = X_best;

cameraModelObj = eyet.CameraModelVT.CameraModelAlt(intrinsics,X([1;2;3]),[X([4 5 6])]);

reconstructionError = eyet.fit.camera_error(cameraModelObj,w_pt,c_pt);
