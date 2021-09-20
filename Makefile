SHELL != which bash

top:; @date

input.txt: Human_HighQuality.txt; tail -n+2 $< | expand -t 1 > $@

dict-with-awk.txt: input.txt; < $< time factor-prefix-simple.awk > $@
dict-with-awk.json: dict-with-awk.txt; < $< jq -nR '[inputs] | map(split(" ") | { (.[0]): .[1:] }) | add' > $@

%.txt: %.json; < $< jq -r 'to_entries | map([.key] + .value | join(" "))[]' > $@

dict-with-python.json: input.txt factor-prefix-with-dict.py; < $< time python $(word 2, $^) > $@
dict-with-jq.json: input.txt factor-prefix-with-dict.jq; < $< time jq -nR -f $(word 2, $^) > $@

input: input.txt
awk: dict-with-awk.txt
python: dict-with-python.txt
jq: dict-with-jq.txt

all := input.txt dict-with-awk.json dict-with-python.txt dict-with-jq.txt

all: $(all)
clean:; rm -f $(all) dict-with-awk.txt dict-with-jq.json dict-with-python.json

check: check-sorted check-alt

check-sorted:
	diff <(tail -n+2 Human_HighQuality.txt) <(tail -n+2 Human_HighQuality.txt | sort)
	diff input.txt <(sort input.txt)

check-alt: dict-with-awk.json
	diff dict-with-{awk,jq}.txt
	diff dict-with-{jq,python}.txt
	diff dict-with-{awk,jq}.json
	jsondiff dict-with-{jq,python}.json | jq

################

input.dot: input.txt; { echo 'graph G {'; < $< head -1000 | tr -d .- | sed -re 's/\b(\w*)\b/n\1/g' -e 's/ / -- /' -e s/_HU//g; echo '}'; } > $@
input.pdf: input.dot; < $< neato -Tpdf > $@

