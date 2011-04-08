# umount USB mountpoint if not yet done by NETFS method

df -P | grep -q "${BUILD_DIR}/netfs" || return 0	# already umounted

if test "$USB_UMOUNTCMD" ; then
	Log "Running '$USB_UMOUNTCMD ${BUILD_DIR}/netfs'"
	$USB_UMOUNTCMD "${BUILD_DIR}/netfs"
else
	umount "${BUILD_DIR}/netfs"
fi || Error "Could not unmount directory ${BUILD_DIR}/netfs"

# argument to RemoveExitTask must be identical to AddExitTask
RemoveExitTask "umount -fv '$BUILD_DIR/netfs' 1>&2"
