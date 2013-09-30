TARGET   = manual
SOURCES  = manual.tex
PICTURES = *.eps

#PDICT = paper.ispell
#SPELL = ispell -p $(PDICT)
PDICT = manual.aspell
SPELL = aspell -d en_US -t -p ./$(PDICT) -c

all: manual.pdf

dvi:
	latex manual && latex manual

manual.dvi: $(SOURCES)
	latex manual && latex manual

ps manual.ps: manual.dvi
	dvips -Ppdf -G0 manual

pdf manual.pdf: manual.dvi
	dvipdf manual

preview: dvi
	xdvi -expert -k -s 6 \
		-geometry 710x1050 \
		-xoffset 0.5cm \
		-yoffset 0.25cm \
		manual.dvi > /dev/null 2>&1 &

spell:
	$(SPELL) $(SOURCES)

$(PDICT):
	touch $(PDICT)

neat:
	rm -f manual.aux manual.log manual.bbl manual.blg \
	manual.toc *.bak *~

clean: neat
	rm -f manual.dvi manual.ps manual.pdf
