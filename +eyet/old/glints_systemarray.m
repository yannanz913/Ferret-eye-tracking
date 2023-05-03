function G = glints_systemarray(x, cmag, arrayscale)
% GLINTS_SYSTEMARRAY - return the glint locations for a model of the system
%
% G = GLINTS_SYSTEMARRAY(X, CMAG, ARRAYSCALE)
%
% Computes the glint positions for an led/camera array with camera magnification
% CMAG and array scaling ARRAYSCALE.
%
% X is a multi-element vector:
% X(1) - a of the eye ellipsoid
% X(2) - b of the eye ellipsoid
% X(3) - c of the eye ellipsoid
% X(4) - r1 - rotation of the led/camera array about the X axis
% X(5) - r2 - rotation of the led/camera array about the Y axis
% X(6) - r3 - rotation of the led/camera array about the Z axis
% X(7) - p1 - shift position of the led/camera array in X
% X(8) - p2 - shift position of the led/camera array in Y
% X(9) - p3 - shift position of the led/camera array in Z
% 

E = [x(1:3)]; 
E = E(:);

R = [x(4:6)];
R = R(:);

P = [x(7:9)];
P = P(:);

[L,C] = eyet.led_2camera_array(P,R,cmag); 
[im,cmap,intensity] = eyet.cameraview(C,E,L);
num_Lights = size(L,2);
G = eyet.detect_artificial_glints(im,intensity,num_Lights);
for i=1:size(G,2),
	if isnan(G(1,i)), 
		G(:,i) = [ -100000 ; -100000]; % just make error huge, don't let it fail
	end;
end;
