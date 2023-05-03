function [Lerror] = lightsource_error(glints_pts, E,L,C)
% eyet.fit.lightsource_error - compute error in light source estimate given glints, camera properties, light properties, eye)
%
% Lerror = eyet.fit.lightsource_error(glints_pts, E, L, C)
%
% Given a CameraModel C, light system L, an EyeModel E, and locations of glints on the camera's
% X and Y position for each camera, compute the error in back-projecting the glint light through the 
% camera back to the source.
%
% The error for each camera and glint / light combination is returned as a column vector.
% 

Lerror = [];

use_debugging_plot = 0;

for c=1:numel(C), % for each camera
	for i=1:size(glints_pts{c},2), % for each glint / light

		% find the camera projection

% 		pix_array_pt = [];
% 		for j=1:3, % 3 dimensions
% 			pix_array_pt(j) = interp2( C(c).pixel_array_pt(:,:,j), ...
% 				glints_pts{c}(2,i),glints_pts{c}(1,i)); % the dimensions seem backward to me but this is right, Y first
% 		end;
% 		%pix_array_pt(1:3) = C(c).pixel_array_pt( round(glints_pts{c}(1,i)),round(glints_pts{c}(2,i)), :); %interpolation is better
% 		direction = C(c).nodal_pt(:) - pix_array_pt(:);
% 		direction = direction / norm(direction);
        
        [pix_array_pt,direction] = C(c).camerapts2worldvectors(glints_pts{c}(:,i));
        
		if c==1 & i == 1 & use_debugging_plot, % debugging plot
			hold on;
			pts = [pix_array_pt(:) pix_array_pt(:)+20*direction]
			plot3(pts(1,:),pts(2,:),pts(3,:),'g--');

		end;
       
		% compute point of intersection with the eye
		P = E.eye.vector_on_ellipsoid(pix_array_pt(:),pix_array_pt(:)+20*direction);
		% now bounce it out
		V_out = E.eye.ellipsoid_bounce_vector(P,-direction);
		V_out = V_out / norm(V_out);

		if c==1 & i==1 & use_debugging_plot, % debugging plot
			hold on;
			plot3(P(1),P(2),P(3),'go','markersize',10);
			pts = [ P(:) P(:)+10*V_out];
			plot3(pts(1,:),pts(2,:),pts(3,:),'r--');
		end;

		% now compute the error to the light here

		x = V_out\(L(:,i)-P); % closest point is P + x*V_out;
		Lerror_here = norm(L(:,i)-(P+x*V_out));

		if isnan(Lerror_here), 
			Lerror_here = 10000; % just make it huge
		end;

		Lerror(end+1) = Lerror_here;
	end;
end;

Lerror = Lerror(:); % column vector
