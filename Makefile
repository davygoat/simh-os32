
xyzzy::
	@echo Nothing happens...

clean::
	rm -f *.zip *.out delme*

clobber:: clean
	rm -f *.dsk

dist::	os32small.zip os32jumbo.zip

os32small.zip:	dm0.dsk
	rm -f os32small.zip
	zip -9 os32small os32.sh dm0.dsk

os32jumbo.zip:	dm0.dsk dm1.dsk
	rm -f os32jumbo.zip
	zip -9 os32jumbo *.tap dm0.dsk dm1.dsk rebuild-system.sh os32.sh

dm0.dsk dm1.dsk:
	[ -x dm0.dsk ] || ./rebuild-system.sh

