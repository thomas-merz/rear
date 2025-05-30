# Save swaps

Log "Saving Swap information."

# Begin of group command that appends its stdout to DISKLAYOUT_FILE:
{
    echo "# Swap partitions or swap files"
    echo "# Format: swap <filename> uuid=<uuid> label=<label>"

    while read filename type junk ; do
        # "$filename" = "Filename" is the header line of /proc/swaps
        # "$filename" =~ ^/dev/zram skips /dev/zram* swap entries from disklayout.conf
        # see https://github.com/rear/rear/issues/3343
        if [ "$filename" = "Filename" ] || [ "$type" = "file" ] || [[ "$filename" =~ ^/dev/zram ]] ; then
            continue
        fi
        # if filename is on a lv, try to find the DM name
        for dlink in /dev/mapper/* ; do
            target=$( readlink -f $dlink )
            if [ "$target" = "$filename" ] ; then
                filename=$dlink
                break
            fi
        done

        # find uuid or label
        if has_binary swaplabel ; then
            while read what value junk ; do
                case $what in
                    (UUID:)
                        uuid=$value
                        ;;
                    (LABEL:)
                        label=$value
                        ;;
                esac
            done < <( swaplabel $filename )
        elif has_binary blkid ; then
            for value in $( blkid $filename | tr " " "\n" ) ; do
                case $value in
                    (UUID=*)
                        uuid=$( echo $value | cut -d= -f2 | sed -e 's/"//g' )
                        ;;
                    (LABEL=*)
                        label=$( echo $value | cut -d= -f2 | sed -e 's/"//g' )
                        ;;
                esac
            done
        fi

        echo "swap $filename uuid=$uuid label=$label"
    done < /proc/swaps
} 1>>$DISKLAYOUT_FILE
# End of group command that appends its stdout to DISKLAYOUT_FILE

# mkswap is required in the recovery system if disklayout.conf contains at least one 'swap' entry
# see the create_swap function in layout/prepare/GNU/Linux/140_include_swap_code.sh
# what program calls are written to diskrestore.sh
# cf. https://github.com/rear/rear/issues/1963
grep -q '^swap ' $DISKLAYOUT_FILE && REQUIRED_PROGS+=( mkswap ) || true

