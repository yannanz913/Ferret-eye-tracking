function G_marks = glints_systemarray(x, cmag, arrayscale)
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
% X(10) - pupil_ellipse x
% X(11) - pupil_ellipse y
% X(12) - pupil_ellipse z
% X(13) - pupil_origin x
% X(14) - pupil_origin y
% X(15) - pupil_origin z


E = [x(1:3)]; 
E = E(:);

R = [x(4:6)];
R = R(:);

P = [x(7:9)];
P = P(:);

pupil_ellipse = [ x(10:12) ];
pupil_ellipse = pupil_ellipse(:);

pupil_origin = [ x(13:15)];
pupil_origin = pupil_origin(:);

[L,C] = eyet.led_2camera_arrayB(P,R,cmag); 
[im,cmap,intensity] = eyet.cameraview(C,E,L,pupil_ellipse, pupil_origin);
num_Lights = size(L,2);
G1 = eyet.detect_artificial_glints(im{1},intensity{1},num_Lights);
G2 = eyet.detect_artificial_glints(im{2},intensity{2},num_Lights);

%  % camera 1 pixel point
% X1 = C(1).pixel_array_pt(round(G1(1,1)),round(G1(2,1)),:);
%  % direction through camera's nodal point:
% X2 = C(1).nodal_pt - X1;
% X2 = X2 / norm(X2);
% 
% X3 = C(2).pixel_array_pt(round(G2(1,1)),round(G2(2,1)),:);
%  % direction through camera's nodal point:
% X4 = C(2).nodal_pt - X1;
% X4 = X4 / norm(X4);

% [P1, P2, match] = eyet.closest_pt_2vector(X1,X2,X3,X4);

% GP = [G1 P1 G2 P2];
% for i=1:size(GP,2),
% 	if isnan(GP(1,i)), 
% 		GP(:,i) = [ -100000 ; -100000]; % just make error huge, don't let it fail
% 	end;
% end;

[L1, L2, match] = eyet.detect_artificial_marks(im, intensity, num_lightsources);

G_marks = [G1 L1(:,4:7) G2 L2(:,4:7)];
for i=1:size(G_marks,2),
 	if isnan(G_marks(1,i)), 
 		G_marks(:,i) = [ -100000 ; -100000]; % just make error huge, don't let it fail
 	end;
end;
