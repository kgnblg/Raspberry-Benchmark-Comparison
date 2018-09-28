#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/pi/Desktop/phototaker.sh

sudo python /home/pi/Desktop/mot_det.py
sleep 2
sudo cp /home/pi/Desktop/5minupdates/imagesa.jpg /home/pi/Desktop/faceanalyze/face.jpg
sleep 2
sudo curl --form photo=@/home/pi/Desktop/5minupdates/imagesa.jpg "http://kaganbalga.com/bitirme/gateway.php?token=a&service=media&params=upload/1/0"

sleep 5
sudo rm /home/pi/Desktop/5minupdates/imagesa.jpg
%python kgnblg.py
sudo python /home/pi/Desktop/facerec_header.py
sleep 5

if [ -f /home/pi/Desktop/originalfaces/face.jpg ]
then

sudo curl --form photo=@/home/pi/Desktop/originalfaces/face.jpg "http://kaganbalga.com/bitirme/gateway.php?token=a&service=media&params=upload/1/1"
sleep 3
sudo rm /home/pi/Desktop/originalfaces/face.jpg

fi

sudo rm /home/pi/Desktop/faceanalyze/face.jpg
