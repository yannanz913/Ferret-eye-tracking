function L = detect_artificial_glints(im, intensity, num_lightsources)
% DETECT_ARTIFICIAL_GLINTS
%
% L = DETECT_ARTIFICIAL_GLINTS(IM, NUM_LIGHTSOURCES)
%
% Detect glints in a simulated image of the eye and pupil. The pupil
% is the first point returned and is denoted in the image by a pixel value
% of 3.
%
% Given an image IM that is a simulated image of the eye such as that
% produced by eyet.cameraview, returns the center-of-mass of the glints.
% Each glint is assumed to be defined by a value 11 or greater.
% (Color map value 11 is the first glint.)
%
% The lights are glints 2 ... N+1 lights.
%
% INTENSITY is the intensity of the light at each pixel.
%
% The detected points L will be returned in columns in units of pixels of
% the image.
%
% The number of light sources should be entered in NUM_LIGHTSOURCES.
%

M = num_lightsources;

L = zeros(2,0);

for i=[3 4 5 10+[1:M]],
	[I,J] = find(im==i);
	indexes = sub2ind(size(im),I,J);
	if ~isempty(I),
		pos = vlt.math.center_of_mass([I J],intensity(indexes));
		L(:,end+1) = pos(:);
	else,
		L(:,end+1) = [NaN; NaN];
	end;
end;

