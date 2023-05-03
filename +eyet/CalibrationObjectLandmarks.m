classdef CalibrationObjectLandmarks
    
    properties (SetAccess=protected, GetAccess=public)
		brick_points  % A cell array of points on the brick (one entry for each camera)
	end; % properties

    
	methods
        function obj = CalibrationObjectLandmarks()
			% abstract class, nothing done
			obj.brick_points = {};
		end; % CalibrationObjectLandmarks(), creator
        
        
        function worldpts_cali = worldlandmarks(CalibrationObjectLandmarksObj, CameraModelObj)
			% WORLDLANDMARKS - convert landmarks from camera model coordinates to world coordinates
			%
			% WORLDPTS_CALI = worldlandmarks(CALIBRATIONOBJECTLANDMARKSOBJ, CAMERAMODELOBJ)
			%
			% Given an eyet.CameraModel object (or array) model of a camera system, and a set of
			% pixel landmarks eyet.CalibrationObjectLandmarks object, compute the best fit world coordinates
			% of the pixel landmarks.
			%
			% Returns a structure WORLDPTS_CALI with two entries:
			%       brick_points  - Brick points in world coordinates
				
				worldpts_cali.brick_points = camerapts2world(CameraModelObj, CalibrationObjectLandmarksObj.brick_points); 

		end; % worldlandmarks()
            
            
        function landmarks = image2landmarks(CalibrationObjectLandmarksObj, image, n)
            % image2landmarks - return coordinates of brick points in each image (in pixels)
            %
            % LANDMARKS = image2landmarks(CALIBRATIONOBJECTLANDMARKSOBJ, IMAGES, N)
            % 
            % images - a cell array of images (one for each camera)
            % n - reads up to n points
            % CalibrationObjectLandMarksObj - a set of pixel landmarks eyet.CalibrationObjectLandmarks object
            %
            % User can click on all the points in the image (1 to 7, the same order as in calibration_obj.m) 
            % and get the points in each camera coordinate system (2-dimensional, in pixels).
            % 
            % Example:
            % obj = eyet.CalibrationObjectLandmarks
            % landmarks = image2landmarks(obj, '/Users/elainezhu/Desktop/lego_left_cam.png', 7)
            
            if nargin < 2
                n = Inf;
                landmarks = zeros(2, 0);
            else
                landmarks = zeros(2, n);
            end
            
            imshow(image);
            xold = 0;
            yold = 0;
            k = 0;
            hold on;           % and keep it there while we plot
            
            while 1
                [xi, yi, but] = ginput(1);      % get a point
                if ~isequal(but, 1)             % stop if not button 1
                    break
                end
                k = k + 1;
                landmarks(1,k) = xi;
                landmarks(2,k) = yi;
                 
                    if xold
                        plot([xold xi], [yold yi], 'go-');  % draw as we go
                    else
                        plot(xi, yi, 'go');         % first point on its own
                    end
                
                    if isequal(k, n)
                        break
                    end
                    xold = xi;
                    yold = yi;
            end
            
            hold off;
            if k < size(landmarks,2)
                landmarks = landmarks(:, 1:k);
            end   
%             
%             % convert xy coordinates to pixels
%             [X,cmap] = imread(image);
%             R = worldfileread(image,'planar',size(X));
%             for i = 1:n
%                 [landmarks(1,i),landmarks(2,i)] = map2pix(R,landmarks(1,i),landmarks(2,i));
%             end
        
        end; % image2landmarks()
    end; % methods
end