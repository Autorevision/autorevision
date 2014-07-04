#!/bin/sh

# List of formats (short names).
read -d '' formats << EOF
h
xcode
swift
sh
py
pl
lua
php
ini
js
json
java
javaprop
tex
m4
EOF

cd "$(git rev-parse --show-toplevel)"

./autorevision.sh -o autorevision.cache -t h

for type in ${formats}; do
	./autorevision.sh -o autorevision.cache -f -t "${type}" > "examples/autorevision.${type}"
done
