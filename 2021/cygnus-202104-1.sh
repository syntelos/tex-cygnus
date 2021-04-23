#!/bin/bash
#
function usage {
    cat<<EOF>&2

Synopsis

  $0 process

Description

  Perform file set generation.

Synopsis

  $0 add

Description

  Perform file set update.

Synopsis

  $0 tail

Description

  Echo last basename

Synopsis

  $0

Description

  Echo file set in basename.

Synopsis

  $0 <fxt>

Description

  Echo file set in filename extension <fxt>.

Synopsis

  $0 -?

Description

  This message.

EOF
}
#
function current {
  cat cygnus-202104-1.txt | sed 's%/%%g; s%^%cygnus-%; s%$%-0%;'
}
#
function tail {
  tail -n 1 cygnus-202104-1.txt | sed 's%/%%g; s%^%cygnus-%; s%$%-0%;'
}
#
function fext {
  fxt="${1}"
  for src in $(current)
  do
    echo ${src}.${fxt}
  done
}
#
function tail_fext {
  fxt="${1}"
  for src in $(tail)
  do
    echo ${src}.${fxt}
  done
}
#
function process {
    for src in $(fext tex)
    do
        tex $src
    done

    for src in $(fext dvi)
    do
        dvips $src
    done

    for src in $(fext dvi)
    do
        dvipdf $src
    done

    pdfunite $(fext pdf) cygnus-202104-1.pdf
}
#
function add {
    for src in $(tail_fext tex)
    do
        tex $src
    done

    for src in $(tail_fext dvi)
    do
        dvips $src
    done

    for src in $(tail_fext dvi)
    do
        dvipdf $src
    done

    pdfunite $(fext pdf) cygnus-202104-1.pdf
}
#
if [ -n "${1}" ]
then

    if [ -n "$(echo ${1} | egrep '^process$')" ] && process
    then
        exit 0

    elif [ -n "$(echo ${1} | egrep '^add$')" ] && process
    then
        exit 0

    elif [ -n "$(echo ${1} | egrep '^tail$')" ] && tail
    then
        exit 0

    elif [ -n "$(echo ${1} | egrep '^[a-z][a-z][a-z]$')" ] && fext ${1}
    then
        exit 0
    else
        usage
        exit 1
    fi
else
    if current
    then
        exit 0
    else
        exit 1
    fi
fi
