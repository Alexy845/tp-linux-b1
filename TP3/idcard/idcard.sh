 #!/bin/bash
echo "$/srv/idcard/idcard.sh"

echo "Machine name : $(hostnamectl | grep hostname | cut -d':' -f2)"

source /etc/os-release
echo "OS ${NAME} and kernel version is $(uname -rs)"

echo "IP : $(hostname -I | cut -d' ' -f2)"

echo "RAM : $(free -h | grep Mem | tr -s ' ' | cut -d ' ' -f7) memory available on $(free -h | grep Mem | tr -s ' ' | cut -d ' ' -f2) total memory"

echo "Disk : $(df -h | grep rl | tr -s ' ' | cut -d ' ' -f4) space left"

echo "Top 5 processes by RAM usage :"


for i in $(seq 1 5)
do
  echo "  - $(ps -eo pmem,args | tail -n +2 | sort -rnk 1 | sed -n ${i}p)"
done

echo "Listening ports :"

ss_outpout="$(sudo ss -alnptu4H | tr -s ' ')"
while read line
do
  port=$(echo "$line" | cut -d' ' -f5 | cut -d':' -f2)
  program=$(echo "$line" | cut -d'"' -f2)
  type=$(echo "$line" | cut -d' ' -f1)
  echo "  - $port $type : $program"
done <<< "${ss_outpout}"

curl --silent -o cat.jpg https://cataas.com/cat

echo " Here is your random cat : $(ls cat.jpg)"