CONTENT = $(shell find content -iname "*.md")

all: pdf html

target.md: $(CONTENT)
	ocamlc -o preprocess unix.cma src/preprocess.ml
	./preprocess ./target.md ./content/Home.md \
		`find ./content/*/ -iname "*.md" | sed -e 's:\n: :g' -e 's://*:/:g'`

pdf: target.md
	cat ./rsc/options | \
	sed 's:^\([a-z]\):-V \1:; s:##version##:$(version):g'| \
	tr '\n' ' ' |  xargs \
	pandoc --template=./rsc/template ./target.md \
	-s -o doc.pdf

html: target.md
	cat ./rsc/options | \
	sed 's:^\([a-z]\):-V \1:; s:##version##:$(version):g'| \
	tr '\n' ' ' |  xargs \
	pandoc --toc -S -H ./rsc/github-pandoc.css.include ./target.md \
	-s -o doc.html

update:
	rm -f ../../README.md
	echo "\n\n<!-- DO NOT EDIT, see ./doc/usr/content/Home.md -->\n\n" > \
		../../README.md
	cat content/Home.md | \
		sed -e 's:](\./\([^)]*\)):](doc/usr/content/\1):g' >> \
		../../README.md
	cp content/9_other/license.md ../../LICENSE.md

clean:
	rm -f src/*.cmi src/*.cmo src/*.cmx src/*.o
	rm -f preprocess
	rm -f target.md

.PHONY: pdf html
