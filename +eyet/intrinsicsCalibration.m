function intrinsics = intrinsicsCalibration(checkerboardPath, varargin)
% intrinsicsCalibration - compute the calibration of camera intrinsics from checkerboard images
%
% INTRINSICS = eyet.intrinsicsCalibration(CHECKERBOARDPATH)
%
% Compute Matlab Vision Toolbox intrinsic parameters, given a directory
% of files of photographs of a checkerboard image.
%
% This function calls OPENCV functions in Python. It is necessary to have a
% Python environment with opencv2 installed.
%
% This function takes name/value pairs that alter its default behavior.
% 
% ------------------------------------------------------------|
% | Parameter (default):   | Description                      |
% |------------------------|----------------------------------|
% | checkerRows (7)        | Rows of the checkerboard pattern |
% | checkerColumns (6)     | Number of columns of checkerboard|
% | useDistortion (1)      | 0/1 Should we use the distortion |
% |                        |   parameters?                    |
% |------------------------|----------------------------------|
%
% Example:
%   myfilepath = '/Users/myusername/calibirations/mycamera/';
%   intrinsics = eyet.intrinsicsCalibration(myfilepath);
%
 
checkerRows = 7;
checkerColumns = 6;
useDistortion = 1;

vlt.data.assign(varargin{:});

pyfile = fullfile(userpath,'tools','vhlab-eyetracking-matlab','+eyet','CameraCalibrationCommand.py');

[cameraMatrix, cameraDistortion, imageSize] = pyrunfile(pyfile, ["cameraMatrix" "cameraDistortion" "imageSize"], image_folder_path=checkerboardPath, rows=checkerRows, cols=checkerColumns);

cameraMatrix2 = double(cameraMatrix);
cameraDistortion2 = double(cameraDistortion);
imageSize2 = double(imageSize);

focalLength = [cameraMatrix2(1,1) cameraMatrix2(2,2)];
disp(focalLength * 4.98 / 720);
principalPoint = [cameraMatrix2(1,3) cameraMatrix2(2,3)];

focalLength = double(focalLength);
principalPoint = double(principalPoint);

if ~useDistortion,
	intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize2);
    disp(focalLength);
    disp(principalPoint);
    disp(imageSize2);       
else,
	intrinsics = cameraIntrinsicsFromOpenCV(cameraMatrix2, cameraDistortion2, imageSize2);
end;

