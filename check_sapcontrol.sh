#!/bin/bash

version=1.2
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
 echo " -v verbose output [0|1|2|3]"
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
   i) TENANTID=$OPTARG
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

#export LD_LIBRARY_PATH="/usr/sap/Q10/SYS/exe/run:/usr/sap/Q10/SYS/exe/uc/linuxx86_64:/usr/sap/Q10/hdbclient"
case $TYPE in

  ABAP_DW)
     regstring="disp+work"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "disp+work")
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;

  ABAP_ENQ)
     regstring="enserver"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "enserver")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  ABAP_MSG)
     regstring="msg_server"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "msg_server")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  ABAP_GW)
     regstring="gwrd"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "gwrd")
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  ABAP_ICM)
     regstring="icman"
     # 20230925, i007163, added sudo to sapcontrol-call
     #OUTPUT=$(sudo -u icinga /usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "icman")
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  JAVA_ENQ)
     regstring="enserver"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function GetProcessList|grep "enserver")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  JAVA_MSG)
     regstring="msg_server"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function GetProcessList|grep "msg_server")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  JAVA_GW)
     regstring="gwrd"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "gwrd")
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $3}'|$sedpath 's/,//g')
     ;;
  JAVA_JSTART)
     regstring="jstart"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep "jstart")
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $4}'|$sedpath 's/,//g')
     ;;
  JAVA_SRV0)
     regstring="server0"
     functiontype="J2EEGetProcessList"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function J2EEGetProcessList|grep "server0")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $9}'|$sedpath 's/,//g')
     ;;
  JAVA_SRV1)
     regstring="server1"
     functiontype="J2EEGetProcessList"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function J2EEGetProcessList|grep "server1")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $9}'|$sedpath 's/,//g')
     ;;
  JAVA_SRV2)
     regstring="server2"
     functiontype="J2EEGetProcessList"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function J2EEGetProcessList|grep "server2")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $9}'|$sedpath 's/,//g')
     ;;
  JAVA_SRV3)
     regstring="server3"
     functiontype="J2EEGetProcessList"
#     OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $SCSNR -function J2EEGetProcessList|grep "server3")
     OUTPUT=$($sapctl -host "$HOST" -nr "$SCSNR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $9}'|$sedpath 's/,//g')
     ;;
  JAVA_SRV)
     regstring="J2EE Server"
     functiontype="J2EEGetProcessList"
     bsrv=0                 # Bad Java Services
     gsrv=0                 # Good Java Services
     declare -a myArray

     if [[ "$verbose" -gt 2 ]]
       then
         mapfile myArray < "./ifile_JAVA_SRV.txt"
     else
         mapfile myArray < <($sapctl -host $HOST -nr $SCSNR -function $functiontype | grep $regstring)
     fi

     if [[ "$verbose" -gt 1 ]]
       then
       printf '%s' "${myArray[@]}"
     fi

     for i in ${!myArray[@]};
       do
         STATE=$(echo ${myArray[$i]}|$awkpath 'NF{print $9}'|$sedpath 's/,//g')
         if [[ "$STATE" == "Running" ]]
           then
            ((gsrv++))
           else
            ((bsrv++))
         fi
       done

     if [[ "$verbose" -gt 1 ]]
       then
         echo "Number good JAVA : $gsrv"
         echo "Number bad  JAVA : $bsrv"
     fi

     if [[ "gsrv" -gt 0 ]] && [[ "bsrv" -eq 0 ]]
       then
         STATE='GREEN'
     elif [[ "gsrv" -gt 0 ]] && [[ "bsrv" -eq 1 ]]
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
     OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype|grep $regstring)
     STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $4}'|$sedpath 's/,//g')
     ;;
  HDB_IDX)
  # HANA DB Indexserver
     regstring="Index"
    # when executng HDB_IDX with SID=ALL we loop over all Tenants
    if [[ "$SID" == "ALL" ]]
       then
          bidx=0                 # Bad Index Server
          gsrv=0                 # Good Index Server
          declare -a myArray
          if [[ "$verbose" -gt 2 ]]
            then
              mapfile myArray < "./ifile_HDB_IDX.txt"
          else
              mapfile myArray < <($sapctl -host "$HOST" -nr "$NR" -function $functiontype|grep $regstring)
          fi

          if [[ "$verbose" -gt 1 ]]
             then
                printf '%s' "${myArray[@]}"
          fi

          for i in ${!myArray[@]};
             do
                STATE=$(echo ${myArray[$i]}|$awkpath 'NF{print $5}'|$sedpath 's/,//g')
                if [[ "$STATE" == "Running" ]]
                   then
                     ((gidx++))
                   else
                     ((bidx++))
                fi
             done

          if [[ "$verbose" -gt 1 ]]
             then
                echo "Number good IDX : $gidx"
                echo "Number bad  IDX : $bidx"
          fi

          if [[ "gidx" -gt 0 ]] && [[ "bidx" -eq 0 ]]
             then
                STATE='GREEN'
          else
                STATE='RED'
          fi
    else
       #OUTPUT=$(/usr/sap/hostctrl/exe/sapcontrol -host $HOST -nr $NR -function GetProcessList|grep Index|grep $SID)
       #OUTPUT=$($sapctl -host $HOST -nr $NR -function $functiontype|grep $regstring|grep $SID)
       # if we want only one tenant we use the tenantID-parameter for grep:
       OUTPUT=$($sapctl -host "$HOST" -nr "$NR" -function $functiontype|grep $regstring|grep "$TENANTID")
       STATE=$(echo "$OUTPUT"|$awkpath 'NF{print $4}'|$sedpath 's/,//g')
    fi
     ;;
  *)
    echo -n "unknown Type"
    exit "$STATE_UNKNOWN"
    ;;
esac

if [[ "$verbose" -gt 0 ]]
 then
  echo "$PARAMETERS"
fi

if [[ "$verbose" -gt 1 ]]
 then
  echo "$OUTPUT"
  echo "$STATE"
fi


if [[ "$STATE" == "GREEN" ]] || [[ "$STATE" == "Running" ]]
  then
    #echo -e "\033[42m\033[30mOK\033[0m"
    echo "OK - sapcontrol-state for $regstring is $STATE"
    exit "$STATE_OK"
elif [[ "$STATE" == "YELLOW" ]]
  then
    #echo -e "\033[43m\033[30mWARNING\033[0m"
    echo "WARNING - sapcontrol-state $regstring is $STATE"
    exit "$STATE_WARNING"
else
    #echo -e "\033[41m\033[30mERROR\033[0m"
    echo "ERROR - sapcontrol-state $regstring is $STATE"
    exit "$STATE_CRITICAL"
fi
