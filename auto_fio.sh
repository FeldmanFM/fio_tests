#!/bin/bash

#### GLOBAL VARIABLES

IFS=';'
test_disk=$1
fio_config=auto_fio.ini
bs="4k;512k"
mode=write
fsize="1G"
iodepth="1;2;4;8;16"



#### FUNCTIONS


function create_fio_file {
cat > $7 << EOF
$6
[$4 with bs $2 and iodepth $1]
blocksize=$2
filename=$3
rw=$4
direct=1
buffered=0
ioengine=libaio
iodepth=$1
size=$5
EOF
}



#### MAIN SCRIPT

if [ -z $1 ]; then
	echo "You should enter the file/disk to check"
	echo "usage: $0 /dev/example"
	exit 255
fi

printf 'TEST IN PROGRESS\ntest: mode %s, filesize %s, filename %s\nbs\tfsize\tiodepth\tbw,KB/s\tiops\tlat\n' $mode $fsize $test_disk

for bs in $bs
 do
 for i in $iodepth
  do
	phrase="#created at with $0 $(date +%F/%H-%M-%S)"
	create_fio_file $i $bs $test_disk $mode $fsize $phrase $fio_config
	line=($(fio $fio_config --minimal ))
	if [ $mode = "read" ]; then
		printf '%s\t%s\t%s\t%s\t%s\t%s\n' $bs $fsize $i ${line[6]} ${line[7]} ${line[15]}
  	elif [ $mode = "write" ]; then
		printf '%s\t%s\t%s\t%s\t%s\t%s\n' $bs $fsize $i ${line[47]} ${line[48]} ${line[56]}
	fi
		
  done
done
