#!/bin/bash
#
#
declare -g circa=$(basename $0 .sh)
declare -g flist=${circa}.txt
declare -g summation=${circa}.pdf
declare -g head=$(which head)
declare -g tail=$(which tail)
#
function usage {
    cat<<EOF>&2


      Echo file set in basename.

  <fxt>

      Echo file set in filename extension <fxt>.

  process

      Perform file set generation.

  add

      Perform file set update.

  tail

      Echo last basename

  -?

      This message.

EOF
}
#
function current {
  cat ${flist} | sed 's%/%%g; s%^%cygnus-%; s%$%-0%;'
}
#
function tail {
  ${tail} -n 1 ${flist} | sed 's%/%%g; s%^%cygnus-%; s%$%-0%;'
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
function process_tex {
    for src in $(fext tex); do tex ${src}; done
}
#
function process_dvips {
    for src in $(fext dvi); do dvips ${src}; done
}
#
function process_dvipdf {
    for src in $(fext dvi); do dvipdf ${src}; done
}
#
function process_summation {
    pdfunite $(fext pdf) ${summation}
}
#
function process {

    if process_tex
    then

        if process_dvips
        then

            if process_dvipdf
            then

                if process_summation
                then
                    git status --porcelain $(fext tex) $(fext dvi) $(fext ps) $(fext pdf) ${summation}
                    return 0
                else
                    cat<<EOF>&2
$0 [process] error in 'process_summation'.
EOF
                    return 1
                fi
            else
                cat<<EOF>&2
$0 [process] error in 'process_dvipdf'.
EOF
                return 1
            fi
        else
            cat<<EOF>&2
$0 [process] error in 'process_dvips'.
EOF
            return 1
        fi
    else
        cat<<EOF>&2
$0 [process] error in 'process_tex'.
EOF
        return 1
    fi
}
#
function tail_tex {
    for src in $(tail_fext tex); do tex ${src}; done
}
#
function tail_dvips {
    for src in $(tail_fext dvi); do dvips ${src}; done
}
#
function tail_dvipdf {
    for src in $(tail_fext dvi); do dvipdf ${src}; done
}
#
function add {

    # (update process)
    if cp ${flist} /tmp/tmp && date +%Y/%m/%d >> /tmp/tmp
    then
        cat -n /tmp/tmp | sed 's%^%A %;'
        if read -p 'Update? [Ny] ' update &&[ -n "${update}" ]&&[ "${update}" = 'y' -o "${update}" = 'Y' ]
        then
            cp /tmp/tmp ${flist}
        fi
    fi
    # (tail process)

    if tail_tex
    then

        if tail_dvips
        then

            if tail_dvipdf
            then

                if process_summation
                then
                    git status --porcelain $(tail_fext tex) $(tail_fext dvi) $(tail_fext ps) $(tail_fext pdf) ${summation}
                    return 0
                else
                    cat<<EOF>&2
$0 [add] error in 'process_summation'.
EOF
                    return 1
                fi
            else
                cat<<EOF>&2
$0 [add] error in 'tail_dvipdf'.
EOF
                return 1
            fi
        else
            cat<<EOF>&2
$0 [add] error in 'tail_dvips'.
EOF
            return 1
        fi
    else
        cat<<EOF>&2
$0 [add] error in 'tail_tex'.
EOF
        return 1
    fi
}
#
#
if [ -n "${1}" ]
then

    case "${1}" in
        process)
            if process
            then
                exit 0
            else
                exit 1
            fi
            ;;
        add)
            if add
            then
                exit 0
            else
                exit 1
            fi
            ;;
        tail)
            if tail
            then
                exit 0
            else
                exit 1
            fi
            ;;
        [a-z][a-z][a-z])
            if fext ${1}
            then
                exit 0
            else
                exit 1
            fi
            ;;
        *)
            usage
            exit 1
            ;;
    esac

else
    if current
    then
        exit 0
    else
        exit 1
    fi
fi
