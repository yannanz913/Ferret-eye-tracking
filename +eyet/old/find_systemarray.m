function [E,R,P] = find_systemarray(E_in, R_in, P_in, cMag, arrayscale)
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
%    [Eout,Rout,Pout] = eyet.find_systemarray(Ein,Rin,Pin,250,1);
%    disp(['Eye size (correct, found):']);
%    [Ein Eout]
%    disp(['Rotation (correct, found) :']);
%    [Rin(:) Rout]
%    disp(['Position [x;y;z] (correct, found) :']);
%    [Pin Pout]
%


[Lactual,Cactual] = eyet.led_camera_array(P_in, R_in, cMag, arrayscale);
[im_actual,cmap,intensity_actual] = eyet.cameraview(Cactual,E_in,Lactual);
G_observed = eyet.detect_artificial_glints(im_actual,intensity_actual,size(Lactual,2));

options = optimoptions('fsolve','Display','iter'); %,'algorithm','trust-region-reflective'); %,'OptimalityTolerance',1e-8,'Algorithm','trust-region-reflective');

X0 = [1;1.8;1;0;0;0;8;0;0];
disp('Initial guess glints:');
Y = eyet.glints_systemarray(X0,cMag,arrayscale)

[X,fval,exitflag,output] = fsolve(@(x) eyet.glints_systemarray(x,cMag,arrayscale)-G_observed, ...
	[ ...
	  1;1.9;1;... % ellipse estimate
	  0;0;0;... % rotation estimate, no rotation 
	  12;0.1;0.1;... % position guess
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

[Lcomputed,Ccomputed] = eyet.led_camera_array(P, R, cMag, arrayscale);
[im_out,cmap,intensity_out] = eyet.cameraview(Ccomputed,E,Lcomputed);

figure;
subplot(2,2,1);
eyet.plot.image(im_actual,cmap);
ax1 = gca;
title(['View through the actual system']);
subplot(2,2,2);
eyet.plot.image(im_out,cmap);
ax2 = gca;
title(['View through the found system']);

linkaxes([ax1 ax2]);

