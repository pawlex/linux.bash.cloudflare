#!/bin/bash
###################################################################
#Script Name    : cloudflareZoneRecord.sh
#Description    : A quick and dirty shell script to view and 
#               : manipulate cloudflare zone records
#Args           : GETZONE,GETRECORD,SETRECORD,DYNDNSUPDATE
#Author         : Paul Komurka
#Email          : pawlex@gmail.com
###################################################################

## QUIT IF NO ARGS PASSED
if [ $# -lt 1 ]
then
        echo "Usage : $0 <COMMAND> <RECORD>"
        exit
fi

# Need to make sure the system has CURL installed.
if hash curl 2>/dev/null; then
    CURL=`which curl`
else
    printf "CURL not installed"
    exit -1
fi


# Load configuration from file if it exists.
# You may also define your credendials inline (below)
if [ -e ./config.cf ]; then
    source ./config.cf
fi

# REQUIRED
#EMAIL="user@email"         # CloudFlare account ID
#GLOBAL_API_KEY="apikey"    # CloudFlare account API Key
#ZONEID="zonekey"           # CloudFlare zone key
# OPTIONAL
#DYNDNSRECORDID="700f7b170dcd84adasdadadas"
#DYNDNSRECORDNAME="foo.bar.baz"
#DYNDNSRECORDTYPE="A"

function formatJson() {
    # Reformat output if json_reformat exists
    if hash json_reformat 2>/dev/null; then
        echo "$(echo $1 | json_reformat)"
    else
        echo "$1"
    fi
}


# GET RECORD
function getRecord() {
    RECORDTYPE=$1
    RECORDNAME=$2
    RETVAL=$($CURL -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records?type=$RECORDTYPE&name=$RECORDNAME" \
        -H "X-Auth-Email: $EMAIL" \
        -H "X-Auth-Key: $GLOBAL_API_KEY" \
        -H "Content-Type: application/json")
    RETVAL=$(formatJson $RETVAL)
    printf "$RETVAL\n"
}

# UPDATE RECORD
function setRecord() {
    RECORDID=$1
    RECORDTYPE=$2
    RECORDNAME=$3
    RECORDVALUE=$4
    #
    RETVAL=$($CURL -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$RECORDID" \
         -H "X-Auth-Email: $EMAIL" \
         -H "X-Auth-Key: $GLOBAL_API_KEY" \
         -H "Content-Type: application/json" \
         --data "{\"type\":\"$RECORDTYPE\",\"name\":\"$RECORDNAME\",\"content\":\"$RECORDVALUE\"}")# &> /dev/null
    #
    if [[ "$RETVAL" == *'"success":true'* ]]; then
        echo "SUCCESS"
        exit 0
    else
        echo "FAILED"
        printf "$RETVAL\n"
        exit -1
    fi
}

# GET ALL ZONE RECORDS
function getZone() {
    RETVAL=$($CURL -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records" \
        -H "X-Auth-Email: $EMAIL" \
        -H "X-Auth-Key: $GLOBAL_API_KEY" \
        -H "Content-Type: application/json" )
    RETVAL=$(formatJson $RETVAL)
    printf "$RETVAL\n"
}


##  PROGRAM ARGS
case "$1" in

GETZONE)
        getZone
;;

GETRECORD) if [ $# -lt 3 ]
        then
            echo "Usage : $0 $1 <RECORD TYPE: EG AAAA> <RECORDNAME: EG www.domain.com>"
            exit
        fi
        getRecord $2 $3
;;

SETRECORD) if [ $# -lt 5 ]
       then
            echo
            echo "  Usage  : $1 <id*> <type> <name> <value>"
            echo "  Example: $1 94a30abbca443e03fd11aa00ca74627e AAAA test.mydomain.org 127.0.0.1"
            echo "      * record id can found by running GETZONE"
            echo
            exit -1
        fi

        setRecord $2 $3 $4 $5
;;

DYNDNSUPDATE)

    if [ -z "$DYNDNSRECORDID" ] || [ -z "$DYNDNSRECORDNAME" ] || [ -z "$DYNDNSRECORDTYPE" ]; then
        printf "\$DYNDNSRECORDID, \$DYNDNSRECORDNAME, \$DYNDNSRECORDTYPE not defined!\n"
        exit -1
    fi
    
    if hash host 2>/dev/null; then
        HOST=`which host`
    else
        printf "host not installed.  cannot resolve $DYNDNSRECORDNAME"
        exit -1
    fi

    ## GRAB CURRENT LOCAL IP ADDRESS and PREVIOUS IP address from cloudflare
    CURRENT_IP=$($CURL -s checkip.dyndns.org | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])')
    PREVIOUS_IP=$($HOST -4 $DYNDNSRECORDNAME ken.ns.cloudflare.com | grep "has address" | cut -d" " -f4)
    
    if [ $CURRENT_IP == $PREVIOUS_IP ]; then
        echo "NO UPDATE NECESSARY"
    else
        echo "UPDATE NECESSARY"
        echo "$PREVIOUS_IP -> $CURRENT_IP"
        setRecord $DYNDNSRECORDID $DYNDNSRECORDTYPE $DYNDNSRECORDNAME $CURRENT_IP
    fi
;;

*) echo echo "Usage : $0 <COMMAND> <RECORD>"
;;

esac

exit 0
