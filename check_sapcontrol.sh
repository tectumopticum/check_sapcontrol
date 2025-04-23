#!/bin/bash

version=1.3
verbose=0
# mandatory parameters:
hostflag=0
sidflag=0
sysnrflag=0
typeflag=0

# find out name of script
scriptname=$(/usr/bin/basename "$0")
# source utils.sh
if [ -f /usr/local/nagios/libexec/utils.sh ]; then
  . /usr/local/nagios/libexec/utils.sh
else
  . /usr/lib/nagios/plugins/utils.sh
fi

# add var-definitions
sedpath=/bin/sed
awkpath=/bin/awk
sapctlpath=/usr/sap/hostctrl/exe/sapcontrol

functiontype=GetProcessList

# define functions

function printUsage() {
 echo
 echo "This plugin checks the status of a SAP-system by using sapcontrol"
 echo
 echo "Usage: $scriptname [-H hostname|IP] [-S SID] [-N SYS-nr] [-T systemtype] [-i tenant-id] [-s service-instance] [-h] [-v] [-V]"
 echo "Options:"
 echo " -H hostname or IP of SAP-system"
 echo " -S SAP-Id"
 echo " -N SYS-Number (network-port)"
 echo " -T SAP-systemtype [ABAP_DW|ABAP_ENQ|ABAP_MSG|ABAP_GW|ABAP_ICM|JAVA_MSG|JAVA_ENQ|JAVA_GW|JAVA_JSTART|JAVA_SRV0|JAVA_SRV1|JAVA_SRV2|JAVA_SRV3|JAVA_SRV|HDB_NS|HDB_IDX]"
 echo " -i tenant-Id"
 echo " -s SAP central service instance"
 echo " -v verbose output [1|2|3]"
 echo " -V Version"
 echo " -h this help"
 }

function printVersion() {
 echo
 echo "$scriptname Version $version"
 echo
}

function checkOptions() {
 while getopts ":hVv:N:s:i:H:S:i:T:" opt; do
  case $opt in
   H) HOST=$OPTARG
      hostflag=1;
      #echo "hostname is $HOST"
      ;;
   S) SID=$OPTARG
      sidflag=1;
      ;;
   N) NR=$OPTARG
      sysnrflag=1;
      ;;
   T) TYPE=$OPTARG
      typeflag=1;
      ;;
   i) TENANTID+=("$OPTARG")
      ;;
   s) SCSNR=$OPTARG
      ;;
   v) verbose=$OPTARG
      ;;
   h) printUsage
      exit "$STATE_UNKNOWN"
      ;;
   V) printVersion
      exit "$STATE_UNKNOWN"
      ;;
   \?)echo
      echo "Invalid option: $OPTARG"
      printUsage
      exit "$STATE_UNKNOWN"
      ;;
   :) echo
      echo "Invalid option: $OPTARG requires an argument"
      printUsage
      exit "$STATE_UNKNOWN"
      ;;
   *) printUsage
      ;;
  esac
 done
}

function checkNumberArgs() {
mandarg=$((hostflag + sidflag + sysnrflag + typeflag))
if [ "$OPTIND" -eq 1 ] || [ "$mandarg" -lt 4 ];
then
   echo
   echo  "Error: Not enough arguments provided or mandatory arguments missing."
   printUsage
   exit "$STATE_UNKNOWN"
 fi
}


checkOptions "$@"
checkNumberArgs

if [ -e "$sapctlpath" ] || [ -x "$sapctlpath" ]; then
   sapctl="sudo -u icinga /usr/sap/hostctrl/exe/sapcontrol"
else
   echo "$sapctlpath not found or executable"
   exit "$STATE_UNKNOWN"
fi


#set default-state
STATE="UNDEFINED"
PARAMETERS=$*

