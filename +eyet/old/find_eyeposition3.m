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

 % Step 1: calculate the view through the model input system to get its views

modelcomp = eyet.compute_model(C,E_in,L);

t = modelcomp.world_coords.eye_plane.t;
Eye_rotation_initial = vlt.math.rad2deg([t(1);t(2);0]); % initial eye rotation guess
Eye_center_initial = (modelcomp.world_coords.eye_plane.P1+modelcomp.world_coords.eye_plane.P2)/2;
Eye_center_initial = E_in.eye.center();

 % Step 2: search for the system


% 1) search for intersection points and pupil origin without initial pupil
% position estimation

 % initial guess
%X0 = [ eyesize_x; eyesize_y; eyesize_z; eyecenter_x; eyecenter_y; eyecenter_z; pupil_azimuth; pupil_elevation];
X0 = [ 1; 2.1; 1; Eye_center_initial(:)-0.4*randn(3,1); 25;0];

eye_model_error = fittype(@(a,b,c,d,e,f) ...
	[eyet.lightsource_error(modelcomp.camera_coords.glints, ...
			eyet.eye('eye_ellipse_size',[a;b;c],'eye_center',[d;e;f],'eye_rotation',Eye_rotation_initial), L, C); ...
			eyet.pupil_error(modelcomp.camera_coords.pupil, ...
			eyet.eye('eye_ellipse_size',[a;b;c],'eye_center',[d;e;f],'eye_rotation',Eye_rotation_initial), C); ]);

options = fitopen(eye_model_error);

options.StartPoint = X0;
options.lower = [ 0.8;1.8;0.8;Eye_center_initial(1)-1;Eye_center_initial(2)-1;Eye_center_initial(3)-1;-45;-45];
options.upper = [ 1.2;2.2;1.2;Eye_center_initial(1)+1;Eye_center_initial(2)+1;Eye_center_initial(3)+1;45;45];

eye_model_error = setoptions(eye_model_error,options);

 % plot initial guess

Einit = eyet.eye('eye_ellipse_size',X0(1:3),'eye_center',X0(4:6),'eye_rotation',Eye_rotation_initial,'pupil_elevation_angle',X0(8),'pupil_azimuth_angle',X0(7));
model_initialguess = eyet.compute_model(C,Einit,L);

[eye_model_errorc,eye_model_error_gof] = fit([0

%[X_1,fval,exitflag,output] = fsolve(@(x) ...
%		[eyet.lightsource_error(modelcomp.camera_coords.glints, ...
%			eyet.eye('eye_ellipse_size',x(1:3),'eye_center',x(4:6),'eye_rotation',Eye_rotation_initial), L, C); ...
%			eyet.pupil_error(modelcomp.camera_coords.pupil, ...
%			eyet.eye('eye_ellipse_size',x(1:3),'eye_center',x(4:6),'eye_rotation',Eye_rotation_initial), C); ], ...
%	[ ...
%        X0
%    ],...
%	options);

sum(fval),
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
eyet.plot.image(modelcomp.cameraimages.image{1},modelcomp.cameraimages.cmap); 
ax1 = gca;
title(['Camera 1: View through the actual system']);

subplot(2,2,2);
eyet.plot.image(im_out{1},cmap);
ax2 = gca;
title(['Camera 1: View through the found system']);

subplot(2,2,3);
eyet.plot.image(modelcomp.cameraimages.image{2},modelcomp.cameraimages.cmap);
ax3 = gca;
title(['Camera 2: View through the actual system']);

subplot(2,2,4);
eyet.plot.image(im_out{2},cmap);
ax4 = gca;
title(['Camera 2: View through the found system']);

linkaxes([ax1 ax2]);
linkaxes([ax3 ax4]);


