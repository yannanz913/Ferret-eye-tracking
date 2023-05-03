"""
ExtractEyeInfo_MV.py

Uses opencv tools to find an eye and glints within a movie.
Contains three functions:
    main: the main function of the script. Opens a video and calls blob_process
    and crop_eye to determine eye/glint ellipse information and saves them. 
    Also shows new video with ellipses drawn on original video.
    
    blob_process: Takes a frame uses specified parameters to find blobs within
    the frame. minArea and maxArea are used to filter out blobs found using 
    cv2.SimpleBlobDetector.
    
    crop_eye: similar to blob_process, but a simpler function to find the eye
    and crop it from the frame to better process it in blob_process

"""
import cv2
import pandas as pd
import numpy as np

# Variable definitions (Change these values for filtering out blobs)
pupil_val = 83 # threshold value used for cv2.Threshold
pupil_min = 3000 # minArea
pupil_max = 20000 # maxArea

glint_val = 120 # threshold value used for cv2.Threshold
glint_min = 200 # minArea
glint_max = 700 # maxArea

eye_val = 120 # threshold value used for cv2.Threshold
eye_min = 10000 # minArea
eye_max = 200000 # maxArea

# Parameters for the pupil used by SimpleBlobDetector (Chnage params to better find blobs)
# ! I would suggest not changing area values unless absolutely necessary !
pupilparams = cv2.SimpleBlobDetector_Params()
pupilparams.filterByArea = True
pupilparams.maxArea = 40000 # Tried using from 300 - 3000 and can't get a detection
pupilparams.minArea = 3000
pupilparams.filterByCircularity = False
pupilparams.filterByColor = False
pupilparams.filterByConvexity = False
pupilparams.filterByInertia = True
pupilparams.minInertiaRatio = 0.5
pupildetector = cv2.SimpleBlobDetector_create(pupilparams)

# Parameters for the pupil used by SimpleBlobDetector (Chnage params to better find blobs)
# ! I would suggest not changing area values unless absolutely necessary !
glintparams = cv2.SimpleBlobDetector_Params()
glintparams.filterByArea = True
glintparams.maxArea = 1000 # Tried using from 300 - 3000 and can't get a detection
glintparams.minArea = 300
glintparams.filterByCircularity = False
glintparams.filterByColor = False
glintparams.filterByConvexity = False
glintparams.filterByInertia = False
glintdetector = cv2.SimpleBlobDetector_create(glintparams)



def blob_process(frame, threshold, minArea, maxArea, detector, color=(0,255,0), inv = 1):
    # Morphological image processing
    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    _, img = cv2.threshold(gray_frame, threshold, 255, cv2.THRESH_BINARY)
    img = cv2.erode(img, None, iterations=2)
    img = cv2.dilate(img, None, iterations=3)
    img = cv2.medianBlur(img, 9)
    if inv == 0: # Necessary to better find glints
        img = cv2.bitwise_not(img)
    # Find contours, then use SimpleBlobDetector object to find blobs
    contours, hierarchy = cv2.findContours(img, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
    keypoints = detector.detect(img)
    # Filter blobs and fit an ellipse around blob to approximate eye/glints
    ellipses = []
    for i,keypoint in enumerate(keypoints):
        keypoint_area = np.power((keypoints[i].size/2),2)*np.pi
        for j,contour in enumerate(contours):
            if cv2.contourArea(contour) > minArea and cv2.contourArea(contour) < maxArea and abs(keypoint_area - cv2.contourArea(contour)) < 700:
                ellipse = cv2.fitEllipse(contour)
                ellipses.append(ellipse)
                frame = cv2.ellipse(frame,ellipse,color,2)
    if not ellipses: # for when ellipses cannot be found
        ellipses = [((0,0),(0,0),0)]
            
    return frame,img,ellipses,keypoints 

def crop_eye(frame, threshold, minArea, maxArea):
    # Morphological Image Processing
    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    _, img = cv2.threshold(gray_frame, threshold, 255, cv2.THRESH_BINARY)
    img = cv2.erode(img, None, iterations=2)
    img = cv2.dilate(img, None, iterations=4)
    img = cv2.medianBlur(img, 5)
    # Find contours, then crop eye out from frame
    contours, hierarchy = cv2.findContours(img, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
    x = 0
    y = 0
    w = 0 
    h = 0
    center = (0,0)
    for i,contour in enumerate(contours):
        if cv2.contourArea(contour) > minArea and cv2.contourArea(contour) < maxArea:
            x,y,w,h = cv2.boundingRect(contour)
            frame = frame[y:y+h,x:x+w]
            center = (int(frame.shape[1]/2),int(frame.shape[0]/2))
            #img = cv2.rectangle(frame,(x,y),(x+w,y+h),(0,255,0),2)
    return x,y,w,h,center

def main():
    d = {}
    eye_center = []
    pupil_ellipses = []
    glint_ellipses = []
    """ CHANGE PATH TO VIDEO YOU WANT TO PROCESS """
    # Use first frame to determine cropped eye image dimensions
    cap = cv2.VideoCapture(" ")
    _, frame = cap.read()
    x1,y1,w1,h1,center1 = crop_eye(frame, eye_val, eye_min, eye_max)
    # While cap is opened, read and process frame
    while (cap.isOpened()):
        r, frame = cap.read()
        if r == True:
            # Find eye
            x,y,w,h,center = crop_eye(frame, eye_val, 10000, 200000)
            frame = frame[y1:y1+h1,x1:x1+w1] if x1 !=0 else frame
            
            # Find pupil and glints
            pupil_img,pupil_threshold,pupil_ellipse,pupil_keypoints = blob_process(frame, pupil_val, pupil_min, pupil_max, pupildetector,(0,255,0))
            glint_img,glint_threshold,glint_ellipse,_ = blob_process(pupil_img, glint_val, glint_min, glint_max,glintdetector, (0,0,255),0)
            glint_img = cv2.circle(glint_img,center, 5, (255,0,0), 2)
            
            # Save info
            eye_center.append(center)
            pupil_ellipses.append(pupil_ellipse)
            glint_ellipses.append(glint_ellipse)
            
            # Draw ellipses onto image
            cv2.imshow('Tracking', glint_img)
            cv2.imshow('pupil_threshold', pupil_threshold)
            cv2.imshow('glint_threshold', glint_threshold)
            
        else:
            break
    cap.release()
    cv2.destroyAllWindows()
    
    # Save info into a .pkl file
    d['Eye Center'] = eye_center
    d['Pupil Ellipses'] = pupil_ellipses
    d['Glint Ellipses'] = glint_ellipses
    df = pd.DataFrame(d)
    """ CHANGE NAME AND ADD .pkl TO END"""
    df.to_pickle("Qtcam-21_11_16_11_19_05.pkl")
   
if __name__ == "__main__":
    main()

