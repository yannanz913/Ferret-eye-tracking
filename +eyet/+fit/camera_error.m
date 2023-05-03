function Cerror = camera_error(C, world_pts,camera_pts)
% eyet.fit.camera_error - compute error in the distance of the world pupil position from the estimated eye surface
%
% Cerror = eyet.fit.camera_error(C, world_pts, camera_pts)
%
% Given a camera system C and world points world_pts (columns of 3-space
% vectors in real world coordinates), calculates the error between the predicted 
% model camera points and the catual measured camera_pts (columns of 2-space points).
% 
% 

model_camera_pts = C.worldpt2camera(world_pts);

Cerror = model_camera_pts - camera_pts;

Cerror(find(isnan(Cerror))) = 10000;
