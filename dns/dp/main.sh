#remove CF_ID in config after edit the domain

CURDIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
PRIMARY_DOMAIN=$1
SUBDOMAIN=$2
IP=$3
cd $CURDIR
source config

if [ $SUBDOMAIN == $PRIMARY_DOMAIN ]
then
    FULLDOMAIN=$SUBDOMAIN
    SUBDOMAIN="@"
else
    FULLDOMAIN="$SUBDOMAIN.$PRIMARY_DOMAIN"
fi

log()
{
	echo "[$(date "+%m-%d %H:%M:%S")]$1:$2"
}

dp_req()
{
    if [ ! -z $CURLPROXY ]
    then
        atte="--proxy $CURLPROXY"
    fi
    if [ ! -z $SOCKSPROXY ]
    then
        atte="--socks5-hostname $SOCKSPROXY"
    fi
    gg="$3&login_token=$DP_ID,$DP_TOKEN&format=json"
    if [ $1 == "GET" ]
    then
        curl -X $1 "https://dnsapi.cn/$2" $atte 2> /dev/null
    else
        curl -X $1 "https://dnsapi.cn/$2" $atte \
        --data "$gg" 2> /dev/null
    fi
}

res=$(dp_req "POST" "Record.List" "domain=$PRIMARY_DOMAIN&sub_domain=$SUBDOMAIN&record_type=A")
st=$(echo $res | grep -o "\"status\":[^\,]*" | grep -o "[0-9]\+")
if [ ! $st == "1" ]
then
    log dns_dp "Subdomain not found"
    dp_req "POST" "Record.Create" "record_line=%E9%BB%98%E8%AE%A4&domain=$PRIMARY_DOMAIN&sub_domain=$SUBDOMAIN&record_type=A&value=$IP" > /dev/null
    log dns_dp "Created $SUBDOMAIN:$IP"
else
    log dns_dp "Subdomain found"
    DID=$(echo $res | grep -o "\"records\":\\[[^}]*" | grep -o "\"id\":[^\,]*" | grep -o "[0-9]\+")
    OIP=$(echo $res | grep -o "\"records\":\\[[^}]*" | grep -o "\"value\":[^\,]*" | grep -o "\([0-9]\{1,3\}.\)\{3\}[0-9]\{1,3\}")
    dp_req "POST" "Record.Modify" "record_line=%E9%BB%98%E8%AE%A4&domain=$PRIMARY_DOMAIN&sub_domain=$SUBDOMAIN&record_type=A&value=$IP&record_id=$DID" > /dev/null
    log dns_dp "Changed $SUBDOMAIN:$OIP->$IP"
fi