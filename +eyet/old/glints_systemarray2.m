function GD = glints_systemarray2(x, cmag, arrayscale)
% GLINTS_SYSTEMARRAY - return the glint locations for a model of the system
%
% [GD] = GLINTS_SYSTEMARRAY2(X, CMAG, ARRAYSCALE)
%
% Computes the glint positions and glint dispairities across the two cameras
% for an led/2 camera array with camera magnification
% CMAG and array scaling ARRAYSCALE.
% This function concatenates the glints from the two cameras into one
% vector, and includes a point that describes the disparity between the
% glints on the two images. That is, GD = [G1 G2 G1-G2], where G1
% is the set of glints for the first image, and G2 is the set of glints for 
% the second image.
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
% Example:
%    E = [ 1 2 1];
%    R = [ 0; 0; 0];
%    P = [ 10; 0; 0];
%    G = eyet.glints_systemarray2([E(:);R;P],250,1);


E = [x(1:3)]; 
E = E(:);

R = [x(4:6)];
R = R(:);

P = [x(7:9)];
P = P(:);

[L,C] = eyet.led_2camera_arrayB(P,R,cmag); 
[im,cmap,intensity] = eyet.cameraview(C,E,L);
num_Lights = size(L,2);
G1 = eyet.detect_artificial_glints(im{1},intensity{1},num_Lights);
G2 = eyet.detect_artificial_glints(im{2},intensity{2},num_Lights);
GD = [G1 G2];
for i=1:size(GD,2),
	if isnan(GD(1,i)), 
		GD(:,i) = [ -100000 ; -100000]; % just make error huge, don't let it fail
	end;
end;

