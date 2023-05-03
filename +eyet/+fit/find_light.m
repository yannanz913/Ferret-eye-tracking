function [lightObj,lightObj_guess] = find_light(w_pt,c_pt,initial_position_guess_l, initial_angle_guess_l, varargin)


number_of_starts = 25;
initial_position_guess_l = initial_position_guess_l(:);
% initial_angle_guess_l = initial_angle_guess_l(:);

light_parameters_guess = initial_position_guess_l(:, 1);

X0 = light_parameters_guess;

options = optimoptions('lsqnonlin','Display','iter','algorithm','trust-region-reflective');

bestErr = Inf;
X_best = [];
for i=1:number_of_starts,
  X0 = [light_parameters_guess(1:3) + 2*randn(3,1); light_parameters_guess(4:6) + vlt.math.deg2rad(10)*randn(3,1)];
	[X_1,fval,exitflag,output] = lsqnonlin(@(X) ...
                eyet.fit.lightsource_error(glints_pts, E, eyet.fit.find_lightsources(C, xy_pt11, xy_pt12, xy_pt21, xy_pt22, radii, marble_center,rotation),C), ...
		[ X0 ],lower, upper, options);

	if sum(fval)<bestErr, % did we beat our best?
		bestErr = sum(fval); 
		X_best = X_1;
	end;
end;

X = X_best;

lightObj = eyet.LightModel(positions); % rotations?
