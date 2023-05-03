function [L,C] = led_camera_array(P, R, mag, scale)
% LED_CAMERA_ARRAY - create an LED/CAMERA array
%
% [L,C] = eyet.led_camera_array(P,R,mag, scale)
% 
% Creates a linked LED and camera array. The Array are first rotated
% about the X, Y, and Z axes by R(1), R(2), R(3) (in degrees), and then shifted
% by P (P(1) is X, P(2) is Y, P(3) is Z). The camera magnification is MAG.
%
% The LED array normally has a maximum distance of 10 in real space. It will
% be scaled by SCALE. If scale is not provided, scale==1.
% 
% The camera will have 200x200 pixels and points at the Y axis.
%
% Example:
%   E = [ 1 2 1];
%   [L,C] = eyet.led_camera_array([10;0;0],[0 0 0],250);
%   figure;
%   eyet.plot.system(E,C,L);
%   [im,cmap,intensity] = eyet.cameraview(C,E,L);
%   figure;
%   eyet.plot.image(im,cmap);
%   G = eyet.detect_artificial_glints(im,intensity,size(L,2));

pixels = 100;

mag = pixels* mag / 100;

if nargin<4,
	scale = 1;
end;

Lo = [ [0;-10;-10] [0;-10;-5] [0;-10;0] [0;-10;7.5] [0;-5;0] ... % -Y/Z branch
	[0;10;0] [0;10;10] [0;10;5] ... % +Y/Z branch
	[3;0;10] [1.5;0;-10]... % +X/Z branch
 ] ;

Lo = scale * Lo;

 % center point, nodal point, x_axis point
Cpo = [ [0;0;0] [-1;0;0] [0;1;0] ];

R = deg2rad(R);

RM = vlt.math.rot3d(R(3),3)*vlt.math.rot3d(R(2),2)*vlt.math.rot3d(R(1),1);

L = (RM * Lo) + P(:); % rotate and shift

Cp = (RM * Cpo) + P(:);

C = eyet.CameraModel(Cp(:,1),Cp(:,2),Cp(:,3),mag,pixels,pixels);

