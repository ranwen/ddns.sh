gg=$(curl https://ifconfig.co/json -4 2>/dev/null | grep -o "\"ip\":\"[^\"]*" | grep -o "\([0-9]\{1,3\}.\)\{3\}[0-9]\{1,3\}")
echo $gg