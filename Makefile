
all::	os32.dsk

clean::
	rm -f *.zip *.out delme* wop pdf/*.pdf

clobber:: clean
	rm -f *.dsk

dist::	os32doc.zip os32kit.zip
	@for f in $^; do echo ; echo ===== $$f ===================== ; echo ; unzip -lv $$f; done

FTPDOC=Adding\ an\ FTP\ server\ to\ your\ SimH\ project
MANDOC=SimH\ OS32\ FTP\ Server\ User\ Guide
PRGDOC=Program\ Development\ under\ OS32
HLADOC=HLAL2\ High\ Level\ Assembler\ Language\ Macros

FILES=README.md README.txt OS32-FTPd os32.ini supnik.ini ftpd.config example.shadow.config *.sim *.tcl Makefile

v3:: v3/BIN/id32
	cp $< ./

v4:: v4/BIN/id32
	cp $< ./

v3/BIN/id32:
	rm -rf v3
	wget http://simh.trailing-edge.com/sources/simhv312-2.zip
	unzip simhv312-2.zip
	mv sim v3
	cd v3 ; make id32

v4/BIN/id32:
	rm -rf v4
	git clone https://github.com/simh/simh
	mv simh v4
	cd v4 ; make id32

os32kit.zip: $(FILES) os32.dsk doc
	rm -f os32kit.zip
	zip -r9 os32kit $(FILES) os32.dsk pdf/2020\ -\ $(FTPDOC).pdf

os32doc.zip: doc
	rm -f os32doc.zip
	zip -r9 os32doc pdf/ -x pdf/2020\ -\ $(FTPDOC).pdf

os32.dsk: stage-??-*.ini
	[ -x os32.dsk ] || ./rebuild-system.sh

############################################################################################################################

doc::	pdf/1974\ -\ 32\ Bit\ Series\ Reference\ Manual.pdf                                                                \
	pdf/1975\ -\ FORTRAN\ V\ Level\ II\ Compiler\ Functional\ Spec.pdf                                                 \
	pdf/1976\ -\ Model\ 832\ Micro-Instruction\ Reference\ Manual.pdf                                                  \
	pdf/1976\ -\ OS32\ MT\ Program\ Logic\ Manual.pdf                                                                  \
	pdf/1976\ -\ OS32\ MT\ Program\ Reference\ Manual.pdf                                                              \
	pdf/1982\ -\ Pascal\ User\ Guide,\ Language\ Reference,\ and\ Run\ Time\ Support.pdf                               \
	pdf/1982\ -\ System\ Mathematical\ Run\ Time\ Library\ Reference\ Manual.pdf                                       \
	pdf/1982\ -\ Utilisation\ of\ Perkin-Elmer\ Operating\ System\ Features\ to\ Optimise\ Programming\ Efficiency.pdf \
	pdf/1984\ -\ C\ Programming\ Manual.pdf                                                                            \
	pdf/1984\ -\ OS32\ Network\ Drivers\ Programming\ Reference\ Manual.pdf                                            \
	pdf/1984\ -\ OS32\ Operations\ Primer.pdf                                                                          \
	pdf/1984\ -\ OS32\ System\ Generation\ [SYSGEN32]\ Reference\ Manual.pdf                                           \
	pdf/1984\ -\ OS32\ System\ Support\ Run-Time\ Library\ Reference\ Manual.pdf                                       \
	pdf/1984\ -\ OS32\ System\ Support\ Utilities.pdf                                                                  \
	pdf/1985\ -\ OS32\ Driver\ Writers\ Guide.pdf                                                                      \
	pdf/1985\ -\ OS32\ MTM\ Installation.pdf                                                                           \
	pdf/1985\ -\ OS32\ Operator\ Reference\ Manual.pdf                                                                 \
	pdf/1985\ -\ OS32\ v8.1\ Internals\ Student\ Guide.pdf                                                             \
	pdf/1985\ -\ OS32\ v8.1\ Software\ Installation\ Guide.pdf                                                         \
	pdf/1985\ -\ $(HLADOC).pdf                                                                                         \
	pdf/2016\ -\ Getting\ Started\ with\ Interdata\ OS32.pdf                                                           \
	pdf/2020\ -\ Adding\ an\ FTP\ server\ to\ your\ SimH\ project.pdf

pdf/2020\ -\ $(FTPDOC).pdf: doc/$(FTPDOC).odt
	rm -f "$@"
	libreoffice6.2 --convert-to pdf doc/$(FTPDOC).odt
	mv $(FTPDOC).pdf pdf/2020\ -\ $(FTPDOC).pdf

pdf/1985\ -\ $(HLADOC).pdf: doc/$(HLADOC).odt bookmarks/$(HLADOC).txt
	rm -f "$@"
	libreoffice6.2 --convert-to pdf doc/$(HLADOC).odt
	-jpdfbookmarks --apply bookmarks/$(HLADOC).txt $(HLADOC).pdf --out "$@"
	rm $(HLADOC).pdf

pdf/1974\ -\ 32\ Bit\ Series\ Reference\ Manual.pdf: \
			bookmarks/32\ Bit\ Series\ Reference\ Manual.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/29-365R01_32BitRefMan_Jun74.pdf
	-jpdfbookmarks --apply "$^" 29-365R01_32BitRefMan_Jun74.pdf --out "$@"
	rm 29-365R01_32BitRefMan_Jun74.pdf

pdf/1976\ -\ Model\ 832\ Micro-Instruction\ Reference\ Manual.pdf: \
			bookmarks/Model\ 832\ Micro-Instruction\ Reference\ Manual.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/8-32/29-438R01_8-32_Micro-Instruction_Reference_Manual_May76.pdf
	-jpdfbookmarks --apply "$^" 29-438R01_8-32_Micro-Instruction_Reference_Manual_May76.pdf --out "$@"
	rm 29-438R01_8-32_Micro-Instruction_Reference_Manual_May76.pdf

pdf/1976\ -\ OS32\ MT\ Program\ Logic\ Manual.pdf: \
			bookmarks/OS32\ MT\ Program\ Logic\ Manual.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/2.0_Nov76/B29-391R02_OS32MT_ProgramLogic_Apr76.pdf
	-jpdfbookmarks --apply "$^" B29-391R02_OS32MT_ProgramLogic_Apr76.pdf --out "$@"
	rm B29-391R02_OS32MT_ProgramLogic_Apr76.pdf

pdf/1976\ -\ OS32\ MT\ Program\ Reference\ Manual.pdf: \
			bookmarks/OS32\ MT\ Program\ Reference\ Manual.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/2.0_Nov76/29-390R05_OS32MT_PgmRef_Nov76.pdf
	-jpdfbookmarks --apply "$^" 29-390R05_OS32MT_PgmRef_Nov76.pdf --out "$@"
	rm 29-390R05_OS32MT_PgmRef_Nov76.pdf

pdf/1984\ -\ C\ Programming\ Manual.pdf: \
			bookmarks/C\ Programming\ Manual.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/lang/48-103F00R00_C_PgmgRef_1984.pdf
	-jpdfbookmarks --apply "$^" 48-103F00R00_C_PgmgRef_1984.pdf --out "$@"
	rm 48-103F00R00_C_PgmgRef_1984.pdf

pdf/1975\ -\ FORTRAN\ V\ Level\ II\ Compiler\ Functional\ Spec.pdf: \
			bookmarks/FORTRAN\ V\ Level\ II\ Compiler\ Functional\ Spec.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/lang/FORTRAN_V_Level_II_Compiler_Functional_Spec_Jan75.pdf
	-jpdfbookmarks --apply "$^" FORTRAN_V_Level_II_Compiler_Functional_Spec_Jan75.pdf --out "$@"
	rm FORTRAN_V_Level_II_Compiler_Functional_Spec_Jan75.pdf


pdf/1982\ -\ Pascal\ User\ Guide,\ Language\ Reference,\ and\ Run\ Time\ Support.pdf: \
			bookmarks/Pascal\ User\ Guide,\ Language\ Reference,\ and\ Run\ Time\ Support.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/lang/48-021R01_Pascal_May82.pdf
	-jpdfbookmarks --apply "$^" 48-021R01_Pascal_May82.pdf --out "$@"
	rm 48-021R01_Pascal_May82.pdf

pdf/1985\ -\ OS32\ MTM\ Installation.pdf: \
			bookmarks/OS32\ MTM\ Installation.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/8.1.0_1985/04-083M95R10_OS32_MTM_Installation_May85.pdf
	-jpdfbookmarks --apply "$^" 04-083M95R10_OS32_MTM_Installation_May85.pdf --out "$@"
	rm 04-083M95R10_OS32_MTM_Installation_May85.pdf

pdf/1984\ -\ OS32\ Operations\ Primer.pdf: \
			bookmarks/OS32\ Operations\ Primer.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/7.2_1984/48-076F00R00_OS32OperationsPrimer_1984.pdf
	-jpdfbookmarks --apply "$^" 48-076F00R00_OS32OperationsPrimer_1984.pdf --out "$@"
	rm 48-076F00R00_OS32OperationsPrimer_1984.pdf

pdf/1985\ -\ OS32\ Operator\ Reference\ Manual.pdf: \
			bookmarks/OS32\ Operator\ Reference\ Manual.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/8.1.0_1985/48-030F00R03_8.1_Operator_1985.pdf
	-jpdfbookmarks --apply "$^" 48-030F00R03_8.1_Operator_1985.pdf --out "$@"
	rm 48-030F00R03_8.1_Operator_1985.pdf

pdf/1984\ -\ OS32\ Network\ Drivers\ Programming\ Reference\ Manual.pdf: \
			bookmarks/OS32\ Network\ Drivers\ Programming\ Reference\ Manual.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/7.2_1984/48-079F00R00_OS32_NetworkDrivers_1984.pdf
	-jpdfbookmarks --apply "$^" 48-079F00R00_OS32_NetworkDrivers_1984.pdf --out "$@"
	rm 48-079F00R00_OS32_NetworkDrivers_1984.pdf

pdf/1984\ -\ OS32\ System\ Generation\ [SYSGEN32]\ Reference\ Manual.pdf: \
			bookmarks/OS32\ System\ Generation\ [SYSGEN32]\ Reference\ Manual.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/7.2_1984/48-037F00R02_SYSGEN32_7.2_1984.pdf
	-jpdfbookmarks --apply "$^" 48-037F00R02_SYSGEN32_7.2_1984.pdf --out "$@"
	rm 48-037F00R02_SYSGEN32_7.2_1984.pdf

pdf/1984\ -\ OS32\ System\ Support\ Utilities.pdf: \
			bookmarks/OS32\ System\ Support\ Utilities.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/7.2_1984/48-031F00R02_SysSupportUtil_1984.pdf
	-jpdfbookmarks --apply "$^" 48-031F00R02_SysSupportUtil_1984.pdf --out "$@"
	rm 48-031F00R02_SysSupportUtil_1984.pdf

pdf/1985\ -\ OS32\ Driver\ Writers\ Guide.pdf: \
			bookmarks/OS32\ Driver\ Writers\ Guide.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/8.1.0_1985/48-190f00r00_DriverWritersGuide.pdf
	-jpdfbookmarks --apply "$^" 48-190f00r00_DriverWritersGuide.pdf --out "$@"
	rm 48-190f00r00_DriverWritersGuide.pdf

pdf/1984\ -\ OS32\ System\ Support\ Run-Time\ Library\ Reference\ Manual.pdf: \
			bookmarks/OS32\ System\ Support\ Run-Time\ Library\ Reference\ Manual.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/7.2_1984/48-152F00R00_SystemSupportRTL_1984.pdf
	-jpdfbookmarks --apply "$^" 48-152F00R00_SystemSupportRTL_1984.pdf --out "$@"
	rm 48-152F00R00_SystemSupportRTL_1984.pdf

pdf/1985\ -\ OS32\ v8.1\ Software\ Installation\ Guide.pdf: \
			bookmarks/OS32\ v8.1\ Software\ Installation\ Guide.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/8.1.0_1985/04-082M95R16_OS32v8.1Installation_May85.pdf
	-jpdfbookmarks --apply "$^" 04-082M95R16_OS32v8.1Installation_May85.pdf --out "$@"
	rm 04-082M95R16_OS32v8.1Installation_May85.pdf

pdf/1985\ -\ OS32\ v8.1\ Internals\ Student\ Guide.pdf: \
			bookmarks/OS32\ v8.1\ Internals\ Student\ Guide.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/8.1.0_1985/OS32v8.1_Internals_Aug85.pdf
	-jpdfbookmarks --apply "$^" OS32v8.1_Internals_Aug85.pdf --out "$@"
	rm OS32v8.1_Internals_Aug85.pdf

pdf/1982\ -\ System\ Mathematical\ Run\ Time\ Library\ Reference\ Manual.pdf: \
			bookmarks/System\ Mathematical\ Run\ Time\ Library\ Reference\ Manual.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/pdf/interdata/32bit/os32/lang/48-025F00R00_MathRTL_1982.pdf
	-jpdfbookmarks --apply "$^" 48-025F00R00_MathRTL_1982.pdf --out "$@"
	rm 48-025F00R00_MathRTL_1982.pdf

pdf/1982\ -\ Utilisation\ of\ Perkin-Elmer\ Operating\ System\ Features\ to\ Optimise\ Programming\ Efficiency.pdf: \
			bookmarks/Utilisation\ of\ Perkin-Elmer\ Operating\ System\ Features\ to\ Optimise\ Programming\ Efficiency.txt
	rm -f "$@"
	mkdir -p pdf/
	wget "http://eprints.whiterose.ac.uk/76197/1/report 180.pdf"
	-jpdfbookmarks --apply "$^" report\ 180.pdf --out "$@"
	rm report\ 180.pdf

pdf/2016\ -\ Getting\ Started\ with\ Interdata\ OS32.pdf: \
			bookmarks/Getting\ Started\ with\ Interdata\ OS32.txt
	rm -f "$@"
	mkdir -p pdf/
	wget http://bitsavers.org/bits/Interdata/32bit/os32/getting_started_with_os32.zip
	unzip -o getting_started_with_os32.zip
	-jpdfbookmarks --apply "$^" os32/simh-id32-os32.pdf --out "$@"
	rm -rf getting_started_with_os32.zip os32/

