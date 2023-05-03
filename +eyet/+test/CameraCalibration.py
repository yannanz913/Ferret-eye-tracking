import cv2
import glob
import numpy as np
import glob

criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

rows = 7
columns = 6
world_scaling = 1.

objp = np.zeros((rows*columns,3), np.float32)
objp[:,:2] = np.mgrid[0:rows,0:columns].T.reshape(-1,2)
objp = world_scaling* objp

imgpoints = []

objpoints = []

images = glob.glob('/Users/adrita/Documents/MATLAB/tools/vhlab-eyetracking-matlab/calibration_images/animalview_Lcam_cali/Used/*.pgm')

image_size_x = 0
image_size_y = 0

for img in images:

    frame = cv2.imread(img)

    image_size_x = frame.shape[0]
    image_size_y = frame.shape[1]

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    ret, corners = cv2.findChessboardCorners(gray, (rows, columns), None)

    if ret == True:

        conv_size = (11, 11)

        corners = cv2.cornerSubPix(gray, corners, conv_size, (-1, -1), criteria)
        cv2.drawChessboardCorners(frame, (rows,columns), corners, ret)

        objpoints.append(objp)
        imgpoints.append(corners)

    cv2.imshow('Image', frame)
    cv2.waitKey(1000)

ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(objpoints, imgpoints, gray.shape[::-1], None, None)

"""
The cameraMatrix is in the form:

fx    0     cx
0     fy    cy
0     0     1

fx and fy are the x and y focal lengths

cx and cy are the x and y coordinates of optical center in the image planes
"""

print("Focal Length:")
print("(" + str(mtx[0][0]) + ", " + str(mtx[1][1]) + ")")

print("Principal Point:")
print("(" + str(mtx[0][2]) + ", " + str(mtx[1][2]) + ")")

print("Image Size:")
print("(" + str(image_size_x) + ", " + str(image_size_y) + ")")