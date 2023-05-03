function [L_1 L_2] = find_lightsources(C, xy_pt11, xy_pt12, xy_pt21, xy_pt22, radii, marble_center,rotation)
% FIND_LIGHTSOURCES searches for IR sources positions, given the camera locations, 
% the parameters of the calibration object, and the pixel locations of the glints on the two images
%
% Inputs:
% C - camera locations
% xy_pt - coordinates of glints on the image
% radii - the marble radii [a;b;c]
% marble_center - the origin of the marble
% rotation - The rotation of the marble about the x, y, and z axes
%
% Example:
%
% radii = [0.16; 0.16; 0.16];
% marble_center = [0.17; 0.82; 0];
% rotation = [0; 0; 0];
%
% xy_pt11 = [481.1912  303.6095];
% xy_pt12 = [502.4401  305.0328];
% xy_pt21 = [676.6336  239.8139]; 
% xy_pt22 = [693.5184  238.2372];
% 
% [L_1 L_2] = eyet.fit.find_lightsources(C, xy_pt11, xy_pt12, xy_pt21, xy_pt22, radii, marble_center,rotation);
% 
% lego sphere:
% radii = [1.57/2; 1.57/2; 1.57/2];

% step0: convert xy image coordinates to world pixel coordinates
pixel_pt11 = squeeze(C(1).pixel_array_pt(int16(xy_pt11(1)),int16(xy_pt11(2)),:));
pixel_pt12 = squeeze(C(1).pixel_array_pt(int16(xy_pt12(1)),int16(xy_pt12(2)),:));
pixel_pt21 = squeeze(C(2).pixel_array_pt(int16(xy_pt21(1)),int16(xy_pt21(2)),:));
pixel_pt22 = squeeze(C(2).pixel_array_pt(int16(xy_pt22(1)),int16(xy_pt22(2)),:));

% step1: establish the marble as an ellipsoid object
marble = eyet.math.ellipsoid3(radii,marble_center,rotation);

% step2: find the 3-d intersection point on the ellipsoid
nodal_pt1 = C(1).nodal_pt;
nodal_pt2 = C(2).nodal_pt;

v_in_11 = nodal_pt1 - pixel_pt11;
v_in_12 = nodal_pt1 - pixel_pt12;
v_in_21 = nodal_pt2 - pixel_pt21;
v_in_22 = nodal_pt2 - pixel_pt22;

         % sv: the inputs to vector_on_ellipsoid were the pext points
         % the function vector_on_ellipsoid finds the closest point on the
         % ellipse to the first input argument, so it was doing the right
         % thing by finding the points on the other side of the marble
         % the 15 cm extension was going through the marble
         % we should use pext for plotting only
[i_11,az_11,el_11] = marble.vector_on_ellipsoid(pixel_pt11,nodal_pt1); % left glint in C(1)
[i_12,az_12,el_12] = marble.vector_on_ellipsoid(pixel_pt12,nodal_pt1); % right glint in C(1)
[i_21,az_21,el_21] = marble.vector_on_ellipsoid(pixel_pt21,nodal_pt2); % left glint in C(2)
[i_22,az_22,el_22] = marble.vector_on_ellipsoid(pixel_pt22,nodal_pt2); % right glint in C(2)  

% step3: determine a reflecting vector off the ellipsoid
v_out_11 = marble.ellipsoid_bounce_vector(i_11, -v_in_11);
v_out_12 = marble.ellipsoid_bounce_vector(i_12, -v_in_12);
v_out_21 = marble.ellipsoid_bounce_vector(i_21, -v_in_21);
v_out_22 = marble.ellipsoid_bounce_vector(i_22, -v_in_22);

% step4: solve for the IR positions

% i_11 + d_11 * v_out_11 = i_12 + d_12 * v_out_12
% i_21 + d_21 * v_out_21 = i_22 + d_22 * v_out_22

% d_11 * v_out_11 - d_12 * v_out_12 = i_12 - i_11;
A = [v_out_11 -v_out_12];
b = i_12 - i_11;
X = linsolve(A,b);
d_11 = X(1);
d_12 = X(2);

% d_21 * v_out_21 - d_22 * v_out_22 = i_22 - i_21;
A_2 = [v_out_21 -v_out_22];
b_2 = i_22 - i_21;
X_2 = linsolve(A_2,b_2);
d_21 = X_2(1);
d_22 = X_2(2);

L_1 = i_11 + d_11 * v_out_11;
L_2 = i_21 + d_21 * v_out_21;


%% plot to test
% plot marble and reflection route

[xe,ye,ze] = marble.plotpoints();

figure;
h = plot3(xe,ye,ze,'ko');
hold on;
plot(C(1));
plot(C(2));

 % plot lines from camera pixels to each glint

% Extend the ray for plotting
factor_distance = 15;
pext_11 = pixel_pt11 + v_in_11*factor_distance;
pext_12 = pixel_pt12 + v_in_12*factor_distance;
pext_21 = pixel_pt21 + v_in_21*factor_distance;
pext_22 = pixel_pt22 + v_in_22*factor_distance;

plot3([pixel_pt11(1),pext_11(1)],[pixel_pt11(2),pext_11(2)],[pixel_pt11(3),pext_11(3)],'b-');
plot3([pixel_pt12(1),pext_12(1)],[pixel_pt12(2),pext_12(2)],[pixel_pt12(3),pext_12(3)],'g-');
plot3([pixel_pt21(1),pext_21(1)],[pixel_pt21(2),pext_21(2)],[pixel_pt21(3),pext_21(3)],'b--');
plot3([pixel_pt22(1),pext_22(1)],[pixel_pt22(2),pext_22(2)],[pixel_pt22(3),pext_22(3)],'g--');


h_obj = eyet.plot.calibration_obj2();
% h_obj = eyet.plot.calibration_obj();

h1 = plot3(L_1(1),L_1(2),L_1(3),'ro', 'MarkerSize', 10);
h2 = plot3(L_2(1),L_2(2),L_2(3),'go', 'MarkerSize', 10);


% plot intersection points

plot3([i_11(1)],[i_11(2)],[i_11(3)],'yx','MarkerSize',10);
plot3([i_12(1)],[i_12(2)],[i_12(3)],'yx','MarkerSize',10);
plot3([i_21(1)],[i_21(2)],[i_21(3)],'yx','MarkerSize',10);
plot3([i_22(1)],[i_22(2)],[i_22(3)],'yx','MarkerSize',10);

pout_11 = i_11 + v_out_11*factor_distance;
pout_12 = i_12 + v_out_12*factor_distance;
pout_21 = i_21 + v_out_21*factor_distance;
pout_22 = i_22 + v_out_22*factor_distance;
plot3([i_11(1),pout_11(1)],[i_11(2),pout_11(2)],[i_11(3),pout_11(3)],'b-','LineWidth',2);
plot3([i_12(1),pout_12(1)],[i_12(2),pout_12(2)],[i_12(3),pout_12(3)],'g-','LineWidth',2);
plot3([i_21(1),pout_21(1)],[i_21(2),pout_21(2)],[i_21(3),pout_21(3)],'b--','LineWidth',2);
plot3([i_22(1),pout_22(1)],[i_22(2),pout_22(2)],[i_22(3),pout_22(3)],'g--','LineWidth',2);



