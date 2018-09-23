#!/usr/bin/python
# facerec.py
import cv2, sys, numpy, os
size = 1
fn_haar = '/home/pi/Desktop/haarcascade_frontalface_default.xml'
fn_dir = '/home/pi/Desktop/att_faces'

# Part 1: Create fisherRecognizer
print('Training...')

# Create a list of images and a list of corresponding names
(images, lables, names, id) = ([], [], {}, 0)

# Get the folders containing the training data
for (subdirs, dirs, files) in os.walk(fn_dir):

    # Loop through each folder named after the subject in the photos
    for subdir in dirs:
        names[id] = subdir
        subjectpath = os.path.join(fn_dir, subdir)

        # Loop through each photo in the folder
        for filename in os.listdir(subjectpath):

            # Skip non-image formates
            f_name, f_extension = os.path.splitext(filename)
            if(f_extension.lower() not in
                    ['.png','.jpg','.jpeg','.gif','.pgm']):
                print("Skipping "+filename+", wrong file type")
                continue
            path = subjectpath + '/' + filename
            lable = id

            # Add to training data
            images.append(cv2.imread(path, 0))
            lables.append(int(lable))
        id += 1
(im_width, im_height) = (112, 92)

# Create a Numpy array from the two lists above
(images, lables) = [numpy.array(lis) for lis in [images, lables]]

# OpenCV trains a model from the images
# NOTE FOR OpenCV2: remove '.face'
model = cv2.createFisherFaceRecognizer()
model.train(images, lables)

image = cv2.imread("/home/pi/Desktop/faceanalyze/face.jpg")
haar_cascade = cv2.CascadeClassifier(fn_haar)

#frame = cv2.flip(image,1,0)
frame = image
gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
mini = cv2.resize(gray, (int(gray.shape[1] / size), int(gray.shape[0] / size)))
flag = False

faces = haar_cascade.detectMultiScale(mini)
for i in range(len(faces)):
	face_i = faces[i]
	
	(x,y,w,h) = [v * size for v in face_i]
	face = gray[y:y + h, x:x + w]
	face_resize = cv2.resize(face, (im_width, im_height))

	prediction = model.predict(face_resize)
	cv2.rectangle(frame, (x,y), (x + w, y + h), (0, 255, 0), 3)
	
	if prediction[1]<800:
		flag = True
		cv2.putText(frame,
		'%s - %.0f' % (names[prediction[0]],prediction[1]),
		(x-10, y-10), cv2.FONT_HERSHEY_PLAIN,1,(0, 255, 0))
	else:
		flag = True
		cv2.putText(frame,
		'Bilinmeyen',
		(x-10, y-10), cv2.FONT_HERSHEY_PLAIN,1,(0, 255, 0))

if flag is True:
	cv2.imwrite('/home/pi/Desktop/originalfaces/face.jpg', frame)
else:
	print "Face not found"
