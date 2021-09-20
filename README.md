# Check that data is already sorted

```bash
diff <(tail -n+2 Human_HighQuality.txt) <(tail -n+2 Human_HighQuality.txt | sort)
```

# Use an input file without line count as first line

```console
thy@tde-ws:~/usr/hub/work/ext/matylde$ make input
tail -n+2 Human_HighQuality.txt | expand -t 1 > input.txt
```

May require `sudo apt install make`

# Solution with awk without using dict

Fast and memory inexpensive (no need to read the whole data set), but
use imperative style. Works because the data file is sorted

- Src [factor-prefix-simple.awk](factor-prefix-simple.awk)

```console
thy@tde-ws:~/usr/hub/work/ext/matylde$ make awk
< input.txt time factor-prefix-simple.awk > dict-with-awk.txt
0.02user 0.00system 0:00.02elapsed 96%CPU (0avgtext+0avgdata 3900maxresident)k
0inputs+776outputs (0major+217minor)pagefaults 0swaps
```

May require `sudo apt install gawk` [The GNU Awk User’s Guide][]

[The GNU Awk User’s Guide]:
    https://www.gnu.org/software/gawk/manual/gawk.html
    "www.gnu.org"

# Solution with python, use dict

Still quite fast, at least if the data set can be kept in memory

- Src [factor-prefix-with-dict.py](factor-prefix-with-dict.py)

```console
< input.txt time python factor-prefix-with-dict.py > dict-with-python.json
0.06user 0.01system 0:00.07elapsed 100%CPU (0avgtext+0avgdata 19432maxresident)k
0inputs+1000outputs (0major+3994minor)pagefaults 0swaps
< dict-with-python.json jq -r 'to_entries | map([.key] + .value | join(" "))[]' > dict-with-python.txt
```

Use `json` tp output `python` dict ([Introducing JSON][])

[Introducing JSON]:
    https://www.json.org/json-en.html
    "json.org"

# Solution with jq, use dict

Slower (less that 5 seconds), same algo than python but more succinct

- Src

  ```jq
  [inputs] | map(split(" ")) | reduce .[] as $i ({}; .[$i[0]] += [$i[1]])
  ```

```console
thy@tde-ws:~/usr/hub/work/ext/matylde$ make jq
< input.txt time jq -nR -f factor-prefix-with-dict.jq > dict-with-jq.json
3.04user 0.00system 0:03.05elapsed 99%CPU (0avgtext+0avgdata 14564maxresident)k
0inputs+1288outputs (0major+3487minor)pagefaults 0swaps
< dict-with-jq.json jq -r 'to_entries | map([.key] + .value | join(" "))[]' > dict-with-jq.txt
```

May require `sudo apt install jq`

[jq is a lightweight and flexible command-line JSON processor.]:
    https://stedolan.github.io/jq/
    "github.io"

# Check that all json and text ouput are similar for all implementation

```console
thy@tde-ws:~/usr/hub/work/ext/matylde$ make check
diff <(tail -n+2 Human_HighQuality.txt) <(tail -n+2 Human_HighQuality.txt | sort)
diff input.txt <(sort input.txt)
< dict-with-awk.txt jq -nR '[inputs] | map(split(" ") | { (.[0]): .[1:] }) | add' > dict-with-awk.json
diff dict-with-{awk,jq}.txt
diff dict-with-{jq,python}.txt
diff dict-with-{awk,jq}.json
jsondiff dict-with-{jq,python}.json | jq
{}
```

May require `sudo apt install python3-jsondiff`

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
