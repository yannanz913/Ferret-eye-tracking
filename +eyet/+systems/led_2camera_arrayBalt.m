function [L,C] = led_2camera_arrayBalt(P, mag, scale)
% LED_CAMERA_ARRAY - create an LED/CAMERA array
%
% [L,C] = eyet.led_2camera_array(P,mag, scale)
% 
% Creates a linked LED and camera array, which are shifted
% by P (P(1) is X, P(2) is Y, P(3) is Z). The camera magnification is MAG.
%
% The LED array normally has a maximum distance of 10 in real space. It will
% be scaled by SCALE. If scale is not provided, scale==1.
% 
% The camera will have 100x100 pixels and points at the Y axis.
%
% Example:
%   E = [ 1 2 1];
%   [L,C] = eyet.led_2camera_arrayBalt([10;0;0],[0 0 0],250,1);
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
az1 = vlt.math.deg2rad([-45]);
el1 = [ 0];
th1 = [vlt.math.deg2rad(180)];

camera_xaxis_unit1 = vlt.math.rot3d(vlt.math.deg2rad(90),3) * np1_unit;
camera_xaxis_1 = camera_center_1 + camera_xaxis_unit1;

camera_center_2 = [0;10;0];
camera_point_2 = [ -10; 0; 0];
np2_direction = [ camera_point_2-camera_center_2 ];
np2_unit = np2_direction/norm(np2_direction);
np2 = camera_center_2 + np2_unit;
camera_xaxis_unit2 = vlt.math.rot3d(vlt.math.deg2rad(90),3) * np2_unit;
camera_xaxis_2 = camera_center_2 + camera_xaxis_unit2;
az2 = vlt.math.deg2rad([+45]);
el2 = [0];
th2 = [vlt.math.deg2rad(180)];


 % center point, nodal point, x_axis point
%Cpo = [ [0;-10;0] [-1;0;0] [0;1;0] ];
%Cpo2 = [ [0;10;0] [-2;0;0] [0;2;0] ];

Cpo = [ camera_center_1 np1 camera_xaxis_1 ];
Cpo2 = [ camera_center_2 np2 camera_xaxis_2 ];

L = (Lo) + P(:); % rotate and shift

Cp = (Cpo) + P(:);
Cp2 = (Cpo2) + P(:);

C(1) = eyet.CameraModel.CameraModelAlt(Cp(:,2),[az1 el1 th1],mag,pixels,pixels);
C(2) = eyet.CameraModel.CameraModelAlt(Cp2(:,2),[az2 el2 th2],mag,pixels,pixels);

