kjv: kjv.sh kjv.awk kjv.tsv.gz
	cat kjv.sh > $@

	echo 'exit 0' >> $@

	echo '#EOF' >> $@
	tar czf - kjv.awk kjv.tsv.gz >> $@

	chmod +x $@
