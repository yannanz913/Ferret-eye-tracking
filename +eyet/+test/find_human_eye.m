function E = find_human_eye(C)

% measured light sources position
L = [ [29.5; 14.2; 6.8]  [30; 2.7; 6.8] ];

% calculate the actual visual angle in degrees
angle_left = atand(59/81.2);
angle_right = atand(54/81.2);
angle_up = atand(60/54.7123);

% find visual angle based on C, L, and eye landmarks

% step 1: load images
img_leftcam_left = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/humaneye_testing_0305/leftcam_left.png']));
img_rightcam_left = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/humaneye_testing_0305/rightcam_left.png']));
img_leftcam_straight = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/humaneye_testing_0305/leftcam_straight.png']));
img_rightcam_straight = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/humaneye_testing_0305/rightcam_straight.png']));
img_leftcam_right = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/humaneye_testing_0305/leftcam_right.png']));
img_rightcam_right = imread(fullfile([userpath '/tools/vhlab-eyetracking-matlab/calibration_images/humaneye_testing_0305/rightcam_right.png']));
% img_leftcam_left = imread('/Users/elainezhu/Downloads/humaneye_testing_0305/leftcam_left.png');
% img_rightcam_left = imread('/Users/elainezhu/Downloads/humaneye_testing_0305/rightcam_left.png');
% img_leftcam_straight = imread('/Users/elainezhu/Downloads/humaneye_testing_0305/leftcam_straight.png');
% img_rightcam_straight = imread('/Users/elainezhu/Downloads/humaneye_testing_0305/rightcam_straight.png');
% img_leftcam_right = imread('/Users/elainezhu/Downloads/humaneye_testing_0305/leftcam_right.png');
% img_rightcam_right = imread('/Users/elainezhu/Downloads/humaneye_testing_0305/rightcam_right.png');
overExposedImg_leftcam_left = imadd(img_leftcam_left, 70); 
overExposedImg_rightcam_left = imadd(img_rightcam_left, 70); 
overExposedImg_leftcam_straight = imadd(img_leftcam_straight, 70); 
overExposedImg_rightcam_straight = imadd(img_rightcam_straight, 70); 
overExposedImg_leftcam_right = imadd(img_leftcam_right, 70); 
overExposedImg_rightcam_right = imadd(img_rightcam_right, 70); 
% image(overExposedImg_leftcam_left);
% landmarks = ginput

% step 2: find eye landmarks
    % landmarks = [pupil glint1 glint2 eye_left eye_right eye_top eye_bottom]
landmarks_cameras_leftlook = eyet.ManualLandmarks({[258.8871;  265.7701], [365.0622;  240.5438]}, {[[149.3940;  273.6533] [199.1636;  270.5000]], [[232.3433;  224.7774] [302.0207;  234.2372]]}, {[[-166;  310] [464.6014;  442.3540] [149.3940;  98.6460] [161.0069;  450.2372] ],[[-256; 275], [676.9516;  466.0036], [210.7765;  73.4197], [207.4585;  453.3905]] });
landmarks_cameras_middle = eyet.ManualLandmarks({[318.6106;  242.1204], [270.5000;  188.5146]}, {[[315.2926;  251.5803] [265.5230;  205.8577]], [[358.4263;  256.3102] [316.9516;  216.8942]]}, {[[-101.1129;  284.6898] [-67.9332;  245.2737] [613.9101;  313.0693] [723.4032;  365.0985] ],[[318.6106;  115.9891], [257.2281;   32.4270], [315.2926;  488.0766], [225.7074;  497.5365]] });
landmarks_cameras_rightlook = eyet.ManualLandmarks({[305.3387;  264.1934], [195.8456;  205.8577]}, {[[340.1774;  262.6168] [242.2972;  209.0109]], [[381.6521;  267.3467] [300.3618;  220.0474]]}, {[[-59.6382;  311.4927] [-114.3848;  240.5438] [696.8594;  358.7920] [723.4032;  325.6825] ],[[340.1774;  161.7117], [169.3018;   57.6533], [325.2465;  472.3102], [159.3479;  473.8869]] });

% step 3: find eyemodel
E_guess = eyet.EyeModel('eye_ellipse_size',[2.3; 2.3; 2.3],'eye_center',[-2;-2;0],...
	'eye_rotation',[0;0;0]);
landmarks = landmarks_cameras_leftlook;
% landmarks = landmarks_cameras_middle;
% landmarks = landmarks_cameras_rightlook;
[E_L,E_guess_L,bestErr_L] = eyet.fit.find_eyemodel(landmarks, C, L);
[E_M,E_guess_M,bestErr_M] = eyet.fit.find_eyemodel(landmarks, C, L);
[E_R,E_guess_R,bestErr_R] = eyet.fit.find_eyemodel(landmarks, C, L);








