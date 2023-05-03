function [E,R,P] = find_systemarray(E_in, P_in, R_in, cMag, arrayscale)
% FIND_SYSTEMARRAY - solve for the parameters of the system array
%
% [E,R,P] = eyet.find_systemarray(E_in, P_in, R_in, cMag, arrayscale)
%
% Given a system, estimate the best ellipse, array rotation, and array position that
% will explain the view of the glints.
%
% Example:
%    % Ein = eyet.eye('pupil_elevation_angle',10,'pupil_azimuth_angle',25);
%    Ein = eyet.eye('eye_ellipse_size',[1;2;1],'eye_center',0,'eye_left_angle',-70,'eye_right_angle',70,'eye_top_angle',70,'eye_bottom_angle',-70);
%    Rin = [0; 0; 0];
%    Pin = [10;0;0];
%    [Eout,Rout,Pout] = eyet.find_systemarray(Ein,Pin,Rin,250,1);
%    disp(['Eye size (correct, found):']);
%    [Ein Eout]
%    disp(['Rotation (correct, found) :']);
%    [Rin(:) Rout]
%    disp(['Position [x;y;z] (correct, found) :']);
%    [Pin Pout]
%


 % Step 1: make an example system to try to find based on E_in, R_in, P_in


[Lactual,Cactual] = eyet.led_2camera_arrayB(P_in, R_in, cMag, arrayscale);
[im_actual,cmap,intensity_actual] = eyet.cameraview(Cactual,E_in,Lactual);
[IN_observed_1, P_observed_1, glints_observed_1] = eyet.detect_artificial_marks(im_actual{1}, intensity_actual{1}, size(Lactual,2));
[IN_observed_2, P_observed_2, glints_observed_2] = eyet.detect_artificial_marks(im_actual{2}, intensity_actual{2}, size(Lactual,2));

marks_observed = [IN_observed_1 IN_observed_2],

 % Step 2: search for the system

options = optimoptions('fsolve','Display','iter','algorithm','trust-region-reflective'); %,'OptimalityTolerance',1e-8,'Algorithm','trust-region-reflective');

% 1) search for intersection points and pupil origin without initial pupil
% position estimation

X0 = [1;2.2;1;1;-75;75;75;-75;1.1;0;0;11.1;0;0];
[Y,Einit,Cinit,Linit,im_init,cmap_init,intensity_init] = eyet.marks_systemarray(X0,cMag,arrayscale)

 % plot initial guess

size(Y)
size(marks_observed),
figure;
h_system = eyet.plot.system(Cinit,Einit,Linit);

h_image = {};
for i=1:numel(im_init),
	figure;
	h_image{i} = eyet.plot.image(im_init{i},cmap_init);
	title(['Camera ' int2str(i) ' image']);
	[skinintersections{i},pupils{i},glints{i}] = eyet.detect_artificial_marks(im_init{i},intensity_init{i},size(Lactual,2));
end;

h_intensity = {};
for i=1:numel(im_init),
	h_intensity{i} = imagedisplay(intensity_init{i}');
	title(['Camera ' int2str(i) ' intensity' ]);
end;

[X_1,fval,exitflag,output] = fsolve(@(x) eyet.marks_systemarray(x,cMag,arrayscale)-marks_observed, ...
	[ ...
        X0
    ],...
	options);

fval,
exitflag,
output,

E = X_1(1:8);
E = E(:);

E_ellipse_size = X_1(1:3);
E_center = [X_1(4);0;0];

xl = E(5);
xr = E(6);
xt = E(7);
xb = E(8);

R = [X_1(9:11)];
R = R(:);

P = [X_1(12:14)];
P = P(:);

 % Step 3: Plot the system that was found

[Lcomputed,Ccomputed] = eyet.led_2camera_arrayB(P, R, cMag, arrayscale);
[im_out,cmap,intensity_out] = eyet.cameraview(Ccomputed,E,Lcomputed);

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


