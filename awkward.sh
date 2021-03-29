#!/bin/sh
# awkward
# License: Public domain

SELF=$0
get_data() {
    # extract archived files appended to sh script
    sed '1,/^#EOF/d' < $SELF | \
        # decompress by whatever algorithm was used to compress
        ( bzip2 -dc || xz -dc || gzip -dc || compress -dc ) 2>/dev/null | \
        # cat $1 = [*.tsv/*.awk] from archive
        tar -xpf - "$1" | cat -
}

if [ -z "$PAGER" ]; then
	if command -v less >/dev/null; then
        # Prepare interactive mode
		PAGER="less"
        WARDTEXT=$(get_data awkward.tsv)
        WARDSCRIPT=$(get_data awkward.awk)
	else
		PAGER="cat"
	fi
fi

show_help() {
	exec >&2
	echo ""
	echo " usage: $(basename "$0") [flags] [reference...]

    -d    decrypt this source file
    -e    encrypt source file for redistribution
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
	       All verses in a chapter of a book that match a pattern
	     "
	exit 2
}

show_list() {
	awk -v cmd=list -f $WARDSCRIPT $WARDTEXT | $PAGER
        #     <-- for /usr/local/bin placement or other binary-type use
	#awk -v cmd=list -f awkward.awk awkward.tsv
        #     <-- for use with shell script inside installed directory
}

self_decrypt() {
	echo "Decrypting for first use..."
	mkdir -p /tmp/awkward/CRYPT/
	timestamp=$(date "+%Y%m%d%H%M%S")
	# suffix "zzz" denotes we don't know how it was compressed, but we know it's a compressed archive
	# ... we let get_data() handle what to do with it.
	sed '1,/^#EOF/d' < $SELF > /tmp/awkward/CRYPT/$timestamp.tar.zzz.gpg && \
	# symmetric decryption, requires only the passphrase given by the distributor
	gpg2 -d /tmp/awkward/CRYPT/$timestamp.tar.zzz.gpg > /tmp/awkward/CRYPT/$timestamp.tar.zzz
}

self_encrypt() {
	echo "Encrypting for redistribution..."
	mkdir -p /tmp/awkward/SHAREME/ || (echo "awkward: are you sure you don't already have a shareable copy?" && exit 2)
	# TODO insert README under SHAREME tmp folder, so distributors know exactly how it'll work
	touch /tmp/awkward/SHAREME/README
	timestamp=$(date "+%Y%m%d%H%M%S")
	sed '1,/^#EOF/d' < $SELF > /tmp/awkward/$timestamp
        # Encrypt only the archived files
	gpg2 -c /tmp/awkward/$timestamp
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
	elif [ "$1" = "-d" ]; then
		self_decrypt || (echo abort && exit 2)
		sed '1,/^#EOF/!d' < $SELF > /tmp/awkward/CRYPT/$timestamp.sh
		cat /tmp/awkward/CRYPT/$timestamp.sh /tmp/awkward/CRYPT/$timestamp.tar.zzz > $SELF
		chmod +x $SELF
		rm -r /tmp/awkward/CRYPT/
		echo "awkward: success! you can now use or redistribute at will"
		exit 0
	elif [ "$1" = "-e" ]; then
		self_encrypt || (echo abort && rm -r /tmp/awkward/ && exit 2)
		# Past the encryption stage... prepending
		sed '1,/^#EOF/!d' < $SELF > /tmp/awkward/SHAREME/awkward
		cat /tmp/awkward/$timestamp.gpg >> /tmp/awkward/SHAREME/awkward
		chmod +x /tmp/awkward/SHAREME/awkward
		rm /tmp/awkward/$timestamp*
		echo "awkward: success! you can find your safely redistributable program in /tmp/awkward/SHAREME"
		exit 0
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
		awk -v cmd=ref -v ref="$ref" -f $WARDSCRIPT $WARDTEXT | $PAGER
            # <-- for /usr/local/bin placement or other binary-type use
		#awk -v cmd=ref -v ref="$ref" -f awkward.awk awkward.tsv | $PAGER
            # <-- for use with shell script inside installed directory
	done
	exit 0
fi

awk -v cmd=ref -v ref="$*" -f $WARDSCRIPT $WARDTEXT | $PAGER
#awk -v cmd=ref -v ref="$*" -f awkward.awk awkward.tsv | $PAGER
exit 0
#EOF
