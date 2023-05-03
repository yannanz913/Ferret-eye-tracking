function [C,C1err,C2err] = findactualcameraVT2()
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
im1 = imread(fullfile(userpath,'tools','vhlab-eyetracking-matlab','calibration_images','Lcam_0102.png'));
im2 = imread(fullfile(userpath,'tools','vhlab-eyetracking-matlab','calibration_images','Rcam_0102.png'));
                                 
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

worldmarks1 = eyet.systems.calibration_obj3_left();
worldmarks2 = eyet.systems.calibration_obj3_right();

worldmarks = [worldmarks1 worldmarks2];

worldmarks = worldmarks(:,1:14); % only fit the cube part

disp(['Fitting camera ' int2str(1)]);

% Intrinsic Parameters of Left Camera with only fitted focal length
% focalLengthL    = [3841.3247424880833 3844.296941698488]; 
% principalPointL = [270.0 360.0];
% imageSizeL      = [540 720];

% Intrinsic Parameters of Left Camera without distortion
focalLengthL    = [3841.3247424880833 3844.296941698488]; 
principalPointL = [440.6619040953648 388.2411715405204];
imageSizeL      = [540 720];

% Intrinsic Parameters of Left Camera with distortion
% focalLengthL    = [3841.324742488083 3844.296941698488]; 
% principalPointL = [440.6619040953648 388.2411715405204];
% imageSizeL      = [540 720];

intrinsicsL = cameraIntrinsics(focalLengthL,principalPointL,imageSizeL);

[C(1),C1err,Cguess(1)] = eyet.fit.find_cameraVT(intrinsicsL,worldmarks,landmarks1,initial_position_guess(:,1),initial_angle_guess(:,1),...
    'number_of_starts',2);

disp(['Fitting camera ' int2str(2)]);

% Intrinsic Parameters of Right Camera with only fitted focal length
% focalLengthR    = [3111.946479127888 3154.7736921319197]; 
% principalPointR = [270.0 360.0];
% imageSizeR      = [540 720];

% Intrinsic Parameters of Right Camera without distortion
focalLengthR    = [3111.946479127888 3154.7736921319197]; 
principalPointR = [516.1667775884604 484.41379501095753];
imageSizeR      = [540 720];

% Intrinsic Parameters of Right Camera with distortion
% focalLengthR    = [3111.946479127888 3154.773692131920]; 
% principalPointR = [517.1667775884604 485.4137950109575];
% imageSizeR      = [540 720];

intrinsicsR = cameraIntrinsics(focalLengthR,principalPointR,imageSizeR);

[C(2),C2err,Cguess(2)] = eyet.fit.find_cameraVT(intrinsicsR, worldmarks,landmarks2,initial_position_guess(:, 2),initial_angle_guess(:, 2),...
    'number_of_starts',2);

disp(['comparison']);

figure;
eyet.plot.calibration_obj3(0);
eyet.plot.calibration_obj3(1);
hold on;
fontsize(gca,scale=1.5);
plot(C(1));
plot(C(2));


% plot camera views

figure;
subplot(2,2,1);
image(im1);
fontsize(gca,scale=2.5);
hold on;
eyet.plot.cameraview_calibration_obj(C(1));
plot(landmarks1(1,:),landmarks1(2,:),'gs')
subplot(2,2,2)
image(im2);
hold on;
fontsize(gca,scale=2.5);
eyet.plot.cameraview_calibration_obj(C(2));
plot(landmarks2(1,:),landmarks2(2,:),'gs')

norm_c1err = vecnorm(C1err);
norm_c2err = vecnorm(C2err);

avg_c1err = mean(norm_c1err,2)
avg_c2err = mean(norm_c2err,2)

disp("Average Error");
disp((avg_c1err + avg_c2err)/2);

disp("Extrinsic Parameters for C1");
disp("Rotation Matrix");
disp(C(1).extrinsics.RotationMatrix);
disp("Translation Vector");
disp(C(1).extrinsics.TranslationVector);

disp("Extrinsic Parameters for C2");
disp("Rotation Matrix");
disp(C(2).extrinsics.RotationMatrix);
disp("Translation Vector");
disp(C(2).extrinsics.TranslationVector);


