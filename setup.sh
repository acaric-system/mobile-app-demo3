#!/bin/sh
#
# mobile-app-demo1 setup script
#

usage() {
  echo "usage: $(basename $0) [-d <path>] [-w <URL>]"
  echo "  -d <path>    application directory"
  echo "  -g <number>  GCM project number for push notification"
  echo "  -w <URL>     hosted web-application URL"
}


## parameter settings
_BASE_DIR=$(cd $(dirname $0); pwd)
_APP_DIR=mobile-app-demo-1
_WEBAPP_URL='https://enterprise.acaric.com/MobileHelloWorld/'
_GCM_ID="123456"

while getopts "d:g:hw:" OPT
do
  case $OPT in
    d ) _APP_DIR="$OPTARG" ;;
    g ) _GCM_ID="$OPTARG" ;;
    w ) _WEBAPP_URL="$OPTARG" ;;
    h ) usage ; exit ;;
    * ) echo "Invalid option: -$OPT" ; usage ; exit 1 ;;
  esac
done

# check
if [ ¥command -v cordova >/dev/null 2>&1 ]; then
  echo '"cordova" command not found.'
  exit 1
fi
cd $_BASE_DIR
if [ -d $_APP_DIR -o -f $_APP_DIR ]; then
  echo "$_BASE_DIR/$_APP_DIR already exists."
  exit 1
fi

# confirm
echo " _APP_DIR = $_APP_DIR"
echo " _WEBAPP_URL = $_WEBAPP_URL"
echo " _GCM_ID = $_GCM_ID"
echo 'OK? (y/n) >'
read _ISOK
if [ "$_ISOK" != 'y' ]; then
 echo 'sure, setup exit.'
 exit 0
fi

# source setup
cordova create $_APP_DIR com.acaric.ios.AcaricOfficialApp1 HelloCordovaOSP
cd $_APP_DIR
cordova platform add ios --save
cordova platform add android --save
cordova plugin add cordova-plugin-device
cordova plugin add phonegap-plugin-push --variable SENDER_ID="$_GCM_ID"

mkdir res
mkdir res/android
mkdir res/ios
cd $_BASE_DIR
_WEBAPP_HREF=$(echo $_WEBAPP_URL | awk -F/ '{print $1}')'//'$(echo $_WEBAPP_URL | awk -F/ '{print $3}')
_FILES=$(find src -type f | cut -b5-)
for _FILE in $_FILES
do
  if [ $(grep -l '_WEBAPP_[URL_|HREF_]' src/$_FILE) ]; then
    sed -e "s*_WEBAPP_URL_*$_WEBAPP_URL*g" -e "s*_WEBAPP_HREF_*$_WEBAPP_HREF*g" -e "s*_GCM_ID_*$_GCM_ID*g" src/$_FILE > $_APP_DIR/$_FILE
  else
    cp src/$_FILE $_APP_DIR/$_FILE
  fi
done


echo ''
echo 'mobile-app-demo3 setup success! (^ - ^)'
