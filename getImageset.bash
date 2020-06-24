#!/bin/bash
# For AppIcon imagesets use: https://appicon.co/#app-icon
# The scripts accepts an arbitrary image type and produces pngs
image=$1

if [ -n "$image" ]; then
  
  if [ "$2" != "launch" ]; then
    # PLAIN IMAGE SET
    # Create directory for imageset
    DIR=$(echo $image | sed 's/\.[0-9A-z]\{1,5\}$//').imageset
    mkdir $DIR
    
    # Use magick to identify size and scale 2x and 3x
    width=$(magick identify $image | awk '{print $3}' | grep -o "^[0-9]\{1,\}")
    height=$(magick identify $image | awk '{print $3}' | grep -o "[0-9]\{1,\}$")

    convert $image -resize $(($width*2))x$(($height*2)) $DIR/$(echo $image | sed "s/\./@2x./; s/\.[0-9A-z]\{1,5\}$/.png/") 
    convert $image -resize $(($width*3))x$(($height*3)) $DIR/$(echo $image | sed "s/\./@3x./; s/\.[0-9A-z]\{1,5\}$/.png/")
    convert $image $DIR/$(echo $image | sed 's/\.[0-9A-z]\{1,5\}$/.png/')

    # Create the Contents.json file for the imageset
    echo "{
  \"images\" : [
    {
      \"filename\" : \"$image\",
      \"idiom\" : \"universal\",
      \"scale\" : \"1x\"
    },
    {
      \"filename\" : \"${image//.png/}@2x.png\",
      \"idiom\" : \"universal\",
      \"scale\" : \"2x\"
    },
    {
      \"filename\" : \"${image//.png/}@3x.png\",
      \"idiom\" : \"universal\",
      \"scale\" : \"3x\"
    }
  ],
  \"info\" : {
    \"author\" : \"xcode\",
    \"version\" : 1
  }
}" > $DIR/Contents.json
  
  else
    # LAUNCH IMAGE SET
    DIR=LaunchImage.launchimage
    mkdir $DIR
    convert $image -resize 1024x768 $DIR/Default1024x768.png   
    convert $image -resize 1125x2436 $DIR/Default1125x2436.png
    convert $image -resize 12424x2208 $DIR/Default1242x2208.png
    convert $image -resize 1536x2048 $DIR/Default1536x2048.png
    convert $image -resize 1920x1080 $DIR/Default1920x1080.png
    convert $image -resize 2048x1536 $DIR/Default2048x1536.png
    convert $image -resize 2208x1242 $DIR/Default2208x1242.png
    convert $image -resize 2436x1125 $DIR/Default2436x1125.png
    convert $image -resize 320x480 $DIR/Default320x480.png
    convert $image -resize 3840x2160 $DIR/Default3840x2160.png
    convert $image -resize 640x1136 $DIR/Default640x1136.png
    convert $image -resize 640x960 $DIR/Default640x960.png
    convert $image -resize 750x1334 $DIR/Default750x1334.png
    convert $image -resize 768x1024 $DIR/Default768x1024.png

    echo "{
  \"images\" : [
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default1125x2436.png\",
      \"idiom\" : \"iphone\",
      \"minimum-system-version\" : \"11.0\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"3x\",
      \"subtype\" : \"2436h\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default2436x1125.png\",
      \"idiom\" : \"iphone\",
      \"minimum-system-version\" : \"11.0\",
      \"orientation\" : \"landscape\",
      \"scale\" : \"3x\",
      \"subtype\" : \"2436h\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default3840x2160.png\",
      \"idiom\" : \"tv\",
      \"minimum-system-version\" : \"11.0\",
      \"orientation\" : \"landscape\",
      \"scale\" : \"2x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default1920x1080.png\",
      \"idiom\" : \"tv\",
      \"minimum-system-version\" : \"9.0\",
      \"orientation\" : \"landscape\",
      \"scale\" : \"1x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default1242x2208.png\",
      \"idiom\" : \"iphone\",
      \"minimum-system-version\" : \"8.0\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"3x\",
      \"subtype\" : \"736h\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default2208x1242.png\",
      \"idiom\" : \"iphone\",
      \"minimum-system-version\" : \"8.0\",
      \"orientation\" : \"landscape\",
      \"scale\" : \"3x\",
      \"subtype\" : \"736h\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default750x1334.png\",
      \"idiom\" : \"iphone\",
      \"minimum-system-version\" : \"8.0\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"2x\",
      \"subtype\" : \"667h\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default640x960.png\",
      \"idiom\" : \"iphone\",
      \"minimum-system-version\" : \"7.0\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"2x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default640x1136.png\",
      \"idiom\" : \"iphone\",
      \"minimum-system-version\" : \"7.0\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"2x\",
      \"subtype\" : \"retina4\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default768x1024.png\",
      \"idiom\" : \"ipad\",
      \"minimum-system-version\" : \"7.0\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"1x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default1024x768.png\",
      \"idiom\" : \"ipad\",
      \"minimum-system-version\" : \"7.0\",
      \"orientation\" : \"landscape\",
      \"scale\" : \"1x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default1536x2048.png\",
      \"idiom\" : \"ipad\",
      \"minimum-system-version\" : \"7.0\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"2x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default2048x1536.png\",
      \"idiom\" : \"ipad\",
      \"minimum-system-version\" : \"7.0\",
      \"orientation\" : \"landscape\",
      \"scale\" : \"2x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default320x480.png\",
      \"idiom\" : \"iphone\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"1x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default640x960.png\",
      \"idiom\" : \"iphone\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"2x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default640x1136.png\",
      \"idiom\" : \"iphone\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"2x\",
      \"subtype\" : \"retina4\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default768x1024.png\",
      \"idiom\" : \"ipad\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"1x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default1024x768.png\",
      \"idiom\" : \"ipad\",
      \"orientation\" : \"landscape\",
      \"scale\" : \"1x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default1536x2048.png\",
      \"idiom\" : \"ipad\",
      \"orientation\" : \"portrait\",
      \"scale\" : \"2x\"
    },
    {
      \"extent\" : \"full-screen\",
      \"filename\" : \"Default2048x1536.png\",
      \"idiom\" : \"ipad\",
      \"orientation\" : \"landscape\",
      \"scale\" : \"2x\"
    }
  ],
  \"info\" : {
    \"author\" : \"xcode\",
    \"version\" : 1
  }
}
" > $DIR/Contents.json

  fi
    

else 
    echo "No image provided"
fi
