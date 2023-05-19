all: usami_automaton_images

usami_automaton_images: usami_automaton_image.pdf
	pdftocairo -png -r 1200 $^

%.pdf: %.tex
	latexmk $^

clean:
	latexmk -C

