#!/bin/sh
# Check the witness programs in witnesses/ against GHC.
#
# Each witness starts with two header lines:
#
#   -- Extensions: X Y ...
#   -- Class: R      (or M)
#
# For classes R and M the witness must compile under -XHaskell2010.  For
# each listed extension, class R means the program must be rejected once
# the extension is on, and class M means it must still compile but print
# something different.
#
# Class D marks a program that is valid by the report but that GHC rejects
# under -XHaskell2010; the script checks the rejection and reports what
# happens with each listed extension.
#
# Class A marks a program that the report rejects but that some GHC versions
# accept under -XHaskell2010.  A third header line lists those versions:
#
#   -- Deviates: 9.12
#
# The script expects acceptance from a listed major version and rejection
# from any other, and reports what happens with each listed extension.
#
# Usage: ./check-witnesses.sh [witnesses/Foo.hs ...]
# Set GHC to choose the compiler (default: ghc).

set -u

GHC=${GHC:-ghc}
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

[ $# -eq 0 ] && set -- "$here"/witnesses/*.hs

# build DIR FILE [FLAG ...]: compile FILE into DIR/prog, logging to DIR/log.
build() {
  dir=$1 file=$2
  shift 2
  mkdir -p "$dir"
  "$GHC" -XHaskell2010 "$@" -i"$here/witnesses" -outputdir "$dir" \
    -o "$dir/prog" "$file" >"$dir/log" 2>&1
}

# run DIR: run DIR/prog, recording its output and exit status in DIR/out.
run() {
  "$1/prog" >"$1/out" 2>&1
  echo "exit $?" >>"$1/out"
}

"$GHC" --version
major=$("$GHC" --numeric-version | cut -d. -f1,2)
status=0
for file in "$@"; do
  exts=$(sed -n 's/^-- Extensions: //p' "$file")
  [ -n "$exts" ] || continue
  class=$(sed -n 's/^-- Class: //p' "$file")
  name=$(basename "$file" .hs)

  if [ "$class" = A ]; then
    deviates=$(sed -n 's/^-- Deviates: //p' "$file")
    case " $deviates " in
      *" $major "*) expect=accepted ;;
      *) expect=rejected ;;
    esac
    if build "$tmp/$name/base" "$file"; then got=accepted; else got=rejected; fi
    if [ "$got" != "$expect" ]; then
      echo "FAIL $name: $got under Haskell2010, expected $expect for GHC $major"
      status=1
      continue
    fi
    for ext in $exts; do
      if build "$tmp/$name/$ext" "$file" "-X$ext"; then
        echo "ok   $name (A): $got by GHC's Haskell2010, accepted with $ext"
      else
        echo "ok   $name (A): $got by GHC's Haskell2010, rejected with $ext"
      fi
    done
    continue
  fi

  if [ "$class" = D ]; then
    if build "$tmp/$name/base" "$file"; then
      echo "FAIL $name: accepted under Haskell2010"
      status=1
      continue
    fi
    for ext in $exts; do
      if build "$tmp/$name/$ext" "$file" "-X$ext"; then
        echo "ok   $name (D): rejected by GHC's Haskell2010, accepted with $ext"
      else
        echo "ok   $name (D): rejected by GHC's Haskell2010 and with $ext"
      fi
    done
    continue
  fi

  if ! build "$tmp/$name/base" "$file"; then
    echo "FAIL $name: rejected under Haskell2010"
    status=1
    continue
  fi
  run "$tmp/$name/base"

  for ext in $exts; do
    dir=$tmp/$name/$ext
    if build "$dir" "$file" "-X$ext"; then
      if [ "$class" = R ]; then
        echo "FAIL $name: accepted with $ext"
        status=1
        continue
      fi
      run "$dir"
      if cmp -s "$tmp/$name/base/out" "$dir/out"; then
        echo "FAIL $name: same behaviour with $ext"
        status=1
      else
        echo "ok   $ext (M): $(head -n 1 "$tmp/$name/base/out") => $(head -n 1 "$dir/out")"
      fi
    elif [ "$class" = R ]; then
      echo "ok   $ext (R): rejected"
    else
      echo "FAIL $name: rejected with $ext"
      status=1
    fi
  done
done
exit $status
