#!/bin/bash
# Brian Wilson <brian@wiltech.org>
# Depends: bc xlsx2csv

CACHE_DIR=$(mktemp -d)

# Enable debug mode
DEBUG=false

if [[ "$DEBUG" == true ]]; then
    set -uo pipefail
    trap 's=$?; echo "$0: Error on line $LINENO: $BASH_COMMAND" $s' ERR
fi

# Commands to run on script exit
# Usage: defer '<command>'
exit_cmd=""
defer() { exit_cmd="$@; $exit_cmd"; }
trap 'bash -c "$exit_cmd"' EXIT

defer "rm -rf $CACHE_DIR"

CSV_CACHE=""

# Function: parse_rows
# $1: Starting column offset
# $2: length of clumns to pull from left to right
# $3: Number of rows to skip before starting to pull data
# Desc: parse the $CSV_CACHE into more simpliefied csv data
# that is easier to work with
parse_rows() {
    _starting_ofst="$1"
    _ending_ofst=$(bc <<< "$_starting_ofst + $2")
    _skip_rows="$3"

    while read -r _row; do
        _tmp=$(echo $_row | awk -v s=$_starting_ofst -v e=$_ending_ofst 'BEGIN{FS=OFS=","}{for (i=s; i<=e; ++i) printf "%s%s", $i, (i<e?OFS:ORS)}')
        # Check to see if our first column is not empty ...
        # Checks that very first character of the row is not a ','
        if [[ ! "$_tmp" =~ ^, ]]; then
            echo "$_tmp"
        fi
    done <<< $(echo "$CSV_CACHE" | awk "NR > $_skip_rows")
}

# Production Logs...
echo "Running Production Logs..."
CSV_CACHE=$(xlsx2csv -f "%Y-%m-%d" "$1" 2> /dev/null)

OUT_FILE="test.txt"
echo "" > "$OUT_FILE" # Blank the file out

wln() {
    echo "$1" | tee -a "$OUT_FILE"
}

data=$(parse_rows 1 11 1 | sed 's/ /\\_/g')

saveIFS=$IFS
for row in ${data[@]}; do
    IFS=','
    cols=($row)
    IFS=$saveIFS
    
    friendlyName="$(echo ${cols[0]} | sed 's/\\_/ /g')"
    ammoType="$(echo ${cols[1]} | sed 's/\\_/ /g')"
    formID="$(echo ${cols[2]} | sed 's/\\_/ /g')"
    baseDmg="$(echo ${cols[3]} | sed 's/\\_/ /g')"
    randDmgMult="$(echo ${cols[6]} | sed 's/\\_/ /g')"
    outOfRangeDmgMult="$(echo ${cols[7]} | sed 's/\\_/ /g')"
    baseDmgPistolMult="$(echo ${cols[8]} | sed 's/\\_/ /g')"
    outOfRangePistolMult="$(echo ${cols[9]} | sed 's/\\_/ /g')"
    onHit="$(echo ${cols[10]} | sed 's/\\_/ /g')"
    reloadSpeedMult="$(echo ${cols[11]} | sed 's/\\_/ /g')"
    
    formID=${formID:(-6)}

    echo "AmmoList.Add('$formID=$baseDmg,$randDmgMult,$outOfRangeDmgMult,$baseDmgPistolMult,$outOfRangePistolMult,$onHit,$reloadSpeedMult');" | tee -a "$OUT_FILE"

done
