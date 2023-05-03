function [MP,im,cmap,intensity] = marks_eyeposition(x, Eye_rotation, L, C)
% MARKS_SYSTEMARRAY - return the mark and glint locations for a system array
%
% MP = MARKS_SYSTEMARRAY(X, L, C)
%
% Computes the 3d pupil and glint positions for an led/camera array with camera magnification
% CMAG and array scaling ARRAYSCALE.
%
% Inputs: 
%     X is a multi-element vector with the parameters of the system to evaluate:
%       X(1) - a of the eye ellipsoid
%       X(2) - b of the eye ellipsoid
%       X(3) - c of the eye ellipsoid
%       X(4) - origin x of eye ellipsoid
%       X(5) - origin y of eye ellipsoid
%       X(6) - origin z of eye ellipsoid
%       X(7) - azimuth of pupil
%       X(8) - elevation of pupil
%
%    Eye_rotation is an estimate of the eye rotation, in degrees
%    L - the system of lights that form glints on the eyes
%    C - the camera system coordinates
%
% Outputs:
%    MP - a multi-element vector with the results of certain calculations of the system
%       MP(1:3) - Estimate of the pupil position in x, y, z in world coordinates
%       MP(4:5) - estimate of the first glint on camera 1 in camera x, y
%       MP(6:7) - estimate of the first glint on camera 2 in camera x, y
%       MP(8:9) - estimate of second glint on camera 1 in camera x, y
%       MP(10:11) - estimate of second glint on camera 2 in camera x, y
%       (and so on for all remaining light sources)


E_ellipse_size = vlt.data.colvec(x(1:3));
E_center = vlt.data.colvec(x(4:6)); 

E = eyet.eye('eye_ellipse_size',E_ellipse_size,'eye_center',E_center, 'eye_rotation', Eye_rotation,'pupil_elevation_angle',x(8),'pupil_azimuth_angle',x(7));

[im,cmap,intensity] = eyet.cameraview(C,E,L);
num_Lights = size(L,2);

[IN1,P1,L1] = eyet.detect_artificial_marks(im{1},intensity{1},num_Lights);
[IN2,P2,L2] = eyet.detect_artificial_marks(im{2},intensity{2},num_Lights);

pupil_position_world = eyet.cameraview2world(C,{P1 P2});

L_total = vlt.data.colvec([L1 ; L2]);

L_total(find(isnan(L_total))) = -10000; % just make huge error, don't let it fail

MP = [pupil_position_world(:); L_total(:)];

