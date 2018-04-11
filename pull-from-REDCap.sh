curl -X POST https://redcap.uahs.arizona.edu/api/ \
    -d token=$(head -1 $1) \
    -d content=record \
    -d format=csv \
    -d rawOrLabelHeaders=raw
