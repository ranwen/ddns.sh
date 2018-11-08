gg=$(curl http://ip-api.com/json -4 2>/dev/null | grep -o "\"query\":\"[^\"]*" | grep -o "\([0-9]\{1,3\}.\)\{3\}[0-9]\{1,3\}")
echo $gg