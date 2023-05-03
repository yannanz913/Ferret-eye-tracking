import cv2
import glob
import numpy as np
import glob

def calibration(image_folder_path, rows = 7, columns = 6):

    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

    rows = 7
    columns = 6
    world_scaling = 1.

    objp = np.zeros((rows*columns,3), np.float32)
    objp[:,:2] = np.mgrid[0:rows,0:columns].T.reshape(-1,2)
    objp = world_scaling* objp

    imgpoints = []

    objpoints = []

    images = glob.glob(image_folder_path + '/*.pgm')

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

#         cv2.imshow('Image', frame)
#         cv2.waitKey(1000)

    ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(objpoints, imgpoints, gray.shape[::-1], None, None)

    cameraMatrix = mtx
    cameraDistortion = dist
    imageSize = [image_size_x, image_size_y]

    return (cameraMatrix, cameraDistortion, imageSize)

cameraMatrix, cameraDistortion, imageSize = calibration(image_folder_path, rows, cols)