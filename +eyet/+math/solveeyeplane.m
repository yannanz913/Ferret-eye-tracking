function [P1,P2,P3,theta,axis1,axis2] = solveeyeplane(SC1, SC2, top, bottom)
% eyet.math.solveeyeplane - 
%
% [P1,P2,P3,THETA,AXIS1,AXIS2] = eyet.math.solveeyeplane(SC1,SC2,top,bottom)
%
% Given the two skin corner intersection points in 3 space,
% and two points that are equally high (top) or low (bottom) 
% on the eye in 3 space, compute a plane that is parallel to the
% face of the animal at the location of the eye.
%

P1 = SC1;
P2 = SC2;
A = SC2 - SC1;
if A(2)<0,
    P1 = SC2;
    P2 = SC1;
    A = -A;
end;
B = bottom - top;
P3 = P1 + B;

P1 = P1(:); % column
P2 = P2(:); % column
P3 = P3(:); % column

 % now calculate Y axis, X axis rotations that bring it there

A = A/norm(A);

theta_y = atan2(A(1),A(3));
A_ = A(:)'*vlt.math.rot3d(theta_y,2);

theta_x = atan2(A_(3),A_(2));
A__ = A_*vlt.math.rot3d(theta_x,1);

theta = [theta_x;theta_y;];

axis1 = P2-P1;
axis1 = axis1/norm(axis1);
axis2 = P3-P1;
axis2 = axis2/norm(axis2);

% now A = vlt.math.rot3d(theta_y,2)) * vlt.math.rot3d(theta_x,1) * [0 1 0]'

