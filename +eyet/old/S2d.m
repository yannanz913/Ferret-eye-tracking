function [S,fval] = S2d(eyesize, L, C)
% S2D - For a 2-dimensional system, find the point of reflection off the eye
%
% [S,FVAL] = S2D(EYESIZE, L, C)
%
% Given a model of the sysytem where
%    a) the eye is at the origin and is an ellipsoid with spread eyesize(1),eyesize(2), etc...
%    b) L is the location of the light source (a point in N-space)
%    c) C is the location of the observer (a point in N-space)
%
% returns S, the location of the reflection off the eye in N-space.
% Also returns FVAL, the error of the system (see help eyet.system).
%
%

eyesize = eyesize(:);
L = L(:);
C = C(:);

%F = @(S,eyesize,L,C) [dot(L-S,eyet.ellipsegrad(S,eyesize))/norm(L-S) - dot(C-S,eyet.ellipsegrad(S,eyesize))/norm(C-S) ; sum((S.^2)./eyesize.^2)-1]

options = optimoptions('fsolve','Display','off','OptimalityTolerance',1e-8);

[S,fval] = fsolve(@(x) eyet.system(eyesize,L,C,x),[2;1],options);


