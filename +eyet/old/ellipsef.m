function f = ellipsef(ellipse, x)
% ELLIPSE - evaluate an ellipsoid surface function
% 
% F = ELLIPSEF(ELLIPSE, X)
%
% Given an ellipse defined at the origin with major, minor, tertiary, axes of
% ELLIPSE (such as ELLIPSE = [a b c]), evaluate F(X) which is
%
% x(1)^2/a^2 + x(2)^2/b^2 + ... - 1
%
% If X is a point on the ellipse, the function should equal zero. If not, there will
% be some non-zero value.

 % make sure ellipse is a column vector
ellipse = ellipse(:);

f = [sum((x.^2)./ellipse.^2)-1];
