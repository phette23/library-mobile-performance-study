#! /bin/bash
##############################################
# Test a series of sites with analyze-url.sh #
##############################################

# takes a json file of format
# {
#   "sites": [
#       { "title" : "Google", "url" : "www.google.com" },
#       { "title" : "DuckDuckGo", "url" : "duckduckgo.com" },
#       { "title" : "Phette Dot Net", "url" : "phette.net" }
#       ]
# }
# & runs analyze-url.sh on each site, output is in analysis.csv

if [ ! "$1" ]
    then echo "Usage: ./test-sites input.json"
    exit
fi

# iterate over the list of sites
NUMSITES=`jshon -e sites -l < "$1"`
echo "$NUMSITES sites found in $1."
i=0
while [ $i -lt $NUMSITES ]
do
    # extract current site title & URL
    CURRENTTITLE=`jshon -e sites -e $i -e title < "$1"`
    CURRENTURL=`jshon -e sites -e $i -e url -u < "$1"`
    echo "Analyzing site $CURRENTTITLE at URL $CURRENTURL ..."
    ./analyze-url.sh -u $CURRENTURL -t "$CURRENTTITLE"
    i=$(( $i + 1 ))
done

# can remove yslow's json output which only holds data for the last site anyways
if [ -f analysis.json ]
    then rm analysis.json
fi
