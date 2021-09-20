[inputs] | map(split(" ")) | reduce .[] as $i ({}; .[$i[0]] += [$i[1]])
