#!/bin/bash
#
# Prefer Native Tools
#
# Claude Code PreToolUse hook for the Bash tool. Denies shell invocations that
# read or write file contents when a native tool (Read / Edit / Write) does the
# same job, so those calls never reach an interactive permission prompt.
#
# Author(s): Cody Buell
#
# Requisite: jq, registered as a PreToolUse hook with matcher "Bash" in
# `$CONFIGDIR/claude/settings.json`.
#
# Task:
#
# Usage: invoked by Claude Code, receives hook JSON on stdin
#        scripts/../claude/hooks/prefer-native-tools.sh --test
#
# Exit 0 = allow, fall through to normal permission handling.
# Exit 2 = deny, stderr is fed back to the agent as the reason.
#
# Bulk and multi file work is deliberately left alone: anything piping through
# xargs, find -exec, or a for loop is a transform that shell does better than a
# stack of Edit calls.

#################
#  Definitions  #
#################

# constructs that mark a command as a bulk transform, exempt wholesale
BULK_RE='(^|[[:space:]])(xargs|-exec|-execdir)([[:space:]]|$)|(^|;[[:space:]]*)for[[:space:]]'

# commands that read file contents to stdout
READERS='cat head tail less more bat'

# in place edits by stream editors
SED_INPLACE_RE='(^|[[:space:]])sed([[:space:]]+-[[:alnum:]]+)*[[:space:]]+-[[:alnum:]]*i'
PERL_INPLACE_RE='(^|[[:space:]])perl([[:space:]]+-[[:alnum:]]+)*[[:space:]]+-[[:alnum:]]*i'

# sed used as a pager, ie `sed -n '10,20p' file`
SED_READ_RE='(^|[[:space:]])sed([[:space:]]+-[[:alnum:]]+)*[[:space:]]+-[[:alnum:]]*n'

# literal content pushed into a file
REDIRECT_RE='^[[:space:]]*(echo|printf|cat)([[:space:]]|$).*>'
HEREDOC_RE='<<-?[[:space:]]*['"'"'"]?[A-Za-z_][A-Za-z0-9_]*'

# interpreter one liners that touch the filesystem
INTERP_RE='(python3?|node|ruby)[[:space:]]+-[ce].*(open\(|writeFile|File\.write|\.write\()'

##
 # Deny
 #
 # Emit the reason for the agent on stderr and block the tool call.
 #
 # @params $1 offending construct, $2 native tool to use instead
 # @return none
##
deny() {
  cat >&2 <<MSG
Blocked: \`$1\` reads or writes file contents through the shell.

Use the $2 tool instead. Native tools show the user a diff, fail loudly on a
missing or ambiguous anchor, and do not trigger a permission prompt.

If this is a genuine multi file or regex driven transform, express it with
find -exec or xargs and it will be allowed through.
MSG
  exit 2
}

##
 # Count Operands
 #
 # Number of non flag, non numeric arguments a command was handed. Flags and
 # their numeric values do not count, so `head -50` reading a pipe scores zero
 # while `head -50 file.md` scores one. Used to tell a command reading a file
 # from one consuming stdin.
 #
 # @params $@ words of the command, including the command itself
 # @return none, count is echoed
##
count_operands() {
  shift
  local word count=0
  for word in "$@"; do
    case "$word" in
      -*)        continue ;;
      *[!0-9]*)  count=$((count + 1)) ;;
    esac
  done
  echo "$count"
}

##
 # Inspect
 #
 # Run every rule against a command string.
 #
 # @params $1 the full command line
 # @return none, exits 2 on a denial
##
inspect() {
  local command="$1"
  local first_segment words reader operands stripped

  [ -z "$command" ] && return 0

  [[ "$command" =~ $BULK_RE ]] && return 0

  # text inside quotes is data, not shell, drop it before pattern checks so a
  # commit message mentioning `sed -i` or a heredoc does not trip a denial
  stripped=$(printf '%s' "$command" | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")

  # only the head of the pipeline can be reading a file, later segments are
  # consuming stdin, so `grep -rn foo . | head -50` stays allowed
  first_segment="${command%%|*}"
  read -ra words <<< "$first_segment"

  operands=$(count_operands "${words[@]}")

  for reader in $READERS; do
    if [ "$(basename "${words[0]:-}")" = "$reader" ] && [ "$operands" -ge 1 ]; then
      deny "$reader" "Read"
    fi
  done

  # sed always takes a script operand, so a file is only present at two or more
  if [[ "$first_segment" =~ $SED_READ_RE ]] && [ "$operands" -ge 2 ]; then
    deny "sed -n" "Read"
  fi

  [[ "$stripped" =~ $SED_INPLACE_RE ]]  && deny "sed -i" "Edit"
  [[ "$stripped" =~ $PERL_INPLACE_RE ]] && deny "perl -i" "Edit"
  [[ "$stripped" =~ $HEREDOC_RE ]]      && deny "heredoc" "Write"
  [[ "$stripped" =~ $REDIRECT_RE ]]     && deny "shell redirection into a file" "Write or Edit"
  # interpreter rule needs the quoted code itself, so match the full command
  [[ "$command" =~ $INTERP_RE ]]        && deny "interpreter one liner writing a file" "Write or Edit"

  return 0
}

############
#  Invoke  #
############

if [ "${1:-}" = "--test" ]; then
  # self check, prints PASS / FAIL for a battery of representative commands
  status=0
  while IFS='|' read -r expect command; do
    [ -z "$expect" ] && continue
    ( inspect "$command" ) >/dev/null 2>&1
    actual=$?
    if [ "$actual" = "$expect" ]; then
      printf 'PASS  %s\n' "$command"
    else
      printf 'FAIL  expected %s got %s: %s\n' "$expect" "$actual" "$command"
      status=1
    fi
  done <<'CASES'
2|cat foo.go
2|head -50 x.md
2|tail -n 20 log.txt
2|sed -n '10,20p' y.lua
2|sed -i '' 's/a/b/' z.sh
2|perl -pi -e 's/a/b/' z.sh
2|echo 'x' > f.txt
2|printf "a" > f.txt
2|cat > f.txt <<EOF
2|python3 -c "open('f','w').write('x')"
0|grep -rn foo . | head -50
0|find . -name '*.ts' -exec sed -i '' 's/a/b/' {} ;
0|git ls-files | xargs sed -i '' 's/a/b/'
0|go test ./...
0|git diff
0|git log --oneline | head -20
0|ls -la
0|cat
0|make build 2> err.log
0|rg foo | awk '{print $1}'
0|brew info jq
0|npm run lint
0|tail -f
0|sed -n '1p'
0|git commit -m "explain the sed -i and heredoc <<EOF deny rules"
0|echo "sed -i is blocked"
2|sed -i.bak -e s/a/b/ config.lua
CASES
  exit $status
fi

INPUT=$(cat)
inspect "$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')"
exit 0
