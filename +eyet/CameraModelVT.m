classdef CameraModelVT 
% Specify a camera model for the eye tracker
%
	properties
		intrinsics % Camera intrinsic parameters
		extrinsics % Camera extrinsics parameters
	end


	methods

		function c = CameraModelVT(intrinsics, extrinsics)
			% eyet.CameraModelVT - specify a camera with the Matlab vision toolbox
			%
			% C = eyet.CameraModelVT(INTRINSICS, EXTRINSICS)
			%
			% INTRINSICS should be a set of camera intrinsic parameters
			% such as is returned by 
			%
			% EXTRINSICS should be a structure with two fields,
			%   RotationMatrix - a 3x3 rotation matrix. 
			%   TranslationVector - a 1x3 translation vector in X,Y,Z
			% The camera position is determined by rotating the vector
			% [0 0 1] by the transpose of the rotation matrix and then
			% translating by the TranslationVector.
			%   
			%
			% Example:
			%   focalLength = [800 800];
			%   principalPoint = [320 240];
			%   imageSize = [480 640];
			%   intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);
			%   % camera at [10;0;0], pointing at [0;0;0]
			%   extrinsics.RotationMatrix = vlt.math.rot3d(deg2rad(-90),2)*vlt.math.rot3d(deg2rad(90),3);
			%   extrinsics.TranslationVector = [0 0 10];
			%   c = eyet.CameraModelVT(intrinsics,extrinsics);
			%   figure;
			%   h = c.plot();
			%   xlabel('x'); ylabel('y'); zlabel('z');
			%

				c.intrinsics = intrinsics;
				c.extrinsics = extrinsics;
		end; % CameraModelVT

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
            varargout = {};
            
			tolerance = 1;
                   
            % loop over all camera points
            for p = 1:numel(varargin),
				P = varargin{p};

				P_out = [];      
                   
            % get origin for first and second camera	
                points_ = varargin{p};
          
                [o_1,v_1]= C(1).camerapts2worldvectors(points_{1});
                [o_2,v_2]= C(2).camerapts2worldvectors(points_{2});

