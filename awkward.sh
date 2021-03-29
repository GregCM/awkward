#!/bin/sh
# awkward: Read the Word of God from your terminal
# License: Public domain

SELF="$0"
get_data() {
    # extract archived files appended to sh script
    sed '1,/^#EOF/d' < "$SELF" | \
        # decompress by whatever algorithm was used to compress
        ( bzip2 -dc || xz -dc || gzip -dc || compress -dc ) 2>/dev/null | \
        # cat $1 = [*.tsv/*.awk] from archive
        tar -xpf - "$1" | cat -
}

if [ -z "$PAGER" ]; then
	if command -v less >/dev/null; then
        # Prepare interactive mode
		PAGER="less"
        WHRTEXT=$(get_data awkward.tsv)
        WHRSCRIPT=$(get_data awkward.awk)
	else
		PAGER="cat"
	fi
fi

show_help() {
	exec >&2
	echo "usage: $(basename "$0") [flags] [reference...]

    -e    encrypt awkward for redistribution
    -l    list books
    -L    print license
    -h    show help
    -W    no line wrap

	Reference types:
	    <Book>
	        Individual book
	    <Book>:<Chapter>
	        Individual chapter of a book
	    <Book>:<Chapter>:<Verse>[,<Verse>]...
	        Individual verse(s) of a specific chapter of a book
	    <Book>:<Chapter>-<Chapter>
	        Range of chapters in a book
	    <Book>:<Chapter>:<Verse>-<Verse>
	        Range of verses in a book chapter
	    <Book>:<Chapter>:<Verse>-<Chapter>:<Verse>
	        Range of chapters and verses in a book

	    /<Search>
	        All verses that match a pattern
	    <Book>/<Search>
	        All verses in a book that match a pattern
	    <Book>:<Chapter>/<Search>
	       All verses in a chapter of a book that match a pattern"
	exit 2
}

show_list() {
		awk -v cmd=list $WHRSCRIPT $WHRTEXT | $PAGER
            # <-- for /usr/local/bin placement or other binary-type use
		#awk -v cmd=list -f awkward.awk awkward.tsv
            # <-- for use with shell script inside installed directory
}

# loop through positional paramters
while [ $# -gt 0 ]; do
	isFlag=0
	firstChar="${1%"${1#?}"}"
	if [ "$firstChar" = "-" ]; then
		isFlag=1
	fi

	if [ "$1" = "--" ]; then
		shift
		break
	elif [ "$1" = "-e" ]; then
        echo "Encrypting for redistribution..."
        echo "Give recipient's email, full name, or unique-alias (best) of their preference:"
        # Encrypt only the archived files
        sed '1,/^#EOF/d' < "$SELF" | gpg2 -cse || \
        echo "abort"
        exit
	elif [ "$1" = "-l" ]; then
		# List all book names with their abbreviations
        show_list
        exit
	elif [ "$1" = "-L" ]; then
        echo "$(get_data LICENSE)"
        exit
	elif [ "$1" = "-W" ]; then
        #FIXME
		export _NOLINEWRAP=1
		shift
	elif [ "$1" = "-h" ] || [ "$isFlag" -eq 1 ]; then
		show_help
	else
		break
	fi
done

if [ $? -eq 0 ]; then
    export _MAX_WIDTH="$(tput cols 2>/dev/null)"
fi

if [ $# -eq 0 ]; then
	if [ ! -t 0 ]; then
		show_help
	fi

	# Interactive mode
	while true; do
		printf "awkward> "
		if ! read -r ref; then
			break
		fi
        if $ref == "exit" || $ref == "quit"; then
            exit
        elif $ref == "help" || $ref == "?"; then
            show_help | $PAGER
        elif $ref == "list"; then
            show_list | $PAGER
        fi
		awk -v cmd=ref -v ref="$ref" -f $WHRSCRIPT $WHRTEXT | $PAGER
            # <-- for /usr/local/bin placement or other binary-type use
		#awk -v cmd=ref -v ref="$ref" -f awkward.awk awkward.tsv | $PAGER
            # <-- for use with shell script inside installed directory
	done
	exit 0
fi

awk -v cmd=ref -v ref="$*" -f $WHRSCRIPT $WHRTEXT | $PAGER
#awk -v cmd=ref -v ref="$*" -f awkward.awk awkward.tsv | $PAGER
exit 0
#EOF
