function [R,P] = find_camera_position_rotation(right, left)

% the equation we wish to solve:
R1*x + P1 == right;
R2*y + P2 == right;

R1*a + P1 == left;
R2*b + P2 == left;
