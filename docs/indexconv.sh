#!/usr/bin/env bash

# Searches (1)the directory where THIS shell script file resides, and
# (2)its immediate child directories (`docs/ja/` and `docs/en/`) recursively
# to find files with name `*.adoc`.
# Deeper sub directories (`sub/subsub/moresub/`) is not searched.
#
# Will convert all the files with name ending with `.adoc` into `.md`.
# `*.adoc` is an Asciidoc document file, `*.md` is a Markdown document file.
#
# However we have some details to note.
#
# 1. A file named `attribute.adoc` is treated specially.
#    It will NOT be transformed into the Markdown document at all.
#
# 2. A file with file name that starts with under bar `_` will be ignored.
# - `_index.adoc` is NOT processed by this script, will not be converted into .md
# - `_1_introduction.adoc` is not processed, will not be converted into .md
#
# 3. File name that ends with `_.adoc` is treated specially.
#    The under line character _ will be removed.
# - `index_.adoc` will be converted into `index.md`
# - `index-ja_.adoc` will be converted into `index-ja.md`
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

# a file with name ending with `*_.md` will be renamed to `index*.md`.
find $SCRIPTDIR -iname "*_.md" -type f -maxdepth 2 | while read fname; do
    WORKINGDIR=$(cd -P $(dirname $fname) && pwd -P)
    NEWNAME=$(echo $fname | sed -e "s/_\.md/.md/")
    echo Renaming $fname to $NEWNAME
    mv $fname $NEWNAME

    # slightly modifies the generated index-ja.md file
    #     - [Solution 1](#_solution_1)
    # will be translated to
    #     - [Solution 1](#solution-1)
    java -jar $SCRIPTDIR/lib/MarkdownUtils-0.1.0.jar $WORKINGDIR/index-ja.md
done



