function [L,C] = led_2camera_arrayB(P, R, mag, scale)
% LED_CAMERA_ARRAY - create an LED/CAMERA array
%
% [L,C] = eyet.led_2camera_array(P,R,mag, scale)
% 
% Creates a linked LED and camera array. The Array are first rotated
% about the X, Y, and Z axes by R(1), R(2), R(3) (in degrees), and then shifted
% by P (P(1) is X, P(2) is Y, P(3) is Z). The camera magnification is MAG.
%
% The LED array normally has a maximum distance of 10 in real space. It will
% be scaled by SCALE. If scale is not provided, scale==1.
% 
% The camera will have 100x100 pixels and points at the Y axis.
%
% Example:
%   E = [ 1 2 1];
%   [L,C] = eyet.led_2camera_arrayB([10;0;0],[0 0 0],250,1);
%   figure;
%   eyet.plot.system(E,C,L);
%   [im,cmap,intensity] = eyet.cameraview(C,E,L);
%   figure;
%   eyet.plot.image(im{1},cmap);
%   G1 = eyet.detect_artificial_glints(im{1},intensity{1},size(L,2))
%   figure;
%   eyet.plot.image(im{2},cmap);
%   G2 = eyet.detect_artificial_glints(im{2},intensity{2},size(L,2))

pixels = 100;

mag = pixels* mag / 100;

if nargin<4,
	scale = 1;
end;

Lo = [ [0;-10;-10] [0;0;10] [0;10;-10]];

Lo = scale * Lo;

 % we'd like each camera to be located 10 units away from center, pointing at the eye at 0,0,0

camera_center_1 = [0;-10;0];
camera_point_1 = [ -10; 0; 0];
np1_direction = [ camera_point_1-camera_center_1 ];
np1_unit = np1_direction/norm(np1_direction);
np1 = camera_center_1 + np1_unit;
camera_xaxis_unit1 = vlt.math.rot3d(vlt.math.deg2rad(90),3) * np1_unit;
camera_xaxis_1 = camera_center_1 + camera_xaxis_unit1;

camera_center_2 = [0;10;0];
camera_point_2 = [ -10; 0; 0];
np2_direction = [ camera_point_2-camera_center_2 ];
np2_unit = np2_direction/norm(np2_direction);
np2 = camera_center_2 + np2_unit;
camera_xaxis_unit2 = vlt.math.rot3d(vlt.math.deg2rad(90),3) * np2_unit;
camera_xaxis_2 = camera_center_2 + camera_xaxis_unit2;

 % center point, nodal point, x_axis point
%Cpo = [ [0;-10;0] [-1;0;0] [0;1;0] ];
%Cpo2 = [ [0;10;0] [-2;0;0] [0;2;0] ];

Cpo = [ camera_center_1 np1 camera_xaxis_1 ];
Cpo2 = [ camera_center_2 np2 camera_xaxis_2 ];

R = deg2rad(R);

RM = vlt.math.rot3d(R(3),3)*vlt.math.rot3d(R(2),2)*vlt.math.rot3d(R(1),1);

L = (RM * Lo) + P(:); % rotate and shift

Cp = (RM * Cpo) + P(:);
Cp2 = (RM * Cpo2) + P(:);

C(1) = eyet.CameraModel(Cp(:,1),Cp(:,2),Cp(:,3),mag,pixels,pixels);
C(2) = eyet.CameraModel(Cp2(:,1),Cp2(:,2),Cp2(:,3),mag,pixels,pixels);

