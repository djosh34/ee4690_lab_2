#!/bin/bash

# git add .
# git commit -m "Report update of $(date)"
# git push
# tectonic -X compile main.tex --synctex --keep-logs --keep-intermediates --reruns 0

pdflatex -interaction=nonstopmode main.tex -synctex=1
biber main
pdflatex -interaction=nonstopmode main.tex -synctex=1


