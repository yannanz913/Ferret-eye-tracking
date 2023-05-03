function landmarks = findImagePoints(im)
%FINDIMAGEPOINTS Summary of this function goes here
%   Detailed explanation goes here
    % Example:
    % im = imread('Users/adrita/Documents/MATLAB/tools/vhlab-eyetracking-matlab/calibration_images/left_cam_0711_.png');
    
    image(im)
    landmarks = ginput % press RETURN when you're done clicking
    
end

