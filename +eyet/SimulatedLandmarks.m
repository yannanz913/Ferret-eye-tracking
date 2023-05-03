classdef SimulatedLandmarks < eyet.CameraImageLandmarks

	methods
		function obj = SimulatedLandmarks(images, intensity, num_lightsources);
			% eyet.SimulatedLandmarks - CameraLandmarks from a simulated model image
			%
			% SLobj = eyet.SimulatedLandMarks(IMAGES, INTENSITY, NUM_LIGHTSOURCES)
			%
			% Generates camera image landmark measurements from a 
			% set of images returned from the CameraModel.cameraview function.
			%
			% IMAGES should be a cell array of simulated camera images, INTENSITY should
			% be a cell array of intensity values from the images (in 0..1) and
			% NUM_LIGHTSOURCES should be the number of light sources that were used to generate
			% the images.
			%
				for i=1:numel(images),
					[obj.skin{i},obj.pupil{i},obj.glints{i}] = ...
						eyet.SimulatedLandmarks.detect_artificial_marks(images{i},intensity{i},num_lightsources);
				end;
		end; % SimulatedLandmarks(), creator

	end; % methods

	methods(Static)

		function [IN,P,L] = detect_artificial_marks(im, intensity, num_lightsources)
			% DETECT_ARTIFICIAL_MARKS
			%
			% [IN,P,L] = DETECT_ARTIFICIAL_MARKS(IM, NUM_LIGHTSOURCES)
			%
			% Detect marks such as skin intersections, top and bottom middle point of eye, the pupil, and the light glints in a
			% simulated image of the eye and pupil. 
			%
			% Given an image IM that is a simulated image of the eye such as that
			% produced by eyet.cameraview, returns the center-of-mass of the marks.
			% Each light glint is assumed to be defined by a value 11 or greater.
			% (Color map value 11 is the first glint.)
			% The pupil is defined to have a color map value of 3. And the left and
			% right skin intersections are defined to have map values of 4 and 5,
			% respectively. The top and bottom middle point of eye are defined to have 
			% map values of 6 and 7, respectively.
			%
			% INTENSITY is the intensity of the light at each pixel.
			%
			% The detected points [I,P,L] will be returned in columns in units of pixels of
			% the image.
			%
			% The number of light sources should be entered in NUM_LIGHTSOURCES.
			%

				M = num_lightsources;
				number_of_pupils = 1;
				number_of_intersections = 4;


				L = zeros(2,0);

				for i=[3 4 5 6 7 10+[1:M]],  % pupil is 3, 4 - 7 are skin intersections, 11 and up are glints
					[I,J] = find(im==i);
					indexes = sub2ind(size(im),I,J);
					if ~isempty(I),
						pos = vlt.math.center_of_mass([I J],intensity(indexes));
						L(:,end+1) = pos(:);
					else,
						L(:,end+1) = [NaN; NaN];
					end;
				end;



				P = L(:,1:number_of_pupils);
				IN = L(:,number_of_pupils+1:number_of_pupils+number_of_intersections);
				L = L(:,1+number_of_pupils+number_of_intersections:end);
		end; % eyet.SimulatedLandmarks.detect_artificial_marks()

	end; % static methods


end % class
