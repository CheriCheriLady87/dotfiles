# Copyright 2015 Koichi Murase <myoga.murase@gmail.com>. All rights reserved.
# This script is a part of blesh (https://github.com/akinomyoga/ble.sh)
# provided under the BSD-3-Clause license.  Do not edit this file because this
# is not the original source code: Various pre-processing has been applied.
# Also, the code comments and blank lines are stripped off in the installation
# process.  Please find the corresponding source file(s) in the repository
# "akinomyoga/ble.sh".
#
# Source: /lib/test-main.sh
ble-import lib/core-test
ble/test/start-section 'ble/main' 21
(
  ble/test ble/util/put a     stdout=a
  ble/test ble/util/print a   stdout=a
  ble/test 'ble/util/put "a b"'   stdout='a b'
  ble/test 'ble/util/print "a b"' stdout='a b'
  ble/test 'ble/util/put "a b"; ble/util/put "c d"' \
           stdout='a bc d'
  ble/test 'ble/util/print "a b"; ble/util/print "c d"' \
           stdout='a b' \
           stdout='c d'
)
(
  function ble/test/dummy-1 { true; }
  function ble/test/dummy-2 { true; }
  function ble/test/dummy-3 { true; }
  ble/test ble/bin#has ble/test/dummy-1
  ble/test ble/bin#has ble/test/dummy-{1..3}
  ble/test ble/bin#has ble/test/dummy-0 exit=1
  ble/test ble/bin#has ble/test/dummy-{0..2} exit=1
  alias ble_test_dummy_4=echo
  shopt -u expand_aliases
  ble/test '! ble/bin#has ble_test_dummy_4'
  shopt -s expand_aliases
  ble/test 'ble/bin#has ble_test_dummy_4'
)
(
  if [[ $OSTYPE == msys* ]]; then
    export MSYS=${MSYS:+$MSYS }winsymlinks
  fi
  ble/bin#freeze-utility-path readlink ls
  function ble/test:readlink.impl1 {
    ret=$1
    ble/util/readlink/.resolve-loop
  }
  function ble/test:readlink.impl2 {
    ret=$1
    ble/function#push ble/bin/readlink
    ble/util/readlink/.resolve-loop
    ble/function#pop ble/bin/readlink
  }
  ble/test/chdir
  cd -P .
  command mkdir -p ab/cd/ef
  command touch ab/cd/ef/file.txt
  command ln -s ef/file.txt ab/cd/link1
  command ln -s ab link.d
  command ln -s link.d/cd/link1 f.txt
  ble/test '
    ble/util/readlink f.txt
    [[ $ret != /* ]] && ret=${PWD%/}/$ret' \
    ret="${PWD%/}/ab/cd/ef/file.txt"
  command touch loop1.sh
  command ln -s loop1.sh loop0.sh
  command ln -s loop1.sh loop3.sh
  command rm loop1.sh
  command ln -s loop3.sh loop2.sh
  command ln -s loop2.sh loop1.sh
  for impl in impl1 impl2; do
    ble/test "ble/test:readlink.$impl loop0.sh" ret='loop1.sh'
  done
  mkdir -p phys.dir
  touch phys.dir/1.txt
  ln -s ../../../phys.dir ab/cd/ef/phys.link
  ln -s ab/cd/ef/phys.link phys.link
  local pwd=$PWD xpath=
  ble/test code:'
    path=phys.link/1.txt
    ble/util/readlink/.resolve-physical-directory
    declare -p path PWD >&2
    [[ $path == */phys.dir/1.txt && $PWD == "$pwd" ]]'
  ble/test/rmdir
)
(
  ble/test '[[ -d $_ble_base ]]'
  ble/test '[[ -d $_ble_base_run ]]'
  ble/test '[[ -d $_ble_base_cache ]]'
)
(
  qnl="\$'\n'"
  value=$'\nxxx is a function\nhello\nyyy is a function\n'
  pattern=$'\n+([][{}:[:alnum:]]) is a function\n'
  shopt -s extglob
  ble/test '[[ ${value//$pattern/'"$qnl"'} == '"$qnl"'hello'"$qnl"' ]]'
  shopt -u extglob
  ble/test '[[ ${value//$pattern/'"$qnl"'} != '"$qnl"'hello'"$qnl"' ]]'
)
ble/test/end-section
