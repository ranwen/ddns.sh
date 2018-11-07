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
else
    FULLDOMAIN="$SUBDOMAIN.$PRIMARY_DOMAIN"
fi

log()
{
	echo "[$(date "+%m-%d %H:%M:%S")]$1:$2"
}

cf_req()
{
    if [ ! -z $CURLPROXY ]
    then
        atte="--proxy $CURLPROXY"
    fi
    if [ ! -z $SOCKSPROXY ]
    then
        atte="--socks5-hostname $SOCKSPROXY"
    fi
    if [ $1 == "GET" ]
    then
        curl -X $1 "https://api.cloudflare.com/client/v4/$2" \
        -H "X-Auth-Email: $CF_MAIL" \
        -H "X-Auth-Key: $CF_KEY" \
        -H "Content-Type: application/json" $atte 2> /dev/null
    else
        curl -X $1 "https://api.cloudflare.com/client/v4/$2" \
        -H "X-Auth-Email: $CF_MAIL" \
        -H "X-Auth-Key: $CF_KEY" \
        -H "Content-Type: application/json" $atte \
        --data "$3" 2> /dev/null
    fi
}

if [ -z $CF_ID ]
then
    CF_ID=$(cf_req "GET" "zones?name=$PRIMARY_DOMAIN" | grep -o "\[.\"id\":\"[^\"]*\"" | grep -o "[0-9a-f]\\{32\\}")
    if [ -z $CF_ID ]
    then
        echo "DNS API ERROR"
        exit 1
    fi
    echo >> config
    echo "#added by ddns.sh" >> config
    echo "export CF_ID=\"$CF_ID\"" >> config
fi
log dns_cf "ZoneID:$CF_ID"
res=$(cf_req "GET" "zones/$CF_ID/dns_records?type=A&name=$FULLDOMAIN")
cnt=$(echo $res | grep -o "\"count\":[^\,]*" | grep -o "[0-9]\+")
if [ $cnt == "0" ]
then
    log dns_cf "Subdomain not found"
    cf_req "POST" "zones/$CF_ID/dns_records" "{\"type\":\"A\",\"name\":\"$SUBDOMAIN\",\"content\":\"$IP\"}" > /dev/null
    log dns_cf "Created $SUBDOMAIN:$IP"
else
    log dns_cf "Subdomain found"
    DID=$(echo $res | grep -o "\"id\":\"[0-9a-f]\{32\}\"" | grep -o "[0-9a-f]\{32\}")
    OIP=$(echo $res | grep -o "\"content\":\"[^\"]\+\"" | grep -o "\([0-9]\{1,3\}.\)\{3\}[0-9]\{1,3\}")
    cf_req "PUT" "zones/$CF_ID/dns_records/$DID" "{\"type\":\"A\",\"name\":\"$SUBDOMAIN\",\"content\":\"$IP\"}" > /dev/null 
    log dns_cf "Changed $SUBDOMAIN:$OIP->$IP"
fi