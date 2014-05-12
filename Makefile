LTX=report.ltx
LTXMAIN=$(basename $(LTX))
PDF=$(subst .ltx,.pdf,$(LTX))
TEX=$(subst .ltx,.tex,$(LTX))
LOG=$(subst .ltx,.log,$(LTX))
BIB=latex-base/refs.bib

default : $(PDF)

# Skim on OS X, zathura elsewhere.
preview : $(PDF)
	@if [ `uname` = 'Darwin' ]; then \
	  open -a /Applications/Skim.app $(PDF); \
	else \
	  zathura $(PDF); \
	fi

$(TEX) : $(LTX)
	lhs2tex $(LTX) > $(TEX)

# Stolen from Stefan Holdermans:
# http://www.cs.uu.nl/foswiki/pub/Apa/CourseSoftware/typeandeffect-latex-base.zip
$(PDF) : $(TEX) $(BIB)
	pdflatex -halt-on-error $(TEX)
	biber $(LTXMAIN)
	pdflatex -halt-on-error $(TEX)
	sh -c ' \
	  i=1; \
	  while [ $$i -lt 5 ] && ( \
	    grep -c "Rerun" $(LOG) \
	    || grep -c "undefined citations" $(LOG) \
	    || grep -c "undefined references" $(LOG) ); \
	  do pdflatex -halt-on-error $(TEX); \
	     i=`expr $$i + 1`; \
	     done; \
          echo "Iterations: $$i"'

clean :
	rm -f *.aux *.log *.nav *.out *.ptb *.toc *.snm $(PDF) $(TEX) *.synctex.gz *.bbl *.blg
