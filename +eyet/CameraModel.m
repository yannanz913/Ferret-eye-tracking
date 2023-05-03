classdef CameraModel
% Specify a camera model for the eye tracker
%

	properties (SetAccess=protected, GetAccess=public)
		center_pt    % Center point of the camera pixel array, in world coordinates
		nodal_pt     % Nodal point of the camera's lens, in world coordinates
                x_axis_pt    % A point along the X-axis of the camera in world coordinates
                mag          % Magnification of the camera
                N            % Pixel units in X, from -N/2:N/2
                M            % Pixel units in Y, from -M/2:M/2
                Nx           % Pixel X locations in world coordinates; the view of each X pixel is of a ray starting at these locations and passing through the nodal point
                Mx           % Pixel Y locations in world coordinates; the view of each Y pixel is of a ray starting at these locations and passing through the nodal point
		x_axis_unit_vector % 
		nodal_unit_vector % 
		y_axis_unit_vector % 
		Npt
		Mpt
		pixel_array_pt


	end;

	methods

		function c = CameraModel(center_pt, nodal_pt, x_axis_pt, mag, N, M)
			% eyet.CameraModel - specify a camera
			%
			% C = eyet.CameraModel(CENTER_PT, NODAL_PT, X_AXIS_PT, MAG, N, M)
			%
			% Specifies a camera by the center_point of its array (in N space), the nodal
			% point directly in nodal of the center of the camera (in N space), and a
			% point on the X axis of the camera in real space, and the magnification of the camera's computer
			% image (MAG). N and M are the number of pixels that the camera encodes.
			%
			% Returns a CameraModel object with the following fields:
			% |---------------------------------------------------------------
			% | Field name:                | Description:                    |
			% |---------------------------------------------------------------
			% | center_pt                  | Center point of the camera pixel| 
			% |                            |   array, in real space units    |
			% | nodal_pt                   | Nodal point of the camera's lens|
			% |                            |   in real space units           |
			% | x_axis_pt                  | A point along the X-axis of the |
			% |                            |   camera in real space units    |
			% | mag                        | Magnification of the camera     |
			% | N                          | Pixel units in X, from -N/2:N/2 |
			% | M                          | Pixel units in Y, from -M/2:M/2 |
			% | Nx                         | Pixel X locations in real space |
			% |                            |   The view of each X pixel is of|
			% |                            |   a ray starting at these       |
			% |                            |   locations in real space and   |
			% |                            |   passing through the nodal     |
			% |                            |   point.
			% | Mx                         | Pixel Y locations in real space |
			% |                            |   The view of each Y pixel is of|
			% |                            |   a ray starting at these       |
			% |                            |   locations in real space and   |
			% |                            |   passing through the nodal     |
			% |                            |   point.
			% 
			%
			% Example:
			%   c = eyet.CameraModel([1 1 0],[0 2 0],[2 2 0],2,50,50);
			%   figure;
			%   h = eyet.plot.camera(c);
			%   xlabel('x'); ylabel('y'); zlabel('z');
			%

				c.center_pt = center_pt(:);
				c.nodal_pt = nodal_pt(:);
				c.x_axis_pt = x_axis_pt(:);
				c.mag = mag;

				c.N = linspace(-N/2,N/2,N);
				c.M = linspace(-M/2,M/2,M);

				c.x_axis_unit_vector = (c.x_axis_pt - c.center_pt)/norm(c.x_axis_pt-c.center_pt);
				c.nodal_unit_vector = (c.nodal_pt - c.center_pt)/norm(c.nodal_pt-c.center_pt);
				if abs(dot(c.x_axis_unit_vector,c.nodal_unit_vector))>1e-6,
					error(['X axis vector and nodal vector are not orthogonal.']);
				end;
				c.y_axis_unit_vector = cross(c.x_axis_unit_vector, c.nodal_unit_vector);

				c.Npt = (1/c.mag)*c.N.*c.x_axis_unit_vector + c.center_pt; 
				c.Mpt = -(1/c.mag)*c.M.*c.y_axis_unit_vector + c.center_pt;  % negative to image draws top to bottom for Matlab image routine

				c.pixel_array_pt = zeros(N,M,3);

				for i=1:numel(c.N),
					for j=1:numel(c.M),
						c.pixel_array_pt(i,j,:) = (1/c.mag) * (c.N(i)*c.x_axis_unit_vector - c.M(j)*c.y_axis_unit_vector) + c.center_pt;
					end;
				end;

		end; % CameraModel

		function varargout = camerapts2world(C,varargin)
			% CAMERAPTS2WORLD - convert points in the space of 2 or more CameraModel objects to the world coordinates
			%
			% [PTS1_WORLD, ..., PTSN_WORLD] = eyet2.camerapts2world(C,PTS1_CAMERA,...,PTSN_CAMERA)
			%
			% Given a 2-camera system C (eyet.CameraModel objects) and a set of points that are viewed
                        % through the cameras (in pixel coordinates), return the WORLD coordinates.
			%
			% Note that these camera points must correspond to points that are viewed by both cameras
			% and cannot be spectal reflections (glints), which move depending upon the viewing angle.
			%
			% C should be a eyet.CameraModel object as returned by eyet.CameraModel().
			%
			% PTSX_CAMERA should be a cell array of 2 or more entries (1 entry per camera model) that
			% has individual points in the columns and the X and Y values as the rows.
			%
			% Points are considered matched in the 2 views if the vectors from the camera models
			% intersect with a tolerance of 0.1 in world coordinates. Otherwise, NaN values are returned.
			% The intersection point is the mean of the closest point between the two lines.
			% 
				 % we are looking for
				 % G = nodal_pt1 + x * direction1
				 % G = nodal_pt2 + y * direction2

				 % or, subtracting
				 % 
				 % 0 == nodal_pt1 - nodal_pt2 + x*direction1 - y*direction2
				 % 
				 % or,
				 % 
				 % A * [x;y] == nodal_pt2-nodal_pt1
				 % where A = [ direction1(:); -direction2(:)]
				 % so we have
				 % 
				 % A * [x;y] == (nodal_pt2-nodal_pt1)

				varargout = {};

				tolerance = 0.1;

				nodal_pt_1 = C(1).nodal_pt(:);
				nodal_pt_2 = C(2).nodal_pt(:);

				for p = 1:numel(varargin),
					P = varargin{p};

					P_out = [];

					for i=1:size(P{1},2), % for each point do
						
						pix_array_pt = [];
						direction = {};
						for c = 1:numel(C), % usually 2 cameras
							for j=1:3, % 3 dimensions
								pix_array_pt(j,c) = interp2( C(c).pixel_array_pt(:,:,j), ...
									P{c}(2,i),P{c}(1,i)); % the dimensions seem backward to me but this is right, Y first
							end;
						%	pix_array_pt(1:3,c) = C(c).pixel_array_pt( round(P{c}(1,i)),round(P{c}(2,i)), :); % interpolation is better
							direction{c} = C(c).nodal_pt(:) - pix_array_pt(:,c);
						end;

						A = [direction{1} -direction{2}];
						xy = A\(nodal_pt_2-nodal_pt_1);
						G1 = nodal_pt_1 + xy(1) * direction{1};
						G2 = nodal_pt_2 + xy(2) * direction{2};
						if norm(G1-G2)<tolerance,
							P_out(1:3,i) = mean([G1(:) G2(:)],2);
						else,
							P_out(1:3,i) = [NaN; NaN; NaN];
						end;
					end;
					varargout{p} = P_out;
				end;

		end; % camerapts2world()

		function c_pt = worldpt2camera(C, w_pt)
			% WORLDPT2CAMERA - convert points in world coordinates to some point on
			% the image plane using vectors
			% c_pt = eyet.calibration_obj(C, w_pt)
			%
			% Returns camera coordinates (X pixel, Y pixel) of a point provided in
			% real-world coordinates.

				  % Step 1: find the point on the camera in real-world coordinates

				center_point = C(1).center_pt(:);
				nodal_point = C(1).nodal_pt(:);

			    top_left_pt = squeeze(C.pixel_array_pt(1,1,:));  % pixel 1
			    top_right_pt = squeeze(C.pixel_array_pt(end,1,:));   % pixel numel(C(1).N)
			    bottom_left_pt = squeeze(C.pixel_array_pt(1,end,:)); % pixel 1
			    %bottom_right_pt = squeeze(C.pixel_array_pt(end,end,:));  % pixel numel(C(1).M)
			    x_axis_vector_world = (top_right_pt - top_left_pt);
			    y_axis_vector_world = (bottom_left_pt - top_left_pt);

                c_pt = [];

                for i=1:size(w_pt,2)

				      % Step 1a: the world point will project onto the camera through the nodal_point
				    input_vector = nodal_point-w_pt(:,i);
				    input_vector_unit = input_vector / norm(input_vector);
				      % Step 1b: how far is the camera sensor array from the nodal point?
				    normal_vector = -(nodal_point-center_point);
				    normal_vector_unit = normal_vector / norm(normal_vector);
				    D = norm(center_point-nodal_point);
				      % Step 1c: now, find out how far a vector at an angle potentially-offcenter travels to get to the sensor array
				      %   angle between nodal and world pt = angle between nodal point and center point
				      %   cos(angle_between_nodal_point_and_center_point) = dot(input_vector_unit, normal_vector_unit)
				      %   cos(theta) = opposite / hypotenuse, so hypotenuse = dot(input_vector_unit, normal_vector_unit)/D
				    h = dot(input_vector_unit, normal_vector_unit)/D;
				      % the camera array location in world coordinates is h units along the input_vector_unit from the nodal_point
				    camera_pt_world = nodal_point + (input_vector_unit) * h;
    
				      % Step 2: now that we know the location on the camera array in world coordinates, 
				      %   we need to convert it to pixel coordinates    
    
				    projection_vector = (camera_pt_world - top_left_pt);
				    c_x_length = dot(projection_vector,x_axis_vector_world) / norm(x_axis_vector_world);				    
				    c_y_length = dot(projection_vector, y_axis_vector_world) / norm(y_axis_vector_world);
    
				    c_pt_here = [vlt.math.rescale(c_x_length,[0 norm(x_axis_vector_world)],[1 numel(C(1).N)],'noclip') ; ...
					    vlt.math.rescale(c_y_length,[0 norm(y_axis_vector_world)],[1 numel(C(1).M)],'noclip') ];
                    if h<0,
                        c_pt_here = [NaN;NaN];
                    end;
                    c_pt = [c_pt c_pt_here(:)];
                end;

		end; % worldpt2camera()


		function [im,cmap,intensity] = cameraview(C, E, L)
			% CAMERAVIEW - compute the view of a CameraModel, EyeModel, and light sources
			%
			% [IM,CMAP,INTENSITY] = cameraview(C, E, L)
			%
			% Given an eyet.CameraModel structure C (see help eyet.CameraModel) an eyet.EyeModel E,
			% and the light sources in the columns of L, compute the view of each pixel of a camera.
			%
			% CMAP is a color map for the image.
			%
			% See also: eyet.CameraModel(), eyet.EyeModel()
			% 
				if numel(C)>1,
					im = {};
					cmap = [];
					intensity = {};

					for i=1:numel(C),
						[im{i},cmap,intensity{i}] = cameraview(C(i), E, L);
					end;

					return;
				end;

				colors = [1 1 1 ; 0.5 0.5 0.5; 0 0 0 ; 0 0 1; 0 0 0.9 ; 0 0 0.8; 0 0 0.7; ones(3,3);spring(size(L,2))];
				cmap = colors;

				numL = size(L,2);

				im = zeros(numel(C.N), numel(C.M));
				intensity = 0.0001 + im; % small intensity everywhere

				S = warning;
				warning off;
				for x=1:numel(C.N),
					for y=1:numel(C.M),
						im(x,y) = 1;
						fields = {'eye','left','right','top','bottom','pupil'};
						col_values = [2 4 5 6 7 3];
						pts = {};
						for i=1:numel(fields),
							pts{i} = [NaN;NaN;NaN];
							if isprop(E,fields{i}),
								F = getfield(E,fields{i});
								if ~isa(F,'eyet.math.ellipsoid3'),
									F = F.e;
								end;
								pts{i} = F.vector_on_ellipsoid(squeeze(C.pixel_array_pt(x,y,:)),C.nodal_pt);
								if ~isnan(pts{i}(1)),
									im(x,y) = col_values(i);
								end;
							end;
						end;
								
						drawit = 0; % some debugging code
						if (x==round(numel(C.N)/2) & y==round(numel(C.M)/2)) & drawit,
							i,
							hold on;
							linept = [];
							linept = squeeze(C.pixel_array_pt(x,y,:));
							linept = [linept squeeze(C.pixel_array_pt(x,y,:)) + (10) * (C.nodal_pt - squeeze(C.pixel_array_pt(x,y,:)))];
							plot3(linept(1,:),linept(2,:),linept(3,:),'k-');
						end;

						% check angle this vector makes with the light bouncing off from each light source
						if ~isnan(pts{1}(1)),
							intensity(x,y) = 0.1;
							vc = C.nodal_pt-pts{1};
							for l=1:numL, % now check for bounces if we are on the eye
								% compute bounce angle of light source vector off of ellipse at that spot
								vl = L(:,l)-pts{1};
								v_out = E.eye.ellipsoid_bounce_vector(pts{1},vl);
								angle_diff = vlt.math.rad2deg(acos(dot(v_out,vc)/(norm(v_out)*norm(vc))));
								if abs(angle_diff)<5, % less than 5 degrees
									im(x,y) = 10 + l;
									intensity(x,y) = exp(-angle_diff.^2/7.5^2);
								end;
							end;
						end;
					end;
				end;

				warning(S);
			end; % cameraview()

		function h = plot(c)
			% PLOT - plot a camera in real space
			% 
			% H = plot(C) 
			%
			% Plots the CameraModel C, in the current axes. 
			% H is a structure of graphic handles to the points in the camera.
			% The current plot is held using 'hold on'.
			%
			% Example:
			%    c = eyet.CameraModel([11;-11;0], [10;-10;0], [12;-10;0], 250, 100, 100);
			%    figure;
			%    h=plot(c);
			%
				hold on;
				h.pixel_array = plot3(c.pixel_array_pt(:,:,1),c.pixel_array_pt(:,:,2),c.pixel_array_pt(:,:,3),'o');
				F = c.nodal_pt;
				h.nodel_pt = plot3(F(1,:),F(2,:),F(3,:),'ko'); % nodal point
				h.center_pt = plot3(c.center_pt(1,:),c.center_pt(2,:),c.center_pt(3,:),'ks');
		end; % plot()

    end; % methods
    
	methods (Static)
        
		function obj = CameraModelAlt(nodal_pt, rotations, mag, N, M)
			% CameraModelAlt - create a camera model from a nodal point and set of rotations
			%
			% OBJ = eyet.CameraModel.CameraModelAlt(nodal_pt, [az el theta], mag. N, M)
			%
			%  AZ is the azimuth angle in radians
			%  EL is the elevation angle in radians
            %
			%  Example:
            %  C = eyet.CameraModel.CameraModelAlt([-10;0;0],[0;0;0], 500,100,100)
            %
				az = rotations(1);
				el = rotations(2);
				theta = rotations(3);
				[center_offset(1,1),center_offset(2,1),center_offset(3,1)] = sph2cart(az,el,1);
				center_pt = nodal_pt + center_offset;


%                PhiTheta = eyet.azel2phitheta([az;el]); % PhiTheta(1) = phi; PhiTheta(2) = theta
				change_with_delta_azimuth = 0.001*[ -sin(az)*sin(pi/2 - el); cos(az)*sin(pi / 2 - el); 0];
                                % dx/dphi cos(az) sin(pi/2 - el) 
								 % dy/dphi sin(az) sin(pi/2 - el)
								 % dz/dphi cos(pi/2 - el)
                R = vlt.math.rot3d(theta,nodal_pt-center_pt);
                x_axis_direction = R*change_with_delta_azimuth;
				x_axis_pt = center_pt + x_axis_direction;
				obj = eyet.CameraModel(center_pt, nodal_pt, x_axis_pt, mag, N, M);
		
		end; % CameraModelAlt
	end; % methods(Static)



end % class




