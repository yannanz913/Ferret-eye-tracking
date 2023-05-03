function [E,R,P,PuE,PuO] = find_systemarray2_with_pupil(E_in, R_in, P_in, pupil_ellipse, pupil_origin, cMag, arrayscale)
% FIND_SYSTEMARRAY - solve for the parameters of the system array
%
% [E,R,P] = eyet.find_systemarray2_with_pupil(E_in, R_in, P_in, pupil_ellipse, pupil_origin, cMag, arrayscale)
%
% Given a system, estimate the best ellipse, array rotation, and array position that
% will explain the view of the glints.
%
% Example:
%    Ein = [1;2;1];
%    Rin = [0; 0; 0];
%    Pin = [10;0;0];
%    pupil_ellipse = [0.01 0.2 0.2];
%    pupil_origin = [ 1 0 0 ];
%    [Eout,Rout,Pout,PuE,PuO] = eyet.find_systemarray2_with_pupil(Ein,Rin,Pin,pupil_ellipse,pupil_origin,250,1);
%    disp(['Eye size (correct, found):']);
%    [Ein Eout]
%    disp(['Rotation (correct, found) :']);
%    [Rin(:) Rout]
%    disp(['Position [x;y;z] (correct, found) :']);
%    [Pin Pout]
%


 % Step 1: make an example system to try to find based on E_in, R_in, P_in

[Lactual,Cactual] = eyet.led_2camera_arrayB(P_in, R_in, cMag, arrayscale);
[im_actual,cmap,intensity_actual] = eyet.cameraview(Cactual,E_in,Lactual,pupil_ellipse,pupil_origin);
G_observed_1 = eyet.detect_artificial_glints(im_actual{1},intensity_actual{1},size(Lactual,2));
G_observed_2 = eyet.detect_artificial_glints(im_actual{2},intensity_actual{2},size(Lactual,2));




X1 = [0;-10;0];
X2 = [-0.7071;0.7071;0];
X3 = [0;10;0];
X4 = [-0.7071;-0.7071;0];
[P_observed_1, P_observed_2, match] = eyet.closest_pt_2vector(X1,X2,X3,X4);

GP_observed = [G_observed_1 P_observed_1 G_observed_2 P_observed_2]

 % Step 2: search for the system

options = optimoptions('fsolve','Display','iter','algorithm','trust-region-reflective'); %,'OptimalityTolerance',1e-8,'Algorithm','trust-region-reflective');

% 1) search for glint points and pupil origin without initial pupil
% position estimation

X0 = [1;2.2;1;0;0;0;11.1;0;0;0.01;0.2;0.2;1;0;0];
Y = eyet.glints_systemarray_pupil(X0,cMag,arrayscale)
size(Y)
size(GP_observed),

[X_1,fval,exitflag,output] = fsolve(@(x) eyet.glints_systemarray_pupil(x,cMag,arrayscale)-GP_observed, ...
	[ ...
        X0
    ],...
	options);

fval,
exitflag,
output,

E = X_1(1:3);
E = E(:);
R = X_1(4:6);
R = R(:);
P = X_1(7:9);
P = P(:);
PuE = X_1(10:12);
PuE = PuE(:);
PuO = X_1(13:15);
PuO = PuO(:);

% 2) search for pupil origin with initial pupil
% position estimation

% X1 = [0;-10;0];
% X2 = [-0.7071;0.7071;0];
% X3 = [0;10;0];
% X4 = [-0.7071;-0.7071;0];
% Y1 = eyet.closest_pt_2vector(X1,X2,X3,X4)
% size(Y1)
% size(PuO)
% 
% [X_2,fval,exitflag,output] = fsolve(@(x) PuO-eyet.closest_pt_2vector(X1,X2,X3,X4), ...
% 	[ ...
%         X1,X2,X3,X4
%     ],...
% 	options);
% 
% fval,
% exitflag,
% output,
% 
% PuO_accurate = X_2(1:3);

 % Step 3: Plot the system that was found

[Lcomputed,Ccomputed] = eyet.led_2camera_arrayB(P, R, cMag, arrayscale);
[im_out,cmap,intensity_out] = eyet.cameraview(Ccomputed,E,Lcomputed,PuE,PuO);

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

