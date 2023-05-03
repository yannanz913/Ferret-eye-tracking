function [E,R,P] = find_systemarray2(E_in, R_in, P_in, cMag, arrayscale)
% FIND_SYSTEMARRAY - solve for the parameters of the system array
%
% [E,R,P] = eyet.find_systemarray(E_in, R_in, P_in, cMag, arrayscale)
%
% Given a system, estimate the best ellipse, array rotation, and array position that
% will explain the view of the glints.
%
% Example:
%    Ein = [1;2;1];
%    Rin = [0; 0; 0];
%    Pin = [10;0;0];
%    [Eout,Rout,Pout] = eyet.find_systemarray2(Ein,Rin,Pin,250,1);
%    disp(['Eye size (correct, found):']);
%    [Ein Eout]
%    disp(['Rotation (correct, found) :']);
%    [Rin(:) Rout]
%    disp(['Position [x;y;z] (correct, found) :']);
%    [Pin Pout]
%


 % Step 1: make an example system to try to find based on E_in, R_in, P_in

[Lactual,Cactual] = eyet.led_2camera_array(P_in, R_in, cMag, arrayscale);
[im_actual,cmap,intensity_actual] = eyet.cameraview(Cactual,E_in,Lactual);
G_observed_1 = eyet.detect_artificial_glints(im_actual{1},intensity_actual{1},size(Lactual,2));
G_observed_2 = eyet.detect_artificial_glints(im_actual{2},intensity_actual{2},size(Lactual,2));
G_observed = [G_observed_1 G_observed_2]


 % Step 2: search for the system

options = optimoptions('fsolve','Display','iter','algorithm','trust-region-reflective'); %,'OptimalityTolerance',1e-8,'Algorithm','trust-region-reflective');

X0 = [1;2.2;1;0;0;0;11.1;0;0];
Y = eyet.glints_systemarray2(X0,cMag,arrayscale)
size(Y)
size(G_observed),

[X,fval,exitflag,output] = fsolve(@(x) eyet.glints_systemarray2(x,cMag,arrayscale)-G_observed, ...
	[ ...
        X0
    ],...
	options);

fval,
exitflag,
output,

E = X(1:3);
E = E(:);
R = X(4:6);
R = R(:);
P = X(7:9);
P = P(:);

 % Step 3: Plot the system that was found

[Lcomputed,Ccomputed] = eyet.led_2camera_array(P, R, cMag, arrayscale);
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

