#! /bin/bash
#############################################
# Analyze sites for performance using YSlow #
#############################################

# no URL parameter
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
# these options are: info=grade, format=json
phantomjs ./build/phantomjs/yslow.js -i grade -f json $URL > analysis.json

########################
# Parse the YSlow JSON #
########################
# overall grade
OVERALL=$(jshon -e o < analysis.json)
# no. of requests
REQS=$(jshon -e r < analysis.json)
# No. of requests grade
REQSGRADE=$(jshon -e g -e ynumreq -e score < analysis.json)
# Compression grade
GZIPGRADE=$(jshon -e g -e ycompress -e score < analysis.json)

######################
# Build analysis CSV #
######################
touch analysis.csv
# header row
echo "Title,URL,Overall Grade,No. Requests,Requests Score,GZIP Grade" >> analysis.csv
# fill in values using input & YSlow results
echo "THIS IS THE TITLE,$1,$OVERALL,$REQS,$REQSGRADE,$GZIPGRADE" >> analysis.csv
