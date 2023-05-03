function [Perror] = pupil_error(pupil_pts, E,C)
% eyet.fit.pupil_error - compute error in the distance of the world pupil position from the estimated eye surface
%
% Perror = eyet.fit.pupil_error(glints_pts, E, L, C)
%
% Given a camera system C, light system L, a model eye E, and locations of the pupil on the camera's
% X and Y position for each camera, compute the distance of where the pupil is estimated to be in
% world coordinates (given the camera system) to the nearest point on the model eye E.
% 
% 

[pupw] = camerapts2world(C,pupil_pts);
[i,v,Perror] = E.eye.closest_pt_on_ellipsoid(pupw);

if isinf(Perror) | isnan(Perror),
	Perror = 10000; % just make error large
end;


