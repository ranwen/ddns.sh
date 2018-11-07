CURDIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
cd $CURDIR
source config

log()
{
	echo "[$(date "+%m-%d %H:%M:%S")]$1:$2"
}
curl "https://tgbot.lbyczf.com/sendMessage/$TOKEN?text=$1" > /dev/null 2> /dev/null
log notify_notificationme_bot "Send $1"