case $TYPE in

  ABAP_DW)
     regstring="disp+work"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "disp+work")
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;

  ABAP_ENQ)
     regstring="enserver"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "enserver")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  ABAP_MSG)
     regstring="msg_server"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "msg_server")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  ABAP_GW)
     regstring="gwrd"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "gwrd")
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  ABAP_ICM)
     regstring="icman"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "icman")
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  JAVA_ENQ)
     regstring="enserver"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function GetProcessList|grep "enserver")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  JAVA_MSG)
     regstring="msg_server"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function GetProcessList|grep "msg_server")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  JAVA_GW)
     regstring="gwrd"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "gwrd")
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  JAVA_JSTART)
     regstring="jstart"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "jstart")
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $4}'|$sedpath 's/,//g')
     ;;
  JAVA_SRV0)
     regstring="server0"
     functiontype="J2EEGetProcessList"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function J2EEGetProcessList|grep "server0")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $9}'|$sedpath 's/,//g')
     ;;
  JAVA_SRV1)
     regstring="server1"
     functiontype="J2EEGetProcessList"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function J2EEGetProcessList|grep "server1")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $9}'|$sedpath 's/,//g')
     ;;
  JAVA_SRV2)
     regstring="server2"
     functiontype="J2EEGetProcessList"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function J2EEGetProcessList|grep "server2")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $9}'|$sedpath 's/,//g')
     ;;
  JAVA_SRV3)
     regstring="server3"
     functiontype="J2EEGetProcessList"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function J2EEGetProcessList|grep "server3")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $9}'|$sedpath 's/,//g')
     ;;
  JAVA_SRV)
     regstring="J2EE Server"
     functiontype="J2EEGetProcessList"
     badjava=0   # Bad Java Services
     goodjava=0  # Good Java Services
     declare -a myJavaServers
     
     readarray myJavaServers < <($sapctl -host $HOST -nr $SCSNR -function $functiontype | grep $regstring)

     if [[ "$verbose" -gt 1 ]]
       then
          printf "Processes detected for $regstring: %s\n" "${#myJavaServers[@]}"
          echo ${myJavaServers[@]}
     fi

     for i in ${!myJavaServers[@]};
       do
         STATE=$(echo ${myJavaServers[$i]}|$awkpath 'NF{print $9}'|$sedpath 's/,//g')
         if [[ "$STATE" == "Running" ]]
           then
            ((goodjava++))
           else
            ((badjava++))
         fi
       done

     if [[ "$verbose" -gt 1 ]]
       then
         echo "Number good JAVA : $goodjava"
         echo "Number bad  JAVA : $badjava"
     fi

     if [[ "${#myJavaServers[@]}" -eq 0 ]]
     then
        STATE="NOTFOUND"
     elif [[ "${#myJavaServers[@]}" -gt 0 ]] && [[ "goodjava" -gt 0 ]] && [[ "badjava" -eq 0 ]]
       then
         STATE='GREEN'
     elif [[ "goodjava" -gt 0 ]] && [[ "badjava" -eq 1 ]]
       then
         STATE='YELLOW'
     else
       STATE='RED'
    fi
   ;;
  HDB_NS)
  # HANA DB Nameserver
     regstring="Nameserver"
     #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep Nameserver)
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype)
     STATE=$(echo "$OUTPUT"|grep $regstring|$awkpath 'NF{print $4}'|$sedpath 's/,//g')
     ;;
  HDB_IDX)
  # HANA DB Indexserver
     regstring="Index"
    # when executng HDB_IDX with TENANTID=ALL we loop over all detected indexservers-Tenants in processlist
    if [[ "$TENANTID" == "ALL" ]]
       then
          badidx=0  # Bad Index Server
          goodidx=0 # Good Index Server
          declare -a myTenants
          #myTenants=("")
          readarray myTenants < <($sapctl -host "$HOST" -nr "$NR" -function $functiontype|grep $regstring)

          if [[ "$verbose" -gt 1 ]]
             then
                printf "Tenants detected for $regstring: %s\n" "${#myTenants[@]}"
		echo ${myTenants[@]}
          fi

          for i in ${!myTenants[@]};
             do
                STATE=$(echo ${myTenants[$i]}|$awkpath 'NF{print $5}'|$sedpath 's/,//g')
                if [[ "$STATE" == "GREEN" ]] || [[ "$STATE" == "Running" ]]
                   then
                     ((goodidx++))
                   else
                     ((badidx++))
                fi
             done

          if [[ "$verbose" -gt 1 ]]
             then
                echo "Number good IDX : $goodidx"
                echo "Number bad  IDX : $badidx"
          fi

          if [[ "${#myTenants[@]}" -eq 0 ]]
            then
                STATE="NOTFOUND"
          elif [[ "${#myTenants[@]}" -gt 0 ]] && [[ "goodidx" -gt 0 ]] && [[ "badidx" -eq 0 ]]
            then
                STATE="GREEN"
          else
                STATE="RED"
          fi
    elif [[ "${#TENANTID[@]}" -gt 1 ]]
       then
	  badidx=0  # Bad Index Server
          goodidx=0 # Good Index Server
	  for i in ${!TENANTID[@]};
             do
               OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype)
               STATE=$(echo "$OUTPUT" |grep $regstring|grep "${TENANTID[$i]}"|$awkpath 'NF{print $4}'|$sedpath 's/,//g')
                if [[ "$STATE" == "GREEN" ]] || [[ "$STATE" == "Running" ]]
                   then
                     ((goodidx++))
                   else
                     ((badidx++))
                fi
             done

          if [[ "$verbose" -gt 1 ]]
             then
                echo "Number good IDX : $goodidx"
                echo "Number bad  IDX : $badidx"
          fi

          if [[ "goodidx" -gt 0 ]] && [[ "badidx" -eq 0 ]]
            then
                STATE="GREEN"
          else
                STATE="RED"
          fi

    else
       #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep Index|grep $SID)
       # if we want only one tenant we use the tenantID-parameter for grep:
       OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype)
       STATE=$(echo "$OUTPUT"|grep $regstring|grep "$TENANTID"|$awkpath 'NF{print $4}'|$sedpath 's/,//g')
    fi
     ;;
  *)
    echo -n "unknown Type"
    exit "$STATE_UNKNOWN"
    ;;
