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
