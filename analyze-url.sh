#! /bin/bash
#############################################
# Analyze sites for performance using YSlow #
#############################################
function usage() {
    echo -e "Usage: \t\t./analyze-url.sh -u \$URL [-t \$TITLE]"
    echo -e "Or simply: \t./analyze-url \$URL"
}

# no parameters
if [ -z "$1" ]; then
    usage
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
	    if [[ "$OPTARG" =~ ^http://.* || "$OPTARG" =~ ^https://.* ]]; then
		URL="$OPTARG"
	    else
		URL=http://"$OPTARG"
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
    if [[ "$1" =~ ^http://.* || "$1" =~ ^https://.* ]]; then
	URL="$1"
    else
	URL=http://"$1"
    fi
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
GZIP=$(jshon -e g -e ycompress -e score < analysis.json)
# JavaScript at the bottom grade
JSBOTTOM=$(jshon -e g -e yjsbottom -e score < analysis.json)
# Minification grade
MINIFY=$(jshon -e g -e yminify -e score < analysis.json)

######################
# Build analysis CSV #
######################

touch analysis.csv
# header row
echo "Title,URL,Overall Grade,No. Requests,Requests Score,GZIP Grade,JS Bottom Grade,Minification Grade" >> analysis.csv
# fill in values using input & YSlow results
echo "$TITLE,$URL,$OVERALL,$REQS,$REQSGRADE,$GZIP,$JSBOTTOM,$MINIFY" >> analysis.csv
