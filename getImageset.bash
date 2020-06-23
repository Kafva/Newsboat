#!/bin/bash

# Assumes png extension
image=$1

if [ -n "$image" ]; then
    
    # Create directory for imageset
    DIR=${image//.png/}.imageset
    mkdir $DIR
    
    # Use magick to identify size and scale 2x and 3x
    width=$(magick identify $image | awk '{print $3}' | grep -o "^[0-9]\{1,\}")
    height=$(magick identify $image | awk '{print $3}' | grep -o "[0-9]\{1,\}$")

    convert $image -resize $(($width*2))x$(($height*2)) $DIR/$(echo $image | sed "s/\./@2x./") 
    convert $image -resize $(($width*3))x$(($height*3)) $DIR/$(echo $image | sed "s/\./@3x./")
    cp $image $DIR

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
    echo "No image provided"
fi