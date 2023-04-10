#!/bin/sh
# This script was generated using Makeself 2.4.3
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="3033051544"
MD5="f56a09c1c4b01a2ddf358fc794e33b98"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="keyboard_firmware"
script="./flash.sh"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=''
targetdir="stm32duino_bootloader_upload"
filesizes="104588"
totalsize="104588"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="678"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    if test x"$accept" = xy; then
      echo "$licensetxt"
    else
      echo "$licensetxt" | more
    fi
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    # Test for ibs, obs and conv feature
    if dd if=/dev/zero of=/dev/null count=1 ibs=512 obs=512 conv=sync 2> /dev/null; then
        dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
        { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
          test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
    else
        dd if="$1" bs=$2 skip=1 2> /dev/null
    fi
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd "$@"
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 count=0 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.4.3
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet               Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script (implies --noexec-cleanup)
  --noexec-cleanup      Do not run embedded cleanup script
  --keep                Do not erase target directory after running
                        the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the target folder to the current user
  --chown               Give the target folder to the current user recursively
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --ssl-pass-src src    Use the given src as the source of password to decrypt the data
                        using OpenSSL. See "PASS PHRASE ARGUMENTS" in man openssl.
                        Default is to prompt the user to enter decryption password
                        on the current terminal.
  --cleanup-args args   Arguments to the cleanup script. Wrap in quotes to provide
                        multiple arguments.
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n "$skip" "$1" | wc -c | tr -d " "`
    fsize=`cat "$1" | wc -c | tr -d " "`
    if test $totalsize -ne `expr $fsize - $offset`; then
        echo " Unexpected archive size." >&2
        exit 2
    fi
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" != x"$crc"; then
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2
			elif test x"$quiet" = xn; then
				MS_Printf " CRC checksums are OK." >&2
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

MS_Decompress()
{
    if test x"$decrypt_cmd" != x""; then
        { eval "$decrypt_cmd" || echo " ... Decryption failed." >&2; } | eval "gzip -cd"
    else
        eval "gzip -cd"
    fi
    
    if test $? -ne 0; then
        echo " ... Decompression failed." >&2
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." > /dev/tty; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

MS_exec_cleanup() {
    if test x"$cleanup" = xy && test x"$cleanup_script" != x""; then
        cleanup=n
        cd "$tmpdir"
        eval "\"$cleanup_script\" $scriptargs $cleanupargs"
    fi
}

MS_cleanup()
{
    echo 'Signal caught, cleaning up' >&2
    MS_exec_cleanup
    cd "$TMPROOT"
    rm -rf "$tmpdir"
    eval $finish; exit 15
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 312 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Wed Dec 22 12:48:09 CST 2021
	echo Built with Makeself version 2.4.3
	echo Build command was: "/usr/local/bin/makeself.sh \\
    \"stm32duino_bootloader_upload\" \\
    \"DevTerm_keyboard_firmware_v0.3_utils.sh\" \\
    \"keyboard_firmware\" \\
    \"./flash.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
    echo CLEANUPSCRIPT=\"$cleanup_script\"
	echo archdirname=\"stm32duino_bootloader_upload\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
    echo totalsize=\"$totalsize\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5sum\"
	echo SHAsum=\"$SHAsum\"
	echo SKIP=\"$skip\"
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
    cleanup_script=""
	shift
	;;
    --noexec-cleanup)
    cleanup_script=""
    shift
    ;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --chown)
        ownership=y
        shift
        ;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--ssl-pass-src)
	if test x"n" != x"openssl"; then
	    echo "Invalid option --ssl-pass-src: $0 was not encrypted with OpenSSL!" >&2
	    exit 1
	fi
	decrypt_cmd="$decrypt_cmd -pass $2"
	if ! shift 2; then MS_Help; exit 1; fi
	;;
    --cleanup-args)
    cleanupargs="$2"
    if ! shift 2; then MS_help; exit 1; fi
    ;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -e "$0 --xwin $initargs"
                else
                    exec $XTERM -e "./$0 --xwin $initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n "$skip" "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 312 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = x"openssl"; then
	    echo "Decrypting and uncompressing $label..."
	else
        MS_Printf "Uncompressing $label"
	fi
fi
res=3
if test x"$keep" = xn; then
    trap MS_cleanup 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 312; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (312 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | MS_Decompress | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        MS_CLEANUP="$cleanup"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi

MS_exec_cleanup

if test x"$keep" = xn; then
    cd "$TMPROOT"
    rm -rf "$tmpdir"
fi
eval $finish; exit $res
� 	��a�]�w�Ƴ�W��
�:��mɯ�!��@K����{Na-�mY2Z)���o�3�+����i�s K������gfGK�V�I�)�HpOĲj7���Ӫ��������_����[_p��j7��/\����s�n֛�fݮ���p�tn���Vp�2�1�r��y5�l��#�c����i��j��t�v��e�[����4;��vՁ	�4;��u/�{��n�UU�}�~��Z��qn��*�?�����}����n��=�q��v�����_`�y�b����|m����i6�f�ٍ�m����nm�ڝ�M�����i��Ϸ��-t����)�U���Y�����_��7�F��j�^���m����4:�go� ����sv�W*�b�CVq?���φI2��Z
y/
a+�}4�`4e�+�Y5�*���В"Iǆ����5x͜XcK�,KB�!Sڨ�bC릑�0�=3�y&��G`�p��?�?���3�k,���dD\}9X����va��_\+��ס����}n���D�/��Ͱ�`%�XT���	3Ѭ�B�2�Q(��H���A�3��o4��@2�	ry�)��ޗ�h�İ^�V.B_/L��m�2�'�&�'�S,G��� ����9�Cj��ÃM��0�� X�{����������Ʊ "�)A�VVwł7� `
YE�^�U���W�ks��#�6��Cs �Y�$3_��iP�m���p��*�lw�!��LZ]�\B2/��}�[XL0�4�C��=V^/T�%&�8�q����Yn6"�*�ׇ��ꎍ׼�:���(��?:����Q"���3�Z�/�}9�B�Y����7
�f�����}4ake��
�n�"�w?l8��"�;��ַ����vtT;��fG�w�|�jT��ݮ���4��	��OCwx�M�2`���s��(aݱ�a��9kGw�=~p|���ӿ��l�J^���YVY��$��
b-L ͐jd��9���e���?��~HBK�Kt#iJ��v**�.IOa!?W��;]H�IβEA�zb����� ����\��X���c���5�qh+F�X&�0��X����́"�����T*�Aݛ�D)�A�"�~0�W�������z>&�A��
����&����Z�cZn4C�`R�ӫX����5K�< >�J�jI27���.x�W*iһ��HS�e�&���3�����nj�ѽBWn �H�x[Qs:�B���E�C�<`��6��	��J�Tfݺ@V����F�~	-ǸĔ �|��O��'<�3�ԝ��D�i*gG���Cm[O�2
��o@���h"���?��t���'//�Nv�����tF�]P���Kj?}���2:"x���vX�i�ߴv=X�=��W���j��eu�rd�~q�g��aԣZ��f,�Qp�Mq�,#����֪w�c����#���ZԞ�x���3f��<�ze^�)�&��R�͑�Zk�D�e��w�kS�E%����HL~��-7x���D�e��a�Ց��ܿ�R�򉜵�jՋB��(u���E�-��� �8��
h ������ 5�Ep��H-.��f�@ �%E�ѽZ˂���'�����J�pB�U*aLL� -5�M��]���'���@����5kGu�&�
�Qcg��<u����Ō�-�@Lk�D v��l�82�f���K�꒢WQ��j����l�;C�w��vX*��ʱ�+�������E���V��ס�����N�����b��������vr��%����~#�-h�KG=��b0D.��B��'�f�%E�X~؏�%f�?�4����.�a�������
��ݪ���nt
��=���~�Nq�Ӊz�����<�Dx� �D}��ˢ�9U� �
��?#�{�gV�er�M�fr�<\.������"����������/U����n����[���i��Sy�a�����9�P��1�% ڸf�P���E3�����ݚ'Nja����6���(��C��`C�i9�D�'>4U]���>�%	.���D��D�?��L�QPc���W�JTɼ�u��c��~�M���A9��N|��|o�F�v�Ϩ��p����|�U�:\���;��@�Ջ�@��\�u���P[�3	 2dWUD���ѡD�8����`��I�Q��	���O"߻��mI��(�����=A��yjt������ ��}���-��O�cā4P�b�E�gr�	J�crH#�E
L?"�M�������c��{�&r�d� �<�����U���z1�ְ�8JUrZ�I��M�Xl�5?�P����]to��pr�=?�Q�"�<
`R%����L�$^�P�'����R��i@}��!(��Ex�S�{�X�����B�U�AZ%$˖�r��\�+�=�7��`�y;���'+gB��������Ǐw�pЖ�*�����Q��>�S�Y�:m=k�r�sw�=<��x�;�]v���Z����BC�'���ـZ�r�:��H��0�.�E�&v,"\��E�u��*~N��@�s(㫵�;��4� ?-C� Z/��4-�x�����
�N�B�d��+�@Po�C��D����"5��A�)�i����S�iL�fT�������kY���_:'�����V�-���Z�����~��o�\��U���#�?�������K����ϫ����qAPx���a�?;X�P����C�����q�e��8�_�t��o��*�a��k���K�}y����E��[va�Wk��j�Q`���ӏ�4xcf�[�A1��Q`���V&^E�}<k���# ����̻�(Р�CРCp�n#�}�0�Uo@ks�( D��H�j"�`U��r$`�K��6�,�d� =
cQ�0��c��û:6��(61vW}}��n�[�
�=
DȈ�5t
;����0��+���y�:����Bgx�d'of�;�T�^T�j���˙�3Nk���]�۔H��r]��\&A��h�$#+ɩ$��&�t�	�<U푡���h�p���N�4w>��	��A$jH�o�V��W���H��%w��ұ�l�Sa�.�U������k�t<<k������ú�ŭ������QZ˵��l<ũt��8��QX���ٯ�:�H�Ĉ��M.��g��UåC�r١�]ض�j]�|B���@ːd��?P��.p�LU�����~��|�(������q��ɲ�W��T�T��9K�y~��͖�{�����14k�U\��� �'/����fr&;1�}�\4u�[��K���=	xS��e�(��R/i�I��=e������}���InJ$MJJ)���"�CxbQ�|��<��E�	|(��,"<yl��E�3眛ޤ����'�W�s�̙;3gΜ93^p�Q�8�D&D�`��	@)E]�����2R.C����$Ĕ��m8���g"5�X���G��q}z׌h NA��'��MB�ˊzmAS:x��&�
%�'ِ���P�	6 ]$4�
;_*`�C�!f�hWH�)�}p� ��6H�9"�*�t�i`����a�Fq��p�ӓd��KA�p�R]��2�H�X�.<<9�,���<Dţ�~<W�.�4����'=;�3�*�|HTM))%��'�M�Iq4��Jh��$�r���J�(��I��KY}~��|����gbR�6J
�.Hѷ�gF�|LjٖI���ט2
�D�"CS 	O��4%BTy
�H!j�M��qH�[�b�R�����>V��&�Uzʑ:�WX�q
E��a^�_p�`!�ZXI�8i*h�@����eP�|��%6t��s @�f��L�����vqy�$���Ca��/�"}�T70q�
%�����D��I����U������j8��r��^c�k�9����V��{�����2��:�2�������AzM���z�pڂ�Z�nx7\�k��l�_k���g@Ĳ�����{���I��P�+�&g'xO~��a�*���M47�uz��x34 {�!}s��= '-{؀�����])	'?Էj�2r���~��C2�J�?^���2My!��>� >TL 8��.U)�W�0���a��Ll1���I)8`�g׮8�20�/�\�����xӅa e�����o����OJ6T�)d��^�n�ݳ�W��S�U����B������]�`5?�*~��n
e4J�@�y'06`�Q04T8F��f�N��,�>tW����A�w��&	�J �wP���$FLr-��+S4@�H5P�
�����*<z�����n0;hĀ\�F��\���0����D�`��.���9��]���2£f�s��.VXl�LS8Ht��g�\yN'���_ZvV������/3�{,+|5${��4�J2�o
�=V-���&nڊ�L9�&�Y���)*{�I
j�� '�X�©t�ᇍ,p�[���M�T*p�"K�w9��@0Du������[n.�䢞�pP��M������t�j_�`�3h�FKL ����uhIǡ�w]��F�� BD�qAI�Yns�Y̐��~+�
A�2��a'Ɖ2 ��K�[:��x�*� �%MD{<�4Ax䉉��@���o�W����������<@
U�n���\��B��7�'��݌��:	���
	���K��Q@*�Xnl s��r ��45 �� ��>:�#�S�{����ɒ	��� ߌ��')QFk�K�^��o�D_��;]�Aa��O11�0�,MZ(+~Yr�I��(�qG�1�~�ʄ�n�����xE8-�<Q�:�5iq��͌��|��]qnXH=�健\
