#!/bin/bash

# Edit this line to change the sql file name if needed.   SID and orahome should be detected automatically
maskfunc()
{
script=redact.sql
ORACLE_HOME=$orahome
ORACLE_SID=$databasesid
oraclecommand="cd /act/scripts;export ORACLE_HOME=$ORACLE_HOME;export ORACLE_SID=$ORACLE_SID;export PATH=$ORACLE_HOME/bin:$PATH;ORAENV_ASK=NO;sqlplus / as sysdba @/act/scripts/$script;exit"
echo "$oraclecommand"
su -m oracle -c "$oraclecommand"
}

# test for testing
if [ -z "$1" ]; then
	echo "To test this script use this syntax:  $0 test"
	exit 0
fi

# this part of the script ensures we run the masking during a ount after the database is started on the direct mount server
if [ "$ACT_MULTI_OPNAME" == "mount" ] && [ "$ACT_MULTI_END" == "true" ] && [ "$ACT_PHASE" == "post" ]; then
        maskfunc
        exit $?
fi



# this part of the script ensures we run the masking during a scrub mount after the database is started on the scrubbing server
if [ "$ACT_MULTI_OPNAME" == "scrub-mount" ] && [ "$ACT_MULTI_END" == "true" ] && [ "$ACT_PHASE" == "post" ]; then
        maskfunc
        exit $?
fi

# this lets us run this script manually
if [ "$1" == "test" ]; then
        maskfunc
        exit $?
fi
