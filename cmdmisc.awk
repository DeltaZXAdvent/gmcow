#!/bin/awk -f
# Seperately print the CMD macros and the skipstmt with skip location array attached at the beginning
# Keep NR to be the current instruction line number
# TODO change cmds & stmt to array
# TODO learn:
# - Variable initialization
# - Array
# - Reread
# - Argument check
# Potential bugs:
# - string concat


BEGIN {
    if (ARGC != 2)
	exit 1
}

{
    if (rewound)
	print "    " $0
    else if ($0 ~ /^$/) {
	# empty line
	--NR
    } else if ($0 ~ /^"_CMD_.*"$/) {
	# "CMD_.*"\n
	cmds = cmds sprintf("  %s\n", substr($0, 3, length() -3))
	skipstmt = skipstmt sprintf("%d, ", --NR)
    } else if ($0 ~ /^".*"$/) {
	# comments
	--NR
    }
}


ENDFILE {
    if (!rewound) {
	print "enum CMD CMDG_MISC {"
	print cmds "}"
	print ""
	print "rule(\"sub cmdmisc\") {"
	print "  event { subroutine; cmdmisc; }"
	print "  actions {"
	printf "    skip(array(%s)[global.argv[0]]);\n", substr(skipstmt, 1, length(skipstmt) - 2)
	rewound = 1
	for (i = ARGC; i > ARGIND; i--) {
	    ARGV[i] = ARGV[i-1]
	    ARGC++
	}
    } else {
	print "  }"
	print "}"
    }
}
