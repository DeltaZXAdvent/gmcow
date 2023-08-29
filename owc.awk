#!/bin/awk -f
# Group vars, subs, enum definitions etc
# TODO
# - Add dependency check
# - Add rule positioning use "<" & ">"
# - Enum repetition detection
BEGIN {
  construct = "none"
}


{
  if (construct == "none") {
    if ($0 ~ /^comments \{ *$/) {
      construct = "comm"
    } else if ($0 ~ /^dependencies \{ *$/) {
      construct = "depe"
    } else if ($0 ~ /^variables player \{ *$/) {
      construct = "play"
    } else if ($0 ~ /^variables global \{ *$/) {
      construct = "glob"
    } else if ($0 ~ /^subroutines \{ *$/) {
      construct = "subr"
    } else if ($0 ~ /^enum [^ \t]+ \{ *$/) {
      enumcur = $2
      if (!(enumcur in enums)) {
        enumct[$2] = 0
        enums[$2] = ""
        enumorder[ct_enum++] = enumcur
      }
      construct = "enum"
    } else if ($0 ~ /^enum [^ \t]+ [^ \t]+ \{ *$/) {
      enumcur = $2
      if (!(enumcur in enums)) {
        enumct[$2] = 0
        enums[$2] = ""
        enumbase[$2] = $3
        enumorder[ct_enum++] = enumcur
      }
      construct = "enum"
    } else if ($0 ~ /^rule\(".*"\) \{ *$/) {
      match($0, /\(".*"\)/)
      rulecur = substr($0, RSTART + 2, RLENGTH - 4)
      if (rulecur in rules)
        print sprintf("Repeated rule \"%s\" found.", rulecur) > "/dev/stderr"
      else
        ruleorder[ct_rule++] = rulecur
      rules[rulecur] = $0 "\n"
      construct = "rule"
    }
  } else {
    if ($0 ~ /^\} *$/) {
      switch(construct) {
      case "rule":
        rules[rulecur] = rules[rulecur] $0 "\n"
        break
      default:
        break
      }
      construct = "none"
    } else {
      switch(construct) {
      case "comm":
        break
      case "depe":
        break
      case "play":
        vars_player = vars_player sprintf("    %d: %s\n", ct_varsp++, $1)
        break
      case "glob":
        vars_global = vars_global sprintf("    %d: %s\n", ct_varsg++, $1)
        break
      case "subr":
        subs = subs sprintf("  %d: %s\n", ct_subr++, $1)
        break
      case "enum":
        enums[enumcur] = enums[enumcur] (enumcur in enumbase ?
          sprintf("define(`%s', eval(%s * 1000 + %d))dnl\n", $1, enumbase[enumcur], enumct[enumcur]++) :
          sprintf("define(`%s', `%d')dnl\n", $1, enumct[enumcur]++))
        break
      case "rule":
        rules[rulecur] = rules[rulecur] $0 "\n"
        break
      default:
        break
      }
    }
  }
}

END {
  print "variables {"
  print "  global:\n" vars_global
  print "  player:\n" vars_player "}"
  print ""
  print "subroutines {\n" subs "}"
  print ""
  for (i in enumorder)
    print enums[enumorder[i]] "dnl"
  for (i in ruleorder)
    print rules[ruleorder[i]]
}
