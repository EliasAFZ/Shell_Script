#! /bin/sh

# Usage: track.sh -n3 uid -t20
# You must set track.cleanup file permision to executable

# For every 20 seconds(pause time), this program scans uid and reports login 
#  	and logout activities for 3 times

# You must run it on the machine that you want to track users


pause=20	# default, scan every 20 seconds
loopCount=10000	# default, scan for 10000 times
error=0

for arg in $*
do
   case $arg in
      -t*)
	 pause=`echo $arg|sed 's/-t//'`
	 ;;
      -n*)
	 loopCount=`echo $arg|sed 's/-n//'`
	 ;;
      *)
	 user=$arg
	 ;;
   esac
done

if [ ! $user ]
then
   error=1
fi

if [ $error -eq 1 ]
then
   cat << ENDOFERROR
Usage: track [-n#] [-t#] userid
ENDOFERROR
   exit 1
fi

trap 'track.cleanup $$; exit $exitcode' 0
trap 'exitcode=1; exit' 2 3 > .track.old.$$
count=0

while [ $count -lt $loopCount ]
do
   who|grep $user|sort>.track.new.$$
   diff .track.new.$$ .track.old.$$ | sed -f track.sed>.track.report.$$
   if [ -s .track.report.$$ ]
   then
      echo track report for ${user}:
      cat .track.report.$$
   fi
   mv .track.new.$$ .track.old.$$
   sleep $pause
   count=`expr $count + 1`
done

exitcode=0
