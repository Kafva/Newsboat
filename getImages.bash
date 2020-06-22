#!/bin/bash

image=$1

if [ -n "$image" ]; then
    
    mv $image ${image}.old

    # TODO
    # Use magick to identify size and scale 2x and 3x

    convert ${image}.old -resize 100x100 $(echo $image | sed "s/\./@2x./") 
    convert ${image}.old -resize 200x200 $(echo $image | sed "s/\./@3x./")
    convert ${image}.old -resize 300x300 $image

    rm ${image}.old

    # magick identify $image

else 
    echo "No image provided"
fi