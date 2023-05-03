classdef EyeModel
% eyet.EyeModel - a model of the eye in world coordinates for the eye tracker
%

	properties (SetAccess=protected, GetAccess=public)
		eye;      % an eyet.math.ellipsoid3 object with the eye ellipsoid parameters (radii/size, center, rotation)
		pupil;    % structure with fields e (ellipsoid3 object), 'azimuth', 'elevation' for pupil
		left;     % structure with fields e (ellipsoid3 object), 'azimuth', 'elevation' for left skin intersection (corner)
		right;    % structure with fields e (ellipsoid3 object), 'azimuth', 'elevation' for right skin intersection (corner)
		top;      % structure with fields e (ellipsoid3 object), 'azimuth', 'elevation' for top skin intersection (corner)
		bottom;   % structure with fields e (ellipsoid3 object), 'azimuth', 'elevation' for bottom skin intersection (corner)
	end; % properties

	methods

			function E = EyeModel(varargin)
			% eyet.EyeModel - generate an eye model
			%
			% E = eyet.EyeModel(...)
			%
			% Create a model eye structure, based on several properties. The default properties
			% are listed below, and these can be modified by passing name/value pairs
			% to eyet.eye(). For example,
			%
			% E = eyet.eye('eye_center',[1;1;1])
			% 
			% moves the eye to position [1;1;1].
			%
			% Angles are defined so that 0 is the positive Y direction leaving the eye.
			% Increases in elevation move the pupil upward.
			% Increases in azimuth move the pupil towards _the animal's_ right.
			% 
			% |-----------------------------------------------------------------------|
			% | Fieldname (default)       | Description                               |
			% |---------------------------|-------------------------------------------|
			% | eye_center ([0;0;0])      | Eye origin                                |
			% | eye_ellipse_size ([1;2;1])| Ellipse parameters ([x y z])              |
			% | eye_rotation ([0;0;0])    | Eye rotation around X/Y/Z axis (degrees)  |
			% | pupil_elevation_angle (0) | Pupil elevation angle in degrees (0 is    |
			% |                           |   middle)                                 |
			% | pupil_azimuth_angle (0)   | Pupil azimuth angle in degrees            |
			% | pupil_ellipse_size        | Pupil ellipse ([x y z])                   |
			% |     ([0.01;0.2;0.2])      |                                           |
			% | pupil_center              | Calculated from pupil_angle and eye_origin|
			% |                           |     eye_ellipse, and pupil_angle          |
			% | eye_left_angle (-70 deg)  | Left eye sclera intersection with skin,   |
			% |                           |    angular offset from center of eye      |              
			% | eye_right_angle (+70 deg) | Right eye sclera interaction with skin,   |
			% |                           |    angular offset from center of eye      |              
			% | eye_leftright_ellipse_size| Ellipse size of eye intersections of      |
			% |   ([0.01;0.05;0.05])      |   sclera and eye                          |
			% |-----------------------------------------------------------------------|
			%
			% Returns an eyet.EyeModel object with fields:
			%     eye - an eyet.math.ellipsoid3 object with the eye ellipsoid parameters
			%          (radii/size, center, rotation)
			%     pupil.e - an eyet.math.ellipsoid3 object with the pupil dimensions
			%     pupil.azimuth - the azimuth angle of the pupil on the eye
			%     pupil.elevation - the elevation angle of the pupil on the eye
			%     left.e - an eyet.math.ellipsoid3 object with the point dimensions
			%     left.azimuth - the azimuth angle of the left intersection point
			%     left.elevation - the elevation of the left intersection point
			%     right.e - an eyet.math.ellipsoid3 object with the point dimensions
			%     right.azimuth - the azimuth angle of the right intersection point
			%     right.elevation - the elevation angle of the right intersection point
			%     top.e - an eyet.math.ellipsoid3 object with the point dimensions
			%     top.azimuth - the azimuth angle of the top middle point
			%     top.elevation - the elevation angle of the top middle point
			%     bottom.e - an eyet.math.ellipsoid3 object with the point dimensions
			%     bottom.azimuth - the azimuth angle of the bottom middle point
			%     bottom.elevation - the elevation angle of the bottom middle point
			%
			% See also: 
			%
			% Example:
			%
			% 

				  % default values
				eye_center = [0;0;0];
				eye_ellipse_size  = [1;2;1];
				eye_rotation = [0;0;0];

				pupil_elevation_angle = 0;
				pupil_azimuth_angle = 0;
				pupil_ellipse_size = [0.01;0.2;0.2];

				eye_left_angle = -70; 
				eye_right_angle = +70;
				eye_leftright_ellipse_size = [0.01;0.05;0.05];

				eye_top_angle = +70; 
				eye_bottom_angle = -70;
				eye_topbottom_ellipse_size = [0.01;0.05;0.05];

				vlt.data.assign(varargin{:});

				 % make sure we have column vectors
				eye_center = eye_center(:); 
				eye_ellipse_size = eye_ellipse_size(:);
				eye_rotation = vlt.math.deg2rad(eye_rotation(:));

				pupil_ellipse_size = pupil_ellipse_size(:);
				eye_leftright_ellipse_size = eye_leftright_ellipse_size(:);
				eye_topbottom_ellipse_size = eye_topbottom_ellipse_size(:);

				 % now calculate pupil_center

				az_angle_0 = 90; % angle '0' is positive X
				el_angle_0 = 90; % angle '0' is 0 for elevation

				az = vlt.math.deg2rad(az_angle_0 + pupil_azimuth_angle);
				el = vlt.math.deg2rad(el_angle_0 - pupil_elevation_angle);  % needs to be minus because in spherical coords, 0 is up

				sphere_angles = [sin(az)*sin(el);cos(az)*sin(el);cos(el)];
				R = sqrt( 1./ sum( (sphere_angles./eye_ellipse_size).^2 ) ); % now have R on an unrotated ellipse
				ER = eye_rotation;
				ROT_fwd = vlt.math.rot3d(ER(3),3)*vlt.math.rot3d(ER(2),2)*vlt.math.rot3d(ER(1),1);
				R = ROT_fwd * R;
				pupil_center = eye_center + R*sphere_angles;
				pupil_rotation = [0;0;0]; % maybe later

				 % eye intersections do rotate with eye

				 % now calculate left eye position

				az = vlt.math.deg2rad(az_angle_0 + eye_left_angle);
				el = vlt.math.deg2rad(el_angle_0 - 0);
				sphere_angles = [sin(az)*sin(el);cos(az)*sin(el);cos(el)];
				R = sqrt( 1./ sum( (sphere_angles./eye_ellipse_size).^2 ) ); % now have R on unrotated ellipse
				R = ROT_fwd * R;
				eye_left_center = eye_center+R*sphere_angles;
				eye_left_rotation = [0;0;0;];

				 % now calculate right eye position

				az = vlt.math.deg2rad(az_angle_0 + eye_right_angle);
				el = vlt.math.deg2rad(el_angle_0 - 0);
				sphere_angles = [sin(az)*sin(el);cos(az)*sin(el);cos(el)];
				R = sqrt( 1./ sum( (sphere_angles./eye_ellipse_size).^2 ) ); % now on unrotated ellipse
				R = ROT_fwd * R;
				eye_right_center = eye_center+R*sphere_angles;
				eye_right_rotation = [0;0;0;];

				 % now calculate top eye position

				az = vlt.math.deg2rad(az_angle_0 - 0);
				el = vlt.math.deg2rad(el_angle_0 - eye_top_angle);  % needs to be minus because in spherical coords, usually 0 is up
				sphere_angles = [sin(az)*sin(el);cos(az)*sin(el);cos(el)];
				R = sqrt( 1./ sum( (sphere_angles./eye_ellipse_size).^2 ) );
				R = ROT_fwd * R;
				eye_top_center = eye_center+R*sphere_angles;
				eye_top_rotation = [0;0;0;];

				 % now calculate bottom eye position

				az = vlt.math.deg2rad(az_angle_0 - 0);
				el = vlt.math.deg2rad(el_angle_0 - eye_bottom_angle);  % needs to be minus because in spherical coords, usually 0 is up
				sphere_angles = [sin(az)*sin(el);cos(az)*sin(el);cos(el)];
				R = sqrt( 1./ sum( (sphere_angles./eye_ellipse_size).^2 ) );
				R = ROT_fwd * R;
				eye_bottom_center = eye_center+R*sphere_angles;
				eye_bottom_rotation = [0;0;0;];

                disp(pupil_azimuth_angle);
                disp(pupil_elevation_angle);

				E.eye = eyet.math.ellipsoid3(eye_ellipse_size,eye_center,eye_rotation); 
				E.pupil = struct('e', eyet.math.ellipsoid3(pupil_ellipse_size,pupil_center,pupil_rotation),...
					'azimuth',pupil_azimuth_angle,'elevation',pupil_elevation_angle);
				E.left = struct('e', eyet.math.ellipsoid3(eye_leftright_ellipse_size,eye_left_center,eye_left_rotation), ...
					 'azimuth',eye_left_angle,'elevation',0);
				E.right = struct('e', eyet.math.ellipsoid3(eye_leftright_ellipse_size,eye_right_center,eye_right_rotation), ...
					'azimuth',eye_right_angle,'elevation',0);
				E.top = struct('e', eyet.math.ellipsoid3(eye_topbottom_ellipse_size,eye_top_center,eye_top_rotation), ...
					'azimuth',0,'elevation',eye_top_angle); 
				E.bottom = struct('e', eyet.math.ellipsoid3(eye_topbottom_ellipse_size,eye_bottom_center,eye_bottom_rotation), ...
					'azimuth',0,'elevation',eye_bottom_angle); 

		end; % EyeModel


		function [h] = plot(E)
			% EYE - plot an eye structure with pupil,left and right skin/sclera
			% intersections, and top and bottom middle point of eye
			%
			% H = plot(E)
			%
			% Plots an EyeModel object E 
			%
			% The eye is plotted in gray. The pupil, if it exists, is plotted in black.
			% The left and right intersection points are plotted in blue ([0 0 1]) and
			% a paler blue ([0 0 0.9]), respectively. The top and bottom middle points
			% are plotted in still paler blues ([0 0 0.8], [0 0 0.7]), respectively.
			%
			% See also: eyet.EyeModel
			% 
				he = [];
				hp = [];
				hl = [];
				hr = [];
				ht = [];
				hb = [];

				left_color = [0 0 1];
				right_color = [0 0 0.9];
				top_color = [ 0 0 0.8];
				bottom_color = [ 0 0 0.7];

				hold on;
				he = E.eye.plot();
				set(he,'color',0.5*[1 1 1]);

				if isprop(E,'pupil'),
					hold on;
					hp = E.pupil.e.plot();
					set(hp,'color',[0 0 0]);
				end;

				if isprop(E,'left'),
					hold on;
					hl = E.left.e.plot();
					set(hl,'color',left_color);

				end;

				if isprop(E,'right'),
					hold on;
					hr = E.right.e.plot();
					set(hr,'color',right_color);
				end;

				if isprop(E,'top'),
					hold on;
					ht = E.top.e.plot();
					set(ht,'color',top_color);
				end;

				if isprop(E,'bottom'),
					hold on;
					hb = E.bottom.e.plot();
					set(hb,'color',bottom_color);
				end;

				h=cat(2,he,hp,hl,hr,ht,hb);
		end; % plot()


	end; % methods


end %class
	
