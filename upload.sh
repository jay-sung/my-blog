#! /bin/sh

if [ -z "$1" ];
then 
    echo "Error: required commit message"
    exit 1
fi

git add .
git commit -m "$1"
git push