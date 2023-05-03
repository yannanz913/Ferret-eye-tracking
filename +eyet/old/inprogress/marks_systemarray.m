function MP = marks_systemarray(x, cmag, arrayscale)
% MARKS_SYSTEMARRAY - return the mark and glint locations for a system array
%
% P = MARKS_SYSTEMARRAY(X, CMAG, ARRAYSCALE)
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
% X(7) - r1 - rotation of the led/camera array about the X axis
% X(8) - r2 - rotation of the led/camera array about the Y axis
% X(9) - r3 - rotation of the led/camera array about the Z axis
% X(10) - p1 - shift position of the led/camera array in X
% X(11) - p2 - shift position of the led/camera array in Y
% X(12) - p3 - shift position of the led/camera array in Z

E = [x(1:3)]; 
E = E(:);

E_center = [x(4);0;0];

xl = E(5);
xr = E(6);

R = [x(7:9)];
R = R(:);

P = [x(10:12)];
P = P(:);

[L,C] = eyet.led_2camera_arrayB(P,R,cmag); 

eye = eyet.eye('eye_center',E_center,'eye_ellipse_size',E,'eye_left_angle',xl,'eye_right_angle',xr);
[im,cmap,intensity] = eyet.cameraview(C,E,L);
num_Lights = size(L,2);

G1 = eyet.detect_artificial_glints(im{1},intensity{1},num_Lights);
G2 = eyet.detect_artificial_glints(im{2},intensity{2},num_Lights);

GP = [G1 G2 ];
for i=1:size(GP,2),
	if isnan(GP(1,i)), 
		GP(:,i) = [ -100000 ; -100000]; % just make error huge, don't let it fail
	end;
end;
