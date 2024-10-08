#
# restore data with Galaxy
#
# Note:
# GxCmd checks for $# and calls the GxCmdLine script if there are any cmdline args.
# due to the way we call our scripts (with 'source'), the script name is present in $1
# So, in order to make GxCmd work correctly, we have to clear $*, but to be correct we
# restore $* at the end of this script, even though it probably really doesn't matter.
#
# Galaxy also seems to mess with STDERR, so that after this script nothing came to the logfile
# Putting the Galaxy restore in a subshell with () tries to cage Galaxy somewhat.
#
# Schlomo
#

# keep old args
(
	SHORTHOST="$(uname -n)"
	set --
	cd /opt/galaxy/Base
	#-------------- this is from a script generated by the Galaxy GUI ---------
	GALAXY_ENVI="setup"
	source ./GxCmd
	unset GALAXY_ENVI
	Log "Galaxy Settings:
		GALAXY_COMMCELL=$GALAXY_COMMCELL
		GALAXY_PORT=$GALAXY_PORT
		GALAXY_LOGONID=$GALAXY_LOGONID
		SHORTHOST=$SHORTHOST
		GALAXY_INSTANCE=$GALAXY_INSTANCE
		GALAXY_BACKUPSET=$GALAXY_BACKUPSET
	"
	./GxCmd -cmd restore -commcell $GALAXY_COMMCELL \
		-port $GALAXY_PORT -logonid "\"$GALAXY_LOGONID\"" \
		-cl "\"$SHORTHOST\"" -aId 29 \
		-inst "\"$GALAXY_INSTANCE\"" -bs "\"$GALAXY_BACKUPSET\"" \
		-srcPath '"/"' -ft 0 -tt 0 -jobStat 0 -bkpLevel 0 \
		-agedData 0 -opt 4224 -dCl "\"$SHORTHOST\"" \
		-dPath "\"$TARGET_FS_ROOT\"" -mFile '""' -rstUnMap 0 \
		-cpPreVal 0 -dPathLevels 1 -if 0 -strmCount -1 \
		-devNode 0 -devAsReg 0 -mode sync -ss 0
	#-------------- till here
	GALAXY_RETURNCODE=$?
	GALAXY_ERRORS=(
	[1]="Handle Failed to submit Job to CommServ"
	[9]="Handle Job Completed Successfully"
	[10]="Handle Job Failed"
	[11]="Handle Job Killed"
	[12]="Handle Job Completed Partially Successfully"
	[255]="General unknown impossible to understand error (AKA I've got no clue at all !)"
	)
	if test $GALAXY_RETURNCODE -ne 9 ; then
		Error "The restore did not complete successfully. The error was

	$GALAXY_RETURNCODE   ${GALAXY_ERRORS[GALAXY_RETURNCODE]}

	Probably some or all of your data is missing now.


	"
	fi
)
StopIfError "Galaxy aborted"

# create missing directories
pushd $TARGET_FS_ROOT >/dev/null
mkdir -p opt/galaxy/Base/Temp opt/galaxy/Updates opt/galaxy/iDataAgent/jobResults
popd >/dev/null
