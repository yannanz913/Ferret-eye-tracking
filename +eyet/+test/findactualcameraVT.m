function C = findactualcameraVT()
% eyet.test.findactualcamera - test the new function eyet.fit.findcamera
% im - left image
% im2 - right image
% initial_position_guess - initial guess of the position of the camera
% initial_angle_guess - initial guess of the angle of the camera
% pixelsX - the number of pixels in the X dimension of the camera
% pixelsY - the number of pixels in the Y dimension of the camera
% 
% Example:

initial_position_guess = [ [10.2; 2.3; -0.1]  [11.7; -2.8; 0] ];
initial_angle_guess = [ [-0.22 vlt.math.deg2rad(90) vlt.math.deg2rad(-90)]' [0.85 vlt.math.deg2rad(120) vlt.math.deg2rad(-105)]' ];
% im1 = imread('/Users/elainezhu/Desktop/Lcam_0102.png');
% im2 = imread('/Users/elainezhu/Desktop/Rcam_0102.png');
im1 = imread(fullfile(userpath,'tools','vhlab-eyetracking-matlab','calibration_images','Lcam_0102.png'));
im2 = imread(fullfile(userpath,'tools','vhlab-eyetracking-matlab','calibration_images','Rcam_0102.png'));

% Calibrate the camera
images = imageDatastore([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/animalview_Lcam_cali/Used']);
% images = imageDatastore('/Users/elainezhu/Downloads/vhlab-eyetracking-matlab-visiontoolbox/calibration_images/animalview_Lcam_cali');
imageFileNames = images.Files;
[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);
squareSize = 1.25; % millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
I = readimage(images, 1); 
imageSize = [size(I, 1), size(I, 2)];
[params_L, ~, estimationErrors_L] = estimateCameraParameters(imagePoints, worldPoints, ...
                                     ImageSize=imageSize);
images2 = imageDatastore([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/animalview_Rcam_cali/Used']);
% images2 = imageDatastore('/Users/elainezhu/Downloads/vhlab-eyetracking-matlab-visiontoolbox/calibration_images/animalview_Rcam_cali');
imageFileNames2 = images2.Files;
[imagePoints2, boardSize2] = detectCheckerboardPoints(imageFileNames2);
squareSize = 1.25; % millimeters
worldPoints2 = generateCheckerboardPoints(boardSize2, squareSize);
I2 = readimage(images2, 1); 
imageSize2 = [size(I2, 1), size(I2, 2)];
[params_R, ~, estimationErrors_R] = estimateCameraParameters(imagePoints2, worldPoints2, ...
                                     ImageSize=imageSize2);
                                 
%landmarks1 = eyet.test.findImagePoints(im);

landmarks1 = [188  158
               78  16
              376  40
               34  322
              340  354
               24  380
              334  414
              518  186
              386  42
              690  66
              354  354
              660  384
              344  414
              656  446
             ];

landmarks1 = landmarks1'; % put into column form

  %landmarks2 = eyet.test.findImagePoints(im2);

landmarks2 = [222  166
               46  36
              306  60
               44  314
              306  332
               38  366
              300  382
              490  188
              312  60
              558  74
              318  330
              566  346
              312  380
              566  392
             ];

landmarks2 = landmarks2';

% pixelsX = size(im1,2);
% pixelsY = size(im1,1);
% mag_guess = 3500;

worldmarks = eyet.systems.calibration_obj3();

worldmarks = worldmarks(:,1:14); % only fit the cube part

disp(['Fitting camera ' int2str(1)]);

disp(params_L.Intrinsics);

[C(1),Cguess(1)] = eyet.fit.find_cameraVT(params_L.Intrinsics,worldmarks,landmarks1,initial_position_guess(:,1),initial_angle_guess(:,1),...
    'number_of_starts',2);

disp(['Fitting camera ' int2str(2)]);

[C(2),Cguess(2)] = eyet.fit.find_cameraVT(params_R.Intrinsics, worldmarks,landmarks2,initial_position_guess(:, 2),initial_angle_guess(:, 2),...
    'number_of_starts',2);

disp(['comparison']);

figure;
eyet.plot.calibration_obj();
hold on;
plot(C(1));
plot(C(2));


% plot camera views

figure;
subplot(2,2,1);
image(im1);
hold on;
eyet.plot.cameraview_calibration_obj(C(1));
plot(landmarks1(1,:),landmarks1(2,:),'gs')
subplot(2,2,2)
image(im2);
hold on;
eyet.plot.cameraview_calibration_obj(C(2));
plot(landmarks2(1,:),landmarks2(2,:),'gs')



% eyet.plot.cameraview_calibration_obj(C(1));
% eyet.plot.cameraview_calibration_obj(C(2));

