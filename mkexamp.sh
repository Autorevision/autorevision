#!/bin/sh

# List of formats (short names).
read -d '' formats << EOF
h
xcode
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

for type in ${formats}; do
	./autorevision.sh -t ${type} > examples/autorevision.${type}
done
