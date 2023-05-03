function [C, L] = findactual_camera_light2()
% eyet.test.findactual_camera_light - test the new function eyet.fit.find_lightsources,
% using images with glints
% im - right image in the system (left camera from view of animal)
% im2 - left image in the system (right camera from view of animal)
% initial_position_guess_c - initial guess of the position of the camera
% initial_angle_guess_c - initial guess of the angle of the camera
% initial_position_guess_l - initial guess of the position of the IR
% initial_angle_guess_l - initial guess of the angle of the IR
% pixelsX - the number of pixels in the X dimension of the camera
% pixelsY - the number of pixels in the Y dimension of the camera
% 
% Example:

% find the cameras first
% initial_position_guess_c = [ [10.2; 2.3; -0.1]  [11.7; -2.8; -0.2] ];
initial_position_guess_c = [ [10.5; 0; -0.1]  [11.7; -4.5; -0.2] ];
initial_angle_guess_c = [ [0 0 vlt.math.deg2rad(180)]' [-0.43 0 vlt.math.deg2rad(180)]' ];

im = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/left_viewofanimal_glints_1010.png']));
im2 = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/right_viewofanimal_glints_1010.png']));

landmarks1 = [  241.6765  389.2581
   36.1863  225.7911
   51.8725  214.6138
  343.6373  242.5569
   55.0098  154.5362
  106.7745  157.3305];

landmarks1 = landmarks1'; % put into column form

landmarks2 = [ 287.1667  368.3008
   72.2647  239.7626
   98.9314  231.3797
  305.9902  238.3655
   97.3627  179.6850
  135.0098  178.2878];


  %landmarks2 = eyet.test.findImagePoints(im2);

landmarks2 = landmarks2';

pixelsX = size(im,2);
pixelsY = size(im,1);
mag_guess = 3500;

worldmarks = eyet.systems.calibration_obj2();

disp(['Fitting camera ' int2str(1)]);

C(1) = eyet.fit.find_camera(worldmarks,landmarks1,initial_position_guess_c(:,1),initial_angle_guess_c(:,1),mag_guess,...
    'pixelsX',pixelsX,'pixelsY',pixelsY,'search_Magnification',1,'number_of_starts',1,'magnification_Min',3000,'magnification_Max',4000);

disp(['Fitting camera ' int2str(2)]);

C(2) = eyet.fit.find_camera(worldmarks,landmarks2,initial_position_guess_c(:, 2),initial_angle_guess_c(:, 2),mag_guess,...
    'pixelsX',pixelsX,'pixelsY',pixelsY,'search_Magnification',1,'number_of_starts',1,'magnification_Min',3000,'magnification_Max',4000);

% then find the lights
% initial_position_guess_l = [ [3.6; 17.5; 6.1]  [13; 13.3; 6.2] ];
% initial_angle_guess_l = [ [0.22 0 vlt.math.deg2rad(180)]' [-0.23 0 vlt.math.deg2rad(180)]' ];

radii = [1.57/2; 1.57/2; 1.57/2];
marble_center = [0-0.5+0.16-0.784/2; 0+0.784/2+0.7; 0+0.156+(0.956-0.156-0.156-0.156)/2];
rotation = [0; 0; 0];

xy_pt11 = [613.4412   27.3952];
xy_pt12 = [701.2843   30.1895];
xy_pt21 = [484.8137   35.7781]; 
xy_pt22 = [552.2647   31.5867];

[L_1 L_2] = eyet.fit.find_lightsources(C, xy_pt11, xy_pt12, xy_pt21, xy_pt22, radii, marble_center,rotation);



% disp(['comparison']);
% 
figure;
eyet.plot.calibration_obj2();
hold on;
plot(C(1));
plot(C(2));
initial_guess_C(1) = eyet.CameraModel.CameraModelAlt(initial_position_guess_c(:,1),initial_angle_guess_c(:,1), mag_guess,pixelsX,pixelsY);
initial_guess_C(2) = eyet.CameraModel.CameraModelAlt(initial_position_guess_c(:,2),initial_angle_guess_c(:,2), mag_guess,pixelsX,pixelsY);
plot(initial_guess_C(1));
plot(initial_guess_C(2));
% 
% 
% % plot camera views
% 
figure;
subplot(2,2,1);
image(im);
hold on;
eyet.plot.cameraview_calibration_obj2(C(1));
plot(landmarks1(1,:),landmarks1(2,:),'gs')
title({'Right camera on system' 'left camera from view of animal'})
subplot(2,2,2)
image(im2);
hold on;
eyet.plot.cameraview_calibration_obj2(C(2));
plot(landmarks2(1,:),landmarks2(2,:),'gs')
title({'Left camera on system' 'right camera from view of animal'})


