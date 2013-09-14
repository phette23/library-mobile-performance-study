#! /usr/bin/env bash
#############################################
# Analyze sites for performance using YSlow #
#############################################
function usage() {
    echo -e "Usage: \t\t./analyze-url.sh -u \$URL [-t \$TITLE]"
    echo -e "Or simply: \t./analyze-url \$URL"
}

USERAGENT="Mozilla/5.0 (iPhone; CPU iPhone OS 6_0_1 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A523 Safari/8536.25"

# no parameters
if [ -z "$1" ]
    then usage
    exit
fi

# check for parameters
# set to Untitled as a default
TITLE=Untitled
while getopts :t:u:h opt; do
    case $opt in
	t)
	    TITLE="$OPTARG";;
	u)
	    # check for http(s) at the beginning, put there if not present
	    if [[ "$OPTARG" =~ ^http://.* || "$OPTARG" =~ ^https://.* ]]
		then URL="$OPTARG"
	    else
		URL=http://"$OPTARG"
		echo "Prepended http:// to URL"
	    fi;;
	h)
	    usage
	    exit;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1;;
    esac
done

# shorthand use-case: no -u param but $1
if [ -z "$URL" ]; then
    # check for http(s) at the beginning, put there if not present
    if [[ "$1" =~ ^http://.* || "$1" =~ ^https://.* ]]
	then URL="$1"
    else
	URL=http://"$1"
	echo "Prepended http:// to URL: $URL"
    fi
fi

echo "Running YSlow on $TITLE, hang on a minute..."
# see github.com/marcelduran/yslow/wiki/PhantomJS
# these options are: info=grade, format=json, user-agent=iPhone 6
phantomjs ./yslow/build/phantomjs/yslow.js -i grade -f json -u "$USERAGENT" $URL > analysis.json

########################
# Parse the YSlow JSON #
########################

echo "Parsing results json."
# overall grade
OVERALL=$(jshon -e o < analysis.json)
# no. of requests
REQS=$(jshon -e r < analysis.json)
# No. of requests grade
REQSGRADE=$(jshon -e g -e ynumreq -e score < analysis.json)
# Compression grade
GZIP=$(jshon -e g -e ycompress -e score < analysis.json)
# JavaScript at the bottom grade
JSBOTTOM=$(jshon -e g -e yjsbottom -e score < analysis.json)
# Minification grade
MINIFY=$(jshon -e g -e yminify -e score < analysis.json)

######################
# Build analysis CSV #
######################

# create file with header row if it doesn't exist
if [ ! -f analysis.csv ]
    then echo "No analysis.csv! Creating..."
    touch analysis.csv
    echo "Title,URL,Overall Grade,No. Requests,Requests Score,GZIP Grade,JS Bottom Grade,Minification Grade" >> analysis.csv
else
    echo "Analysis.csv exists."
fi

echo "Appending YSlow results..."
# fill in values using params & YSlow results
echo "$TITLE,$URL,$OVERALL,$REQS,$REQSGRADE,$GZIP,$JSBOTTOM,$MINIFY" >> analysis.csv
echo "Finished!"
