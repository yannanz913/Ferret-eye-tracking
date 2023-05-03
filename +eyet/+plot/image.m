function h = image(im,cmap)
% IMAGE - plot an image of the camera view
%
% H = IMAGE(IM, CMAP)
%
% Plot an image using the provided color map CMAP. Returns
% graphics handle in H. Plots in current axes. Image is
% transposed before plotting.
%

h = image(im');
colormap(cmap); % need to transpose because images are transposed in Matlab
title(['Image through the camera.']);
xlabel('X camera');
ylabel('Y camera');
box off;

