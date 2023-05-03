function [E] = find_eyeposition(E_in, L, C)
% FIND_SYSTEMARRAY - solve for the parameters of the system array
%
% [E,R,P] = eyet.find_systemarray(E_in, L, C)
%
% Given a system, estimate the best eye parameters given the camera array
% positions and light source positions.
%
% Example:
%    Ein = eyet.eye('eye_ellipse_size',[1;2;1],...
%         'eye_center',[,'eye_left_angle',-70,'eye_right_angle',70,'eye_top_angle',70,'eye_bottom_angle',-70);
%    [L,C] = eyet.led_2camera_arrayB([10;0;0],[0;0;0],250,1);
%    Eout = eyet.find_eyeposition(Ein,Pin,Rin,250,1);
%    disp(['Eye size (correct, found):']);
%    [Ein Eout]
%    disp(['Rotation (correct, found) :']);
%    disp(['Position [x;y;z] (correct, found) :']);
%


 % Step 1: make an example system to try to find based on E_in, R_in, P_in

[im_actual,cmap,intensity_actual] = eyet.cameraview(C,E_in,L);
[IN_observed_1, P_observed_1, glints_observed_1] = eyet.detect_artificial_marks(im_actual{1}, intensity_actual{1}, size(L,2));
[IN_observed_2, P_observed_2, glints_observed_2] = eyet.detect_artificial_marks(im_actual{2}, intensity_actual{2}, size(L,2));

marks_observed = eyet.marks_eyeposition([E_in.eye.size(:); E_in.eye.center(:); E_in.pupil.elevation; E_in.pupil.azimuth;],vlt.math.rad2deg(E_in.eye.rotation),L,C);

 % get skin intersections from the camera parameters

[skin_pts_world] = eyet.cameraview2world(C,{IN_observed_1 IN_observed_2});
 % find the "eye facet" plane and the rotation of the eye
[P1,P2,P3,t] = eyet.solveeyeplane(skin_pts_world(:,1),skin_pts_world(:,2),skin_pts_world(:,3),skin_pts_world(:,4));

Eye_rotation_initial = vlt.math.rad2deg([t(1);t(2);0]); % initial eye rotation guess
Eye_center_initial = (P1+P2)/2;
Eye_center_initial = E_in.eye.center();




 % Step 2: search for the system

options = optimoptions('fsolve','Display','iter','algorithm','trust-region-reflective'); %,'OptimalityTolerance',1e-8,'Algorithm','trust-region-reflective');

% 1) search for intersection points and pupil origin without initial pupil
% position estimation

 % initial guess
%X0 = [ eyesize_x; eyesize_y; eyesize_z; eyecenter_x; eyecenter_y; eyecenter_z; pupil_azimuth; pupil_elevation];
X0 = [ 1; 2.1; 1; Eye_center_initial(:); 15;-0.5];


 % plot initial guess

Einit = eyet.eye('eye_ellipse_size',X0(1:3),'eye_center',X0(4:6),'eye_rotation',Eye_rotation_initial,'pupil_elevation_angle',X0(8),'pupil_azimuth_angle',X0(7));

[im_init,cmap_init,intensity_init] = eyet.cameraview(C,Einit,L);
figure;
h_system = eyet.plot.system(C,Einit,L);

h_image = {};
for i=1:numel(im_init),
	figure;
	h_image{i} = eyet.plot.image(im_init{i},cmap_init);
	title(['Camera ' int2str(i) ' image']);
	[skinintersections{i},pupils{i},glints{i}] = eyet.detect_artificial_marks(im_init{i},intensity_init{i},size(L,2));
end;

h_intensity = {};
for i=1:numel(im_init),
	h_intensity{i} = imagedisplay(intensity_init{i}');
	title(['Camera ' int2str(i) ' intensity' ]);
end;

[X_1,fval,exitflag,output] = fsolve(@(x) eyet.marks_eyeposition(x,Eye_rotation_initial,L,C)-marks_observed, ...
	[ ...
        X0
    ],...
	options);

fval,
exitflag,
output,
X_1,

E_ellipse_size = vlt.data.colvec(X_1(1:3));
E_center = vlt.data.colvec(X_1(4:6));

E = eyet.eye('eye_ellipse_size',E_ellipse_size,'eye_center',E_center, 'eye_rotation', vlt.math.rad2deg(E_in.eye.rotation),'pupil_elevation_angle',X_1(8),'pupil_azimuth_angle',X_1(7));

 % Step 3: Plot the system that was found

[im_out,cmap,intensity_out] = eyet.cameraview(C,E,L);

figure;
subplot(2,2,1);
eyet.plot.image(im_actual{1},cmap); 
ax1 = gca;
title(['Camera 1: View through the actual system']);

subplot(2,2,2);
eyet.plot.image(im_out{1},cmap);
ax2 = gca;
title(['Camera 1: View through the found system']);

subplot(2,2,3);
eyet.plot.image(im_actual{2},cmap);
ax3 = gca;
title(['Camera 2: View through the actual system']);

subplot(2,2,4);
eyet.plot.image(im_out{2},cmap);
ax4 = gca;
title(['Camera 2: View through the found system']);

linkaxes([ax1 ax2]);
linkaxes([ax3 ax4]);


