#!/bin/bash

# create a script that adds to git all files in ./Genus_Lab2/ and commits with the message "Lab2 [some way of the current time]" and then pushes

cd ~/Genus_Lab2
git add .
git commit -m "Lab2 $(date)"
git push
