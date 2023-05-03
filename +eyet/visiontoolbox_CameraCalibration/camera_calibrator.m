function camera_calibrator()
%% camera calibration for the left camera

% Create a set of calibration images.
images = imageDatastore([userpath '/tools/vhlab-eyetracking-matlab-visiontoolbox/calibration_images/animalview_Lcam_cali']);
% images = imageDatastore('/Users/elainezhu/Downloads/vhlab-eyetracking-matlab-visiontoolbox/calibration_images/animalview_Lcam_cali');
imageFileNames = images.Files;

% Detect calibration pattern.
[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);

% Generate world coordinates of the corners of the squares.
squareSize = 1.25; % millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera.
I = readimage(images, 1); 
imageSize = [size(I, 1), size(I, 2)];
[params, ~, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
                                     ImageSize=imageSize);
                                 
figure(1); 
showExtrinsics(params, "CameraCentric");

figure(2); 
showExtrinsics(params, "PatternCentric");

figure(3); 
showReprojectionErrors(params);

displayErrors(estimationErrors, params);

%% camera calibration for the right camera

% Create a set of calibration images.
images2 = imageDatastore([userpath '/tools/vhlab-eyetracking-matlab-visiontoolbox/calibration_images/animalview_Rcam_cali']);
% images2 = imageDatastore('/Users/elainezhu/Downloads/vhlab-eyetracking-matlab-visiontoolbox/calibration_images/animalview_Rcam_cali');
imageFileNames2 = images2.Files;

% Detect calibration pattern.
[imagePoints2, boardSize2] = detectCheckerboardPoints(imageFileNames2);

% Generate world coordinates of the corners of the squares.
squareSize = 1.25; % millimeters
worldPoints2 = generateCheckerboardPoints(boardSize2, squareSize);

% Calibrate the camera.
I2 = readimage(images2, 1); 
imageSize2 = [size(I2, 1), size(I2, 2)];
[params2, ~, estimationErrors2] = estimateCameraParameters(imagePoints2, worldPoints2, ...
                                     ImageSize=imageSize2);
                                 
figure(4); 
showExtrinsics(params2, "CameraCentric");

figure(5); 
showExtrinsics(params2, "PatternCentric");

figure(6); 
showReprojectionErrors(params2);

displayErrors(estimationErrors2, params2);
