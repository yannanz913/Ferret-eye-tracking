classdef CameraImageLandmarks

	properties (SetAccess=protected, GetAccess=public)
		pupil    % A cell array of points with the pupil center coordinates for each camera
		glints   % A cell array of points with the glint locations (one entry for each camera)
		skin     % A cell array of points with the skin intersection points (one entry for each camera)
	end; % properties


	methods
		function obj = CameraImageLandmarks()
			% abstract class, nothing done
			obj.pupil = {};
			obj.glints = {};
			obj.skin = {};
            
		end; % CameraImageLandmarks(), creator

		function worldpts = worldlandmarks(CameraImageLandmarksObj, CameraModelObj)
			% WORLDLANDMARKS - convert landmarks from camera model coordinates to world coordinates
			%
			% WORLDPTS = worldlandmarks(CAMERAIMAGELANDMARKOBJ, CAMERAMODELOBJ)
			%
			% Given an eyet.CameraModel object (or array) model of a camera system, and a set of
			% pixel landmarks eyet.CameraImageLandmark object, compute the best fit world coordinates
			% of the pixel landmarks.
			%
			% Returns a structure WORLDPTS with two entries:
			%       pupil      - The pupil in world coordinates
			%       skin       - The skin intersections in world coordinates
			%       eye_plane  - A structure with information about the estimated eye plane (from eyet.math.solveeyeplane())
			%          P1      - One point in the plane (skin intersection in corner of eye)
			%          P2      - Another point in the plane (skin intersection in other corner of eye)
			%          P3      - Point from P1 that has the other eye axis
			%          t       - Estimated rotation angles, in radians (t(1) is rotation about x axis, t(2) is rotation about y axis)

				worldpts.pupil = camerapts2world(CameraModelObj, CameraImageLandmarksObj.pupil);
                for i = 1:4,
                    worldpts.skin(1:3,i) = camerapts2world(CameraModelObj, {CameraImageLandmarksObj.skin{1}(:,i) CameraImageLandmarksObj.skin{2}(:,i)});
                end;
                
				[worldpts.eye_plane.P1,...
				 worldpts.eye_plane.P2,...
				 worldpts.eye_plane.P3,...
				 worldpts.eye_plane.t] = ...
					eyet.math.solveeyeplane(worldpts.skin(:,1),worldpts.skin(:,2),...
					worldpts.skin(:,3),worldpts.skin(:,4));

		end; % worldlandmarks()
	end; % methods
end

