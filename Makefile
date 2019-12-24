
xyzzy::
	@echo Nothing happens...

clean::
	rm -f *.zip *.out delme*

clobber:: clean
	rm -f *.dsk

dist::	os32doc.zip os32src.zip os32kit.zip
	@for f in $^; do echo ; echo ===== $$f ===================== ; echo ; unzip -lv $$f; done

os32kit.zip: OS32 dsk4.dsk *.sim
	rm -f os32kit.zip
	zip -r9 os32kit OS32 ftpd.config *.sim dsk4.dsk "doc/Getting Started with Interdata OS32.pdf"

os32doc.zip: doc/*
	rm -f os32doc.zip
	zip -r9 os32doc doc/

os32src.zip: OS32 ftpd.config *.sim rebuild-system.sh make-sim.sh tapes/eou.tap
	rm -f os32src.zip
	zip -r9 os32src $^

dsk4.dsk:
	[ -x dsk4.dsk ] || ./rebuild-system.sh