%                 LINE1 = [o_1  o_1+v_1*10];
%                 LINE2 = [o_2 o_2+v_2*10];
%                 hold on;
%                 plot3(LINE1(1,:),LINE1(2,:),LINE1(3,:),'g--','linewidth',2);
%                 plot3(LINE2(1,:),LINE2(2,:),LINE2(3,:),'r--','linewidth',2);

                A = [v_1 -v_2];
                xy = A\(o_2-o_1);
                G1 = o_1 + xy(1) * v_1;
                G2 = o_2 + xy(2) * v_2;
                if norm(G1-G2)<tolerance,
                    P_out(1:3,p) = mean([G1(:) G2(:)],2);
                else,
                    P_out(1:3,p) = [NaN; NaN; NaN];
                end;
            end; 
            varargout{p} = P_out;
        end; % camerapts2world

		function [o,v] = camerapts2worldvectors(C, c_pt)
			% CAMERAPTS2WORLDVECTORS_L - find the projection vector for
			% camera points
			%
			% [O,V] = CAMERAPTS2WORLDVECTORS(C, C_PT)
			%
			% Given a matrix of 2-row column vectors (2xN) in C_PT, which indicate positions in the camera
			% image plane, compute the origin and vector of a ray traveling into the world (in world
			% coordinates) from the camera. O is a vector of origins size 3x1 and V is a 3xN set of vectors
			% from the origins.
			%
			% Example:
			%  figure;
			%  h = c.plot();
			%  colors = [ 1 0 0; 0 1 0; 0 0 1];
			%  [o,v] = c.camerapts2worldvectors([0 0; 320 240; 0 480]');
			%  d = 5; % plot 5 units out
			%  hold on;
			%  for i=1:size(v,2),
			%       plot3(o(1)+[0 d*v(1,i)],o(2)+[0 d*v(2,i)],o(3)+[0 d*v(3,i)],'-','color',colors(i,:));
			%  end;
			%  xlabel('x'); ylabel('y'); zlabel('z');
			%
				   
				% Step 1: because the Matlab pointsToWorld function only computes 
				% points onto the Z plane, and we want to compute this for arbitrary
				% camera orientations, let's compute this using fixed extrinsic parameters
				% and then rotate and translate our answers
				SimpleRotationMatrix = eye(3);
				TranslationVector = [ 0 ; 0 ; -10 ];
                c_pt = c_pt'; % to adjust the size of pupil/glints/skin input to M*2
				worldpts = pointsToWorld(C.intrinsics, SimpleRotationMatrix, TranslationVector, c_pt);
                
				% Step 2: rotate and translate the points to the actual camera pose/location

				worldpts_trans = [worldpts repmat([-10 1],size(worldpts,1),1)]; % translate camera to origin

				[orientation, location] = extrinsicsToCameraPose(C.extrinsics.RotationMatrix,C.extrinsics.TranslationVector);
				worldpts_new = worldpts_trans * [orientation; location];

				worldpts_vectors = worldpts_new - repmat(location, size(worldpts_new,1),1);
				worldpts_vectors_norm = -worldpts_vectors ./ repmat(vecnorm(worldpts_vectors,2,2),1,3);

				o = location(:);
				v = worldpts_vectors_norm'; % column vectors

		end; % camerapts2worldvectors
        
		function c_pt = worldpt2camera(C, w_pt)
			% WORLDPT2CAMERA - convert points in world coordinates to some point on the image plane
			%
			% c_pt = eyet.calibration_obj(C, w_pt)
			%
			% W_PT is a set of world points provided as column vectors (3xN).
			%
			% Returns camera coordinates (X pixel, Y pixel), with one pixel location per
			% column (2xN). 

			   % easy, just call the Matlab function
			c_pt = worldToImage(C.intrinsics, C.extrinsics.RotationMatrix, C.extrinsics.TranslationVector, w_pt');
			c_pt = c_pt';
		end; % worldpt2camera()

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
			%   focalLength = [800 800];
			%   principalPoint = [320 240];
			%   imageSize = [480 640];
			%   intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);
			%   % camera at [10;0;0], pointing at [0;0;0]
			%   extrinsics.RotationMatrix = vlt.math.rot3d(deg2rad(-90),2)*vlt.math.rot3d(deg2rad(90),3);
			%   extrinsics.TranslationVector = [0 0 10];
			%   c = eyet.CameraModelVT(intrinsics,extrinsics);
			%   figure;
			%   h = c.plot();
                        %   xlabel('x'); ylabel('y'); zlabel('z');
			%

				[orientation,location]=extrinsicsToCameraPose(c.extrinsics.RotationMatrix,c.extrinsics.TranslationVector);
				hold on;
				h = plotCamera('Location',location,'Orientation',orientation,'Size',2,'AxesVisible',1)
		end; % plot()

		function [numx, numy] = imagesize(C, d)
			% IMAGESIZE - return the image size of a CameraModelVT object
			%
			% [NUMX, NUMY] = IMAGESIZE(C)
			% [NUMX] = IMAGESIZE(C, 1)
			% [NUMY] = IMAGESIZE(C, 2)
			%
			% Return the image size (number of pixels in X and number of pixels in Y of a 
			% camera image.  
			% Note that the Y pixels are in the rows of the actual image, and that
			% the X pixels are in the columns of the actual image.
			%
				numx = C.intrinsics.ImageSize(2);
				numy = C.intrinsics.ImageSize(1);
				if nargin>=2,
					if d==2,
						numx = numy; % first output should be y 
						return;
					end;
				end;
		end; % imagesize()

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

				[numX,numY] = C.imagesize();

				[X,Y] = meshgrid(1:numX,1:numY);
				[o,v] = C.camerapts2worldvectors([X(:) Y(:)]');
			
				im = zeros(numY, numX); 
				intensity = 0.0001 + im; % small intensity everywhere

				S = warning;
				warning off;
				
				for x=1:numX,
					for y=1:numY,
						im(y,x) = 1;
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
								pts{i} = F.vector_on_ellipsoid(o,o+0.01*v(:,y+(x-1)*numY));
								if ~isnan(pts{i}(1)),
									im(y,x) = col_values(i);
								end;
							end;
						end;

						drawit = 0; % some debugging code
						if (x==round(numX/2) & y==round(numY/2)) & drawit,
							i,
							hold on;
							linept = [o  10*v(:,y+(x-1)*numY)];
							plot3(linept(1,:),linept(2,:),linept(3,:),'k-');
						end;

						% check angle this vector makes with the light bouncing off from each light source
						if ~isnan(pts{1}(1)),
							intensity(y,x) = 0.1;
							vc = o-pts{1};
							for l=1:numL, % now check for bounces if we are on the eye
								% compute bounce angle of light source vector off of ellipse at that spot
								vl = L(:,l)-pts{1};
								v_out = E.eye.ellipsoid_bounce_vector(pts{1},vl);
								angle_diff = vlt.math.rad2deg(acos(dot(v_out,vc)/(norm(v_out)*norm(vc))));
								if abs(angle_diff)<5, % less than 5 degrees
									im(y,x) = 10 + l;
									intensity(y,x) = exp(-angle_diff.^2/7.5^2);
								end;
							end;
						end;
					end;
				end;

				warning(S);
			end; % cameraview()
        end; % methods

    methods (Static)
        function obj = CameraModelAlt(intrinsics, nodal_pt, rotations)
			% CameraModelAlt - create a camera model from a nodal point and set of rotations
			%
			% OBJ = eyet.CameraModelVT.CameraModelAlt(intrinsics, nodal_pt, [az el theta])
			%
			%  AZ is the azimuth angle in radians
			%  EL is the elevation angle in radians
            %  theta is rotation around the camera axis (spin around that axis)
            %
			%  Example:
            %  C = eyet.CameraModel.CameraModelAlt([-10;0;0],[0;0;0], 500,100,100)
            %
				az = rotations(1);
				el = rotations(2);
				theta = rotations(3);

                % find camera axis
                % we will do this by looking at where a "tip", 1 unit out
                % from the center, goes

                roll = vlt.math.rot3d(theta,3); % Matlab camera points up in Z
                pitch = vlt.math.rot3d(el,vlt.math.rot3d(theta,3)*[0;1;0]);
                az_rot = vlt.math.rot3d(az,pitch*[0;0;1]);
                orientation = az_rot * pitch * roll;
                location = nodal_pt;

                [extrinsics.RotationMatrix,extrinsics.TranslationVector] = cameraPoseToExtrinsics(orientation,location);

                obj = eyet.CameraModelVT(intrinsics,extrinsics);
        end;
    end; %(static methods)
end % class
