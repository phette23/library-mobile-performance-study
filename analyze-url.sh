#! /bin/bash
# no parameter
if [ -z "$1" ]; then
    echo "Usage: ./analyze-url.sh \$URL"
    exit
fi
# check for http(s) at the beginning, put there if not present
if [[ "$1" =~ ^http://.* || "$1" =~ ^https://.* ]]; then
    URL=$1
else
    URL=http://"$1"
fi

# see github.com/marcelduran/yslow/wiki/PhantomJS
phantomjs ./build/phantomjs/yslow.js -i grade -f json $URL
