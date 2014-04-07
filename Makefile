sampleInputDir=docs/hw5/sample_input/
sampleOutputDir=docs/hw5/expected_output/

sampleInputFiles=$(wildcard $(sampleInputDir)/*.txt)
sampleOutputFiles=$(wildcard $(sampleOutputDir)/*.out)

buildFiles=$(addprefix build/, $(notdir $(sampleOutputFiles)))
diffFiles=$(addsuffix .diff,$(basename $(buildFiles)))

diff=/usr/bin/diff --ignore-space-change --side-by-side --ignore-case --ignore-blank-lines --suppress-common-lines

all: main

main: mfpl_parser

lex.tab.c:
	bison mfpl.y
	lex mfpl.l

mfpl_parser: lex.tab.c
	g++ mfpl.tab.c -o mfpl_parser

check: main cleanbuild checkoutput

cleanbuild:
	if [ -a build ]; then rm -R build; fi;
	mkdir build

checkoutput: $(buildFiles) $(diffFiles)

%.diff: $(buildFiles)
	$(diff) $(addsuffix .out,$(basename $@)) $(sampleOutputDir)/$(addsuffix .out,$(notdir $(basename $@))) > $@ | :

%.out: $(sampleInputFiles)
	./mfpl_parser $(sampleInputDir)/$(basename $(notdir $@)) > build/$(notdir $@) | :

clean: 
	rm *.tab.c *.yy.c *.orig mfpl_parser &> /dev/null | :
