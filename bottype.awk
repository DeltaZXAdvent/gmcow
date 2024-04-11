#!/bin/awk -f
# Seperately print the CMD macros and the skipstmt with skip location array attached at the beginning
# Keep NR to be the current instruction line number


BEGIN {
    if (ARGC != 2)
	exit 1
    ct_tags = 0
}


{
    if (rewound)
	print "  " $0 # indent by 2
    else if ($0 ~ /^$/) {
	--NR
    } else if ($0 ~ /^"_BOT_.*"$/) {
	tags[ct_tags] = substr($0, 3, length() - 3)
	locs[ct_tags] = --NR
	ct_tags++
    }
}


ENDFILE {
    if (!rewound) {
	print "enum BOTTYPE {"
	for (i = 0; i < ct_tags; i++)
	    printf " %s\n", tags[i]
	print " BOT_TYPE_CT"
	print "}"
	print ""
	print "rule(\"bot init bot\") {"
	print " event { ongoing - each player; all; all; }"
	print " conditions {"
	print "  is dummy bot(event player) == true;"
	print " }"
	print " actions {"
	printf "  skip(array("
	for (i = 0; i < ct_tags; i++)
	    printf "%d, ", locs[i]
	print "0)[event player.bottype]);"
	rewound = 1
	for (i = ARGC; i > ARGIND; i--) {
	    ARGV[i] = ARGV[i-1]
	    ARGC++
	}
    } else {
	print " }"
	print "}"
    }
}
