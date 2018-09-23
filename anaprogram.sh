#!/bin/bash
PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/pi/Desktop/pysamp/env

deger=1

while [ $deger -lt 2 ]
do
sleep 2
sudo espeak -v tr "Cingöz sizi dinliyor. Lütfen dört saniye içinde komut verin." &> /dev/null

sudo arecord -D plughw:1,0 -q -t wav -d 4 -f S16_LE -r 16000 /home/pi/Desktop/konusma.wav
rmslev=$(sudo sox /home/pi/Desktop/konusma.wav -n stats 2>&1 | grep 'RMS lev dB' | awk '{print $4}')
rmspk=$(sudo sox /home/pi/Desktop/konusma.wav -n stats 2>&1 | grep 'RMS Pk dB' | awk '{print $4}')

if [[ $(echo "$rmslev > -35" | bc) -eq 1 && $(echo "$rmspk > -35" | bc) -eq 1 ]]
then
  sudo espeak -v tr "Konuşma algılandı analiz ediliyor lütfen bekleyin" &> /dev/null
else
  sudo espeak -v tr "Konuşma algılanamadı lütfen tekrar deneyin" &> /dev/null
  sudo rm /home/pi/Desktop/konusma.wav
fi

if [ -f /home/pi/Desktop/konusma.wav ]
then
  sudo sox /home/pi/Desktop/konusma.wav --bits 16 kon.raw
  sudo rm /home/pi/Desktop/konusma.wav
 
  source /home/pi/Desktop/pysamp/env/bin/activate
  analiz=$(sudo /home/pi/Desktop/pysamp/env/bin/python /home/pi/Desktop/pysamp/transcribe.py /home/pi/Desktop/kon.raw)
  if [ ! -z "$analiz" ]
  then
    sudo espeak -v tr "Analiz edilen $analiz" &> /dev/null
    if [[ "$analiz" == "Kimsin" || "$analiz" == "kimsin" ]]
    then
      sudo espeak -v tr "Selçuk üniversitesi teknoloji fakültesi bilgisayar mühendisliği bölümünde" &> /dev/null
      sudo espeak -v tr "profesör doktor fatih başçiftçi danışmanlığında" &> /dev/null
      sudo espeak -v tr "mevlüt kağan balga tarafından geliştirilmiş bir projeyim" &> /dev/null
    fi
    if [[ "$analiz" == "Panik" || "$analiz" == "panik" ]]
    then
      sudo espeak -v tr "Panik kaydı alındı web servisine bildiriliyor." &> /dev/null
    fi
    bosluksil=${analiz//[[:blank:]]/}
    bosluksill=$(echo $bosluksil | tr "[:upper:]" "[:lower:]")
    if [[ "$bosluksill" == "oynatzekimüren" ]]
    then
      sudo aplay /home/pi/Desktop/playlist/zekimuren.wav &> /dev/null
    fi
    if [[ "$bosluksill" == "enbüyükkim" ]]
    then
      sudo espeak -v tr "En büyük tabiki de fenerbahçe" &> /dev/null
      sudo aplay /home/pi/Desktop/playlist/fenermars.wav &> /dev/null
    fi
    sudo espeak -v tr "Analiz veb servisine kaydediliyor." &> /dev/null
    bosluksuzkaydet=${analiz//[[:blank:]]/}
    sudo curl "http://kaganbalga.com/bitirme/gateway.php?token=a&service=media&params=getcommand/1/$bosluksuzkaydet" 
  else
    sudo espeak -v tr "Analiz tamamlandı ancak bir sonuç bulunamadı." &> /dev/null
  fi

sudo rm /home/pi/Desktop/kon.raw
fi

sleep 5
done
