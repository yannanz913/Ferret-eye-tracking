function modelcomp = compute_model(C, E, L, plotit)
% eyet.compute_model - compute the camera images and points for a model of the camera system, lights, and eye
%
% MODELCOMP = eyet.compute_model(C, E, L, PLOTIT)
%
% Computes the simulated camera view and decodes points in world coordinates, as follows. If PLOTIT is 1 or
% not given, the system is plotted in 2 figures.
%
% MODELCOMP is a structure with fields:
%    C                - The CameraModel system (passed through)
%    L                - The light system (passed through)
%    E                - The EyeModel (passed through)
%    cameraimages     - A structure with the results of simulating a view through each camera with  C.cameraview()
%       image         - A simulated image through each camera (computed by eyet.cameraview())
%       cmap          - The color map for each stimulated image (computed by eyet.cameraview())
%       intensity     - The intensity image of the glints for each stimulated image (computed by eyet.cameraview())
%    camera_landmarks - an eyet.SimulatedLandmarks object with the following pixel coordinates:
%       pupil         - The pupil as viewed through each simulated camera image
%       glints        - The glints from the light sources for each simulated camera image
%       skin          - The skin intersections for each simulated camera image
%    world_coords  - The world coordinates of points in the simulated images that don't depend on lighting
%       pupil      - The pupil in world coordinates
%       skin       - The skin intersections in world coordinates
%       eye_plane  - A structure with information about the estimated eye plane (from eyet.math.solveeyeplane())
%          P1      - One point in the plane (skin intersection in corner of eye)
%          P2      - Another point in the plane (skin intersection in other corner of eye)
%          P3      - Point from P1 that has the other eye axis
%          t       - Estimated rotation angles, in radians (t(1) is rotation about x axis, t(2) is rotation about y axis)
%    plot          - A structure with handles to the plots, if requested
%       image      - Handle to the camera image plots
%       intensity  - Handle to the camera intensity plots
%       system     - System plot handles (returned from eyet.system.plot())
% 

if nargin<4,
	plotit = 1;
end;

modelcomp.C = C;
modelcomp.L = L;
modelcomp.E = E;

[modelcomp.cameraimages.image,modelcomp.cameraimages.cmap,modelcomp.cameraimages.intensity] = cameraview(C,E,L);

modelcomp.camera_landmarks = eyet.SimulatedLandmarks(modelcomp.cameraimages.image,modelcomp.cameraimages.intensity,size(L,2));

modelcomp.world_coords = modelcomp.camera_landmarks.worldlandmarks(C);

modelcomp.plot.image={};
modelcomp.plot.intensity = {};
modelcomp.plot.system=[];

if plotit,
	% do the plotting

	% first figure, camera views

	figure;
	for c=1:numel(C),j,
		h1=subplot(2,2,1+(c-1)*numel(C));
		modelcomp.plot.image{c} = eyet.plot.image(modelcomp.cameraimages.image{c},modelcomp.cameraimages.cmap);
		fontsize(gca,scale=1.5);
        title(['Camera ' int2str(c) ' view']);
        fontsize(h1,scale=1.5);

		h2=subplot(2,2,2+(c-1)*numel(C));
		imconv = repmat(modelcomp.cameraimages.intensity{c}',1,1,3); % need to transpose because images are transposed in camera
		modelcomp.plot.intensity{c} = image(imconv);
        fontsize(gca,scale=1.5);
		title(['Camera ' int2str(c) ' intensity']);
        fontsize(h2,scale=1.5);
		linkaxes([h1;h2]);
	end;

	% second figure, system

	figure;
    fontsize(gca,scale=1.5);
	modelcomp.plot.system = eyet.plot.system(C,E,L);
end;


