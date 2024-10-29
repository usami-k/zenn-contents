.PHONY: all
all: images_clean images

.PHONY: clean
clean: images_clean pdf_clean latex_clean

.PHONY: images
images: quaternion quaternion-image

%.pdf: %.tex
	latexmk $^

.PHONY: quaternion
quaternion: quaternion.pdf
	pdftocairo -png -r 1200 $^

%.pdf: %.typ
	typst compile $^

.PHONY: quaternion-image
quaternion-image: quaternion-image.pdf
	pdftocairo -png -r 1200 $^
	magick quaternion-image-1.png -trim +repage quaternion-image-1.png
	magick quaternion-image-1.png -bordercolor white -border 1500x0 quaternion-image-1.png
	magick quaternion-image-2.png -trim +repage quaternion-image-2.png
	magick quaternion-image-2.png -bordercolor white -border 1500x0 quaternion-image-2.png

.PHONY: images_clean
images_clean:
	rm -f *.png

.PHONY: latex_clean
latex_clean:
	latexmk -c

.PHONY: pdf_clean
pdf_clean:
	rm -f *.pdf