K� ���F�eB11)|�W)!z	+"Y��1�
��(>W1�>aLj�[�)��; y�Tȥ]�|���&�"���hT��>*r�ϟǩQࣀ���J#bil���
_bI���Kͪ��	S�~51� ��4�D�o���45���BBf���%H��ɼB;��<��8⽾�,p��'tp>-��9�·\�Jכ�-����^�������5�����W��(Y�R�dUz}(�����*%k`�J�B�ը4�Fo���7Hߐl=@�_s�^}�Wi���V�C��B��4�V�5�4�R�����_�)aawP�k�/f�u�?�����&���9�~�륫gRg�I��ly��wr���}�=���߳;������;Zx��m��u����qǳ�O��kVbX�,n�VgQ��1/�K�]z:�(��{�& Ι�%��4zyȇ�;���O㦳6(��5�(8�e��`x��%Z����Jx5+��oh���,����һ�K��8 ޹ɕ�yu'.�='nC�b�OE��bx���Vo�?&g��»�o����h�C ���s�Q��5�gz�|tI�g�e�������JW�[�r=�ܪS���;�Q֟� '�Bɹ��>;��n���ǿ�{~ސ��[xS���<dvS�aeW���]�uҵ�%�}�l��BB�U���R���'�d�]���,On������3��:��-�;9��Ży���[�8��)�����l����е�J��ۙU{)��c�Mfl�t�SX��8@��`�/��q��;�O|��8�3�pO�c��o��w��)YY��o�|?�5��zxW~�����\���T�lw�ĳm^1�����.����T��O�m�����+ٝ��\�cz)����AF��@���&��Dx�p����Nþ3��Xo���˻����S��I��&�\���!S����Vl�	�f�����s��[Ѩi6�ɾ�!%3�N��a��17S��|āH��E�Ԍ�緦W���}�a�S-�&G|5s�U���#ۇ���Bf�s��t�[�J�X0*������]�~a�ّ+>�v���S��:L��������D�?�g�,?x���#D�X�ř�����7�s��~O��|�Up�pF�*��N���o6=�|������y�l��1�@��v�u�6��X�ˑ�:[�~��q�_��/�7c\W{�{/~o���J����l�O��_�b���ѧP����a����?��!�������׈�߅��u���4j](��v�?������C�HRڡ��pܽ�Hb�L�<�F_LΩ@�x���N ��xL��
�?���p3�^����/�A��}B2Ꜩ���i!�\��μ�័1�>���ju���}��T��pW�?�oH�4��a���J�
�J�`���L<��ҠT��L����NH&��$U��xW��ZM�I%�7it)D���i�"r�Z���!�]���UFA���F%�W��f��3��j�N��Vkћ-<�=�RW��Z���x��d�7BKnu�
9�ER��j�ʨf-j��b4s:�^�W!DyZ`���ZM�c���
0�� z�	�P�X^e�"U����+��3pF�I��ͬ�R&�@]��=?��;=�G|�_����h|Zy�DI��0!�u��`Q[T��ɢ6X�*�Ji6[�F�I���<�n� a�. a����%Un���٠�j�z�Ѫұ��l0���Vm�X�:�WqJu�d#&E ��7�хL��]�EJ#�V �Hm���et!�?d��^�I��^����W��@���
��۩!�:dS�l�Mz���/�;]�<��F6U>�W+�j�C���m��Y��Q��j�j���

