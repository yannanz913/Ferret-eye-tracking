function h = system(C, E, L)
% SYSTEM - plot a whole system 
%
% H = SYSTEM(C, E, L)
%
% Plot the real-world view of a system of light sources,
% camera model(s), and an ellipse. Plots in the current figure.
% Returns graphics handles of plots in H.
% C is the camera(s), E is the EyeModel object, and L is the light sources.
%

hold on;
h.eye = E.plot();
h.lights = eyet.plot.lights(L);
for i=1:numel(C),
	h.camera(i) = plot(C(i));
	% plot a point going out of the nodal line of the camera that has
	% length 10 units
    if isa(C(i),'eyet.CameraModel')
	    pt1 = C(i).nodal_pt;
	    % make line sqrt(2)*10 units in front of camera, pointing through nodal
	    % point, starting at nodal point
	    pt2 = C(i).nodal_pt + sqrt(2)*(10-norm(C(i).nodal_pt-C(i).center_pt)) * (C(i).nodal_pt-C(i).center_pt)/norm((C(i).nodal_pt-C(i).center_pt));
	    %	h.nodal2eyeline(i) = plot3([0 C(i).nodal_pt(1)],[0 C(i).nodal_pt(2)],[0 C(i).nodal_pt(3)],'k-');
	    h.camerasightline(i) = plot3([pt1(1) pt2(1)],[pt1(2) pt2(2)],[pt1(3) pt2(3)],'k-');
    elseif isa(C(i),'eyet.CameraModelVT'),
        [o,v] = C(i).camerapts2worldvectors(C(i).intrinsics.PrincipalPoint');
	    pt1 = o;
	    % make line sqrt(2)*10 units in front of camera, pointing through nodal
	    % point, starting at nodal point
	    pt2 = o+10*v;
	    %	h.nodal2eyeline(i) = plot3([0 C(i).nodal_pt(1)],[0 C(i).nodal_pt(2)],[0 C(i).nodal_pt(3)],'k-');
	    h.camerasightline(i) = plot3([pt1(1) pt2(1)],[pt1(2) pt2(2)],[pt1(3) pt2(3)],'k-');

    end;
end;

% fontsize(gca,scale=1.5);
title('System view');
xlabel('x');
ylabel('y');
zlabel('z');
axis equal;
