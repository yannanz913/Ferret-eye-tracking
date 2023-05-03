function [MP,E,C,L,im,cmap,intensity] = marks_systemarray(x, cmag, arrayscale)
% MARKS_SYSTEMARRAY - return the mark and glint locations for a system array
%
% MP = MARKS_SYSTEMARRAY(X, CMAG, ARRAYSCALE)
%
% Computes the glint positions for an led/camera array with camera magnification
% CMAG and array scaling ARRAYSCALE.
%
% X is a multi-element vector:
% X(1) - a of the eye ellipsoid
% X(2) - b of the eye ellipsoid
% X(3) - c of the eye ellipsoid
% X(4) - x position of eye center
% X(5) - angle made by the left eye/skin intersection
% X(6) - angle made by the right eye/skin intersection
% X(7) - angle made by the top eye/skin intersection
% X(8) - angle made by the bottom eye/skin intersection
% X(9) - r1 - rotation of the led/camera array about the X axis
% X(10) - r2 - rotation of the led/camera array about the Y axis
% X(11) - r3 - rotation of the led/camera array about the Z axis
% X(12) - p1 - shift position of the led/camera array in X
% X(13) - p2 - shift position of the led/camera array in Y
% X(14) - p3 - shift position of the led/camera array in Z

E = [x(1:8)]; 
E = E(:);

E_ellipse_size = x(1:3);
E_center = [x(4);0;0];

xl = E(5);
xr = E(6);
xt = E(7);
xb = E(8);

R = [x(9:11)];
R = R(:);

P = [x(12:14)];
P = P(:);

[L,C] = eyet.led_2camera_arrayB(P,R,cmag,arrayscale); 

E = eyet.eye('eye_ellipse_size',E_ellipse_size,'eye_center',E_center,'eye_left_angle',xl,'eye_right_angle',xr,'eye_top_angle',xt,'eye_bottom_angle',xb);
[im,cmap,intensity] = eyet.cameraview(C,E,L);
num_Lights = size(L,2);

[IN1,P1,L1] = eyet.detect_artificial_marks(im{1},intensity{1},num_Lights);
[IN2,P2,L2] = eyet.detect_artificial_marks(im{2},intensity{2},num_Lights);


% [IN,P,L] = eyet.detect_artificial_marks(im, intensity, num_lightsources);

MP = [IN1 IN2];
for i=1:size(MP,2),
 	if isnan(MP(1,i)), 
 		MP(:,i) = [ -100000 ; -100000]; % just make error huge, don't let it fail
 	end;
end;
