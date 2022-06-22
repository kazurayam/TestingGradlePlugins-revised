#!/usr/bin/env bash

# Searches the directory where THIS sh scritp file resides, and
# its immediate child directories (`docs/ja/` and `docs/en/`) recursively
# to find files with name `*.adoc`.
#
# Will convert all the files with name ending with `.adoc` into `.md`.
# `*.adoc` is an Asciidoc document file, `*.md` is a Markdown document file.
#
# The file name `index*_.adoc` is treated specially.
# The underline before `.adoc` will be removed.
# - `index_.adoc` will be converted into `index-ja.md`
# - `index-ja_.adoc` will be converted into `index-ja.md`
#
# Files with name starting with under bar `_` is ignored.
# E.g,
# - `_index.adoc` is NOT processed by this script, will no be converted into .md
# - `_1_introduction.adoc` is not processed, will not be converted into .md

# Also the file name `attribute.adoc` is treated specially. It will NOT be
# transformed into the md at all.
#
# How to active this sh script? In the command line, just type
# `> cd docs`
# `> ./indexconv.sh`
#
# Can generate TOC (Table of contents) in the output *.md file by specifying `-t` option
# `> ./indexconv.sh -t`

SCRIPTDIR=$(cd -P $(dirname $0) && pwd -P)

requireTOC=false

optstring="t"
while getopts ${optstring} arg; do
    case ${arg} in
        t)
            requireTOC=true
            ;;
        ?)
            ;;
    esac
done

find $SCRIPTDIR -iname "*.adoc" -type f -maxdepth 2 -not -name "_*.adoc" -not -name "attribute.adoc" | while read fname; do
    target=${fname//adoc/md}
    xml=${fname//adoc/xml}
    echo "converting $fname into $target"
    # converting a *.adoc into a docbook
    asciidoctor -b docbook -a leveloffset=+1 -o - "$fname" > "$xml"
    if [ $requireTOC = true ]; then
      # generate a Markdown file with Table of contents
      cat "$xml" | pandoc --standalone --toc --markdown-headings=atx --wrap=preserve -t markdown_strict -f docbook - > "$target"
    else
      # without TOC
      cat "$xml" | pandoc --markdown-headings=atx --wrap=preserve -t markdown_strict -f docbook - > "$target"
    fi
    echo deleting $xml
    rm -f "$xml"
done

echo ""

# if we find a index*.md (or index*.md),
# we rename all of them to a single index-ja.md while overwriting,
# effectively the last wins.
# E.g, if we have `index_.md`, it will be overwritten into `index-ja.md`
find $SCRIPTDIR -iname "index*.md" -not -name "index.md" -type f -maxdepth 2 | while read fname; do
    WORKINGDIR=$(cd -P $(dirname $fname) && pwd -P)
    echo Renaming $fname to $WORKINGDIR/index-ja.md
    mv $fname $WORKINGDIR/index-ja.md

    # slightly modifies the generated index-ja.md file
    #     - [Solution 1](#_solution_1)
    # will be translated to
    #     - [Solution 1](#solution-1)
    java -jar $SCRIPTDIR/lib/MarkdownUtils-0.1.0.jar $WORKINGDIR/index-ja.md
done



