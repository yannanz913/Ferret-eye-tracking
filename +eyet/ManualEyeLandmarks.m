classdef ManualEyeLandmarks < eyet.CameraImageLandmarks
    % a class that helps the user select the CameraImageLandmarks for the pupil, glints, and skin intersections

        properties (SetAccess=protected, GetAccess=public)
		eye_points  % A cell array of points on the eye (one entry for each camera)
	end; % properties

    
	methods
        function obj = ManualEyeLandmarks(image_array)
			% abstract class, nothing done

			% must create obj.pupil, obj.glints, obj.skin
			skin_intersections = {};
			for i=1:numel(image_array),
				skin_intersections{i} = eyet.EyeLandmarks.image2landmarks(images{i},4);
			end;
			% ask user to identify pupil
			% ask user to identify glints
			obj.skin = skin_intersections;
			obj.pupil = pupil_variable;
			obj.glints = glint_variable;
			
		end; % ManualEyeLandmarks(), creator     

     end; % methods

     methods (Static)
	    
		function landmarks = image2landmarks(image)
		    % image2landmarks - return coordinates of eye points in each image (in pixels)
		    %
		    % LANDMARKS = image2landmarks(IMAGES)
		    % 
		    % images - an image
            %
		    % User can click on all the points in the image (1 to 7, the same order as in calibration_obj.m) 
		    % and get the points in each camera coordinate system (2-dimensional, in pixels).
		    % 
		    % Example:
		    % landmarks = image2landmarks('/Users/adrita/Documents/MATLAB/+eyet/calibration_images/humaneye_testing_0305_increased_exposure/leftcam_left.png')

			selected_landmarks = zeros(2, 5);

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
			    selected_landmarks(1,k) = xi;
			    selected_landmarks(2,k) = yi;

			    plot(xi, yi, 'go');     

			    if isequal(k, 6)
				    break
			    end
			    xold = xi;
			    yold = yi;
		    end

		    hold off;
		    if k < size(selected_landmarks,2)
			    selected_landmarks = selected_landmarks(:, 1:k);
            end  

            eye_length = selected_landmarks(1, 3) - ((selected_landmarks(1, 1) + selected_landmarks(1, 2))/2);

            landmarks = zeros(2, 6);

		    landmarks(1, 1) = selected_landmarks(1, 1);
            landmarks(2, 1) = selected_landmarks(2, 1);

            landmarks(1, 2) = selected_landmarks(1, 2);
            landmarks(2, 2) = selected_landmarks(2, 2);

            landmarks(1, 3) = selected_landmarks(1, 3) - 2 * eye_length;
            landmarks(2, 3) = selected_landmarks(2, 3);

            landmarks(1, 4) = selected_landmarks(1, 3);
            landmarks(2, 4) = selected_landmarks(2, 3);

		    landmarks(1, 5) = selected_landmarks(1, 4);
            landmarks(2, 5) = selected_landmarks(2, 4);

            landmarks(1, 6) = selected_landmarks(1, 5);
            landmarks(2, 6) = selected_landmarks(2, 5);

		end; % image2landmarks()
	
	end; % static methods

end
