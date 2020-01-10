
xyzzy::
	@echo Nothing happens...

clean::
	rm -f *.zip *.out delme* wop

clobber:: clean
	rm -f *.dsk

dist::	os32doc.zip os32src.zip os32kit.zip
	@for f in $^; do echo ; echo ===== $$f ===================== ; echo ; unzip -lv $$f; done

FTPDOC=Adding\ an\ FTP\ server\ to\ your\ SimH\ project

FILES=OS32-FTPd ftpd.config *.sim make-sim.sh

doc/${FTPDOC}.pdf: ${FTPDOC}.odt
	libreoffice6.2 --convert-to pdf ${FTPDOC}.odt
	mv ${FTPDOC}.pdf doc/

doc::	doc/$(FTPDOC).pdf

os32kit.zip: $(FILES) dsk4.dsk
	rm -f os32kit.zip
	zip -r9 os32kit $^ "doc/Getting Started with Interdata OS32.pdf" doc/${FTPDOC}.pdf

os32src.zip: $(FILES) rebuild-system.sh tapes/eou.tap wild.c* search.c* ftp.css
	rm -f os32src.zip
	zip -r9 os32src $^

os32doc.zip: doc/* doc/${FTPDOC}.pdf
	rm -f os32doc.zip
	zip -r9 os32doc doc/

dsk4.dsk:
	[ -x dsk4.dsk ] || ./rebuild-system.sh

