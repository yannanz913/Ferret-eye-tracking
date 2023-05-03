function [C, L] = findactual_camera_light()
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
initial_position_guess_c = [ [10.2; 2.3; -0.1]  [11.7; -2.8; -0.2] ];
initial_angle_guess_c = [ [0.22 0 vlt.math.deg2rad(180)]' [-0.23 0 vlt.math.deg2rad(180)]' ];
im2 = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/left_cam_glints0801.png']));
im = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/right_cam_glints0801.png']));

landmarks1 = [  165.5691  297.2638
   89.2558  139.8294
  353.0346  177.6137
   39.4862  446.8265
  281.6982  465.7187
   31.1912  498.7799
  276.7212  522.3950
655.4446  198.3646
619.2677  492.0008];

landmarks1 = landmarks1'; % put into column form

landmarks2 = [ 354.6935  243.7362
  208.7028  113.0656
  459.2097  119.3630
  200.4078  382.2784
  426.0300  388.5758
  193.7719  432.6574
  427.6889  440.5292
718.9857  134.6820
710.4640  402.8797];

  %landmarks2 = eyet.test.findImagePoints(im2);

landmarks2 = landmarks2';

pixelsX = size(im,2);
pixelsY = size(im,1);
mag_guess = 3500;

worldmarks = eyet.systems.calibration_obj();

disp(['Fitting camera ' int2str(1)]);

C(1) = eyet.fit.find_camera(worldmarks,landmarks1,initial_position_guess_c(:,1),initial_angle_guess_c(:,1),mag_guess,...
    'pixelsX',pixelsX,'pixelsY',pixelsY,'search_Magnification',1,'number_of_starts',1,'magnification_Min',3000,'magnification_Max',4000);

disp(['Fitting camera ' int2str(2)]);

C(2) = eyet.fit.find_camera(worldmarks,landmarks2,initial_position_guess_c(:, 2),initial_angle_guess_c(:, 2),mag_guess,...
    'pixelsX',pixelsX,'pixelsY',pixelsY,'search_Magnification',1,'number_of_starts',1,'magnification_Min',3000,'magnification_Max',4000);

% then find the lights
initial_position_guess_l = [ [3.6; 17.5; 6.1]  [13; 13.3; 6.2] ];
initial_angle_guess_l = [ [0.22 0 vlt.math.deg2rad(180)]' [-0.23 0 vlt.math.deg2rad(180)]' ];

radii = [0.16; 0.16; 0.16];
marble_center = [0.16; 0.8; 0];
rotation = [0; 0; 0];

xy_pt11 = [481.1912  303.6095];
xy_pt12 = [502.4401  305.0328];
xy_pt21 = [676.6336  239.8139]; 
xy_pt22 = [693.5184  238.2372];

disp(['Fitting light source ' int2str(1)]);

L(1) = eyet.fit.find_lightsources(C, xy_pt11, xy_pt12, xy_pt21, xy_pt22, radii, marble_center,rotation);

disp(['Fitting light source ' int2str(2)]);

L(2) = eyet.fit.find_lightsources(C, xy_pt11, xy_pt12, xy_pt21, xy_pt22, radii, marble_center,rotation);





disp(['comparison']);

figure;
eyet.plot.calibration_obj();
hold on;
plot(C(1));
plot(C(2));
initial_guess_C(1) = eyet.CameraModel.CameraModelAlt(initial_position_guess_c(:,1),initial_angle_guess_c(:,1), mag_guess,pixelsX,pixelsY);
initial_guess_C(2) = eyet.CameraModel.CameraModelAlt(initial_position_guess_c(:,2),initial_angle_guess_c(:,2), mag_guess,pixelsX,pixelsY);
plot(initial_guess_C(1));
plot(initial_guess_C(2));


% plot camera views

figure;
subplot(2,2,1);
image(im);
hold on;
eyet.plot.cameraview_calibration_obj(C(1));
plot(landmarks1(1,:),landmarks1(2,:),'gs')
title({'Right camera on system' 'left camera from view of animal'})
subplot(2,2,2)
image(im2);
hold on;
eyet.plot.cameraview_calibration_obj(C(2));
plot(landmarks2(1,:),landmarks2(2,:),'gs')
title({'Left camera on system' 'right camera from view of animal'})
