#!/usr/bin/env bash
set -eu

failed=0

test_pattern='\b(fdescribe|fit|fcontext|xdescribe|xit|xcontext)\b'
if git diff-index -p -M --cached HEAD -- '*Tests.swift' '*Specs.swift' | grep '^+' | egrep "$test_pattern" >/dev/null 2>&1
then
  echo "COMMIT REJECTED for fdescribe/fit/fcontext/xdescribe/xit/xcontext." >&2
  echo "Remove focused and disabled tests before committing." >&2
  echo '----' >&2
  git grep --cached -E "$test_pattern" '*Tests.swift' '*Specs.swift'  >&2
  echo '----' >&2
  failed=1
fi

misplaced_pattern='misplaced="YES"'

if git diff-index -p -M --cached HEAD -- '*.xib' '*.storyboard' | grep '^+' | egrep "$misplaced_pattern" >/dev/null 2>&1
then
  echo "COMMIT REJECTED for misplaced views. Correct them before committing." >&2
  echo '----' >&2
  git grep --cached -E "$misplaced_pattern" '*.xib' '*.storyboard' >&2
  echo '----' >&2
  failed=1
fi

exit $failed
