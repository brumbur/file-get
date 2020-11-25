#!/bin/bash


###########################
# functions
###########################

# monitor given remote directory and download new files to the target directory
function usage {
  echo -e "Usage:\n\t`basename $0` <url> [chunk size (default: 128MB)] [sourcedir (default: autodetect)] [targetdir (default: autodetect)]"
  exit 1
}

#Cleanup on kill
function clean {
  echo "Download failed! Cleaning..."
  # kill 0
  rm $OUT_DIR/$FILENAME.* 2> /dev/null
  rm -R $OUT_DIR/wrk 2> /dev/null
  exit 1
}


# get the file details and parse the size
function getSize() {
  local SIZE="`curl -qIL $1 2> /dev/null | awk '/Length/ {print $2}'|grep -o '[0-9]*'`"
  local SIZE=${SIZE:-1}
  echo $SIZE
  return
}


# function download() {

# }

# takes an array refference and updates it with the file names in the given directory
function getDirectoryContent() {
  local -n arr=$1
  local url="$2"

  arr=($(curl -s '$url/' | sed -nr 's/(^-[ rw-].*)( *)([0-9])(.*)/\4/p' | sed -e 's/^ //g' | sed -e 's/ /\ /g'))

  return
}

# takes the complete URL as argument and returns the last modified time
function getLastModifiedDate() {
    local filename=$1
    local dt=`curl -I "$url/$filename" 2>&1 | awk '/Last-Modified:/ {sub("\r",""); print  $2,$3,$4,$5,$6,$7}'`
    local ms="$(date -d "${dt}" '+%s')" # convert to ms
    echo "$ms"
    return
}

# filters out any files that are older than the cutoff time
function getNewFiles() {
    local -n arr=$1
    local cutoff=$2

    for f in ${arr[@]}; do
        local lmd=$(getLastModifiedDate "$f")
        if [ $cutoff -gt $lmd ]; then
            arr=("${arr[@]/$f}") # remove old file
        fi
    done
    return
}

function get() {
  local url="$1"
  local ms="$(date -d "$2" '+%s')"
  local -n files_arr=$3

  getDirectoryContent f_arr $url
  getNewFiles files_arr $ms
}

#Test splitness
function test() {
  OUT=`curl -m 2 --range 0-0 $URL 2> /dev/null`
  case ${#OUT} in
    0)  echo "curl error";; #Curl error
    1)  echo ;; #OK, got a byte
    *)  echo Server does not split...;SPLIT_NUM=1;; #Got more than asked for
  esac
}

function calcProgress() {
  # local FNAME=$1
  # local PARTNUM=$2
  # local SZ=$3
  # local T=$4

  local GOTSIZE=$((`eval ls -l "$1".{1..$2} 2> /dev/null|awk 'BEGIN{SUM=0}{SUM=SUM+$5}END{print SUM}'`))
  local TIMEDIFF=$(( `date +%s` - $4 ))
  local RATE=$(( ($GOTSIZE / $TIMEDIFF)/1024 ))
  local PCT=$(( ($GOTSIZE*100) / $3 ))

  echo -n "Downloading $1 in $2 parts: $(($GOTSIZE/1048576)) / $(($3/1048576)) mb @ $(($RATE)) KB/s ($PCT%).    "

  return
}

function download() {
  local SRC="$1"
  local DEST="$2"
  local FILE_NAME=$3
  local FILE_SIZE=$4
  local SPLIT_SIZE=$5

  SPLIT_NUM=$((${FILE_SIZE:-0}/$SPLIT_SIZE))
  [ $SPLIT_NUM -ne 0 ] || SPLIT_NUM=1

  WRK_DIR="$DEST/wrk"
  [ -f "$WRK_DIR" ] || `mkdir -m 755 "$WRK_DIR"`

  echo "Downloading $FILE_NAME from: $SRC to: $DEST"
  echo "FILE_SIZE: $FILE_SIZE"
  echo "SPLIT_SIZE: $SPLIT_SIZE"
  echo "SPLIT_NUM: $SPLIT_NUM"
  echo "WRK_DIR: $WRK_DIR"

  local START=0
  local CHUNK=$((${FILE_SIZE:-0}/${SPLIT_NUM:-1}))
  local END=$CHUNK

  #Invoke curls
  for PART in `eval echo {1..$SPLIT_NUM}`;do
    echo "curl --ftp-pasv -o $WRK_DIR/$FILE_NAME.$PART --range $START-$END $SRC/$FILE_NAME"
    curl --ftp-pasv -o "$WRK_DIR/$FILE_NAME.$PART" --range $START-$END "$SRC/$FILE_NAME" 2> /dev/null &
    START=$(($START+$CHUNK+1))
    END=$(($START+$CHUNK))
  done

  #Wait for all parts to complete while spewing progress
  TIME=$((`date +%s`-1))
  while jobs | grep -q Running ; do
    # echo $(calcProgress "$WRK_DIR/$FILE_NAME" $SPLIT_NUM $FILE_SIZE $TIME)
    tput ech ${#FILE_SIZE}
    tput cub 1000
    sleep 1
  done

  # echo $(calcProgress "$WRK_DIR/$FILE_NAME" $SPLIT_NUM $FILE_SIZE $TIME)

  #Join all the parts
  eval cat "$WRK_DIR/$FILE_NAME".{1..$SPLIT_NUM} > "$DEST/$FILE_NAME"

  if [ $? -eq 0 ]
  then
    echo "Download completed! Check file $DEST"
    rm -R $WRK_DIR
  else
    echo "Could not download file: $?" >&2
    clean
  fi

  return
}


###########################
# main
###########################
FILENAME="AppleSoftwareUpdate.msi"
downloader_output_dir="/home/alex/dev/file-get/td"
OUT_DIR=${downloader_output_dir:-"/tmp"}

URL=$1
cutoff=$2

# declare -a f_arr
# getDirectoryContent f_arr $URL
# get "$1" "$2" f_arr
# echo "Found ${#f_arr[@]} files"

SPLIT_SIZE=${3:-${downloader_chunk_size:-128}}
SPLIT_SIZE=$(($SPLIT_SIZE * 1024 * 1024)) # convert to Mbs
echo "SPLIT_SIZE: $SPLIT_SIZE"

FILE_SIZE=$(getSize "$URL/$FILENAME")
echo "FILE_SIZE: $FILE_SIZE"

#Trap ctrl-c
trap clean SIGINT SIGTERM

# local SRC="$1"
# local DEST="$2"
# local FILE_NAME=$3
# local FILE_SIZE=$4
# local SPLIT_SIZE=$5
download "$URL" "$OUT_DIR" "$FILENAME" $FILE_SIZE $SPLIT_SIZE

# ./file-get.sh ftp://alex:ficus5657@192.168.1.1:21/media/apps/Apple "Mon, 17 Feb 2020 20:38:04 GMT" 1