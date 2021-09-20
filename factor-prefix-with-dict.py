import sys, json
from functools import reduce

def merge(a, b): a[b[0]] = a.get(b[0], []) + [b[1]]; return a
json.dump(reduce(merge, list(map(lambda x: x.strip().split(" "), sys.stdin.readlines())), {}), sys.stdout)
