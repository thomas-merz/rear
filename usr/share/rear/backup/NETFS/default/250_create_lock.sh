# create a lockfile in $NETFS_PREFIX to avoid that mkrescue overwrites ISO/LOGFILE
# made by a previous mkbackup run when the variable NETFS_KEEP_OLD_BACKUP_COPY has been set

# do not do this for tapes and special attention for file:///path
local scheme="$( url_scheme "$BACKUP_URL" )"
local path="$( url_path "$BACKUP_URL" )"
local opath="$( backup_path "$scheme" "$path" )"

# if $opath is empty return silently (e.g. scheme tape)
[ -z "$opath" ] && return 0

if test -d "${opath}" ; then
	> "${opath}/.lockfile" || Error "Could not create '${opath}/.lockfile'"
fi
