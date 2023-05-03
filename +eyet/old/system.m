function x = system(eyesize, L, C, S)
% SYSTEM - the model of the eye, light source, camera, and reflecting point S
%
% [X,valid] = SYSTEM(EYESIZE, L, C, S)
%
% The eye is located at the origin; it is an ellipsoid with a, b, (c, ...) equal
% to EYESIZE. That is, EYESIZE is = [a b c ...] of the n-dimension ellipsoid.
%
% The point light sources are indicated by the columns of L. That is,
% L = [[L1x;L1y] [L2x;L2y]]
%
% The camera point sources are indicated by the columns of C. That is,
% C = [[C1x;C1y] [C2x;C2y]]
%
% The reflection locations off the eye are the columns of S. That is,
% S = [[S1x;S1y] [S2x;S2y]]
%
% The points S must lie on the ellipse of the eye.
%
% X is a two column vector; the first column is the error of the points lying on the
% ellipsoid. The second column is the error of the reflection line going through the 
% light source and the camera. 


% ensure all reflecting points are on the surface

surface_error = [sum((S.^2)./eyesize.^2)-1]; 

vector_error = [dot(L-S,eyet.ellipsegrad(S,eyesize))/norm(L-S) - dot(C-S,eyet.ellipsegrad(S,eyesize))/norm(C-S)];

% concatenate error values; first column can be examined to see if points are really on surface
x = [surface_error(:) vector_error(:)]; 