&�.Ǥ��V����x]:k������z%���]��n/6�0ܴ�i`}Y�fN�Ŝ��w��-C���vM���ϕ}+�&�!۾��fz}�/�7��}�x��r���l����/��V]�(;*|��E+�6�&)��ו�3�q<fcA�iv����U�opRz�f�1�{
�.? �/+9758�#��A: �yD�n��	g!�m�xbR&��6��^Y/ʹk�pS�������`�k������c�Z���z�')n:.v��?ًGV���*��Q2lz�SJU^��ֳ�1��ɻfÆt[긕F�\wN�M��qd7���3I"\,��y��
��x�Oܶ۳ML7Ϩ0��Ջ%#!u�s�?�&��DʽN5���}��l|�T�5$�����=i��tY9����+�	FSp�Z㶩��ڥ�I,7}�G�o��17��9 �/�;�_�3�Ni�gK��AK���)��D.V�[����������� 3?�������������V[�����˄})�?$�� B���������讍�|Py��}�)qi0��FGeV{jUS����,����;�R7�U�CG�$��8���?�<i�}E�8����Je
�(U.���*�߳ީݻ�F���ZL��m$�W��Ps�o�A{����!!4��"s� ���Z[?&�˄})��F-�����
��M�bL�#���!,��5s�3�*
D-�@�h�����$�
���8E���h4O&��]v��o���iM�WX��}��s�(
B}���߯�i���2a_��#�`_�?��������j�"��{��nЗР���?f��?�B
6}���UT5��U4^hihKQ�Kn��cP/��C-�D��/aY��AD����E�?�8Mƀ��#H���(�u`�"D����p�B��+��ߡ�_G����	���P�1˅}	���B��HZ�׊�A<���c�8bw�3�v���ގ�� S�}��0��W��WJ)I�~�Gu����n�T{\���nn���Bbhqc�ab�����Z�L�Yȩ�J1��v�=sɻ|B�k�v��^��FBX�P,�J'��S����b��B��<M�?4W&�H4O�cId4	���&�X���]�'������������O�����_&�߯� ��c�'@���B��g�݄����N��8�U��r�V'VYE�R���p��P����,	đ���-�O�K_S�}Nk:�SzV�s/5J��G��	ǋ�䝥�&����>��b����θk.I]��7�UO�a��Xj��L.���{��ir�����6̚�>0"��Y���݁Z�ї����{�<�FN�v;��J�ef}Z��$Ki9G_?������!k�����l,f2ʦb"L�;�����VMY��e;�Fް�7�{�h�����V�,��29T�?����t��tHk���R�}�Z��W=�:7�I?0x�֕�f���^��}��e�D����`�*���n�v�Sk���}�_�F�<aT`�뽓hĪ /~�{ý2�TRz�v!��OI�inf�y�棏���U��],7��Pk��'O�Z��B�t��y����JA]��Ὧ�f�QFG<b��.u�L����2Ml,��uej}����0[�!����,��T�&�c���<�8������ؚ7	�[���lr,���F@��1�㙏�%�`��#�{�y�<�.�a)��<yD��M�h������;%��A��Of�i��T�W�{����*3��
DBv�
�!���W�4uZ,U��ئ:��I-ˤdl�[w�/j|a�O//�ԇ��8�>�$��M�-��v���Dv��O�3�l��w0��~=qb8�9�6�� k�L����p������Em{L,�[M=�$˟����K|`�n۞��-
�h����c��!���#��9J	$��E�8��pH�cЈe�����o
A�����o�XD�i��5�/�%� $r!�h���
�?U�ɖ����(�<�p$�F��꺚\������~�������D������ڽ��#�wE�^S�}�zn�M������^M�Dv����׭w�Q����V)���͹�C�iN�A��0�U��Ͷ]��׬We�����&�g�>K�|y��U�r�˟6�y����.+x�)���9�vuA��x�����Y�/���]ċ����
�o�-�Ի�=1���<хJ���,ؠ��op�Gg��!A�� ��mmOȩ�o6:1۱ح�4�/�ۥ���S���=�Ge֚E��ڊ�^�8��a�lG�'���>�G�આ���"q�a�2�t��a��2CI�\�[=�:����P�T�������B\������d��L<ֵ�~S�w��ڏ�8��b23k�A&tL������4L�#��i��4~f�r����B�f���7�Q�ngJ�y���cb�%=��u�#}�/G��m	(K�Wx#6��ԡ�Y�m�!�|ƊǜO|���u�I4Q�?��".iu�u┉��/7�}���a���-��D��~P�]�I͍q)��F�����܆5f��}K%P�-�9��	��
����f���e=p�(�ii^g�H��\��c�T���]�G�&F\��NM]���.#�����O��h���t��b_�����RZ��*{``z��~fމ
ҧɀ��h�)�����
o
�����᭑ ��B�	p�
���&@�|����d�?+�g�����������?�`���R���� 6�����Q^�@�CY!F����x�'�dY���]2'<�}$4Ĺ�s�ca�'���Ic�q�4�Ɩ!(Bb��w��n�������B�!�pX$��6` k
�qޟ�#�aa��`@|�;JLi����چ����R8z����-�ºk�(yl�3o�$β(0u��f��{������ÿ��Pԗ�����D��X�
�o�ϳܗ+[3"7�N27��~�N��AY����y�� ��agb4�M�\�%o�ܳ�Nށ��E�c���Fk/�Ģ"]���m�v{ ��-?���q�!XT�˻fN��U� ������{Z�[��[�tㅷq���>C��;�U���8Gz���)NJX@��`i�({������|�@�?�е�wM���I 
�JC^�ݮ�H�}c����>���IO�`�T���$�CyfzCl������(��-�E�7
sα)�5�xD<u��^���u�����*Ev(7����/OV��(��z�fZKfZ^�"ķƚ�Z���0O�<���R��#%)7�Yd�S��6��-f�Ъ�K!��tm����"t��{w&r��X�'��5Vm���Z�=Lx_�W�$���HI�Ψ��?����~K�	"-e�O�z�ߔ1�k[�7��&��~e�Zxc��F��n&D:x�m�, /|A.��੕J��R��f���?�jĞ�;f�y�M�!$@��&����=������N
��Az:����X|v25~v>���+�3$-Ɵ�j�R���.�6�$���ʞ�'؄�
n�x��3ؽU
10R�-Ջ.��N��h
���]Q��(�.9zK ou�d7ٶ�̕��NP^��(��8�������'��z����0�
i)��[byR��3�
,����ꁖih)�.�߁�:�v;\�Pߎ�Nx�<K}�����m�*l�]�%h˵h��V�f4��n6�|�Y�;6��Z�Wf�{�������foz�1α��#��,m��x 1�K�m�S�e1�X�q�B�erR��*�S����X:��2���a��av��s��g���Wύ8�do<��v0q�>�B��Q�Ɗ8k�4���T	(A�ȏ�A���U������˂��guO�<��h��ލA�)��C�B&Z��O�p���W��ԶR�̦��(_���[�V�~N߷����%ËT�$>�:y�����՘8k�^wq�*�<�E��ޱ��>�6>��~:�+}�`.R����?�&,�td���W���K��C��]��k-��ͤ��r�������<�y�
�m��͹4/��@S=�̣�����a��\)���_u������ج������6>=���|<(�\f������ �Y�>���4���`�J|#��Ԭ�&-a9�A�����M5.���g�#��il>��\K~p�T� ׻D�W�l�t�v��繪�
���Z�e�-�e9�In�I��,�揄e�9�wN�j|ki�1h�UU�Z�>n���n`Ҫ�驻��x��=f�1\�"mۦ����s�(�o�yԫ{�-!�}�lu�[�ckL���Fk7�foTJ���p۱���):y�M��p�9�2ţKW�71����y���b��[��A��e�ߖE����S9�;8&�0'�Ԏ��W`�|1kn�`�m���/էF};�2��s[,�K\ooCw+��)52�����A��B����~�uDu��j��×B�;�˪fV�)qXr0��_
��R��y�c�.�j ����K�-Ńe�^��ki_B�����Ly��	x��5G�؍-���ck]�i[��Z_�$ �B�P��`Y���wtaC�*��&?�������̸�ؿ��Q�D�`��^��-O���
S�^ܕ�:�:<�\��wը��wj�TT�����D�4ӦW����Afb0]ΧLP���f����xJ��3}]����z���yBe�r9Ŀ/��,���޼���oܧL�α�$��RU�9�6�E��� _h삞>=���Xz�m# �~�#\`��9�;6���֞�'D5�^�D���ߙ�t��*ٟͅ��?ao����CQr��Ç[��;��N;�Օ��v,�q.i�"�B3�k�����g.9���M��eݺNv�mk(��?y�ri
-�Y����å�A�`-�`%����騲��>����N��6������#�D��
�\Y�r�~lԁ9����'�� hE���Ӆ���]�>������/@l�HJ[Z#�6�H��K!@@Rii#)E�[�H��?����?����DJB��������/��?��?X�t�����'�/�ۢg0�5�H�^^F_ܠ�.�J
%�N2�P�z����,Ѷ.��)b�I�#��	A��d������m��$��O�H��w9@؀ 6?����B�N��������?��S�����Y��?R�'�W�i�����i��O8=�J�G�c1&����B��ڍ�&��j��f��)�'!>��LCv�(�|	�^���H9�+�c��O�ӯֳ�YL�5Ln�j�l�>�V�������L�"��������|D�%S�D(�[��qA�d���;��U;15��
�jH�}��!u<A|����J�9׊�֌ݢH�������ibC#�
�g�h��P
Y�XO��i�h�/O�sjP����6^�F�>��xO��*^3PL���!+lWڮ��[")��͛����i��@��:�����ն���̐��U�+�9ݗ���磹_M9\� d�v�zȼ�oO��;@}4d
�?ű���/*&=E����I�?Y��q��g��\n2b΁��o����T���'��I�,�yM<�e�p��E�mj���z[:z�P �J>Dq�F@G�������0��c6W�&#o\
�[��	�L�	O�����{�]|"���#]�3
ɚ�)�/��g��}l<�9�'yCv/?���΃�$σ�ӕ�	�4=J��y:>?�y�,ńe'�&��ݖ�
>|�������!�gs��� ��Q��w�>���%q��Xf_:��0���o�ykNbxL5-H�mȝ�����zq &	H֘+�2t��RͤIp&��6���z�^|B>�T��0H)��*��o�e���:�QP/�Y%}��pV��;(�	�d��Ă�ŭr����
'&i�!�ê�d/�(4�K�f�#����緘��Vh�p�_�k���O8/�<V�[��XC[������}��j��J��G�Z�0���t�E^�1�ɟT��a���3\N8O��E�?����M"�^�5��.A����Q��K#k�;�u�R��%�4rPb���\��J��+֑`�X��G�+����#�q
_�'IەY��4>�԰�1>�(;��dr.+9�P2%���c
�m���TI��ڟ;V�_P	k~x��1|�+��{T
�~C=G����ڙ|����x�Ai�`3"e�;�|s��'.���&4߀��O��{�U�dA D�0ӱ��$͹�4���vn�ʥ9��<��;�2ؓy��P�Y"�>�;S��~�5j���pr��j7�v��/=xQ��H�w��>�p!��,x��n]h�YQ��u���'�>cH%�����!��A
�nҸ�W��n���y�O�4�@�Gv�2�P�E���D*)���a�� 2����m߼�K̀�	~'}r���y]�e0:�8�����jW�Y0�{MiZW�$�,���z]zRh�k�������^���_�v9p'�ɶ�����<;7�T����A;bj`ć'�#�1n��˯�v���Ͽ�*�􇷩ɂX�U+��p�T�4���俱w^AM��GPi�HD4X�RH#+R)����4�	E�(�T:"�ҥI/A�қH�5Ҳqϙ3�]��<۽���\d�J~��{��eT�<+��'�PrF���4�4��WQa%��d5�{F?�to����ɜc��M^^,V^uT-�b銳������N���[�oߟD����UF�~�
�E��D����n��5�ܬ�w��վ,��ؓ|�Ճ�W�U�0��"n�乼�d�S��yk�/�ԝ%��8�Z�5}IN�b�����}(����]0�FP`����9[c��c�*��S�;�VOݱ�0�N�����2�O�8��t�K�����z��`rl�}�]gÑk�,��W���c�W��Z�#�.$ߧ�+%�ā���tN�*&�S�<����Tx��[S���kF����VR�,d[�k�:��25���"� ����6 �FĨ)Wd��\X�p��2��R�`����-��2�8\)�B��.�z	Q��:[�J}T�+�Y*�Na��/H�e6�ޚa��LM(=:�й$� ���#���A�
��<~cJ���EQ�������
Dc���*E!c��G@�Cx	�� 4��֬��h�{�&�RU���~+g�ja���E�2��o4�<M(n*�P��7�a��wckt^�{���hꁥyev�S��y��^d���a��wm?Xﮖ5�N�
���f��wgw��{��������G������O����k�`VF�1��3�0����B�#xv-���L[��ג��G���_��_p�II����><�!N����N����w�~O��Sfä��]=��#e!'�߼�[�d�=e�l�欲��5���[K�����˪����)���$v�������C�x�1E�$X,�}
��Y����]����� �A��P�o��Bv�����#`��D���¬��	��������J�]K^6J�����2Vڃ7���ֺ�P�D~~]��W�C��aEV%d�8m�T���ڬEw������1��=�:�{dD�XB�jM���`V���sc����������|��0h��N���vi����@�i�w���~��7������h$����P㝷tA  �4|G�(	�����r�����O�����]����a�+�?����`bW���_	�������w�S��`}��Bt
�RH�RKW�6���s< =�^�]�l��P�?��R�;G����X�}�8]X�}P�Td�k��������%ߧ�A�	WC�,�����C�[�f�Oe�V�,IOAE�j�ID�1/^�s�=!f���?)|���o<T�`��*�.��z��p������F;�NtGJ v� A�FX8
&�ã���������#a���?��E��~��~������d�]��A����Cv�N�����wB®������f���A�Hհk�A&�Wip.d��^.��Us�}��Wj����n��@���YaN>˽�_^�P�zV�u1 )Ӵ�~s*�/��R�J��:(.�F�zk�I��X?Is���\lN�*��3i�[�]���R�Ӝ��p�2����'2��K��'��_�Ym����[$����+
Ⱦ%AWMY��b�ţoN�*?�6�N�п�ȵ����3�F��{�r^B'.�r`U�V������\a��C�i��W�z@�iohMj�XJ� ���2���2�`�]�D�ZacvxTpx��u�ћ�Sl�D��K�r�q��W�H�>��a�����R�CƜ;9�ah���}r��N�U�:U�l�-����zB�냆X/�v��^~9PLwTI�s����%�^i�c��R������+����)��u=* 3Xѷ���!Siά�O�GOW�}�E� ���6��6�z�~�Dp�|�n�m��-�|����v�G��TTHY��i��0��M���)����m\\�� 4	꠵�^�v�  �zx��ضx�S!u���ܰݶ��5Hɧ��/����G���Ӏ��hg�* �Mw�p�Ml{���q��1@��~�o��1��y=�!�Ra���t�T���<G@��07y
����ɡ#�(AW�P�K�	L4}�_S*"��l9�MW0!>�M�\،�$�`L[慂��M�t�9t6�6�/J��,�me�_�Q�P:׼qV�Lt��n���'{�s���,��sk���������/�a��-��>�l�0�uֺ�{Y�t����S$��]�J�;N�i
�u��W��cQ��s�Љ�U]�XO{�
�5��b(�w}�V��>����jxi��OW�."�W9i�=2���΃Թ���do�bR�ɼ��b�I���"�ba��vp��L�����%��GeV�R��,[�z��{=5 �v��xh�?krAʱ�e�קr��w��%�7�͊<��ۦ��X�8eu��6��sdUm1q��P)
ض�Q�[m�/�=c���(��M��2���beW_xZ7��p�bA��6pa�w���'׀��zF��B�K�Q��-[&�{5f��ց�.�}��3��E��΢65>��V
6(�z�k<����r
��
;c���I��Ac�-s�X����J��{��η�v�4��X3�Q��Ov��m%��?֕���MP�L�u
F�����3i�2������ױST`�)��lWY�I7���~�i�͑���E
(��ZJ2vs���iȸ���U�2`Q;e:�/��A��7�0���naU6!#��[&24w��\���ޝmN�ȫ����2W0��E�Ev+;I��7:�z6J�ۗ��ˈ�9�'F��Gl�_�)�[���c�F=+rX����WOk�\_`�N��h�]�eRΪ�G������ț<�Q��
5_
yԯ�^�͟�zL�+��h�b�3�:J���x��5�?]����١��G�/����N��IE|��&��,�(����=ű�}��Іp��.�e���{�}�N��T�d-ڜq��oN��j%9�~���v�?���.M�y���ݧ�x�wF���E�]՟5y#����(�eH�F�_Y`F�Y�1�S��
�q���8(�g[D���rSL�)|SU�IQH^��a���"�{{Ro�ea�V����nJ��`�bj�����^���B���ʈ ������ٲ�o3��5
~�MD%m$��O��Q�+(��,�y�{ۢo.!�
V*4։�;T�#+�Ǖ&��`��<��\9��� IL4�t�FK#�@U������j��
��Yߣ�ڗ|��S��L�s�&�~�a��8x~`��K�fw�j	�L�&/�fR]7�cY�*�-�Y��7��]�)�������e�֤D�/��d�枡�E�/�I-3@6kN��b���N�7d�m������WY��Yz'�/�+p���O~|�<��k:PL����%{$�O��V��-+>t]($ޚ�z��O�G�~�����/�S7[�}_2̺����8�o0�#*��󜿜�y��S�-�F a��2HQY��,W��BP � �����������'���?����w�����������!
���p���9�����o�/�-'g�	6���+�f�� �8��� @y%y�� ����q�+8A��	��A@E�"�����'��?[��#���*��%0����Ƀ�<H�o����	[�?���������������ߟ�����F���a�$�cnY�>�vg~zϛ̆z�ޚ���Od��L>$N���:V[���[�؄1�|[9�2t��j���T�F�ҙa�d��"�X`����_	~��_��\�v�e��}&�T���тk5�l�Пח�G~*��3�\����T�I��k�j���v�&Z�OAwK��-����ݱ肥-i��_<v�զ]��l��0�� ,�v�'��~�3�)"@%�v ��ApGE0��q;��0 S����I��D�O���� ��k���F�o��$��g���,�̇>j"{>�:��i�[��t����S��x�k�e����a�v��f��C,Q��<�3bY?�����h�U��7dAv��m�Z�z�Q���~�Y���'ڀ|��7�l\O�f�d�����6�BH�Ē�烜i��PI�����4�4M4-
�]h����Z�'P8ݦQ��>�zG?-�ڇ�EO8��k��,�-�x@y�D}�)��\
�"z{�af.���
><w��b�@7+��8k]Ԅlqμ�wCŗ�R|���xd��8^̀�ɡr��J��X�!=��C��g��o����XC�t$�)r:V���	Ƅ�_�M�S}���h�G��Ԁ�ܘ��p��wЊ�����f�P�H��
T��C��.���i�#]ɭrs �)=��)e��
�S6��c��]E��M�2��.ߜ1?��	��}W4VJ��p
;ܷ.?�X�)�S�^b��ާ��u���|2]�2��e:�F��<?�XZ��l����v�6j���=p!��j/�S�e�X�i����㕟0��l���t��6��������\82����#8�qe��ӥ����T� �ѩ٧_~�\�+���g�d.��(dU]K��m�f�{�J2+��{_Pն��	E�$)A�kө "!!¦6��  !����%R"ҍ"��o�����}�����g�f���9�3�s�9X4-8Z�+��2ơT��~6,�<�&ƴv��Q4�[�Y%��b��b��,ý�^׽)�:J��)�wlU��m���w�>�l'��	M�'V���o�6SO�Eң.?�A:��ãw1�RB�X]ģ��^F�~�U7���`H~��Aȫ{PS�R�5�C�,%�b�6���#h��F���Cn�B�+�;K{�3
�U7@Ikz���9c������s
!҇f�r{d#Փx�^��8+��?U����[GD���6�:��өb�����+=�Ҫ��gklK-s�W��/���ft�)�;��T��,�r�8f�Ƕf�v��$q<�TZ&�Q��E
c���C�7����u��~��{�{p]Η9cu+�����Р�<���|�3

��� 7�0]���U�Ƭ���?S;��lT�X�{�7;��8Ey���a	�҆0╠����,�t�d\/��r.x[��y��d���6�Z��l����Y��w�w�V�_��T���-hu��|�Wb�uƧ���Q��z&���/E����S��73]�c<����Xas����Hl���Sl����R�1݇��qP(,,��~,+�#�?�X�/ifqё^�\�.v�Z��T�TR\e������Α���s�����n��K�6c+��]��i������
/o�&u����o�r���9�V��"�뇒����BU���DE+r��=,_>��-?(���"6ti�/4̫M7O����'#Dث�u�ʜ�ח����4�M���L��)���n�" ma�W�UKwH"/����x�^�'�(��yZ��/d�oݣ�qE��+ϝ@�*����\X+����yX��7{2f����;
���Gf�'oE�X��d?��ɗz��_j��\���U�~���cծ�)���HJ�D����̇�ԱS�X�ڞ��K����`C{}G�i��ɮ>>��
>�ie��%�V:pN�+���4i� ��
jK	�˺C���Á����������YK�&�(��Tl���mGVDӱ�7��I���ൌ�@n����h�����yhl�UbM�`²Xa���lJ� +t�}^4���s���T3{�$�F͓C���)m�99O�_�! �<�d�f�u�����4ؿ�mK�����J�W?�{�m=��*`�.L�D��ն5Ƒ��?Ș�
���A�Z|;�y�ݘ+Z)˳�%�Q�B���ëߡ��8�0+
�M���9N������|jaN�^��ZS9��X9����|��NbA�F�����z|W��و�@I�8��)�Y�Vnj�����Ӈ�E�����#�������ע���C�m{��(ŵhI���|���=ec�su����ԙ�sb��2����p�#c�Y�X�Ռ#��3������Si�5T{T�]�i�Z�j��
�F�.�C9��n".�|4�Li��%|��=�/Ư^�BD/e�r��M�>G��p�0)��q�es}��Ke�\M�v�J�S�;��1�يð;V���p����DC{�񷏆/�b�,�)�*��+m;�Bn���<B�d
3-{&٘p���RT�r�s01~�C�pl
_�Fc1|w~�F0R?�	v�dZp�I���|>�
����#�2�Q�x�6�Ҡ�Z{{i\|�
�n���KL|��"�"�cW�4�x.�]���[=�
7w���;V��V�dMY"���ö*�7�����j�E-qx�����B�#��r�Rb���O	;a��5w�RL�ȮPR|t�5����y���'ϫ��"U;���a���DLI'�-_c��d��uO�u�u��獱��"�Q��'H���|�e�E\��	8��9-�g���rH�#��z���_��(�l��ȯ�Tpnt�>|�1J�K�3�!ر���Q`�������{��*�{�f�鎩M�C�G��yG~��{�{x�߬|��y̹a�v�%�^���%;zϺ��X��bב���K[w���=֒�Niz��c�^�ⱀ�ط�;C��>8y���e�s���5�*��+��#��WMo�ꩂ�h��vK0 ��g�~��#��fj=�4e��1V����������=I�\u�����t��+i�{�8`"h#_�(�%����a�g�pԂN��L����]Q`A��`RK�}�K�`f��yۗ�JE�����_g;����(ii5�����U�fQtU����<�+,P��R�4�?�cT�uï[���[w�+��P��H�V
�m���v��m���p���y����9���$���x��f�BXNqfq&[��۷m��b�}��w.
����rE�x��Tע%��_?2��}9z밪����0
�o�F1�9�\��('�CN�p����w~��Q��N�--�G-�hv_��K2�`"۶?��}�aپ0VP)�,�-��#�a��a��|>Ђ����eS�V��\�Sp�
���h��\aѭ|��Ⱥ�}�mc�˛��5b��t3nmt�ԍ|����ܬV�^/�3�ƣ�=.�'���Q��E�^���S���VJ5��'�)2����L���j��f[�珚.�F���"m>M�Y[�t��
�Z)(]/}����0/F*�U���m'1���c�2ێm�_=<|L
eFtZx��W��'~������4�ج#$8�2�#�^�U�\�(#]J��.�z��y��j�_{�g�a���o7/���P��%��L_�zX������ζw����&8�Y)��cl@�+��H@������u�׬8R�U�[���:�s��{�m3n{�[���8u��ͩ�Y�#��u�+e?�|�@�ap�����į�ԏJ�h���KR7����۫�}�Eؔ�eۦ���m�M����͹�oQh���oI���3Ր�i�<���HJ7b�ә�d�8���21���P�Ԃ;�ԟ��Fjح�c(�+�t+bײ^)hdM"��Lm�3��O��h�M��tN�������9(o}	+�0J0�%ݛ�N	����d��Bi{Ï�3=R�Zn%9���|�]�6ϋ��$�EU�����x/y����Uу#=��Q�hy���w%N�v�ACH��)^�,�w�jzAӦq=[MHC��|�\E�̕�q@���z��4�4A�L2�=MRU_��V�M�Y��MM��|Qe�#e_�m���u��9�R��-�>�|��#�T�m�����^䍲�ޙ�
-�/.;�"���|$��$,�L���Ԑm�$`�)�/�W݀`�y��鑆�W�&Uq
�P��[�0�Bryn��@
�3E����A�׋������e��ܬ)ry�YsCn`[��(:�^�븡w��qh�봘�~�k~7��ü^��ΨMnӸ��:�(!-�N�кm�.�Թ��|�˕/�%�u�%/�t�f8�X~��@���܏�Mӑ!�Y��%�2�Izj���@��Qv��B�Ws�U��-�U�����Z̓ͲYŗ�D���o�>����ӣ���3*h6�L�7N�U����{�HW����IE��e���v�q�]\ޚ봳kh����ܶ�?�)ǌ5T���X�x����e�I�ݺ����(�ָ�Ԟd���SH\��3a�s��m3}�i>��N�n[8������Vw	X1:�"����9��&pͬ8�<�ؿ5�ApLw@�������9+g?\�r�V�kz�K����]��ލ����+{տ��ݒ���� e�2���82'z�Qe�Mˁ϶�f�D��Im�I����f���b˨(N��q����u[�!�{������:���7��o��~�UB�3��n��-���V�k)��U޼�W�k�c���z�1E�ԟO�n�S�r���G'r���&7�.��fkA+d��2�(^+O�����A��K�
-f��Ü�
(�lj���3���5̔�߽@Q�6�r���s�˟ʧްy���F�]�����a�w?��7f�P�G�/�_��P��Q���Zr�{�!��0ę��rn�Z�Y+1�}����	���וx��u��L�{��4*֟�z��k�_����,j*.1
M�a@_DHe���{X��T(�y-�o�̜���H���8PBEN-8[����MY��� �V(���E�a��mH���V��)����z�c��H��0��r�`��ou�̡�S"}�J�
@�/vN����V߫�`�?��R�j�DP���]��yO��kq`ȴ +_��$d�TT�h�f��i��K|�F�ۜ�D��w�'����ҩ�=Q6��헒��p3�Xrt;([P֬Q��%�f��8J�Y'Ϭ�����l��u�hPl%]�A�W��z��zSH���y΂�����~�ޚuT�����O8Qc��g����j(���m�9��<�80?���Z�v�F?�+��`�.^J99̃�NDd$��Ak�M��il�74SM�7b�=��=����kv�go�������څY-0�I�a�h���4�g��(ӈ��j�깆��3%ñ��E�ah?kn�op��k�x&��M�L�����>W�L{]�@]��
��
̗AtF.LX6XY��v_rp5�ݵj�~�HR5��^�O�vo ��d�����mL�,�MR����l�����M����Z1�����Cg*�ʮm_'[�_���M�������yB�\�7�g~�Iէ�æ҈$��=��G� �a�y�O��
VQ@���B�w3'����O5�Fʋ��e�M�?c�J݇�"�X��O�T�%ޙ1�E�g�*ɀ�}uI�{zq$��L�u�Iτ̣*� �\^�q�
t�%���텝�������ܟ��9�\�5}\�0�5��f�
��7z��x?����X_�\g�+<BU����g�{:���M��������GR�x��~�p��Y{��������V�o�uH�Y���)17�=ѽ�����|�g�v���+��h���&Ь_��'����y/=��B���u�\TSP!�z|e��G"�[B2�a�a<�a|�J����+�V��y_�]�p+���A2�J$H�r�<y)�!'���	u�E
L
� �+����0����<
ִ]\%Xi��Kn�;z�(����y}m����Fպ�۸�Uϣ��z���r��邮�}Z�ɠnNf�0?� B�"���J�dʒ�y���;n���
s~��f����
r?H|��{��Ո�P7�AW�D��`���~dW\���wG���%uTڔ��x�.�ß���W��K@�bo֧�\:�>|�+b��� ��¸>�4�_��i.
��$.�c!SZ_��\�<���mĽ���m\�s'}y�&�?�#�``�HH����c�8o������v3���̊b��r2]�=�����ٷ�m��
.{2~�*�c|EG͸��Ҿ��<��k�l��B�e)m 0:M�6��xY���޶!Gё*���?#�k
�\<�閔)�]Hȝ��̺�de���8�}��_���x�Z�����E�_n��*�&�!hcć����f$z�k�`���S��1�t0�"�G���j���������]���M���A��~;u\��Bt�L��o���s���6.v��r�S�5��6�y.��/�R5m��M�{���Ž�n��g�d9�����ȣki�+�a�����𠮵o4�Q���2�8Fh��#�F0v����Bf��0?/,�e�۝odH��w/��ړFl5%-É@1�'jn����3XG�1�����j������_��U�P���s��]bL��*&�_�$e�n$;�e󴫛�Qn~V��HQz׬<�V��o�����&Y��6��\;����98�][&����1qU�d��M»YjL[��y�\���7%���c>�z�r��w	�6۳q
���h&���i��+H�%��+��xo��9���-S1�8�}k�u����q��'o��D
+ه�%��@*s�:@uc�XC�ޝ�x͔U��mi�-��R@4:�Q���d�K��;��E
�t��=����k#9�RҪ��5��|���X���� �@�~���-r����>��-��;+!�6�VC�[���?/�"4+]b�Ǹ�
t�N�ɳ��a����p(�ū�֕��,���p��L'��9���hDė6v너���6fX3�����_�v=��x3����mA��qk�F�["}���Q���"� �c�n���^��'kƟ��:���q�l������u�Ι][��r��g�u	�5Iɢ�i��w@�:�~��u�#;���]m�B�V�c�z�7�@D5�e������Q�n1�sN \py�6<ӷ�䥈�LEJ�CX�jz=�e�w��U��A�����ڛͲ[��3�7^1��q�c��3RJ��Eء�}U{?�������/�q}�Ӆ�ʲܜ������϶a,�ܳ�Hڸ���RAS�E��w%����4,5��mM�^I�LI���3��WbV=��]o�dI��wߞ��=�K?2&���GڣT�
bGT�x�L�jY8|"��;6�UV�e��ax�N$�����e�}Y���F���?c��T��S(!j�ye�;Ja.����s���,�0���-�B����O�J�5Jg��d�l�o�a��e�J�mm�Ի��*���_�b�qQ�t� �_nYfE�k|4��R�둼�D`��@�jwdr{:��� c���	Yi!K��+Ν0�/p	��ƹ%�Xw�֨5����վn�S���*pRa�yiJ�}����@pM��+LV��,*o,*�@-?�=��X&�KU��1%�L7$lK-��b�M�����5��<C����^�`������~�XF�d���Y�k
7N���-�.iy��`.F��X3�k$f
m�#�o
烜�b�����}�����g�p��}}�g�ޣm�v�^}��@g�e���mmߧE�����*���e�c�o��s��E/$W|u��?im�7&-z�4��,��f��z_�Q�t�s�1�l��PA�E+���$�R��t'@���#bUW��~z�&�������+A�E��o����n��pe��� �l��Vs�i�pm�F(}l��̟c��
���Q,�U�����k��]�Y�r��
����)��h�/B����z%oW++{W���<b�7�2�f������kd� B��%=r�o߽��j(R�s:i�"c�a{�s�d�\�j�za߁�n��A��[cB<윧�
�n�/$��_�βk��5����S��*�!C���b�Ԝ҄{W�"�l��-Wb��f��{�E�hK9a�G�i.OY�l��2�4K�#	e>ѻ�f��q Xo;qI�)3,�G����E���e�fB��~^�<�@{H}�;|���R���
�";�C�7*yfv�# �X�SE0B��
�,+�:�w�����;7�߿���%�V3!PW?p��(2-�6� �1�c��$=�qWW��LQ�ia�>����;9n�� �5H���_��\� My):��7�o2G��)ϵ�ס�U�Z���n�g�`S�?_S�T<�恹�p��I�Jtx@�u�wi�zV:����Q��G�暊(��[;ku7Oo��)Yp�r��}��+*ª�q.
�v�o3���z�A��7"��Kf��H�`?nxw��řZ����9v���:��*흪��;��VA��=�����j$�N:��H��|=��%7�=�fT�=���4����t������.�Љ@nk�{)X�(�F����.��96!VwI@�}�t��C&�{qq�a)��oy�?����
4�
�;�?
i�����u�1X��Y+�F�V�)����B���+R�m�M*f/|37vD�1��lG�'�0-N�Th8bO��-��q$|�vLz�e"�݌�>��VS����\j�FUc���\�6��HF�2<KJ�4ɯ^�z�ԡ*��sa� ������f���)l�h���~�מ�F����aɵ�G��}"�Y�7]d�߼��o��4Z��e_P\���*I3�me��F��wL�ʸc����RM��'�r����C
=��c�ӂ�R62	�Fv��陋��)����-u��eug��af;px����b9���]������M5b��_r+��+�?]\$h��ͥ��JBXAr���ex��ؑYC'䀲�+F=\���y��{����Qk�^9
#�6J�fqJ��P/��2�w����P�p�RS���Zʸ�Ʃ_�s�:�ioTH}U�|њ��"�E�+�
�@�l����O[hE���,T�b:Fh�{0�_ q�Ӥ���&̤�f���d�wVIy��P!�Gri�����v�稾1"���ђ�.O��E�,�"��d}`<��g�tL材~�uQF/��;R����|EM��0y)[�	��s���G������f�}h��'�J�@�N��渕����{X�5j7a{a7�JUl�O	�p��y�Ǥ�i,�y�
���9�6�˒lH`2���|�
�"B?�r�qe�������6M�9 ϑ]V��='L��ɷ�ۄr�/��y����%���YҒjU���eT�Y����m�yK�l�@av���7T��IF
">>z<��ܰ(���(������m��\޾e
򲒣�����ĝ����(����#�J�������B�Yo(����%aOr�匎M�:^���q����\Gc�d�������_k/��`-!fc���4�7�=�"k/������;���l�d��v�[L��{��VNҺ�J*���y�Y˹Wuv-�Ȓ�����6x��*�f>�m�<
�Üm��2ov�l��$�Ǚ��j#mpuK��;�@�� �=��Ş'�0����6iX+2=I�֨J�I��Q<oc�� �[l������\I!�w(><`��4p�^�x0�PR2lӿ�����7�:�3��}Kx�Ō~��������sS�>λԧ���6VՒ�_o�6�䬦��#<����)��h��:��@�3o͵E�ˈ�U�����QD��5��ӷ�5C�)��<�"�1����Y�s �����)��[M\����d���~�v(6����qH��� �?���5
�%W%��i��fQ�s��(,��&�O$%-��+ň0C�&{T<_��DCW�a��2��yӦ?Q僞�޿.С�0�9?9nʆ|��Mi<F;���^&�Nq�ȕ!e�����q���-DZ��np89LO����k�7Yq�l���,�|�r�'��`�TL�}Qʍ
ԌoI��Fx�9~y��M'!Ă�I�e����p�����@"U�&2��WX,4�x�4H�zt��4r0cʜ���V���m��ʇ-}��ϖwD�?���B?q��6��cO�[_���1���`ы�T0�Ф,�C�g5�#f\�Fb*�XK�<(,��PMA�e+�<j䚾��}�� IXX��
�?ʫy׶l�񭵔���&D������Pn�O�P$]��^��*�;�pˌZ.Xq���q�U~�N���r�J���>�������ls,~�6^�|�:�L�>���0C{0�M� Y�k`t \ICSc�Dm��q�d�
��k��h\�ʐ"����0��̐�҅���"��'9�*o�#[��"#�{'�N	�m�Q>�
Q�4���ܡ�J�Ā�ۈ�_"ِ��T�F*�����z"Y�l�ҧ_�j��D9}���YS��b�1�y�T�x3��g{��;����!�d._�v������4�<�S�bK�h��������T��ul4)�G��/(&8�B,�kwL1��<�z�|ԩ�"����6yP�G죎�K /V-b@�Zy���cF�WR^� [��b��.�q}Տy�Ɏ
6;B�K�����(��jK����%%������K��tk�i�n����ݜ��jd�Z=����}h�	�O�^% ^IT�DNQU
,F�\�k�|c���x�˯��Ǧf`SUeP�WgabdReUe`S��*�j`&V5fF6�����ο��������������������������7���x�/=��C�_����y��ȧfqI:e  >j�J!����_8m
���te����7k��jA,�/]��������?��#1 '���x���[�������H��������������^��O��o*�?��t����qW�����UVcj03��4X�UX�X�Ԙՙ�5�4Y�`:F�+u�_�M���f`SZCmMm��F�|��H����G��� ��������1� YYi Μ��a�����.�^�ֿ����6�E�^�Y���ߢ��j�,l��ꌪl�lj*,L@F �:=X���PgSUc��P�R������LE��\����0120C����t���~��dce�acccf�cea�O _���D{�[�n����m�c��?�����o��_X��%��i`h�[��?3�����1^����������ĒCn���`��ZV �������������3�tL� �����qQ�^i������/������M����!����LW���g��>=
�������7���怎��?��p-���ￋ�������Fz���R����
"j5"jC"R^"RNH�O���z�BH+���Q:O���V1`G�7ѿ(d�Bt������5-�������132�x���������.FF6fVf:�? ����I��в0_��7��/R���3�]���_�����?�wj=ms+jMs�����i������L,?��1��_��������������@������W������%������������W��W�����7����[�?���C�͕�������h���������?hY� ��,lW��o���%��O���E����+��w�����y�VQ��Ҹz�����|��P����ߣ��z: ����� ����������d�acac�20��FBh��~���E�����O��e�g�����[.sS0�����%��$23� �*zz�Dz*�ZDfZ`"S3}FusmC"Um��#������#��C�)F"5-m#��?*�CF�HL�	6 ����ՉT��L�z`��0�����q}����TϷI�
��
`SC��٩X*&fD*���oJd���wB)���c����%:"Ȏ�J����`U��kT4����gA��� ]0�������WzF���������g֓w83^|�˯K�~_z�[�����+�?���~��L�����������7���L�
8��,=���G���>\LaO�g_��O�����_N� �3:	��`��NS���~7.;��g�@���J��~zppj6hL
L���O�#�{*�i��5wn��ε��\0 D�
��;	@R�n�>���&�I �/�*/;ϗ@��c[�$���$���Ƞ �g��O僂�7M)"�9:F�剀��H�i�H���H|�
��CR贻���и�]bV�2(V@�$#o �J"�	�wPN0ʎi/�w��K�᜶wVg��d�O�N�R]�}r���t0! `<q����!��y�>�w:V?�s
Ȼ��]~ �dL!kP����ж�t�~����<����r����n�S9kn�r!V?`��8�D��Y&xx�O䋇�O����9���m��[�c�����M7�e��0��O�Jt��8����Y_��[}=<�$�{���������J����e�D�I�`_s��ן�>AY��� ��+�>'2�|G�������~2���w�f�D�]�y�����ugv�S��S��q��	��<�7��9MO���w��?��>��gH?Nd���pb?�!�3'}:��-D��x�ew��. �$�� x'�O�$����}�ޙ�:���i���҂!6"��)`S:-��.S@04V��߶L�6d^v ����5xA�v�@&D�Dӝ)�t�뀀I��	lJe O_4�����_ڦڶ�@ڡm��3{���瓵����G��3�u�/���%���S�I��	=��
�:�?���e}~�6 ��TE|!����l���م[h����8ō̴
IgO��߀������������1$5:<>ւ�NG��'۞���JHz�vB]| e#	��"��C"���B>�;��t�P�� �ٳ����V���C!������~:6��c�w��N"KV!u��k�@>v����-:J|l�<�����|(F1(����?+��W��S!}_�IOs=���9�ȇi���'_ c������?+���_�����獹�t=��@l(̣0�p(������}=�(�c�B�y�g_O0uF�Ю7_]W��uu]]W��uu����x������i�iz��������MޭKϽ��1Ϟ��\|�}�R���񏿺~z�v��z�tcy�,������-ԟ�W��}��/ga��P�1�O�ϞY�=[�9{�w׺~Q�����'��?ȶ��t\@G������O�gr���Nb�4�o^'D��;ҳ�g���M��9ɅC�s�ٹ��� ;����f�Dl4�4t��@�Yz::&��������8���q��/q�?��"~������\���X?����8���"�����Ν�����8�qq�?��EP�K����8�/Ea ��]��c�a�.�7��w��c�a?.�=g��� �~���;�X;��˟R\^'/O����?]���
�f�o�6�Ӱ�3����It�6H��D�603�h���A������s9��م�"�� � C=u�d��� ���		���gp��7HP�O���Ӈ �)/�V��?��X�#
	=}z����㇒ ���8?�(H\PP�4H��_��,^P���G/�yy����`� ��ဪ��D�Z�y�x)V�"�s���*f*<^�:i
2��N�5/^
��P����d�!�OG����_"5/�����$6�R��!/�U^��#<����!HK�@2�?�D/���l<��!�յ
�8�;/˫��}\t��Ct�uڵP�[�t��Z��E�'yF^[�߭��t��Z�N/��{�����������g�GԽF���}��N"��b��)�O9��gx���?��U�2�~��`��c���Dβ���Z�v��Y'��W��:ܤ������/����o�N^���խ�ƪ����y�%�/�N~��5c���N><9T�Fz�򻈂��u���oƨ��n������?��&����o"\��Q��{����oV�+���N>����~����R�ۯʛT��+ȟQ���_k�����lc˙�U�`B��΂�O�q��U:]�����cȟQ�p��+�����'��=��u~�c�������b��Ƿ�7<f|���5J��7��+��_���W:�]XPPX�������&.<�M����	�3*����0%4	2�;�wW�+�
��Oi(��{N;�s��P����h����k�@C�ռ�3�
�ea0��B��0p�PA��L����gs.��y����ec�P�EZ����WFu~�g���%�we�;�&�';���d�s�3�d�N��{ϫw�^���o�[���ν�@���v�����j�n�o�<\�-{����#�	�1����SӞ���O��O���kZ:9�]s�8��Hk˿%ݹ%ǚ�����}���L�:73t��.di��N���:ڭ���):�\G��ѹ:z��^��o�ѣ�
��'�[Z{���L]-�+/0����Z�dyp ��J��S��4��fi	����e�I�.�7�3i�,�!�*dK-3�rW晔t�/U�ٳ�����6A�i�^rk�K77��ڮ(g��b�C������5����m�� �y?�z���~����sP�m[ ۂ���g7Ș��H�
�j�+@{�~��j���ujx� <Z=a�N�z�L�P핃�5b\��0n�7C�<���ɀ�zV�C��VA_��>�>|�oC�*��������%PU�0�=�7�B�s���om�Y��m=ҳ^��[{�}�q��x��hj퉃2���	��!Y�|}.��:��z����.�l��<Ps^|?�	g����:W�La����YB��G����u����
x��F^�"��
��0���N�i��I}���ZNөQϚ׾�4Z�´��8���Q���k�`4�ٙ�ypwx_�#N���/�bڃ��:]�9�����!.y��<��a�_`hN��+&��<�J'�������u�i�W���2�V�wt��1�y���/������G��������`��>_����O��T2�Fh�i;Uߨ��M#����O!�h�F�UŌ'�nM4���Re(0�Y��o�|\��U�>����Xe���u��������B��u���h}[�������%������BG���	������e�}1�:�q��?�=��'�N��y���);Rȇ4�?(������-ш?��O���÷(����C��Ј+��
D���w�7O���g޻��0K�_�)�î�[�)���+�OV ���_�oB�)�?@|�r�j]yM:�y�
���������w1�����)�Q��P���ޏe?
c������N�{�}���W��@��l�|%���:��{t�x��w��G��:~Ϳ��~~�y�~�����c�_�黃���.����OGG�]g���g3K�k�l�[-�]��5u^�m�mvi�?$���o�
e�GL�@��P��Q8Z
�{Ѱ���:�vF�AO$F�,�����}4��L$�Y���;�`l@�>�OY�bh"�`���X,$���b��I��|s���c�N鰉ȗ���)�����}{,�"bl��b�0v��$��$�S~�>=���0���c
f�t�?�Vx���\����D���D|�N�!���]4v޹Z"~	��A�8�!���6�!���8�g � �z�"g�~DG*���M�<w@x�Gz ����ag��Έܡ{�x�wD�:
~�WJg4X���[]����U�9*_�u�%X�M����s۩D�<���Z
�#�4�����^vh�╦�4�=+����8L���D�����7��9��Z�O\�H������.sE���s��e5�z��柔m9x�2XmH���&V̫sW�{��|W��ek7J����W�;FD/���OU�7&�Ӭfx���rw�۳�k�X����,
&�v)8�DZ��y.�����>��I<ڔ�-�H���ɵK��=��������S�k|�sѦ��/r��G%���c��w�O�g!=��=� ��t� '��u���{�4��ل�:�v��,�^�����-����'���3R��;�%��{�i�d{�_zk��gl� �l��{k���9X�ۉj�� �;���T�c֏@"}?>�'������PsL�ê�Q��Jz[z8��oU��Z_�QJmL������M Å<؜���iՃ=b]||�k�Yc�ԫ2�[�j=���v���� >��;��$�CT��Nkn��u��]�_���x��`��A��~{C\� �lm�Z�C�?�A�����m��vt����Tj������/�ЃRx/?�Q���_Unt$��C}æ��]����x��1)�w,kG�=ׁ�"�pd�k�}N��会�
a }Y�$���vk���@�5n���o���	��ޟ 4u����KV"�EeSCY4,*n5$�
�[g�:��R7�2E��Em�(�"�������
��TmP�N��%Xg��4������ �+[�Ϲ	������������������9�yγ�{Ͻa^�x-57����%Ǥ�	e^O���;@$��$?gOΛP�+�;��-!ڭD^OH�[�mj�	��#���oD*s���\^y���!��b�rP�h�h�c���rc[Ӣ&2fo���j���ddIR���^�d ��¡fb�I+�X��]Yْ׸Jϲ9M��5��|||�y��Wa�o�� �  ��\i��̆�^u���y�?���t�����TWU���"��Rg�d{=�^1gzq,E��7��۰x�U"�
6\f%���n���=�?��^�Dd��>�ǂ���kz�ߤ�d��g���{(����8��S�Q�-)�Cq��-�� ���z8�/g$R}�� '�Hz� Y���I��8 �@+ y��zbH��k3��Kͽv!,1&�ܥ��<�[!!R3��%^Of�ӽ���}bX�x=��0a%�z�1�s��	F�y�����g��LH�0�B
P�M��S��!��(��S�(���{�R�b�F�����L$�t����6�@��(���;��<z;(½�)Z�(���h�E�����U^O�W�}��̪rs��?G�U$���@����*���!��
�g)k��W�T���K	���=����o�ᓕ�P����;H����Zi���F%�5b�3b8�g�H��i�.G��3�`�8"`�z���Blh��Tk�A� �@�C �f�I�Ţ=�\I�G���mـ��c�t����GredLBhs�}/���EvY.�QTh��A2Vb�b��?<1�TAty*�<�<��
5����Ћ
S��籜�ļ
 Z�`�$7}��.l5�k$�S#�S��H�`�'?Kp�o`�c�rH�x����-:t�b5����Q�nd0pj���f���;U-�Y���Ȋ�9���x��~g��V�JhJD�5*�%s��8)#�^���pV
�/�in	ʻT[�,P���O��� �Ȋ�
���#^�b�� �t�73�Uo�(S4�.%�q�c3�l9ϣ�P-H�*k�m1�1O}���������N46��_�D]+=\���V��w���{b��Ӯ9I}�g+q�?��WW��a}�����
�k���㏖	})�}I��z����	��?ӏ�s�~kT��$RG��Q�r�m�
,�c�ˊ�Z"�ө<-�Y<�=��������G�h;�ܞ� �H���T��ZI��������k��2��+
Crld�������ٺ��*sxa �Y���0f���?�?�����Y��ܘ�%�����7�1��k��Vd@dv8�1�C��n�)��'?�ݙ��Z�
�܌���
88�myT�b�q�(&�U���׶��/맷I^z�'ZΚ��·�*^Z�KJ�9�����W�����5�ŽY�����/}�+Z�[?�jU�/���Ur*q{-���5�S��[��FW;,N�d��R'������'�Ĕ�Η������<����K�A�K�!�m�$n�fxq���=}�K�x2zڅ''�\�Rb@F�)�M�7Q�{�%�)�d�s����o
bc
z)i�G�o��6�{�x?���^bG��S��X�D^� �p��+��7�)i�ME�yb���{�� ��ފ����Y�C3�j�sh@�C�����x����!8>=@�����g$��ޗ410�h��"^a���y�>�}���e#.#wJ����D�]�7���jJ������$�D� ����W����(��n��^bה��4H�<qO���?i�^��͑�dB��z��*~�%L;Di��<�4�6%Qco�Eڬ�qpk3��,�2���#���zN,2r
F����0$����J3N�:�Q�S.��bQ�:�n�|L���K�W#��[����[r�l�x,b��1�%��n;��اM]�C���K�	�������{<��'9DF��H�kUe����@�[�����أ�WU��-�;��4�5l@c$����3�V�upL�v�D�r>][�O�0U���gY�4Ȍfj��Zd@�i�^a���� ?�8��
�n`�IBi�����2��"6�1���O��F��ً��׳��p��,���-X\�xe���UW>x�v�؝�鯷��D�'-�>����/�K$%�&��/ҶFt8�������P k�M��1f�J"fyA�ʂ����1������虃��B�y��()z^�*9�J�̞�u Q@8ΚɊ�"Mc�8VS^�<�\Ţ����豉�q��Z4옒?>F@z�1����zq��Phsp���oE{���?�g�o)Dى�)6� i���8�W�6��H�8qmZ���X����$%r�c�����=?/1��F����
r����g���\
��Q�}L���M�TLD�/R�����R�����S�H3� ��2̖�	f"�O+:̫��6�(<ёߍ���+QܺhO������� �Ⱦ�}�r��z>N��V9�#��q�0�z�K��.�$\$fec�m�r��艓���1,�69��f���-j��CF�}���"YB��d�qy=(���-2k�p��i4�ѫ��Q��3��5%�D���Dq��l���Cޭ|J J��уb�Pz��t���M����^��/� (� ��� .��z����(XgR���K�'}�LH�(�#m�҃��^�p��(��J�c|�/څ2q�'�x3�a�P�$R%rP*�A��H�%b���U�"8Kr�w� O����18�W<��:��^oV1��@�9�����ұq�zT[|�q�=��c��f���l؏#{MIs$�H�]u�_�D��V�a����$��z����N�W̑%W��M`C�h�e��BÑD��F���R"���F�Q���O�f���?�2�s	.��U�)�L����#�E��Y�g=M
`Qb�b$���{�6�1�����'U��(�8�����`m��`wvz5,��JӖ�ҽM�{	.]1���3֌�y|��f��4���l�4�R3ЇH�WX�C�OaM
�CiJH_J�B�ˡ�HH>����!}ʟ���7��W�,>]Eċ:>�6�7ɸ��<���G��I�s<�]�	pϡ�)(!T�[�M��e�DsP�8��hN*W����N�p�N:�JZ���_�$�5)2E'(�\a��듣|�
�� ���?F�w�w� �.�N�뢨Pe��Z��l^�k��ɎVr�
v�ӹ"��%���fkW���yq>��P���9�8$���)�4,5[�R��d�o}`�)9��D�G�.�i��o�~�D�B�WF�[��aeQl��u�I��6����L��+�B?���%&�5��Du�U�T�Y�ޯ}�Xέ����n_�:�T�/�������6"�(o)��W!��6,�q�}C8K~��A|6?>�-��f�\b� m�A���H3~��{����=	^Ҭ�UX�q(�ˏX��MG�p�A�����*o/oϤ�&t�Sr�o��"����x�n��)�����]l���p�8�1rJZ+�/�����c�J��h�	R�/E�]�:�O�U���4��iؒ��.#����%M��Ǧ:�М���c%�+�+�Xi����yC�'�Jm����hS%^R'�8X)��
V Pv�r�
2��������!��rZ�� �KK(�x��Rbz[�Ғe�'iu�#87x͎�LNI� ��̹Skc����1xM�.�P��E�&M�!����7�t���fX�i��\�I���dɲ̲�"��L��Ve��q����4�w�s]���f�S�|M�j	Q�Z/������G��eQ$�Q�F�M]X���͟_�Z|a�i}w낥�8���7G�:�(��S�K����u��-/T>1o#�Rn���%�.̃�h�����/̅k��
%*�n��Fx�1-]L���,P?3�/)\l��՗I���V�4;u����?qZo	g�&Vu[t*�麑N�Y����(Z��|ݝ|N��� K.`�A�:����@�#���z~	i�����}�q�@�I]��W�t[2c�"(��,�|]���r�՜nhǖ���ڵq;�V\Pc�Cu	�Ƽ���%f,�h � �m����x7H".c������P�['�sao
���w ލ�w���{�j��P����
2�@a��?8�	)�=!`�8�qȭ��� �"/����X��I?@����U�/�9�������J����1�NƋm�x���4��EF��X�[Q���"}�e���i!�Ӆ�,�g4�7��
kCk��ۚ�?I�m�ͩ���9ʵ:0o�O��UrZj!XK3Д�T� ]�h��>��g�9�\�c�ϵJ6T�2K\�����4a�U��i��a�䔔Ƭ^;˴ �s:��'�5k-�;{�"�M<���� �Qt�BcN�y�ᓔ����ÚT7��9<p�%U���U�c��G
��"͇�	��>U�a3�b�e)h�-�V�kWA�X��������XB5V�0�
� J�o��c���5�9�7~�|<$'�g���gz�a��@3�O�ڇ=�č��w� 
%_I5s_A�{H��^�%N�u9��P�9��m�I��f����Ov�z��e[k�n��k�Ѡ��uo8�C�~�P�<� h{@�;�?��w;��QI�!g�W��Nʞ�.7�ƈ�=,5i�/b
�����l��f/�s���W�D��sP��ߟ�%4�z�ϱ'�x�:��b ̙��-Ӳ).��9d�BXT*H�e؂���B���;J���>�4��G�.o��8�I��H�H���m=۸���e�*�l�}��W٤��	,�]TQS�b�Ő;F��/�@œv��l�-�c�;w�	�LM9�xdi�¬g8jn#%�0�KU�n��B/�V^"�"+�:����w�3�v������6��
8�P�ȱ���M�CZ�Enp	���Tu^��~������@�����Ѵ�%'mj �w��}��h���&���T"a%f��wi|��;_ �<��5;%L�`��*͸�q�۩�����kv.l����L�q��Ⴔhv���NO^Ld)5�jLda��A�H`�1�����2wG�\�BX1m;$��]RA��>G�'�}��⠭�|ӂ^G���p�6�7@2�F#p�!Ai���4�I��J)ܬ=�������<
�h� �b{m���[��Gk�H��Z�Q��;N�a6�T2G�L��|"�����@���[,���2��'�+y2"��^�#��N�i�6��A�\s4Ȉ���_����8�|��&��Mb���CU���k�OŃa}S�ǵ;����(�K��\k^rؾ������>JXs	v�	�Fȍ桛�y:��J�2<TF�(���Z�7��2%
���=M�Mu�i��٠�q�/��Ӕ��+"[]U���v9��q�9Tq[]e��4�h��߶G��0O}J�6�������}ߋ�=6�N)���(.�b�v39�(��f�f��j7�|Ws�|�)��!��b�x"�v�-���O��zJ��F���KdI����>��<!��
W˄���1"��q{�1��W�{����;�^���!o����ªb�ŗ�+������	e$���8���-j&`�'Mx�ր��=��������>O;�����G����8V�9�J�ӈ�i�K�g\�N�v���N)
v�ep�����_����?���z<�*�D.	��ܕ4�bF0)����? ߪ��RXY�z+�%�Ia|�kP���w������(�'����"�=����v�ޟ6��;(��׷��w�����}J���������?�O	߻�oEV�����R�jdx��'�Q��U��+�w��~�6^9T7j1~VFv���aE12��!�QlDA�\W�wr��Y��P�#cw�o��ݜa��XҎ�����쨗�{}�o��'>��'H��qa��sū�:vsk�vәq��)��us�=㴪���vv���=�@[<W���<?�G�K�'{K�Ɂnl?ɢ8b�R��]�Ծ��Y��b��ȢgQ�.�ϯ�W���w���H�!U^�Y���%	�d�.��?��i�+��u�n��P2����:�� ;�
oAu\R��o67ګ^`��nyl91+�`��#NS��̢*?�@a�T�+A�[�;|��Aֽ(�s��x���C��M�%U�W.u�¦����vV�I���Q�n�A�h��/�n`�v�D���.FD՛W�r4f�h<W�������ܪ�H��E���x�Q�Y*,#��Y�n!�F��E��
O��5���N{.T�o��ڇ�ί�
�����u��몱;|-C�5km��;��TS�m����V돰��)���w��D'�&/�P�ٹ�߲�_�4�t
ߥ�М�e3G%���+(���_�D�����8/�!9�mG#�H�C|Fz��C�x��=�v{�������� h#�|^M�\ݢ�;����������[�>��y�s������`�`���5��+b��6�1Dm�OU	�^��1�h��g�_ɠ�$;���Mr��Q|�m�	Z+�> Q��b�)�^u��/n�Y�}��F��	6pT�X��Y��Q�$��OZO��o�	_?���O���;����=ϵ=����X�(�Eq�^�YD5�-݃?�=fBjL�y'�����6�ɗSTW�|�� zv��,��m6�CA6���A&��Wa�c���I�Qb���)P�]����+߾C��~������:)	
��zO���>��I��{����>^���p&��	��/lqޗ�GK����.����]-1����h{��d0�� ˺�6��������HR� O��%'Bm� p$$<��mG��� ����c=4�g�����DHۡ�n��s��"�ٜ�G�^�8R(C�1�
x�I�����Sxr9�`?��E�f�%q�+��c�hR�e�-�W�ŷ��n]���%r�K,��ss���^l^�`���z�O?T�[�s� ڦ7����u�0;Jn�nC������+�a|�\����:"�ovL��7"��t�B��z�6h\�N���Y��+SMup>P	q�{�~>��n��Ľ��a*�:Q�v�+�����+�݋���U��:C�5z]�����|z��Cu�=T�a}Y�:�)�<�&IzO�h5P7-�i�m�P�烕����xn{�{G�(��
��cNRCט�x�~`3��yu��|���ƺ`��s��� ��mx�e���_�o`���V�{�o��Nf=�N�|-�ӮP�k��ɹ\٢1�=YA��ݺ0]���%��+����P��Mȿ��WoZ�����Q`M���
f�}��uh�ǌG�dB����)���;���S�)A�|����}�^|x��C�1��Cܓ�`!�g�Nt��@Vn��>�]t���ܧ��Md���y�}���������G�_~w���T���9d���Ĳ0Ǥ��GHg�}-�����yƲ-�!��.`���g|�0ڷ����m�0��o�31-4��6�W0A���3���?�h�'�#����
�}�����%��Z|����y��<?���%
��~�,�m`p|�>��:pg$��:�o�����TH��7�,�~��#]���p���(���X*��G��/���c��s�>�ސ�5�nC�I+>g�]Iw�	�"2㍭]����}�ӛ���ܬ(h�
�U�@�J1B~�2��}ʚ��w#���>Le�@%���>�.DD�A�E*�c/�G����im�$����]
s�gsF�ޙee���Kd�_E�ȫ�Ui��?�+N����#�nV@b�G � ��z=�'�M0���dʹ��q�f���.�l�����>�g�I��ϩ�Ԉ�Aل��a�6���e%Pu����g/��ώ[���%󜑞�Ư��.��_��g���f���j� �2ل���{us���;�����{Ȋ%���wE/��_S��R,� �c �Q�{ނ&�oYj�c�w깮P���m	5i�5���0Pe������y���|W�o�]z��U����C�|�|�G��Q��v�2���eq?Υ�R=9�vDOtHiw;͡�7ʧ;���'fY�^}��|'$Jj��|�<�l�e���qν���0wFh�!:ӆ8�
72�|�*�# z-�A��V�C�!���b��/@���eP��b��G�^ B�=��nK��2t����z.�q�[E�{�n�q�Nc���Ś{{}���1^
7�xߩ�������m���}�}(8UqH�������(&�m�q?�r�M��r�K:_�q�kux��l�2���)�����X�N����eQG�G���.��d�=�Q<g,SJ�O�Z��:�?͟�o��yc�i�?֍� ]�w`�\8G��#'��r����F�4�r
r���C��Iܴ([�J� ה�HmA��!�ݫ�_�U�	��7�U�?u��F�<Nqn
]f&�	�Tް��Pm��j�)�ZUi��0'*R�"U�N��g�
��Qp1=�[����[�  ���b�!�uW#_������zM����"=�
��? ����6]:����+�EU��R�o��K'0��P���@a%x-��l:�N�z���3܊gt���|�lx�ik��v�]T�X+��_$Z�Z�\dס��x�
jO�ݴ�3�`
Q��cڰ�3Q�K�{J�?��h�1A2��9d8jP�E4�'ǢN�j��\(;Η����w��߸��I��%%��
�#h;�֒ ;�`thPåVb�ǖ��ޖ��,@��
�����.1U2ϣ�3܊gSa�����3��v�7�7֍�ӸDl�>�F�pK��=%Ԏۊ�0�S��򡶙���.�J�����L���CD�@,G�#�ʂ�.���\��W�*�u�+xd�KY��B����������i�"�mD��仑E��w����&��An���w#73:���ޓ����B���Kn�w���Q��]�Q��s���`c��,�_tt��S�=Ӆ� ���y`�
)��{�ې�uw
lSI���HR	+��غ�Z�d�8z�������A\��͔�1N���u�yD�8>��{%�,н�A@ь��g[1~��\^����"}�w�����sy������I�_&��d�M2�-����ҍ�;V.���:�1⼅8�Ѐ�
t�-�C�p����7w��1X���?涔����/�U�@���F�;g����#��99Hљ�a�?؏�X��tKM
A��A��p�)�Mn�y�r�Jl� �D*1��	�B�1b�Ь��aJi�)�J��9�."(ڊu��|b�x�7��7�0ӊ`��e`���o�(h
���A�[sP���c�`���]F�'��x��9NϡE�Ԛ�5"�����g�mn/�s��W2s��ЕwD�+f���B��G�G��t`����Q�9��y�U'H
��3n�p\��S�m��Wn��S^�V�y�0r���=Ǜ�RG� �a6܎��� ;nK�M�%)#jwG�tC:��|.���A���9d�K�����
יI��oR���:���}2�ׂ����������?2�t>�;H�Y9����g<Z��@�C�]��fjѷ�	R+�'m�A܌Ǿg�o�y����:�c�S��%�҃�g��N�����W{��+J�1��K�;d�@;NW����nC���z�#�n����_MH���v�lA�(����2R�S�g�w�_j��25����V�A��[�
�w���o2�
��ߔ��L���n����kYhɢ/͎�$�<?��r)���%5����e@�{���d���{�����֩@3�+N���Ž���I"h��"�5oU�7e��;h֋m���	z��\�������i� a��j�
4#ƸC��s:#r�1�N9��Z���JE��Me��uY�]z�M*4ƝΖ��K����N��H�GN2#�8�9��;( ����}Lp�h�=��vU1=�G�Ț׉�cz h�o��UJl�,K�?�ӳk��A�. `.ŕ�R�OJ�/H"�痐�w�3i"�pq'|���$����4��E�D��+����.M�$�����>��i�m��W6��L~��B��9u�=�G\[�*�����(�q1�2�X��Y��6?dF\Z�4]�{��2�O�K�P�B�b�̾����W@N�� �i.�w�V�3���ȗt���/�Ev�%n��*\Kl+��c-�
J�n����A՛fSni�,�����ſ����
�Q�9>�q�W:��¿	aᦗ"ݩĿ�(�!y�����b�]$y���y��Y��|כ���y^v�ԋ�I��!R�pӊ�_jd�a�H��7(������Gt�K���l�f�����fq�L=�1���j-�9�P�ᥭO�*��W8>� ��
�����q��!��"5��Y�4`���,�$��P�+?疒�nZV�ig��v����3Z�3��C��$��\�q"���S��ƿ�R��<���7G�Z�AA��K�'���_�#8� �(R���DA��*3�.�{�
g|�z�`̐��ߘ'MGܓ���/e_�.s�V�n)]����d\Q�Ň�R�,���G�j�G�YA:']�k.`=o���.�{]�^&�=��NYF�<���~v7��)�ǹ�E��ڬ��h��u��u����q!�	���g�z�(ޛq�(���)�.<�C�_��~��e�� �����u���Lk�ROt�Q�j�E���4`	���u.Zx +
���S���:���J����]����uhBYw�Qy��x����7ߺ���;�_�j�.�Ϯw��@K��)�~�8PF]�4�q���{[P��.�T<	�Xg��w���sN�0�0�P��9v�t�� �2�X�y[i��=g(�
Lņ�]ŕ��+x�Ziz԰rף�+?{��ʀ��*�jê]�+W}���*�V���~�M��\J�2E9��M�*:?��g� ����T��Mm
zϊ�(|�Y��4��<����J�!�2NkX��kK4g��@?���ysO'�
��?P;ۚ�)_�Yv�1r/���Χ��hN��?õ�ŝ�[5B���u��8�H��WSE鸄Jߵ��q�b �xP��b@q�jG�eM�>h/�D&�?��Z���7H.a@גqt�3�^�8��P�=�#(��W�9���L���YA'�	A�(ݭ�d��VCt��(yb��O_��K��o��.g"������G�yV���rL��-�4��!⢕{��@Y������Dq�٦������������IR��-`:$ߏ&�.�VI�E�2n��>��%:�L��Eƶ;xS�e���H$|���oy��¬׭�B�����'m
=��!�ٮ��3�(�`�����9��ҵ��r�g�[>�\v9���]�z ޼�.���]>pWQ��*O�p������Ε6|��j�")逮���H.R�Ťd��I{7�Q��r锑�=�"}�9���(Iܖ�������L��7�Kx�e�X"����&�ŵ��7B�BL����
6�m��v��x=:WQHW{y��0��Л�׭I`�3���GR� 6pSR���K�$�p��E�]�$f%�%��|�!�OI��L�u��K�,Dg�b&F�g�@�#��48�X!�8���o^�W'׏E��<��VN::W�n��%���1ڡ��������4<���*�����<���7p�����{�2D�����r^��� ���7�q)�v���b�*��u�=	��+��=��]<���r���xP��	p{g|gǒ���N*M����z.��l��jJ����OZo�y3�K��:�D�	��i}oh��W���\XC܁I���7�z�7$����K�\DG�	�-�A�x��6y�Ö�umsa����Y�7��S���ً2φ��^��|cp��p#�4�m�^}}v���
����,!p������#�G�O���)��^zi��E2�#�'�^�#�w�>�f���:�[368�
%�k$ߧ�)g޿5��G���-�+*�$4�̴�~
���hPh�߅�sW���A*։�� ��<��ä)���F�S'�����I�=���cQ,YM�|uQ�P{���|v9^�D��y�1X�Ⱦb.�v���/��*��hQG�H����Ǝ�'�6b���ܴ�nZ�m���zR$��O~��3���GY��c��1<����d=t�E�*��땶����r}���}���k���e�َ����59k�t;�LQ;�s���-�̫u̧p�̽
|��X���֎`�O��b�9���*ߥ��F1�m���Yʓښ�.t\]��
�������:H�Ru4�k0}���J&�Y���+�2pe��[�1��#�ݺ`��8gfOq���q���TT8������+3�/��ۧ*���Y�BD=ލ�f�����jI4QQ�'n?���i�l�Ak�0�;��+/��S�8��3v�+!0}�:�[K��� ����Mڐ:fC6������B|\a�E��p�I�7^�����U|�m��ͻ�w~4�w�K�B��g��B_��*���϶���CB:V���[��^2�^�Tb��ͮ{�߳B���~����as���ɒ���y��<��?�p�i�f��]F_]���� ���})x]��5�<������BO,�8�􈛰-R�̴dX��ݴ=��Y�b����߰1�E�Wy�f�}��JY�G<:�ӗ��qTy�Ab���J�����>�ĎJOT�\k�3ۤ
=��$�5R���Hq��%�i��z��M
nOa�R�/h�����u�W��ⓥ��p<�x�CB��+T��I^3z�gB�u��+���'&��T��p��{��P��)c(7�B����N��d�t���;��0F����{��	H�|�T��W^-Zi?Dǀ=�}��h�Q��"@��� 	���1
��$��߬��%>�$h������ͧ���)��v?�$�N��Ij�<��|R�"�/ޒ�v��k��҆����6��xž/\������/���%iC��0'~7:V�i�Uq�Ac����U8������ n�����k(Y�� �?fM�q7*�2�Y�\�t��#D�P|uV�܁���i�r��������d���Ka*�_Z����}��'�Y�x,���r�n���<j���y�K֓L�#� nk?Y��[Ղ�
q5��`��+D���������(u�Y�G&�77g��v����h�__�`��sr�<lG܃`�%��N4>���v~��]c h0��z�]׼r3zbA����5��Z��1}0����\*(�؉����jU��[k�Bɳ��ߒ4|q#���Ut�|��"�/�%��t�����<���oH�2���→�Z"X�K�k��{ێID��O* ����w�R�ʻ쾯))��@�>E`CV���N����F���z|��7�H�e�����x��{��K>fF���ME�	b�����7H���>�Z�����i������.�z���'ok'�bO�m=�퇦�%bЍ>O�@ˑ
\�TA����8J��sX(}��蓮���H��W�3�^>u�"���z�����>Q���^l���w��<f��e�Q���2���=H��	����z�@Z�<%�8���c�#nK�Z銞*c��]b�����B��m��E��iװ�āD�l������	ȹ��<��y�M���x�.
^�π��c��0�ۑ�}> �C˺�G���q:�_^��Q�(�:�X��F��%�[�Ǹ�^hdPLA�����L(�<��z��v>�!�����g_@q���j�͓��̬�z�"��J;*��bą���Uh�5Y�דtR���=�-=`��d9�`sf��-B�fwkߒ։�T"M�G\C�wߵ���2ϯ��xޞɘ�`�Z���k���P|E��!ECL��5$��@>~����C�VRP��k�w����;�`���\�'�>IO���<��}����$�-��č��Bރ��)����
�;��ɫ߻�猼�hq����Fŋ#^@����~#���H)����(�W�%&�}��܇m<��X޺*�=
/E�f���q���s�ks�
>�L��&�	��\��T�Q���A�}
|���w3����� Z�Q�������)�|E�p��+"�P��Q_��w�4�9G��	g�� �rRb�$Q}YP/����<��d-Q
��䤭Qrij��2:u?��d�%	��2)a��Tʬd|��0��`U6+`����y	���~o��Q��+�����`�0�W	`7�2;���aV�!��/�?�)^�(/r����H�,�ZԖ��0��ڬދrw�BѱC��y�Kwl-k���Z�?f���M��Q]�+ C��;�{����d(d
�7�
͉��
)d�$׳��Ҙ�
��=P�Zg���ѹۚd�����#*7�i�z�Ord�ݴ������$y�b��u7-�j�p=+����c'�Ùq���!Ea�+�@&���2�vz
��(T�����E̷�B�׏^�=ڸ��]S�iV�`i6����e��2p�4o���G�S�|��~�U��zۀ��,K�z`@��X�>s&̧�9QH��k��������|��Hy%���܄��>��a,LK�/C�خ� Op��F���Yq��04&��NwT�Ӌ%�0*�@uT(bl��Uy GX:����pm�r�,u���}~�Y�(s��|�v��˳j��`/���q�YF8�p��u���N�8�X�N[�H{=
ӆ�D)#�������yz�+z�m���������d��K�n��9���L����罒����_�X��_�9�?�8�8lrؔV^Q
6NL1�-ֿ�7>�ǋ�UF�.�f0�3�-xT�l��c���y'2���df,s,�4�si?��S@	�>�G�TÜ��*��������؈��C��'_��ҹ,�� Q�d{�w
�Ua*����d��|���-Ҏmԡ�T]�9�l^@}k�Qn����^��~���UA�0������i9�D�0C�d4��U�C���PQ#7���8}�f/[yl��f���cm	�����J2���1Y����^o��/�P,�#�t���3H�2�L�k|Q�n�Lg��&_f���<�i��&�2Du�������WwW��""�(��CkZ_�Xo~�|�2�+|��$���#l<{9*�u�o��x�q�-�6��)�8qm������1���(�W�:fpkc�;�Z=�#�7���r�������'*�u�k������Ƴ�o|v&J�ي�q�c����-�-�m���K��������>j?͐uD=��jh3���f�����W���[VG#9y����)1b�Q�`��W���b�Iz����1��4�i��6e��|����&����{'pD�*�����<����8�����$��&�_M_�_&���'�D%Pf�9�RlB���Yd�
ȭ��;���D1}�0�P�-���~���;�Kφҏh��p��1�^0O�%f�p\�o_%/�\U/1�_��@�Q�)
�b�Xe��W./b��^�|D� �?8�ˏ��?MrA�(┛
�vDs)��2�w�p�V�	��n���(�Nǿ)�1�Q��izL@���@
{ِZ�\����5�\�D�H��F��V�nX�*��Y�.�c+X��f�b^:�+^�M��y�uj�Ct��,6*K�*�S(G����t9��a�xN"FS�c_)`��	H�OZ1oD%P�G^L4<a�e\��w�V��A�|V�e��)�����l9{���\��6�l�H3��=a���Yi
n�Ќ�^�}ٹK���/���챀^��0���������zĝ�౬�Ӄܩ�`6�<�]b��֙c�{��n���ђ�����J�V*0]�"�Y��*a�8m�&x����o��`��[b|�Q`�(Qg�E�

�D�H8���I����<�=D�x,��Ʀ��n���U!.�#������k������٬G�ې&��:���n�g�_; ��o�Y��/۩�h���@	^j�rQ�Z�� ��
��G�H�G@m$�E�#Q�O��('�L+K�e�,�+�,�G��[[!���a��fb�Jh�*'!-����fzQզ��EZ����}��-M�^N�摲)�)���b@K�$�	N?ri9���,-���7c���M(*G")&��l�I�!� :F?�	� Ǳ���t�Z��Ǹ"u^����G�ρ�s�Y����8��Nh� t
ܩ�Ѝ Y@a�.O�"�(��SC�
���������Y?���?��7���N��?|�/�p�W������Z�����X?$�!�3�`�C��a�
���������Y?���?��7���N��?|�/�p�W������z�~�C�b���t?���y~X��~(��?l�Ó~��g��������;~8������?\���~��C��@(��h?��!��~���������P�5~��'�����a���U?��w�p���s?|�+~������>?�e��>�8��?޻�|6$�P���l(ڸ��P>,kCњ�!O?���k6�6�ڰ~��޴a��a��U�_�a��d,����
q�[S�9I�
�+X���iHge��'C��A~#�k �S���4%�j)��e1Jj�J�0uѰ��5�7�y��	���K���v�z$1�痭�9��+���Ꮿ��<5㾱�������;��'^ڶ��g�v����s��z�����^x�v]���I)��oM�7¤2y�bD`��7��n<�|W_gH��Q$��eD�� /�'��a
�!mJjZ��)S3�e�
�8�n9�i@�.n�u�o
6 )�����U��T��hVʔ���ɩS�M��6%#e*��d9��Kӵ�i)S&��M��2-uJ.]���S��S���}o������������ɿ���S����)S�w�����������z���{�ȟ&f���u�V�������5E*|�a��p�;�
UoX�x��"������ש6o\=;~˓�&�U[�	�Wl,R�nY�*���߲%[JPMPm\STT�J���8i-^���\�f=P�iӖL�\�*U����LN�
6�b�7�ڴyC�,��u�׭\-������
����N�ۥSVLI����U���)�j��olX�۩k&��Տ���K6�۔<���I�#��'?�RC}�z��{��$.y��{K6�e��cg�z~�9�����a�2U�]d�R
6��ԓ j�H��^��j�]�>�ycъ���
��o�l.�-!�][�fM�Ƣ��
q�����uEE���M��a.�N����[6n*ZU�N֮�S&k��Ƣ"_?~T��[Ts�$�� �$�u~p�{�֧&
V���8���kH�L�W<�('o֤�7V�&y��5r�P�`���;U�Ǩ�K�LVJ�3����*ڰa����Y�n�&X�t���.�JȻm2n ��S���T
d����hCq�0%r�!��e-���� ������a����7JLT�T�k'LZ2��nډ����@�_�;��?b�w�j�o_�i����4mZ��i���j�}����/u���p������i�Sa��~~����?X�ɡ�_l�o��?E��+�y������������eYy9l�<����;�}i�?�2�N�@#�8�Eb��[ܩw��"y�Y:ԏ�]����{����31�L�'�I�>�ăۉ���=��}�N�O�Ͽ�|����üY��K/�u����~6uw;�ߎ��cg�}戻σä����w��^��m��_����[9�a����k�
���7���c���5���`��� ׃ӻ���/������A9���x��Ik
����\�\�1%yJ�č�'�ѥ��Ԝ���J�;�1��0���⇏�}'��r�u����[�m� �_gP/�o\��!��	�r�8�����k�3>�5l��m�c�_�/�g�B����!��_�������K~�~�/���B��_�����������W��\ w���MA%�"�Xj�����+.(^��{Y�M��alڴ�_�i
�Ń�n��X�gd���Uv�� �.Ѽd!Q���
 $�D"8V���r���ǉR��HW��$0�?I�RM�U���D\g��o��>�e�x��~�˽��m�܏!�K_�_�
a3�L���r��ы��^�>,��0�Q�|�����/�@K���|5�V.�7����g�q(s=&�G?�ܡ�o����ɢ���__����c��7ݵf���}�:�߉��' S±�'P�[��`�c��Eu��?7@����|������.~$���
6w���Y�����G���:z�����Gy�Gy�����fb��YӤ=Q|�/�B=���+���Ƕ�_��f����v���e�3|��X3��?Ğ��x�����^�f.S�'����������H�!���Nϳ�?���}���J�_S�w�����Ч��ί\��t�_�>���__�cG�~m�"��;yx�p���xx��gx�<���M����k�W�w���}	�+����������e�hk$����9����N���'n�־s;^�v�k��m��~m��Y�ߎϷ������o���_`�o;�о���i�:njh��FG�Ѳװ�M�|b�opܬЖX����R��6'|�5?���yɎ/w�{�v�Wh��Q~�F��p?��e_H�F�Qyi�x�����c
�N˨�#�>��Z��Y��M_���.������{~����o�E?�qK��:lFwJ�*���+Q�7�]B��R����O������.�!��~�׏�T���|([�v`����9�ӯ�#^��vr>��F9~��y_·���>wbz�x,��y��3��
�+ƃ�!�C���Y`ƲC�ka�&` �笕|m#�?��5��[�����͎US�?�)�U��;��TvP���.���|���YV��Cg���\�O�g}��>�
}��u��_<�g5�ͪx�����A��.��0�V��+�Q��/���#����Nr����"<�?Q��x�.������:�G��=M��ժ��W���O+����)�U����7���Y�?��ϧ"|s��/*���L�R�_Џ��b}-�E�����C5\m���%��=�[�o)��s���f.���P�
{��.��}��U�����*�}@y�%�\����)n����W�'���gf)��g�o=�D���Z�����/��y�cJzu>n����D�5.�:T���㊻�?{��G��;L�������o�K~}��9�G_m�����X�Z�����m�mZ��x���R����w��љW��v��������m��
�\O*M������c��9��������,z�6rT�wt�
:2���V&����/^��A׵*�̨�J��*�ff6w���P"���O�F�`��aM=�wiɋ#`��	pv*L��9�(d
J�ow�FJ�X��$�I�3.|�.���P§%�7H��.|��R��J|�H���%�K
.�]���k���
��_���b��o�1}���������(��zX���w��w����9���%|���$�F	?%��%�E�r�EJ�,ῐ�ϓ��+$|�ߙ��~g�!���8�d�ߙ�N�s���{¥ܧ�r����.�����.��Q�o���¿!�\�ր���[��+�������������s�y�����,�.��R��K���e���pn�U��G\�����"�s	���K�5	��q�'Xc/W���k�ۑH󌼏�S�ź䀂�u�1�3
.��3�TQ�&f�$�	�%az�l�`