classdef ellipsoid3
% eyet.math.ellipsoid3 - class for geometric calculations involving ellipsoids
%
	properties (SetAccess=protected, GetAccess=public)
		radii % The ellipsoid radii [a b c]
		center % The ellipsoid's center
		rotation % The ellipsoid's rotations about the three axes [theta_x theta_y theta_z], applied in order (radians)
	end;

	methods
		function ellipsoid3obj = ellipsoid3(varargin)
			% ELLIPSOID3 - creates a new ellipsoid3 object
			%
			% ELLIPSOID3OBJ = ELLIPSOID3([RADII],[CENTER],[ROTATION)
			%
			% Creates a new ellipsoid3d object, a 3-dimensional ellipsoid.
			%
			% Inputs:
			%     RADII    - the ellipsoid radii [a;b;c]. If empty or not
			%                provided, then [1;1;1] is used.
			%     CENTER   - the origin of the ellipsoid. If empty or not
			%                provided, then [0;0;0] is used.
			%     ROTATION - The rotation of the ellipsoid about the x, y, and z
			%              - axes (applied in that order). In radians. If empty or
			%              - not provided, then [0;0;0] is used. 
			% Output:
			%     ELLIPSOIDOBJ3 - a new ELLIPSOID3D object.
			%
			% Examples:
			%    e1 = eyet.math.ellipsoid3(), % default parameters
			%    e2 = eyet.math.ellipsoid3([1;2;1]), % bigger in Y dimension
			%    e3 = eyet.math.ellipsoid3([],[1;1;1],[]), % centered at [1;1;1]
			%    e4 = eyet.math.ellipsoid3([1;2;1],[],vlt.math.deg2rad([45;0;0]) % rotated 45 deg around X axis
			%
			% See also: methods('ellipsoid3d')
			%
				if nargin<1,
					radii = [1;1;1];
				else,
					radii = varargin{1};
					if numel(radii)~=3,
						error(['RADII must be a 3 element vector.']);
					end;
				end;

				if nargin<2,
					center = [0;0;0];
				else,
					center = varargin{2};
					if numel(center)~=3,
						error(['CENTER must be a 3 element vector.']);
					end;
				end;

				if nargin<3,
					rotation = [0;0;0];
				else,
					rotation = varargin{3};
					if numel(rotation)~=3,
						error(['ROTATION must be a 3 element vector.']);
					end;
				end;

				ellipsoid3obj.radii = radii(:); % enforce column
				ellipsoid3obj.center = center(:);
				ellipsoid3obj.rotation = rotation(:);

		end; % ellipsoid3d(), creator

		function g = gradient(e3obj, p)
			% GRADIENT - compute gradient of ELLIPSOID3 object
			%
			% G = GRADIANT(ELLIPSOID3OBJ, P)
			%
			% Compute the gradient of the ellipsoid at point P.
			% 
			% Example: 
			%   % If ellipsoid is x^2/2^2 + y^2/1.5^2 + z^2/1 == 1
			%   %  compute gradient at x==0, y==1.5, z==0
			%   e = eyet.math.ellipsoid3([2 1.5 1]);
			%   g = e.gradient([0;1.5;0]);
			% 
				p = p(:); % make sure column
				p_ = p-e3obj.center; % translate with respect to ellipsoid center
				p__ = e3obj.rotation_reverse() * p_; % rotate by the inverse of rotations applied to the actual ellipsoid
				% now can calculate gradient based on unrotated ellipsoid equation
				g__ = 2 * p__ ./ (e3obj.radii.*e3obj.radii);
				% now rotate this vector according to the ellipse
				g_ = e3obj.rotation_forward() * g__;
				% no need to translate, this is a directional vector
				g = g_;
		end;% gradient

		function R_rev = rotation_reverse(e3obj)
			% ROTATION_REVERSE - a rotation matrix to reverse the rotation of the ellipsoid 
			%
			% R_REV = ROTATION_REVERSE(ELLIPSOID3DOBJ)
			%
			% Calculate a rotation matrix to reverse the rotation of a coordinate in the ellipsoid.
			%
			% Undoes a rotation about the X axis, Y axis, and then Z axis.
			%
			% Example:
			%    % rotate a point x about the ellipsoid in order to make calculations with respect to an unrotated ellipsoid
			%    x = [ 0.3; 0.4; 0];
			%    e = eyet.math.ellipsoid3([],[],vlt.math.deg2rad([45;0;0]);
			%    x_ = e.rotation_reverse() * x;
			%
				R = e3obj.rotation;
				R_rev = vlt.math.rot3d(-R(1),1)*vlt.math.rot3d(-R(2),2)*vlt.math.rot3d(-R(3),3);
		end; % rotation_reverse()

		function R_fwd = rotation_forward(e3obj)
			% ROTATION_FORWARD - rotation matrix to rotate a point from an unrotated ellipse to an arbitrary ellipsoid
			%
			% R_FWD = ROTATION_FORWARD(ELLIPSOID3OBJ)
			%
			% Calculate a rotation matrix to rotate a point about the rotation of the ellipse.
			%
			% Example:
			%    % rotate a point x about the ellipsoid 
			%    x = [ 0.3; 0.4; 0];
			%    e = eyet.math.ellipsoid3([],[],vlt.math.deg2rad([45;0;0]);
			%    x_ = e.rotation_forward()* x;
			%
				R = e3obj.rotation;
				R_fwd = vlt.math.rot3d(R(3),3)*vlt.math.rot3d(R(2),2)*vlt.math.rot3d(R(1),1);
		end; % rotation_forward()

		function [i,az,el] = vector_on_ellipsoid(e3obj, pt1,pt2)
			% VECTOR_ON_ELLIPSE - find point of intersection of a vector on an ellipsoid (if any)
			%
			% [I,AZ,EL] = VECTOR_ON_ELLIPSE(ELLIPSOID3OBJ, PT1, PT2)
			%
			% Given an ELLIPSOID3 object, and given a vector that passes from PT1 to PT2, find 
			% the closest intersecting point to PT2 called I.
			%
			% If I does not exist, then I is NaN * ones(size(PT1)).
			%
			% AZ is the azimuth angle of the point I on the ellipse (rotation about the Z axis), in 
			% radians. Positive angles are clockwise.  0 degrees is along the X axis.
			%
			% EL is the elevation angle (angle above the XY plane) in radians.
			%
				% Step 1: make sure we are in column form
	
				pt1 = pt1(:); % column form
				pt2 = pt2(:); % column form
				
				% Step 2: now we have to deal with the fact that the ellipse is not at the origin and is rotated about its origin
				% we will do this by shifting and rotating pt2 and pt1 in space and find the intersection i_.
				% at the end, we will rotate and shift i_ back to get point i
				
				pt2_ = pt2 - e3obj.center;
				pt1_ = pt1 - e3obj.center;

				% Step 3: now that we have shifted into coordinates of the ellipse's origin, we need to rotate the points

				pt2__ = e3obj.rotation_reverse() * pt2_; 
				pt1__ = e3obj.rotation_reverse() * pt1_; 

				% Step 4: now use eyet.vector_on_ellipse() to find the intersection.
				% It handles a simple ellipse (with radii) at the origin without rotation

				[i__,az,el] = eyet.math.ellipsoid3.vector_on_unrotated_ellipsoid(e3obj.radii, pt1__, pt2__);

				% now we have to transform back

				i_ = e3obj.rotation_forward() * i__; % if i__ is NaN, then i_ will be NaN, too, so no need to do anything special

				% undo shift

				i = i_ + e3obj.center;

		end; % vector_on_ellipsoid

		function v_out = ellipsoid_bounce_vector(e3obj, pt, v_in)
			% ELLIPSOID_BOUNCE_VECTOR - compute a reflecting vector off an ellipsoid
			%
			% V_OUT = ELLIPSOID_BOUNCE_VECTOR(ELLIP, ELLIPSE_CENTER, ELLIPSE_ROTATION, PT, V_IN)
			%
			% Calculates the reflecting vector off the surface of an ELLIPSOID3 object.
			% PT is the intersection point, which must be a point on the ellipsoid.
			% V_IN is the vector along a line pointing towards the object from PT.
			%
				pt = pt(:);
				v_in = v_in(:);

				grad = e3obj.gradient(pt);
				grad_unit = grad / norm(grad);

				v_out = -v_in - 2*dot(-v_in,grad_unit) * grad_unit;

		end; % ellipse_bounce_vector()

		function [i,v,d,az,el] = closest_pt_on_ellipsoid(e3obj, pt, radii, origin, rotation)
			% eye.closest_pt_on_ellipse - return closest point on an ellipsoid to a given point
			%
			% [I,V,D,AZ,EL] = CLOSEST_PT_ON_ELLIPSOID(ELLIPSOID3OBJ, PT)
			%
			% Returns the closest point I to PT that is on an ellipsoid with RADII, ORIGIN,
			% ROTATION. V is the direction from I to the ellipsoid.  D is the distance of the
			% point I to the surface of the ellipsoid. AZ and EL are the aziumuth and elevation of
			% the point on the ellipsoid, in radians.
			%
			% 
				v = e3obj.gradient(pt); 
				% now we have the direction
				[i,az,el] = e3obj.vector_on_ellipsoid(pt,pt+v);
				d = norm(i-pt);
		end; % closest_pt_on_ellipsoid()

		function [x,y,z] = plotpoints(e3obj)
			% PLOTPOINTS - generate an array of points that are on the surface of an ELLIPSOID3 object
			%
			% [X,Y,Z] = PLOTPOINTS(ELLIPSOID3OBJ)
			%
			% Given an ELLIPSOID3 object, generate an array of X, Y, and Z points on the ellipsoid.
			%

				% Step 1, generate the points for an ellipsoid centered at the origin with no rotation		
				[x,y] = meshgrid(linspace(-e3obj.radii(1),e3obj.radii(1),100),linspace(-e3obj.radii(2),e3obj.radii(2),100));
				z = e3obj.radii(3) *sqrt((1-(x.^2/e3obj.radii(1)^2 + y.^2/e3obj.radii(2).^2)));
				z(abs(imag(z))>1e-6) = NaN; % no imaginary points allowed
				% add points above and below in z
				x=[x(:);x(:)];
				y=[y(:);y(:)];
				z=[z(:);-z(:)];

				% Step 2, now rotate and translate
				pts = e3obj.rotation_forward() * [x(:)' ; y(:)' ; z(:)' ];
				pts = pts + e3obj.center;
				x = vlt.data.colvec(pts(1,:));
				y = vlt.data.colvec(pts(2,:));
				z = vlt.data.colvec(pts(3,:));
		end; % plotpoints()

		function h = plot(e3obj) 
			% PLOT - plot an ELLIPSOID3 object in the current axes
			%
			% H = PLOT(ELLIPSOID3OBJ)
			%
			% Plots the ELLIPSOID3OBJ in 3-D space using black circles. The graphics
			% handles are returned in H.
			%
				hold on;
				[xe,ye,ze] = e3obj.plotpoints();
				h = plot3(xe,ye,ze,'ko');
		end; % plot()

		function b = eq(e3obj1, e3obj2)
			% EQ - are two ELLIPSOID3 objects equal?
			%
			% B = EQ(ELLIPSOID3OBJ1, ELLIPSOID3OBJ2)
			%
			% Returns 1 if and only if the two objects have identical properites.
			%
				S1 = struct(e3obj1);
				S2 = struct(e3obj2);
				b = vlt.data.eqlen(S1,S2);
		end; % eq()

	end; % methods

	methods(Static)
		function [i,az,el] = vector_on_unrotated_ellipsoid(radii, pt1, pt2)
			% VECTOR_ON_UNROTATED_ELLIPSOID - find point of intersection of a vector on an ellipsoid (if any)
			%
			% [I,AZ,EL] = VECTOR_ON_UNROTATED_ELLIPSOID(RADII, PT1, PT2)
			%
			% Given an ellipsoid with no rotation defined at the origin with major, minor, tertiary, axes of
			% RADII (such as RADII = [a b c]), and given a vector that passes from PT1
			% to PT2, find the closest intersecting point to PT2 called I. If I does not exist, then 
			% I is NaN * ones(size(PT1)).
			%
			% AZ is the azimuth angle of the point I on the ellipse (rotation about the Z axis), in 
			% radians. Positive angles are clockwise.
			% 0 degrees is along the X axis.
			% EL is the elevation angle (angle above the XY plane) in radians.
			%

				V = pt2-pt1;
				S = pt1;

				A = sum( (V.^2)./radii(:).^2 );
				B = 2*sum(  (V.*S)./radii(:).^2);
				C = sum( (S.^2)./radii(:).^2) - 1;

				n2_1 = (-B+sqrt(B^2 - 4*A*C)) / (2*A);
				n2_2 = (-B-sqrt(B^2 - 4*A*C)) / (2*A);

				if imag(n2_2)==0 & imag(n2_1)==0,
					if abs(n2_1)<abs(n2_2),
						n2 = n2_1;
					else,
						n2 = n2_2;
					end;
				else,
					n2 = NaN;
				end;

				i = n2 * (pt2-pt1)+pt1;

				az = -atan2(i(2),i(1)); % negative to make positive angles clockwise
				el = atan2(i(3),sqrt(i(2)^2+i(1)^2));
		end; % vector_on_untorated_ellpsoid
	end;

end % class
				