esac

if [[ "$verbose" -gt 1 ]]
 then
  echo "parameters passed to script:"
  echo "$PARAMETERS"
fi

if [[ "$verbose" -gt 2 ]]
 then
  echo "List of tenant-values is '${TENANTID[@]}'"
  echo "content of \$OUTPUT-variable:"
  echo "$OUTPUT"
  echo "content of \$STATE-variable:"
  echo "$STATE"
fi


if [[ "$STATE" == "" ]] || [[ "$STATE" == "NOTFOUND" ]]
  then
    STATE=NOTFOUND
    echo "UNKNOWN - sapcontrol-state for $regstring (Tenant-ID: $TENANTID) is $STATE"
    if [[ "$verbose" -eq 1 ]]
    then
       echo "$OUTPUT"
    fi
    exit "$STATE_UNKNOWN"
elif [[ "$STATE" == "GREEN" ]] || [[ "$STATE" == "Running" ]]
  then
    #echo -e "\033[42m\033[30mOK\033[0m"
    echo "OK - sapcontrol-state for $regstring is $STATE"
    if [[ "$verbose" -eq 1 ]]
    then
       echo "$OUTPUT"
    fi
    exit "$STATE_OK"
elif [[ "$STATE" == "YELLOW" ]]
  then
    #echo -e "\033[43m\033[30mWARNING\033[0m"
    echo "WARNING - sapcontrol-state $regstring is $STATE"
    if [[ "$verbose" -eq 1 ]]
    then
       echo "$OUTPUT"
    fi
    exit "$STATE_WARNING"
else
    #echo -e "\033[41m\033[30mERROR\033[0m"
    echo "ERROR - sapcontrol-state $regstring is $STATE"
    if [[ "$verbose" -eq 1 ]]
    then
       echo "$OUTPUT"
    fi
    exit "$STATE_CRITICAL"
fi
