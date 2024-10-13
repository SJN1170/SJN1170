#!/bin/sh

date

if [ -f ~/meter-server/config.cfg ]
then

	echo "ALREADY INSTALLED"
	echo ""
			
	echo "IF YOU WANT TO UNINSTALL SERVER - KILL PROCESS, REMOVE DIRECTORY ~/meter-server AND CLEAN CRON"
	echo ""
			
	exit
	
fi

SHELLUSER=`whoami`
REGNUM=42578921
INSTALLKEY=d185d1d0eb6605b2


if [ -f ~/meter-server/install.cfg ]
then

	MINUTEACT=`date +"%M"`

	if [ $MINUTEACT -eq "52" ]
	then
					
		WGETURL="https://api.meter.net/hs/?rn=${REGNUM}&ik=${INSTALLKEY}&t=install"
		wget -o /dev/null -O ~/meter-server/config.cfg.tmp -t 15 "${WGETURL}"
		
		if [ -f ~/meter-server/config.cfg.tmp ]
		then
			TMPFILESIZE=`cat ~/meter-server/config.cfg.tmp | wc -l | awk '{print $1}'`
		else
			TMPFILESIZE=0
		fi
		
		echo "CONFIG FILE SIZE - ${TMPFILESIZE}"

		if [ $TMPFILESIZE -gt 5 ]
		then
		
			cp ~/meter-server/config.cfg.tmp ~/meter-server/config.cfg
			echo "CONFIG DOWNLOADED"
		
			. ~/meter-server/config.cfg
		
			echo "CONFIG LOADED"
		
			echo "SERVER DOWNLOAD - START"
		
			WGETURL="https://api.meter.net/hs/?rn=${REGNUM}&rnsn=${REGNUMSN}&rnk=${REGNUMKEY}&t=update"
			wget -o /dev/null -O ~/meter-server/wget.tgz -t 15 "${WGETURL}"
			tar -xzf ~/meter-server/wget.tgz -C ~/meter-server
		
			echo "SERVER DOWNLOAD - END"
		
			line="* * * * * ~/meter-server/watcher.sh > /dev/null 2>&1"
			NUMLINES=`crontab -l | grep "${line}" | wc -l | awk '{print $1}'`
			if [ "${NUMLINES}" -eq 0 ]
			then
				(crontab -u "${SHELLUSER}" -l; echo "$line" ) | crontab -u "${SHELLUSER}" - > /dev/null 2>&1
			fi

			echo "APPROVED - INSTALLED"

		else
		
			echo "NOT YET APPROVED - PLEASE WAIT"
				
		fi
	
	fi


else
		
	echo ""
	echo "METER server test point comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law."
	echo "This software is provided for testing."
	echo ""
	
	if [ "${SHELLUSER}" = "root" ]
	then
	
		echo "DO NOT RUN THIS SERVER UNDER ROOT !!!"
		echo ""
		echo "- solution: create new non-root user and run it there"
		echo ""
		echo ""
		exit
	
	fi
		
	if ! type "wget" > /dev/null
	then
		echo "<wget> could not be found - its needed for API communication and HTTPS cert updates"
		echo ""
		echo '- solution: install wget (on debian like linux distro "apt install wget" as root)'
		echo ""
		echo ""
		exit
	fi	

	
	echo -n 'WRITE "YES" if you agree: '
	read agreeValue
	
	if [ "${agreeValue}" = "YES" -o "${agreeValue}" = "yes" ]
	then

		mkdir ~/meter-server
		mkdir ~/meter-server/log
		touch ~/meter-server/install.cfg
		
		echo "# config file for meter.net test point" >> ~/meter-server/install.cfg
		echo "" >> ~/meter-server/install.cfg
		echo "REGNUM=${REGNUM}" >> ~/meter-server/install.cfg
		echo "INSTALLKEY=${INSTALLKEY}" >> ~/meter-server/install.cfg
		echo "" >> ~/meter-server/install.cfg
	
		
		cp $0 ~/meter-server/install-watcher.sh
		
		line="* * * * * ~/meter-server/install-watcher.sh > /dev/null 2>&1"
	
		NUMLINES=`crontab -l | grep "${line}" | wc -l | awk '{print $1}'`
		
		if [ "${NUMLINES}" -eq 0 ]
		then
	
			(crontab -u "${SHELLUSER}" -l; echo "$line" ) | crontab -u "${SHELLUSER}" - > /dev/null 2>&1
			
		fi
			
		echo ""
		echo "INSTALL COMPLETED"
		echo "SERVER WILL START AUTOMATICALLY AFTER APPROVAL"
		echo "(you will be notified on your email)"
		echo ""
		echo ""
			
	else
	
		echo 'You did NOT write "YES", INSTALL FAILED. TRY AGAIN IF YOU WANT TO INSTALL SERVER'
		echo ""

	fi

fi



