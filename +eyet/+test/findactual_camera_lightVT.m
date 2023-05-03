function [C, L] = findactual_camera_lightVT()
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
initial_position_guess = [ [10.2; 2.3; -0.1]  [11.7; -2.8; 0] ];
initial_angle_guess = [ [-0.22 vlt.math.deg2rad(90) vlt.math.deg2rad(-90)]' [0.85 vlt.math.deg2rad(120) vlt.math.deg2rad(-105)]' ];
% im1 = imread('/Users/elainezhu/Desktop/Lcam_glints_0227.png');
% im2 = imread('/Users/elainezhu/Desktop/Rcam_glints_0227.png');
im1 = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/Lcam_glints_0227.png']));
im2 = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/Rcam_glints_0227.png']));

landmarks1 = [  204.1406  503.8431
   18.3341  338.2956
   33.2650  335.1423
  328.5645  352.4854
   38.2419  275.2299
   89.6705  278.3832
  643.7719  172.7482];

landmarks1 = landmarks1'; % put into column form

landmarks2 = [ 297.0438  503.8431
   58.1498  376.1350
   96.3065  369.8285
  328.5645  357.2153
   89.6705  313.0693
  134.4631  313.0693
  603.9562  156.9818];

  %landmarks2 = eyet.test.findImagePoints(im2);

landmarks2 = landmarks2';

% pixelsX = size(im,2);
% pixelsY = size(im,1);
% mag_guess = 3500;

worldmarks = eyet.systems.calibration_obj2();

disp(['Fitting camera ' int2str(1)]);

focalLengthL    = [3841.3247424880833 3844.296941698488]; 
principalPointL = [440.6619040953648 388.2411715405204];
imageSizeL      = [540 720];

intrinsicsL = cameraIntrinsics(focalLengthL,principalPointL,imageSizeL);

[C(1),C1error,Cguess(1)] = eyet.fit.find_cameraVT(intrinsicsL,worldmarks,landmarks1,initial_position_guess(:,1),initial_angle_guess(:,1),...
    'number_of_starts',2);

disp(['Fitting camera ' int2str(2)]);

focalLengthR    = [3111.946479127888 3154.7736921319197]; 
principalPointR = [516.1667775884604 484.41379501095753];
imageSizeR      = [540 720];

intrinsicsR = cameraIntrinsics(focalLengthR,principalPointR,imageSizeR);

[C(2),C2error,Cguess(2)] = eyet.fit.find_cameraVT(intrinsicsR, worldmarks,landmarks2,initial_position_guess(:, 2),initial_angle_guess(:, 2),...
    'number_of_starts',2);

% disp(['comparison']);
% 
figure;
eyet.plot.calibration_obj2();
hold on;
plot(C(1));
plot(C(2));


% plot camera views

camViewFig = figure;
subplot(2,2,1);
image(im1);
hold on;
eyet.plot.cameraview_calibration_obj2(C(1));
plot(landmarks1(1,:),landmarks1(2,:),'gs')
subplot(2,2,2)
image(im2);
hold on;
eyet.plot.cameraview_calibration_obj2(C(2));
plot(landmarks2(1,:),landmarks2(2,:),'gs');


% then find the lights
% initial_position_guess_l = [ [3.6; 17.5; 6.1]  [13; 13.3; 6.2] ];
% initial_angle_guess_l = [ [0.22 0 vlt.math.deg2rad(180)]' [-0.23 0 vlt.math.deg2rad(180)]' ];

radii = [1.545/2; 1.545/2; 1.545/2];
marble_center = [0-0.5+0.16-0.784/2; 0+0.784/2+0.67; 0+0.8/2+0.156+0.8/2];
rotation = [0; 0; 0];

xy_pt11 = [550.8687  138.0620]; 
xy_pt12 = [600.6382  134.9088]; 
xy_pt21 = [477.8733  133.3321]; 
xy_pt22 = [521.0069  131.7555]; 

 % add these to the plot

figure(camViewFig);

subplot(2,2,1);
hold on
plot([xy_pt11(1,1)],[xy_pt11(1,2)],'rd');
plot([xy_pt12(1,1)],[xy_pt12(1,2)],'rd');
subplot(2,2,2);
plot([xy_pt21(1,1)],[xy_pt21(1,2)],'rd');
plot([xy_pt22(1,1)],[xy_pt22(1,2)],'rd');


[L_1 L_2] = eyet.fit.find_lightsourcesVT(C, xy_pt11, xy_pt12, xy_pt21, xy_pt22, radii, marble_center,rotation);

L = [L_1 L_2]

