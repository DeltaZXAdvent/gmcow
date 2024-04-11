#!/bin/awk -f

BEGIN {
  FS = "  "
  normal_nf = 0
  print ""
  print "rule(\"menu init player [config]\") {"
  print "  event { ongoing - each player; all; all; }"
  print "  actions {"
  print "    event player.menusel = MN_LANG;"
  print "    event player.menuitemsel = eval(2 * (CT_LANG + 1));"
  print "  }"
  print "}"
}


{
  if (constructing) {
    if (NF == 0) {
      array = substr(array, 1, length(array) - 2) "\n" # change ",\n" to "\n"
      array = array "  ),\n"
      constructing = 0
    } else {
      if (normal_nf == 0)
        normal_nf = NF
      else if (normal_nf != NF)
        printf "Warning: Unusual number of fields detected at record %d!", NR > "/dev/stderr"
      array = array (substr($1, 1, 1) == "@" ?
        sprintf("    eval(CMDG_JUMP * 1000 + %s),", substr($1, 2, length($1))) :
        sprintf("    %s,", $1))
      for (i = 2; i <= NF; i++)
        array = array sprintf(" custom string(\"%s\"),", $i)
      array = array "\n"
    }
  } else {
    if (NF == 1) {
      menus = menus sprintf("  %s\n", $1)
      array = array "  array(\n"
      constructing = 1
    }
  }
}


END {
  print "enum MENU {"
  print menus "}"
  print ""
  print "rule(\"menu init global\") {"
  print "  event { ongoing - global; }"
  print "  actions {"
  print "    global.menu ="
  print "array("
  print substr(array, 1, length(array) - 2)
  print ");"
  print "  }"
  print "}"

}

