
xyzzy::
	@echo Nothing happens...

clean::
	rm -f *.zip *.out delme*

clobber:: clean
	rm -f *.dsk

dist::	os32doc.zip os32src.zip os32kit.zip os32tiny.zip
	@for f in $^; do echo ; echo ===== $$f ===================== ; echo ; unzip -lv $$f; done

os32kit.zip: os32.sh dm0.dsk
	rm -f os32kit.zip
	zip -r9 os32kit os32.sh dm0.dsk "doc/2016 - Getting Started with Interdata OS32.pdf"

os32doc.zip: doc/*
	rm -f os32doc.zip
	zip -r9 os32doc doc/

os32src.zip: dm0.dsk dm1.dsk
	rm -f os32src.zip
	zip -r9 os32src tapes/ rebuild-system.sh os32.sh Makefile

os32tiny.zip: os32.sh rebuild-system.sh tapes/eou.tap
	rm -f os32tiny.zip
	zip -r9 os32tiny $^

dm0.dsk dm1.dsk:
	[ -x dm0.dsk ] || ./rebuild-system.sh

