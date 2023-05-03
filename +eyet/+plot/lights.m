function h = lights(L)
% LIGHTS - plot lights in real world
%
% H = LIGHTS(L)
%
% Given a set of columns that indicate the positions of light
% sources in 3-space, plot the points in the current axes.
%
% The points will be plotted in colors in the SPRING colormap.
%
% Graphics handles to the plots are returned in H.

h = [];

c = spring(size(L,2));
for i=1:size(L,2),
	h(end+1) = plot3(L(1,i),L(2,i),L(3,i),'o','color',c(i,:));
end;

