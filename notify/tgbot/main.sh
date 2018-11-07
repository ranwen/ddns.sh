CURDIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
cd $CURDIR
source config

log()
{
	echo "[$(date "+%m-%d %H:%M:%S")]$1:$2"
}
tg_req()
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
        curl -X $1 "https://api.telegram.org/bot$BOTTOKEN/$2" $atte 2> /dev/null
    else
        curl -X $1 "https://api.telegram.org/bot$BOTTOKEN/$2" $atte --data "$3" 2> /dev/null
    fi
}
tg_req "POST" "sendMessage" "chat_id=$OWNERID&text=$1" > /dev/null
log notify_tgbot "Send $1"