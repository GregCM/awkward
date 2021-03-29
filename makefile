awkward: awkward.sh awkward.awk awkward.tsv LICENSE

	cat awkward.sh > $@
	
	# compression method of your choosing [bzip2/xz/gzip/compress]
	tar -cmoPf - awkward.awk awkward.tsv LICENSE README.md | bzip2 -zc >> $@

	chmod +x $@
	#cp $@ /usr/local/bin/$@
clean:
	rm awkward && make
