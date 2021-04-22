#!/bin/bash

# curling studyIds from api
CURLSTRING=$(curl http://cbioportal:8080/api/studies)
# extracting studyIds
STUDYSTRING=$(grep -o "\"studyId\":\"[^\"]*\"" <<< $CURLSTRING)
STUDYSTRING=$(sed -r "s|\"studyId\":\"||g" <<< $STUDYSTRING)
STUDYSTRING=$(sed -r "s|\"||g" <<< $STUDYSTRING)
# removing newlines
STUDYSTRING=$(tr '\n' ' ' <<< $STUDYSTRING)
# print result and export as env variable
echo "found studyIds in portal: $STUDYSTRING"
export ALL_CBIOPORTAL_STUDIES=$STUDYSTRING
