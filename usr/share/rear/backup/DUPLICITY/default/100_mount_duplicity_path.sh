if [ -n "$BACKUP_DUPLICITY_NETFS_URL" -o -n "$BACKUP_DUPLICITY_NETFS_MOUNTCMD" ]; then
	if [[ "$BACKUP_DUPLICITY_NETFS_MOUNTCMD" ]] ; then
		BACKUP_DUPLICITY_NETFS_URL="var://BACKUP_DUPLICITY_NETFS_MOUNTCMD"
	fi

	mount_url "$BACKUP_DUPLICITY_NETFS_URL" "$BUILD_DIR/outputfs" $BACKUP_DUPLICITY_NETFS_OPTIONS
	
	BACKUP_DUPLICITY_URL="file://$BUILD_DIR/outputfs"
fi
