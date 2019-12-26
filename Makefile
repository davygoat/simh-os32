
xyzzy::
	@echo Nothing happens...

clean::
	rm -f *.zip *.out delme* wot wop

clobber:: clean
	rm -f *.dsk

dist::	os32doc.zip os32src.zip os32kit.zip
	@for f in $^; do echo ; echo ===== $$f ===================== ; echo ; unzip -lv $$f; done

os32doc.zip: doc/*
	rm -f os32doc.zip
	zip -r9 os32doc doc/

FILES=OS32-FTPd ftpd.config *.sim make-sim.sh

os32kit.zip: $(FILES) dsk4.dsk
	rm -f os32kit.zip
	zip -r9 os32kit $^ "doc/Getting Started with Interdata OS32.pdf"

os32src.zip: $(FILES) rebuild-system.sh tapes/eou.tap wild.c* search.c* ftp.css
	rm -f os32src.zip
	zip -r9 os32src $^

dsk4.dsk:
	[ -x dsk4.dsk ] || ./rebuild-system.sh

