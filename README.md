# check_sapcontrol
bash-based script for checking process-status of SAP-components by using sapcontrol

Usage: check_sapcontrol.sh [-H hostname|IP] [-S SID] [-N SYS-nr] [-T systemtype] [-i tenant-id] [-s service-instance] [-h] [-v] [-V]
Options:
 -H hostname or IP of SAP-system
 -S SAP-Id
 -N SYS-Number (network-port)
 -T SAP-systemtype [ABAP_DW|ABAP_ENQ|ABAP_MSG|ABAP_GW|ABAP_ICM|JAVA_MSG|JAVA_ENQ|JAVA_GW|JAVA_JSTART|JAVA_SRV0|JAVA_SRV1|JAVA_SRV2|JAVA_SRV3|JAVA_SRV|HDB_NS|HDB_IDX]
 -i tenant-Id
 -s SAP central service instance
 -v verbose output [0|1|2|3]
 -V Version
 -h this help


 If you're using this script as plugin for Icinga2 or other Nagios-based checks, you need to set appropriate sudo-rights for the "icinga"-user and add it to the local "sapsys"-group
