classdef ManualLandmarks < eyet.CameraImageLandmarks

	methods
        function obj = ManualLandmarks(pupil, glints, skin);
			% eyet.ManualLandmarks - CameraLandmarks manually detected from camera image
			%
			% MLobj = eyet.SimulatedLandMarks(PUPIL, GLINTS, SKIN)
			%
			% Generates camera image landmark measurements from a 
			% set of images returned from the CameraModel.cameraview function.
			%
            % PUPIL should be a cell array of pupil image locations, one
            % entry for each camera (e.g., {[258.8871;  265.7701], [365.0622;  240.5438]})
            %
            % GLINTS should be the glint locations, one cell array entry
            % for each camera and should match the number of light sources.
            % Each cell array should take a matrix where the column vectors
            % are the locations of each glint.
            % (e.g., {[[149.3940;  273.6533] [199.1636;  270.5000]],
            % [[232.3433;  224.7774], [302.0207;  234.2372]]}
			%
            % SKIN should be the skin intersections in the same format as
            % GLINTS (cell array of column vectors, one cell per camera)

                obj.pupil = pupil;
                obj.glints = glints;
                obj.skin = skin;
		end; % ManualLandmarks(), creator

	end; % methods

end
