function [closest_p1, closest_p2, match] = closest_pt_2vector(V1p,V1d,V2p,V2d)
% CLOSEST_PT_2VECTOR - return the position point where two led_camera arrays intesect, which is 
% the estimated position of pupil origin
% 
% This function estimates pupil origin location beforehand,
% to reduce the error in finding the exact pupil origin location.
%
% Example:
% camera_center_1 = [0;-10;0];
% camera_point_1 = [ -10; 0; 0];
% np1_direction = [ camera_point_1-camera_center_1 ];
% np1_unit = np1_direction/norm(np1_direction);
% camera_center_2 = [0;10;0];
% camera_point_2 = [ -10; 0; 0];
% np2_direction = [ camera_point_2-camera_center_2 ];
% np2_unit = np2_direction/norm(np2_direction);
% [closest_p1,closest_p2,match] = eyet.closest_pt_2vector(camera_center_1,np1_unit,camera_center_2,np2_unit)

 % Step 1:make vectors columns

V1d = V1d(:);
V2d = V2d(:);
V1p = V1p(:);
V2p = V2p(:);

 % Step 2, the equation we wish to solve:
 %find scalars x, y such that:
 %V1d * x + V1p == V2p + y * V2d
 %x * V1d - y * V2d - (V2p-V1p) == 0
 %[x, -y] * [ V1d V2d ] - (V2p-V1p) == 0]

S = warning('query');
warning off;
[x,fval,existflag] = fsolve(@(x) [x(1), -x(2)] * [ V1d' ; V2d' ] - (V2p-V1p)',[1;1],optimoptions('fsolve','Display','off'));
warning(S);

closest_p1 = x(1)*V1d + V1p;
closest_p2 = x(2)*V2d + V2p;

match = mean(closest_p1-closest_p2)<1e-6;

