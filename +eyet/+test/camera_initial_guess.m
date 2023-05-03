function camera_initial_guess()
% eyet.test.camera_initial_guess - plot the initial guess of 2 camera
% positions
% 
% Example:

initial_position_guess = [ [10.2; 2.3; -0.1]  [11.7; -2.8; -0.2] ];
initial_angle_guess = [ [0.22 0 vlt.math.deg2rad(180)]' [-0.23 0 vlt.math.deg2rad(180)]' ];
im1 = imread(fullfile(userpath,'tools','vhlab-eyetracking-matlab','calibration_images','left_cam_0711_.png'));
im2 = imread(fullfile(userpath,'tools','vhlab-eyetracking-matlab','calibration_images','right_cam_0711_.png'));

  %landmarks1 = eyet.test.findImagePoints(im);

landmarks1 = [  255.1544  235.8644
  168.8871   62.6866
  469.1636   83.1531
  124.0945  380.7041
  431.0069  407.4679
  109.1636  442.1035
  424.3710  473.5904];

landmarks1 = landmarks1'; % put into column form

  %landmarks2 = eyet.test.findImagePoints(im2);

landmarks2 = [ 389.9720  170.5058
  242.6121   42.0922
  503.6496   48.4077
  234.1916  309.4451
  493.1239  326.2862
  234.1916  368.3890
  495.2290  381.0199];

landmarks2 = landmarks2';

pixelsX = size(im1,2);
pixelsY = size(im1,1);
mag_guess = 3000;

worldmarks = eyet.systems.calibration_obj();

% plot system view

figure;
eyet.plot.calibration_obj();
hold on;
% plot initial guess camera
initial_guess_C(1) = eyet.CameraModel.CameraModelAlt(initial_position_guess(:,1),initial_angle_guess(:,1), mag_guess,pixelsX,pixelsY)
initial_guess_C(2) = eyet.CameraModel.CameraModelAlt(initial_position_guess(:,2),initial_angle_guess(:,2), mag_guess,pixelsX,pixelsY)
plot(initial_guess_C(1));
plot(initial_guess_C(2));

% plot camera views

figure;
subplot(2,2,1);
image(im1);
hold on;
eyet.plot.cameraview_calibration_obj(initial_guess_C(1));
plot(landmarks1(1,:),landmarks1(2,:),'gs')
subplot(2,2,2)
image(im2);
hold on;
eyet.plot.cameraview_calibration_obj(initial_guess_C(2));
plot(landmarks2(1,:),landmarks2(2,:),'gs')


