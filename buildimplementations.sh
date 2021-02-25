echo Building MD for implementations

tsv=implementations.tsv

if [ ! -f $tsv ]; then
    echo $tsv not found\!
    echo Can\'t build implementations\; exiting
    exit -1
fi

# expectedFieldsFile=implementations-google-column-names.tsv
expectedFieldsFile=implementations-fields.tsv


if [ ! -f $expectedFieldsFile ]; then
    echo $expectedFieldsFile not found\!
    echo Can\'t build implementations\; exiting
    exit -2
fi


# First confirm assumptions about fields
echo Confirming assumptions about fields in $tsv

# head -1 $tsv | diff -w $expectedFieldsFile -
head -1 $tsv | diff $expectedFieldsFile -

if [ ! $? -eq 0 ] ; then
    echo Oh no\!  Field names were not as expected by $0 - diff above
    echo exiting
    exit -3
else
    echo ...confirmed
fi

impl_dir=implementations


# At this point we believe we can recreate everything inside $impl_dir
rm -f ${impl_dir}/*.{md,html}

# Now loop through the remaining rows (all but the first) making a file for each...
# tail +2 $tsv

# awk 1 is to add an extra newline at the end if necessary

tail +2 $tsv | \
#    head -10 | \
    awk 1 | \
    while read line; do
        # First parse all the TSV fields into bash variables

        TIMESTAMP=`echo "$line" | cut -f1`
        SUBMITTER_NAME=$(echo "$line" | cut -f2)
        SUBMITTER_WEBSITE=$(echo "$line" | cut -f3)
        NAME=$(echo "$line" | cut -f4)
        # at this point we don't care about "Update?"
        URL=$(echo "$line" | cut -f6)
        URL_OSC_PART=$(echo "$line" | cut -f7)
        TYPE=$(echo "$line" | cut -f8)
        DESCRIPTION=$(echo "$line" | cut -f9)
        PLATFORM=$(echo "$line" | cut -f10)
        FEATURES=$(echo "$line" | cut -f11)
        TYPES=$(echo "$line" | cut -f12)
        BUNDLE=$(echo "$line" | cut -f13)
        TIMETAG=$(echo "$line" | cut -f14)
        TRANSPORT=$(echo "$line" | cut -f15)
        PUBLICATIONS=$(echo "$line" | cut -f16)
        IMAGES=$(echo "$line" | cut -f17)
        STATUS=$(echo "$line" | cut -f18)
        STATUSDATE=$(echo "$line" | cut -f19)
        SUPERSEDED=$(echo "$line" | cut -f20)
        # Also we ignore "notes"


        
        # Determine this filename based on the name, using these rules:
        
        # Omit anything in parentheses
        # Omit anything after a comma or colon that is followed by a space
        # Omit all punctuation characters
        # Remove trailing whitespace
        # Convert spaces to '-'
        # Convert repeated '--' to just one
        FILENAME=`echo $NAME | sed 's/(.*)//g' | sed 's/[,:][ ].*//g' | tr '-' ' ' | tr  -d '[:punct:]' | sed 's/[ ]*$//g' | tr ' ' '-' | tr -s '-'`


        if [ "$FILENAME" == "Arduino" ] ; then
            # Kludge for now based on problematic legacy content - should be fixed better.
            echo skip Arduino
            continue;
        fi

        FILENAME=${impl_dir}/${FILENAME}.md

        echo $NAME '==>' $FILENAME

        if [ -f $FILENAME ]; then
            # Not good; we deleted all markdown files at the beginning of this script,
            # so this must mean:
            echo At least two implementations want to have the same filename $FILENAME
            echo Abort.
            exit -4;
        fi


        # Now we actually write the markdown file for this implementation...

        echo "# ${NAME}" > $FILENAME
        echo "" >> $FILENAME

        if [ ! -z "$SUPERSEDED" ]  ; then
            echo "**This implementation has been superseded by another!**" >> $FILENAME
            echo $SUPERSEDED  >> $FILENAME
            echo "" >> $FILENAME
        fi

        echo "**status**: $STATUS (as of $STATUSDATE)" >> $FILENAME
        echo "" >> $FILENAME


        if [ ! -z "$TYPE" ] ; then
            echo "**Project Type**: $TYPE" >> $FILENAME
            echo "" >> $FILENAME
        fi

        if [ ! -z "$URL" ] ; then
            echo "**Project URL**: <$URL>" >> $FILENAME
            echo "" >> $FILENAME
        fi

        if [ ! -z "$URL_OSC_PART" ] ; then
            echo "**OSC Documentation URL**: <$URL_OSC_PART>" >> $FILENAME
            echo "" >> $FILENAME
        fi


        if [ ! -z "$DESCRIPTION" ] ; then
            echo "## Description" >> $FILENAME
            echo "" >> $FILENAME
            echo "$DESCRIPTION" >> $FILENAME
            echo "" >> $FILENAME
        fi

        if [ ! -z "$PLATFORM" ] || [ ! -z "$FEATURES" ] || [ ! -z "$TYPES" ] || [ ! -z "$BUNDLE" ] || [ ! -z "$TIMETAG" ] || [ ! -z "$TRANSPORT" ] ; then
            echo "## Implementation Details" >> $FILENAME
            echo "" >> $FILENAME
        fi

        if [ ! -z "$PLATFORM" ] ; then
            echo "**Platform(s)**: ${PLATFORM}" >> $FILENAME
            echo "" >> $FILENAME
        fi

        if [ ! -z "$FEATURES" ] ; then
            echo "**Features**: ${FEATURES}" >> $FILENAME
            echo "" >> $FILENAME
        fi

        if [ ! -z "$TYPES" ] ; then
            echo "**Supported OSC types**: ${TYPES}" >> $FILENAME
            echo "" >> $FILENAME
        fi

        if [ ! -z "$BUNDLE" ] ; then
            echo "**Bundle support**: ${BUNDLE}" >> $FILENAME
            echo "" >> $FILENAME
        fi

        if [ ! -z "$TIMETAG" ] ; then
            echo "**Timetag support**: ${TIMETAG}" >> $FILENAME
            echo "" >> $FILENAME
        fi

        if [ ! -z "$PUBLICATIONS" ] ; then
            echo "## Publications " >> $FILENAME
            echo "" >> $FILENAME
            echo "$PUBLICATIONS" >> $FILENAME
            echo "" >> $FILENAME
        fi


        if [ ! -z "$IMAGES" ] ; then
            echo "## Images " >> $FILENAME
            echo "" >> $FILENAME
            echo "$IMAGES" >> $FILENAME
            echo "" >> $FILENAME
        fi

        if [ -z "$SUBMITTER_WEBSITE" ] ; then
            FULLSUBMITTER="$SUBMITTER_NAME"
        else
            FULLSUBMITTER="[$SUBMITTER_NAME]($SUBMITTER_WEBSITE)"
        fi

        echo "---" >> $FILENAME
        echo "Submitted to [opensoundcontrol.org](https://opensoundcontrol.org) by $FULLSUBMITTER at $TIMESTAMP" >> $FILENAME
done

echo have a nice day
exit 0
