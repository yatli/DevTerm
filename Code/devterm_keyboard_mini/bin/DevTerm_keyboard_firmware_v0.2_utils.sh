#!/bin/sh
# This script was generated using Makeself 2.4.3
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="3050765543"
MD5="16121555674f4ac858ef08e0e0eac68b"
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
filesizes="104844"
totalsize="104844"
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
	echo Date of packaging: Fri Dec 17 20:22:12 CST 2021
	echo Built with Makeself version 2.4.3
	echo Build command was: "/usr/local/bin/makeself.sh \\
    \"stm32duino_bootloader_upload\" \\
    \"DevTerm_keyboard_firmware_v0.2_utils.sh\" \\
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
� ���a�]}w�F��_�SlEn��Ȗd[~		�Z�\
^n�9�ZZ�*�d�R��g�3�+�q�����li_fggv~3;���a�՟��D*k�f��v껏�m����{{�{�������M�>���Ný�4�f�i;�ݸ���
�����S�	�y�r�� )���xͩ>�d������p��gɕY2Y����=�����`�hg6��E�>�X(�~$(�V6�hT�$h�<�@f�0j�˒#K�,��x�m���h�К�T
fYX*���FU�0�LȌY6k�d?���ɇk��̵��c�g�S�W�4|�jp~��5��gi��E���M��]�[�����_�����;ީ�_���J�]�?XI��i�L4k���Lz��a>q�Im��L��'4��x�F\�0ŋ��L� M��΃��U��Kᅹ�!V��^���D�t���>{cX�``��0�6���<�Kp��K#���y��@p|>�Hy�����j�
@!mu�I*p3S ��0�=��mby�~�{~p������ݻ��9��$��bV�����[;��[k���}�>�n@sC �Y�$3_�A�&��d?2ᏀU���=6Bi������dA>�B'�4�$��`�i�m��{��^"��;6*L&i������bD�U�_�ʫ[�]�D��B����{OG���1��oj�?��r��᳎��c_�2���P����z��� �ku���s��OQ��V��]�����k/��(��]��eJp"��0r	�>KC?ۢ�G<�RH�k��n��x"bw��[�ƙ�h ע�׋ď�E*�tH����o(\����D���',���&F`�#�u � ���\�,:�p���"�e��S bY4e�5��`��b'R�I`�He� ����#&���$/Pc �*

{��M��g�0�զ�0<1�ZcOx6|2 "F���`��d�0I���]*"��L�n�=a�xx^�.�t��n<�6�
�cn�D��l�`����U�}<e�k��l
�%E�(f�0 �Ϛ`��8_ ����4[�.�
=sPB��,�~F~�z�%��-��EZQ
�3��,Oc�D�㡀F�b �*�G�9�l�
Rsrl���F��#m���l�rK��s�9�B��}SS�K� ;�{S;�(�0h\���6R�؟��ұ�`�� �D?�=�Q�ra�"��bQ8V26�VK|LˍfHMkzz+����f���{��J�Z��Mp�NH<��T4�=ŉMz�)豗&���c�����nj�ѽBW~�H�xKQs:Ib��$�C��<bk�-v���c��º�(��P�	L̍�9��s�;�U����0>�QX��޼�st�� �rq�1��?Է�D�!��`�v��&�X	����^������
��]��i���2&+j?yrF�'O��qAGof����N�
Lxa�[�1P]i�A��Y-jϞ߻��)3�r�zR�)�ff1��
�#3�� #�f�������6�J.�E����Bk���-�[&��O��;�mf#cA�?aHytħrў�U/�u�/���]&T_��3�V+�X�Φ&D|�� ��
��,�����F�h�A����� �)�Wa<��118#�Ԁ7v���A�#�+f׬��4MJ�)�Ǝ�-�yl����łԝw���ĉ �N�� qd��R���M�%E�����M����7�*?�f�o�a�����.���r��������y6�F���}o�)�~�����[���������� d����D�8y��7"ނF�|�W,C�y�QB�������L=��H�+�I��|y��
k��V�����6�x_�����_�����{-�T�7��[��o����
9�
+2���j�2�'�̪�ܳ&3��/������2������c���rK��=�����s�����N�{���_7��Oy�q2K��s���c�3 �q�@�F	)�f^3��e;�@��<����c@��Q�C�2��"���r0� �Bi�z,�K\O����I�?����ƈQ�������7�A�)6{6Mrb�c;���ݽ=�ڍ<�~ȁ�z�/�T	�p釡�\�YV?I"pj'�m`�O��*]H � ���":�Ώ.%���l�3�L*�
fO��~���*��0$u��ң�
l��G�-ХK
���6�Dg�0K�r�T�?�RL�@�K����	&(�#��E ��)0��$6� 8R�P�	���gj"GM�
���#����ZE���bl
X�%��z�oW�Gv�3�ߠ�g�X>p������1��Nh�݅%h�+u^��P�	�1�A�|�\���Kt�����ND��a��Ng���	���xeB�6���'�n�P;Ȇ�˷�'M�)�B�tt!yA��K�r���3��p��۷�5�9�ي�#���(�i#���d��ğHM�l�b�g���c�Tm��U�A0�D�l�g�kY%���_�&�sp��M���~��_�;]����G�ﳵ�����o����.�?��+r�2u��3����ϋ���ڱ"(<���q�{{OOV0�k0��!�3�~���9��$���t����8���F�����tJ��=�����s��e7���i9���Z�Q���-�~������r�`l�st�2��*���]<և ��>I9놢@�&A���S�!NT;t>aN�ހ��Q@�hW�<��$P��x�r,`�G��fY���&z4����a�*$1��\�����.��5�F�������gŕ���a�!��XŻ�Gj�{�:Ί'���͂�RSB�?�@1	)��Q�����
cQ�0�q�S<{��]�n���N�b�S|�#��M�zSH��ϋZ��$�D��*~���cL�_��N�n�=�S���'&[���
�q�G�6 �)��Z�<���kƟM{��ďa 1h؉�H`l�L�=�_�$t:	�ų�x3���^��d��^#�Cx�3*j+��>ot�~� F��S��o����1t�U�Q,w{�<����^P�%��
�-u��l
QR�C5�jAqq(�l�@���K�s;��\@�yD�hF���Qo��~�`�@��6�j`�c�������n"Fu�6>
�����PW9�	�KY�ȗ(Ǝ�,�~�2�|
�sf�x]����B�x�d�fo��gT�VT�k���˅�Nk�/�ݬ�9���7亞��B��õj�$� +ɩ$�(&�r�	+<U푡���h�p��(��h���ht�'���!����Z��_m��cI���*JP�K�*��υ��,V�����������1���o��_�V�[�W?m0�����k{�9x�S��If�������s^�+t��F�?{O�T�uAD�A@�e����y�%/IY�-em)� KyI^J�MJJ)��
ʢ� �XTvt�Q�g�Ep?�E��u�����%ݤS�I�/$$��{�y�{��#�1�!�*���$� NO �rx~1as3H��l����L��*<����]�)I�����#��/�D�SG�,��]���ZF��HI���WZX�i�(i���2Z�O�	���q� �L���K*	�>�?�zN ^&щ>��8��usw�~�z��!�+�)�Q��L?����B��X���CF�e�P�����2�Ǳ��L�FK@��?���0nH�:
�M�j�lg�(�E����� ���^�	)��M�M$<��"�Q�9X^ ���=�fj�!E~Yr�Ku����|V�A�h_y��)�6�y����E��jy%���a��ԺX
��j~FT��ݔ!�h��H�N`l��`h�p��)����A�CY14
���2�]&6���Bݹ�0.e�L�1L�S&���pP��͂����{��j_�X�3h�F�� 䀫�:����_]��M�� BD�AI�Y���Y���~+��A�&"D&��Z�;0�k!����-�B����z����{�:��FI�p��l���q����!��j�����f�7~����c�����������z!�G�x��!��(4l�@���]�얄�t/���
+��~JI	ø+��@-+Yr�I&*(�qԣ�ԈQur`w�ڀc�B�"��!�FT���a�C�FDܤ�3�0�eW�R��%`)�a)��V%���!t�lA(�$EH��$DyE$�rf\+�X�E�sUbvuRcUrl���~�*1�*y�"Tȥ]�B���&�!�+�h4�u>*r�/�ǩQ��������6U�yq�Z�_�l=�����e�cp�zQ�LC����%����H?6�bw�%LQ�c�*��4�L�o���45���rBf���fh"�ɼB;��<��8⃡�,p�3$tp>-"�9�.��j�@Ö���&���=�8�w�����5�LF�h��,g���M��匬�5-�l�L��b����
ޑ����g{|?Z�4�X�����03�U�8U�M+���������=�q�p�I�Զ�%?]���W������N��v�h8��N�cE�c�`������;��+R��j�W�hޞn��&�w�9�
��_�J�!�ϓ6��|_����9�=�Vd+��ʦ�0�G�&{�^3�����<��_���m?ߖdy�4�궱7/����ϊ	�#�s��ʜ	�o�3��מ������"����?X�����.��Rq�;{�,�hB7�d/��X��nJ;�,�
4y�K��:߼�o׍YZA�&��<���[��?������7}yO�ڹC�9�)�GL���R����$�0H�.2�oo�Y~�qR6�[9�vԺ��G]ܟ��wk��s����GBJ�8@�أ`�/�u˖��w2�����O}(����_��ԠiGf��rf[�K	��.7 �ʊ�J�v��s����� ��������#~��B�2�p��Otg����5�w5��/�.�?���U*BF�)@��֯x]~�p>�f$����.�7d�ur������G�:�eN�$�.�K�b2��|n�v�-�;�ۢ�Hx�o��ګ�W]w}c*��{NAN����Eqr��~����;�K��
HFp����4�S�����@@��2�2�=L�N���d,��}K�)�.\�
�?����3�A��ɉ,�A��}F6�i�'��Z)���zKb�B�Ħ�����<��o���r&�ɪ�l1�V��YK
��X�aD��t	N�a��$p��y��a�LN'����#d��x�v��2ɀV�~� X����2Z�FZہIw�R�����ޣ�����y�N.ɾI�K!�(t�Ns���n��iIwi����bmF�b;/��^̒��X���D��E��
*�!&�L���U�H��e6[�6'���au8�N��w�\� I�h�k&�)TX����G�1w�W(�� �����O����&.n������4jh�o �^��io��o���������_�����6uܦ�����]��@{��]��4�F������lL�������������i	g1����?+ �_0������e�j�����%�B���-���W��/���A
��������$�.�͎����y␢1���~��?2�Y8�X��;�����Y�����+S�/U���s�Ѣ��?�k����1e���΍��Ɣ1�[�3�ӻ�/�`oV��e�����WTm;�����>e6���������
���p6�q�+�{f���gq?��@�jt��:��,To�\�h+�	�9�����E1���'��N��Χ��vzsPVs�?6(���:��LE7٤s�@c����y��P����g
ȑ���U�g�TgmG�wM�$B+z�[2�F�\�H�̊_���Y�,d��ɰ>�I��Wy��Ӧ�ڱ@]���3Y��ċ��x���~�Q��a�h(uk��;k݆79��:%q���l����:����Α�����
�v�7��&{|��J�YeT��ե$����x��R�jM�Ln�
�B���k����p}�j�v�7w��:�!�A�gA���R.�V����&
K�eG�k�
}=�� }��~	��BMOq��dy����H�i��j��e��r$��(I����,��ug���������3����Ϙ�A� ����A@,� �� �?]� �G������4�F���鿏G�0��i�ω'��~E��ֵ�d�Ч�Ŵ2.�LC-��'�d�ψy�*��صtw��o�d�U0Μ1m�Ʀ|��8]��g~����^!��<P�U���Yn�$������1��l��B���d*@(T"�	8�
 	�(h4��&�/B���������������t�?��"�����o�?Wڿ]�a ��?�a���'���P�� ,��9 hP���r�"���jv-#��m~
�r���V`SM\���N��7#rlLC#V��0��_��0}ќ�%�o��K�8K � D!AT,�Є9�?��5��b��������	��X��ǁX���	N��o��\�������������O[��ϋ����r�(w�]8�G�W��SJ�x,ī9����PU q����\]����7�;������=�	=�#���Ւ2X�,}��m\p��to{��Soxm���+J�w������[��QB�"/
�Ó�%��4t8�a�ө��]$�L��pOH�՟�.WUe�;����t���΢���p��8RaFpD* �
�$ A�s���0N����� ������(��p]��<��_4�@h�|y��kl���ϕ�o����?H������4�����i���P�̩6��v�K�[��I^P�11
W��`�1.~Z�}�Y�u��Pfv�؍����0;\�T͛�rk�]q�6ٻ���tq���ͦ�%�~�6�>�0�+�y�n��q��g�QW�P�h�ib�Z���#ս&�*����h�F�Fc��`~�b�'�ǲ�Ǽ$�Ji���e��n&��K4Ē!��-�9���;��ѪCaO�'<�e��!��U����龏�k;֓c�6N5�^I3l�qS�s�9�)�#�L�w~\�1�Y��n�$*�
� ��Š�0	c�T
]	(
��n�����0��������m<��|��� 8@@�����ok��c�?Wڿ]�=�4����'��]\���W�t33-�b.d@����l���@�@D� R�bpx
���@"��#��ع��g��O���������_0?�����?��ȟ������֏��\i�v�G>���=�����������.���7:(x_`(���Fx������F�WNF��&��U������}��O���d]���H:k^�\3���!�-���uOǛ������	��e�ɇ"���D]�r�-_(�Gu�ƅͪ�e��Z�ԺcѸ7ײ���C��\|q�?hA?$����6�Oŀ$��",D%��x
��P�h�:��,�J������3������y��Y>}���X�
�y�O���C������3�߮����L��hF�׼� �������ݠ�	�{5C՝�l����
Ҝed�hΒ,z42�
�G��Ny�\�I��t�~��I;��rC�R�G{�8LeUL�׳=�c'�ğ��*�bo�j��:꘰T��D�K@p躓�KT�� ����ޡ�C5�v�ZRD)���=wՕ�#w%���>��:3�U	)ő�aG=4O�LtX[�yɲ�/0�kw���Ŭ;��q�!�|�Y9��o��TT���]q��6��N�#x"�(�yŤ������Z®!Gs�YZ����	�C��0����,�T��by%��Ye���Γ;ia!������G�ëk�M�
�.��1�<��l� W�!����4��d��F�#q�N?>t���@MV|Q��������V��IB�Gp�`Í���g,������DxEdٞ������t͍o}�LcB23(�K�]���� �0mK�9�F�}>�M�@���"�X�/���ԋSK�l���dD:������߿�	�s��>?�����`���]���LM � 
g�Pa���{�����[���j����b܋g�i�I�!)��a�n�֧ե�~����.
ǍG��:��ė���D����ޅ�]����.��D�)#�AAM/ˆz��]%�W�NUk-O�&��0�֖��!]#��9f��t�YW�l����A��MT����خ�Gw����/:i[���L>#rs���7��Ή����|���5����z-\\�g_���kCp���
�e���l�������o����08���: ��`�X(����0d �����@V����?���E|��@|������p��P���oY��ߓ�������P�b���Y���Ƿ�K�nB�y�f=Բ��=��~|~���R�6no_�$4���p�+��$Ⱦ�C�!<[���>h��*�����/��;��}���gZx����Ew�����S:���e���_�W�$Ol�)s����׭���]��y<�~:��俕�o�����8 �#�(�  ���C�p ����9�?���g��������`���"� k��/���������a����������������>$��R_�,�%�'O�n;�1E.X��#�Yx1T���P�o*޽3���/�?�[�?�ذ�@������ @�� ��ƧX̏��� ��_?����?6�?�������Gi�~���c�a������?f���������om���������x<~f��0���V�w�M>	>�N��`4(���!�ʯ�LdZ"5$4����y?Xo{���4��|�Q�ʂ�]���=�M+��X��H���?�b�@<�����08�E�H<	�n���M�������%��F �������/�����������_�?����S�� 7���ק��?�bt��J�~vLFR��~p,@<�L�
�
ě����,���#j��\=T$�FSn�Q*!`$��+[+*'��DN���]OB���B��Z�?�f71����eh��=yG��wr���O����D���(T%�r���� d[q��ӝy�!XP��
��$C�F;�g/�-a�y}��!|���F�+�t�;�/=�����Yeg	v/��I���Ug}���˼^��t�����䀃��5"`�*�L���*	8f�7k���iʖp��Z'^wl
�����M��
�S�=;3���%=B�Y#$�7%��J�!�����g%��}X��<�yI��4\L"���k������[/��3&��,cKn菪��z�]>�ِs��뷛	QG�h�"˞9'�d��V5r�N���gK5��3μ�!��e�w*?���<��@VUN�Mڇ��ktu*4�'3\m�v$>;�?=�B�x���-ğ�i�V���-ȶ�,����'؈�nA���7ڳM��#~�W�C�)rdu$f��p�v���y�sʹf����G�
���Hͤ���@��������G>���z#�d
}�oȡ���4P�Ru���T_o�^���F���>$tl�|R�,�"GoC?^�V�6�sѩP�M޿�Ƙ_�+��y)TY�\W�~%�4�V5X��d��H��ۛ�;�BZ�"K�׬�:]�^�k/a���_���ɮ'U$�4uG���|���-�����vȥ$����\�B Fq�$&�0����:\jBoY�'�h����+���~#�ѡyj��z��&
*"^�����p�#
,Y:���hj+�.�߉�>�~;򐱡#c�0�j��o ��9�[OS��^~᪏���ׂ���hJW�ɂ�1gM��oKUtr\�S�ҡہV����9ʱ��+��4}?��h!�G�u�3�%�C�*�V�D��fQ�5�Ck����Gy^�@��#��oa��w�F�x��{�b9Q
1�N��I���#�E�um���7IC�<�I�����h-��,&�$(B-{���[��:�`ַ�p2%Ut�JHz��.�gM��S��[��lj[!�������u����Sޙ�e��U �|Nު�*fh7$�:���
�l{�,�U���y��)�!�aفy9}�h&Z����;��WnQa;��ܭ����qO�A�tr�{�j�f�@S����ސ HmU��a�����ee^�F�#�h^D�[@Po�:�H�;���c���uC��)�J��Ƿc$S��Ŧ�'rK���n�������g�5��mVo����We�m&��1X�D��Y�{�<r��G�S��4�&O�
r�Od�\�M�)����<GmEQd�I��!'�X�óy��|��<�&fS8zw�#k�k�b7P�+j6��=�HB���कCwgi��{k5�0�J�훋Rf���S����� u�uڀezؤ��}[�ck��	�
�H� Y�.�,&?\�v�J��܉ͽb�PË9�g�z��h��x���[���NYC�ɮ�̐��A,��S`7����2C=����:�������`�
p`O<Β��Mwn�Hb�?�s�ގ�I�P�j~�3J�:s�*|��s���Yմ'2��M���;�{��Pg�6����ZsP[�����"wt>���
�[S��֛��?�d��=��#J�5y�fR[{���/���P�t�*�)�Տ����ӧ/�ΟΝ��˺u�����pJH���K�)���iJ{}�_�A�jS�@GD�
,E��������&Oz�=�V��BH��`w�U�������jb��8ҥHG@�(�!���A�� ""���BB
��&")A)* HS)�P� H＞{߹s�=�q����������<��3;��>�o����)���dvo��@���K�>��s�p�A%ۼ�)����A��73}PC��̍!%� ߣ6��3�l����+�O�'���Y�
t�T5����E^
�����f�wOD	�Q?u�ib�B%�aShH�j��R��Hu��F�e�k�Y	j|h�N0O�ڦ���(��4B�5��׊y�z�A�k���H��I��N�[��O���ei�
��&�r`i#�=AƳJ���h�R��xz�j]�3�
� a�
[1�mR3Q8X}��}�+_��� �w�L�u�#q��?�yq~������Z�n��W���;��vHG�c�8P�_���
(� ��TB� `{������-ho��������_���������A��@>L��[�������@��~�?��������7 ֈ:�l$�ċ7���j��q��Ŝ�/g�Ovil��/8�,�/�o_NfͿ����!�}2�Ǜ+F���tn��8{�\�?}Gx�WkTd�
`(��_����x�����c�#P��/@�"�?�=��Y���������������"��a��ș|�ة:\P�
���Փ��lĥ]���4rs�ೝ�Zp٭'�v��sh�ź=��!N������E�@啐
 ;;��� �W���(
�E~�������?+���_��?�����N ����,����y�/���+��p����
¸�H%�x�����r�~����~��eK�)?@���2z������i�:J�f$*v�ؿ������� `��= �9 
 ��������<
$�� �����?�?������  Ey��C�����,�U��_R�������/��D��V_Vj�wd���-����D�e�8
�<΅���&_Բd�f燷ǣ|ڧ�l�|v2�1�mo�=T����d�,�`�����\��J�Z�@�Xrbw:�q��l�AO���}Z��3)�� �	�?�T�I�^n�5�:�Lb�6"���k	~�qXj���,æ��1�!��\�aָ#5�.5�5:�@�h7�<r�h��{�~��|�0ӝ{���r����D&5nA�iU�h�f�O:gqѳlV�Xs�m�3l��T�zv
y"���Hhr[����]�P�¨�&��%]U^���p�d
�i�\WU"K��������D����
Xm��ǔ�b�'���t7A �qռ;��%�KJd}�;f.YH���rU��:�vH����D��:��)�W�>���qλV6���RTN�p��b�a|p�lS�:"@�U{J�#jdz��U��z]������)hՍFn����b�(�`�:���Z*7����枓���ud^�"`��d�ˠ���}�8�q%��d6h���z��:�=K���oB̗V��'�����}�������	FP�v{���V�i|L\�Y�g}IY����oS�g�1����:_?C�������|�ق׽��^�7��R]�Z|�7\�k��0K�(�G�*��t$ PX�3����s�/���%�\^͹��)�~��%{my��	�U�?F���Zl�U�X�,P���a�7s��ח2��c�F^��2�w���^KW,�װ۪�j!��n�E5�Kj��^"d��\�f��u4�!ƺqK��a +D�s��O~W��Q�bc,h�rv��]8��g���+�l�E"���^�5K�y�6�Y����W*��H��r�SK}��.7
f�?Ǐw��ٰ�a�$�,$��Ыĵ�����g�A�mL���hM	�Ȫ}ҕ�'�Wmn��:��� :BJM�3{t�bp-ͭ���tǇ4�Ƣ����.��D�ڦ�HG�ֶ�#M�2NޗJ�>M=gl�3S���,	�y�|������Q��[������oyS=���"&�0u=W�I�a
�Z=Vx%���e�shq3�u2�U䧝��_`ɱ�7R������p�Nʉ+���)��K��f�#�U��s��xN~�E*��O���f<U=f� ����Mǖ������s�����e�2ODI�h���U��B������kw�L�:Co���^Cwp��dF��DJẀ8E����l�큽d��8����6�*��286�i�b��b�Բ�3:J��F�$po�R�"��
�ԼJ�Jw��o�B�
����3�Ќ����B^±�qY��Ŀ������%�����7�
ܣD\A���ˮJE��іǮ���'�#SvE��	��<'�łt�a�,"�X:�6�zg��%TL�{6�����a��<��Җǟ����ط�y�%���[q����L�M(U��Xuj̝� P!��I�*o�D7kGe�.��Z�<0�]jO�6/�e�?<���b�� �����{�\)`5'���S��b���#�=~q��5�y�����L��}�uܥ	ǩ<I��w:%��)�LM9�N�w1{�g|�̀�#�6Nٙϧ�¥�˜�r���E�I�g�#��I'�t�tl�]Ǻmy��P��Ayܵ%�;j��儲���������s	�l��óe�
�b�]��kZ�[橗v�hί%��oA��m�=3����Ϡ�)�� ��Ly���?��l�'�L����3�
��xi�~��^0�K��5_�n����w���.�Ӏ:��`+����A�r!�
�
!q��
�xC�Ƹ�N�}��g�����$h1+�v8eX&[�_�,�gmn��V�LvV��8=}��W�����2ꊒ߄��沈�E�e�sL;�C[١ú>t4�F��~c�&�]3��B�±N�S��J��M�N�*h�J��2�
!ڻv�_Y�j߫�0
�����������/��������
�������Ӵ������@8|]����
�SG:������J�=�z�ȡ�
�m�<JMD)�/c�VO�?��I>��=*�1`���*���Żl���R+�L�;�\�p�g��?+����X�P4�1a���\��������(�en���w!,@H �CB�x��������X���%�o�����C~����8�G��`(
����]'������g���tB������u��%�?y��^磳r��i�m<��=�������R�qo:�y�N��TЅM"�~���.n�1����~��o�N���Zu$���R���H�J��	M,��0��|8w�{��Co��v$� vQ��1���جȘ��N�Zʴ]Ed]~�y_��8�oz�������������$9w��:A��m��M���+fn�8S���e�(����n�i38���V�t[�ٙ�4k��w#&��.��ُ�FI��f�%%�N���Z�O�e���ךJ�=Y=��a[}޾�	a�+thMTk��j����İ
�¹��A�,��{�w�� �#��ԁ��N&�VP�q��C
_�R�5^,ţ5QE�Ď�Cd#���V���G��^�`ɰJ�ca~�@k�H���G׍fǁ]t� MM��Bm�|�I4rzE�{)CAf��<�q�����6�I���F���"�N�a9�|�k	s�V��7�[�N�0�o�Po	�"��}�M�l1��5��LMo�����J����ܺ�o/!B~D���=����͕~��ː�i5Qn��{B0�@�XF����d�YT�/ӿ[k�6���bbx>ͼe�/W�*��lr�����>;�\p��W<�� ��W���E�b��W
�3 �|P}���1,�M�����V+|�ۏQ��Ś��}�g����Kf�sB�E�a�<''V�s������2�G�[�5#��:-p��r5S����z$#��T���@�]�[�z��7�O]q�)������p�M�ݯ��p�GW8��I��t��S�"-�;��eۯ��s�dP2<��:u�dQ�j�uM ��8V�_s��j7�=�#�i8,R�J9������W׫������:���c4�G#mF &��B�M��|Z������J�貑�\~Z&���}ϗ�LyVX��-�5sE~%���H�)�����WX3$�}��}Ǘ޼�Y%�ઐ�`������a�2Tl��j�O\e�כ�-��!�y�)�=͓�\�j����ԓ������}��Q���<쐤Z����qe��W=�{�X2�wl�h=���#6� ���D�Sh�q�ͤV9��b:� @�
�i��ۘOۑ�nS�ќէc�:���%�\�}]^nZCמyA~��1]��� 	gV��ȹܩ�� �ݯ$������5����}E�b����qmY.�'�$�v��C��]Ń���[���}|��PV���ܰ	��1�!;�),ϓ�|����г���n��u绒W�J�g ���^��b�\�I�"�؜e�K�V��p�����3�=�]�N��\�r�N)��D��LI�j��Ld�|���k�lx?�mi�����Ab�E�l�ᛥ�٥�遏��/E��Yc|5�z�cb��T'r%�qzm��4$����
��6B7%{�!�y�w�rVۨڙ�������h�����NStI��9�(�3b/K����rf�C�ťbyi_��"]�����bqP��)0W�����f�<��a�-��۝km���_��Ӱ�H⍢̥�6>�eP�a���iG<k���=θ���� �6��3�7�6�-���G��y�o�S������u�>>(TU/мg�;(��(��Л�I�}�A��o>�|'�L��Y�9�-$J���}����W����#c]ؗ��܁-������#^$��s@Li�)_K�TS�u���W�Yb�;Hx�q�~qn�fWu;H�*5��:�Уckg;L��_4"��p�����[�2���`a�ϙ�u�����
Vm.���:��^�J��HP�����r�����4�f�>�s���˯�3]�j�h
�UJ ���5���}����T��}@���E��R��3A�o�nZ'�/�h�kː�i�oc���S�b�O7�MTX&D��
i���Ћ�g�8��6fy*=4�JE���&�}��KX�V�6"���U��ic��������&	{�2�p��]������W_
\:f�v1��œ�k�tmu�ޚe|:>OU����r�5�y+-�U$D�}��y���6�d�H��ي/�[%���Ȋ�VS�,77�^� ��/
�=��ؘ�k�ޠEI�*��G�J�}�j�t�Џ$]{jsg��+�pv��6~����r���g�x��SaW�����*�´��#�Ձ%��C��f$��_�9d~+[�T��N�&�$bU��m֝��9�X��Ь�u�W��A�b]��2iw��~r$lѷs�܌�z�OPHbn8�_E8��,�����Q��q���� E��M��]A������%�&z�<�ᒣɸ�[�~Fiv`��K;o��KA7�ŭ�z�7�W�ٟqr�q[��D8t��]�I�z보ʀh+8DoVJ9+9ޱ�el���{����1�a9�譓�Ɔu�u��UF��V1~́����H��2Bq����o�U�4�$Hyj���$�N�ɪ1XP��:�Gқ^{��[
+����&�r��.��W[L<�c�vo6�u
����!*p(LE+��
���������z��7��aЃ���F����1�Q���G��Wi����þ�?Q>���=����������Cv��9��c���^����9*)�T�a`�*��A��ʘ�'T���;��C�*0��C�����3��)�(�a��J�����.�v������[�?�����y�+������z�����o����	|<N���W�s^��v����nl�5�|����p,�-�c�i|��n�ر�2�����m�	;�A+oFz�n���s����z�S��SӘ5��E������ؕ��sZf��\gs��0���9_e�5W���LYc�9�BTB����)�PaJ#���RΥ�gy��i�i����'��.X���l��Cs('[R�NG�u<�L�i1ƣe�2� �Xa�O?������{�D����!(%G��g����F	��� qRB���(�����������U`��������_���������A��������,��k���L�҂��wH՟�p~�uL�5��9�x�ާ	�n��n��9��:(zL*����Ѡ�V�<Js�͹ߖ�t�vfX�
o��G����yC�h��[�
��t�Zn�	��0�EJx�"�R�<�zZ3LR�,�J+���S�O�FM,StO�|ܝk	�����Ek�K�Ζ��s@	�wRR�K�cma����1�ie�����P�
�c!#ͨS�Hk��뫍?�=�
ڧ5O'�������������,d���+�iN�!��7�G��'�;J�������j���2�ƺ�H�(����D��"��%(_U%r�S%޺�%����1g��Iݿ��Q��L,�� P��T󦖫2O��j�O�r����@�+��;�
����x�_�S�o6��6b��H�x��ƕ5����
*"qr�N�ا3���f
��)�"��R��O"նAe�>�z�0噍�
�X�O|�
�
�����p9��J\b[b�Ft�es�g%���1��Ϥ�LF�w���m#�M�|�̀�ـ��C��q�p��H.�����
˧N��Lm2�%��.���_**M�����,�%fU��|���:&�Yn�;�E��cű�c)�ˀ���Z��oYj��&U*�)}�C|A���ݐȷ�+<_����z)A��S�̤�LoT��b�ݩN-�yi���6�16rv�
�V�ױ
�6O_�&T�<I+����Vޜ���*f�����mÜ�$���Ӣ��~9^@�����p0�_n��0��\Hu���S�kn�Y mz~��!�:J*�����)�y�[��Y�s/������ɬ�)�]q�Fz`Ōq<�wbZ,6���)fg6��,g��sQ�"ϵ�k��Dq�{oWe��
* "�ݝ��!)��-�!����m���9�9�y����w���Yk��Zk���U��͑Lzy[=�[�{�����uXkr@��������	��H���؍7�@�/ ���[������ô��'M�NX�܅��&������G��Z����j?fc�5��k�0la*�2�lQ�ū��I�}��yir����pX���A�m���H�*�ćX-:��@+�/�s�\
U�k�)��A�h���HO֊G��>��*�ߊ�E0j�]�6���~t�G�!���A��My��V��2���E�>� U��;�:��]+�\����MV�V@flV�ONcz���5+]����I�E� �S�b�#��Il2���vl���_ʳ{r-�"M����rkU��[N�_�Mf����%�����ѻ�·}��s��dk�*%J]�f�OY��3t�[Ӓ;��X�N��ɭD���� �ЋNM�����y�LA7�ص�Z�.k�M�X�z���<A��U�?Ϛ�w��������@-�M�#0x�#1ȠE�C0���UE�,�.ڊ׳Q$��刑�&���+n!X�[KO�ϠJ�L�4��)/e��F�_��zM,��g���QNΊ����Y�`jg{�X~�魺I������]���<�3oӽln��d�1"A~�" ��]!����T��.�����?a@h� �J�j�сJGu��g%�Y^^��\RhC�>~�㷱T�>��%���mY��9&�&c.'�A���M}�5��}�R;-4��â�!8��BM�V�!�\I��}=���;��c������Tv�|�*}��3
R�c`�]�0ͱs�~G#�.�� �!�	����M�geћ5���q��.����X�Y��~��Q���mg�����)aC�|�܇�ù�V�� �E�(���-�Bdsq�4!�?����{$;g!{yU@����KX6ޔ���x��maMD��c��{Q��{AyL�8��۶5�?x[P�4I���X�)
}(��8���4	�����,c�����C��k�n5v���fx�g���L&��=i��!8�qy��#
�U!��{Jb���"�Y8Ǆ��E�Z��[�A��ԙ������EY��1��!p9��I��k_L,��180���'J�S�b]_o�mRAV֋�7�0�y��xi9)Xz��%xf7�W�ѭ�1"�Z��Ir��p��l��� lt@�Hi��1Y��@��4�R�A�����a��IE��M�^�{��'��)�@��;��1��W����Q��˫M�#�_�r�%a�[�W�
�|���KOГ&�bBy��U3
1I�W��T�J�G~Fs�,�f*�>��/e�R�|���ֺؑIqϢ�U��4i�fP������|!�\�]�ʇ��bt'����Pq����i��u��zC�$�X/Fƿ�� ]q>@f��DP��Ry��D�����������1e���gY�úB<*ot��g����)�uY�'���=G#��#~@f�\�5��T(U���������q{Tf��0�E�v;Բ���>��|콳a���sR�2��r��{_�������k �����(P(*
��R{���4[o�*�jG �S����7lb>C�k{�����Pl�����"J��h���1��naO�������A�i>�d�~��=/��3�Z����v��7����-/%�H�{�x�w'7�����~GS�)�t^�%e0�>����c =��h��ǐ��,�*�3{ew��o?�] .i1|����m'A.�W�2��
����9�	"N�f$z�����툆��+�Q:'�g�MzÓ�o9Z_#��ӣ�,S]
�rN�pқ��M�n.�ח��2)`+�"��WQ�M�q���8��1KV
��ޚ�y�B@0�񵌱p�Ocذ�@FfE�n�*���y:�&]�J4�ݩ�����#R��_�vq�WQ��v1�����E�*��
���lt� f��V��{?���ݬg�]`��	7c���i���0#ZeE�}�e�f.�=#<�k�y�Nq��QQ���2��cUe"�i���Ӕ=���8B���qC8$:�1)ZVQ���m��JX̴��TIh�i����ޢ4~��[�����)o�w�At�m6��qG[�y���E��S+Tzl�GĚ&�\�1��V]�9ݩJ'�:�G`�`.�kQ��+v��KΠ;���-SN7V�� ��t�/��v�@�i����PA� .�c��*�YQ��w��G>��h�'��s/�zT�-�;3H9���M �v
���}����'H�b���B�~4�\V5��B�[���g�~��7�X�K8�(� ,���;B ����ce,.�\ck+���c���og���ۏ8)�E���`肠�����K$\&���H|&SAE`8&CQ�����6���茒>A|Q^65	��g���5\�0���9p9��M>1Y�.�+�J��PV��UP8>EޱM5Wv-�k��V+\��?�&��J��v|��	ٿ�~��dL�(Ar��������[!�I^��z���".\�SS�r�%G��h���-��q�A������!�9?=)0x�S�̭�Y�G�ٲ��5�͌fη�$��y8yNA/��ꌪ7�(3Y �;�ME�;��?��+F�����u���䙾�%����}�B�!��j�cj����iY/GΙU���6K���6�E�3���T�=k���dFY�R�R��{hj�0U�G����*N�Y�ѫ[8�����`H���f��{(�1P�0k Ґ�QM���ǜ�j<�HՊ��w=P"-P�X|~Y�=k4����VSہ��I;����u�
- h+�p>��{&���8�XM��3�cP�qǧ���[{�+�8��v�U#	�:l��s���u�
?�p���i��"'^��E������,�x��n�rHVaza:s����nt!��Z^�+;)�r�h��T�46O1��HQ�ح�g�b�oG�N+z+ϽO#{���dc��CK�
�R;�d�?��z�h��d`iH?mE���/�K�o��r����̚m~4�\PIsT�gR��9�������:ز�M�{�{�Q/US�I�_mD��e?��E�G���'��:����whX-.�E;
}'�;	�W$������}
h�������"SBS��Y9�5��Qo��o�/�.K�l&㑖��AdV��ޱ���7�%���$�������7�:ϭ��8V�P�h�6Kو�e�R>�J����S��ȶ��h}?>&d�e�������X^�z����+�d�X�*�Fxτ!ƒ]A$�7���u���xdg�6�r��w\c��D�Ҕ"���0|���H! ���ҳ;'|
?m�����q�s9:�s^:ℇS�I~�Y|�,bmxP��G�[KT[	����_m���xЁU�8)"���yC0��%�B�ެ�<9�ajE��F<
�ӱ���p��W���k��i'/�Ns�I����3O'V:R'R���lq�ؐ��s���h���Q�<\����,��^�Ţ�i��r�i���IY�MU��8}1Q2,���q���1�����cN���G�J�埋���E�5d���?��Į�o��v�[K�T�h�II��<ػ�k"�W*���$��&X���w&QY��,a��&�H����ǫ9�>���''��iS�x�`�5�Ij�ng��_hWIS��}^�n�Œt9�S�/;��y�V��c����Ŏ;:����wq�Z�D��s��˃��sNyr��E��d]nYi���e7gc��E�`6'[JuM*��3&q��=P2�!�|��]���=��=m��X=��U��I
�"�U��QZ�|�w�L'$k-
D�0�a�ZLM2��Wm�B��c��k�����P>����3YH��'����js;<���	��g�$��� �k{{��<���&W�m��MV����[.��1
Qc
��\&��ƽ�Fd�GCvк�q�s�U�܎��YqϩO���e7�;$bl��ގQ�̦�q:;��O=@���;��sy�ʖ�2��m�}0�����g�Y��O��B�|����&��Ld�J�j�g�p���]BQv�$���W�S�e�g/I0n�S���s�kC�"�nRMm��,VԘ���<sf�˽ ��bB#\9g��6�{�pbcu�
^�����1%���8ڄ��g�z�"5�)��roF#h��<� Z-G�����q��S�:j��i֖�7���1�\�.ktY㖇|�U��x-KVf�K��;Vdv?H�h��c,��px��3I��30+?|K����M�rP�DĪ]�c5���A�tm���Ӗb�Z	����܎3�^�-ǹ��U�c�R�3]�V��b�m�T��@��~Aca�Qp<=�<rs����|���[!�%��D0�����(� �Ӂ"r�H���$4��$�e�rF�.��}`W��>�;;�xec
���1wt(����!�oe�@�bu,"��mE$��
���:&�z���R���b
��6�(_��g�%��j�o�%�,�O>,
_����?h�����g�b�t�r�7`
sF�>˺�g1���K���k+$R���ɺ�]�h�&�$�t$��(��>V�-8j�]ڐ�E��$��q�Ag,�fؚ��@�09�:�y�m��vێiG�D���|N�`�B�{�Z��$<��P�W���p~�����z�ݰ kD�eưF2�{E_T��'V*-kn��Y0�헖?��-J�:�M@}��U��vk�����PS�3je�^��kw}p��H�ʌ=��Ul�,����E
_lG�$�U#)���@H�o�(i����#܈����$�{nFvb�ၙc��0���-��ѓ�G��wby#� ^� k �D�3w�[d޺��F�t�$��)��ɸ�������D5ֹ��5V����b�����꣕t%V
�A
f��,�^����d��[��=i�_v���l��s�K�چ𷶧��`��+�vʀ ��GS|��x������9k�m)��c���J������e��R�*�dk�⹚~·��6��M�W�n�Q2��^BX�*,E���qm��>k�T����H{�'��@�X/�+���+��0�,��!�56y�>p�Ҝ,C�0��e�1kͦj��%ߢ�G�xؾ6`>#�c^�7�
C�d7�*��������y��b�R��g��H�.3�|�6��|��2<�ÚL��OUM�L�������Vs�-�yte
�9�HCS�ɒpq���;�}�Q��KV����=���ݰLW{�TD����M�Ov��}r�&��!pC�'j��(�5&�:D���Ƶ+�S�aKQ����g0���ʭޡ�6�h3o�\�`����V+�渝"&�G&2�M�����ۅ<�>L�+�ȸ�����B�����
-����zS�^���s�� ̥Y��k�o����P��K�ޱ�Q��hx\��7���^ZO�d%M~��5���/z����Lb�I?7'^U��ܻ;�@?C�a٭���rF��B�/�]�
�}@lFH�K��$R�:3rX������a�2c�l>��,��%ٗ/#wΓ��*���>ӥ����j��fB��jB��g&��
�K-^\�O<�����BX�� y�&�2��w��U�
�&k1����&kif<���iيi�iL�->����5�����8[�o3i9�A��Y(vJu�y�����|}�+�*�׸"����K��^��B������L5ҮwW�-��oN�6Z�X�>FP�}Y1����@�Zs1D�w\,v�.x#�MB�Ec7�1a��Q�mɜ�%]��FuqG�/�](��g�uC��f�rۓhr��❀�
�����`�Bv�B���ƭΎ��7)�;8�����#c�i����{#[n�p'}�"�8D��с�#'I�P�#gE��/u�x�Z�&��?���w�%���}�]!QR�n\@��/)�=�>�iq��b��g�hy�M�G��ٯ�F���|���W���Y�v�Yz0��+誧�U&�t�
`{�f˃@�A���$};�-7+IT}��S��}ӔLbx�Qօh�CSC:,]�Ͳ����"���O�C5-�ӣ�D�;3bÒ�~�}�:W�
��?y2�_�����1�{�mQ�����3�v&�li��l�>����6�G��U�h��g���S��[M�
�x�ia��IdXLY"�Ӝ�.ǻlE����V��
�6��<.��'K�F�~������+"{�RA����)S��~$�ƌW���~�~� 	����c�c�"ꊡp��q������â#�1��c;���'Y�
r$���s���) ./��O��b�҆ԋ\��$�и�!)���9�����.�=d�F��òD2"Y�^�!IӓERY�E��Z��|��n��ˮ?G��$=���(/[xP�;B��	;��&���eu�����G� �֔��:��X�
+@5�V�cwj�;�7ɖ���g�Ѕ�o ';	:��5Z�8ޕf�<��`ʈ���=d1��Y�*<^�*��/�sqC=z�g�A.8<�ٺ��:p;#@ڎ�f��p[R}SQ�p磍���<goް1q`��R��c��r���qvR�u���9M��=��зw�?��?�IVc9o��9��cK.���a;Qrh]j���L������(
#��;�Tmg�h#�@+�s$�kH��uժ��`3"��IFvz�O��q*�qjH�^�e��?���%���$4Wo�t�5'�,� ��'��}�Ե��4A����ّ�� �
�<�_N.�z��Q��Z	��>��g.Z�ͭ��
��WP��޷9T9͟���gP�H�J�yq����2���؞5�X��g�k�j̏�J�9�ۏ\p���?/Ο,Bl�׷����;��[�Ӎ���~���JYKF�¡n� ��{d�L��8۠�'+y|
�h>Y0��^ZZS���q0�� �i~�J'��i=�Wo�n���P�)�*	
��T!0 ���qdI�v�&��3��M
Qbg�0�lux�z���'�" Q�j"�)W������+zp�*.#xu��5�?l�!�y<m�<ÓMݡBuz�LlV�Mk�Q�p�!��n0dQ�Y_��/U�1N۫`��(�ѭ@Z���	+�M�	
=��P���z����Z\3������fζ �&��Tg�4˃�m�Y2:E�43����j��6V����wj��ũ�y]�i|	>q�" >����< ��0�*f�DTx�aͣ
6�
S�xU�3E�W$��0���ќ��*m]�'�QN3,a�!��c: qo�y ט�><��=!��>i�c�y����
������!����+��?j%������r����U����v�kS�1Ƨ䗻��*Vy��޳� ���6R�Ϲ�a��y�G�M�6�m]<^&��Y�d�#;���(�L�Ey�( �����e�bS�~��b�9��x���޳�E Σ�+Ƕ�M��FΞM���g�ų�N����R�?I��������y=���+ϙ�?�-�Z?t�)W3���I[o����CS��y�n�Ld��/��M��b۳)�]}1ˊg�~oh���EY*���=��6"_�U�G�|]P��:q7*̏o>7u�By^|���ل���_Sÿ��^�ώ��*u�n���ݴ@�F� ��k��4��&Z�/�y�E-��녰�C4FG䜴�.�z����ж�h��=�R_(q�/L����j�\�7f��W�"7��F�I#�T';��L�4W�c��,QnV��u�[5���'Hi�j�=Ç��d�ts�tn��l���EH4E�mo>�RC�
�X
pc���"��ф�Q�	���Bw�w��ߓ�����F��S ٫[��.�}�M��#�ջ����N6	���Uw�iH�7��ި��n|�N���A#��r�x!Q�GG��ӦLYf4���>kmW8m�k_x�v8 ����'���_�����`K<���JDԁޝ�8��^T���'F%�A�-���(��V� ;P.�T��Fj���
X)Y��V%�4��e�F�����{�S��m�@m����ţ&X���H��`�/��p�j}��=�i䜄���ݠ��4��b$1��bN+|6��tG��Y���>AQ���fÂr�:>Q/P8U�~���:���4Ms0�C� >q�{`�?TQCSc�HM��y�d�:��{�H�OK������`5��H��։��	O�
��)\�"W�Sk���j#�N�}�Qn���qtj�l���N����!��9Fb�����Ķ��)�a��.W��Bb�:��B@h����f�PU��hÐg����Ӷ�N�6M3M�L�8���h1G���J�Գ݅Nꎄ�e�}_l�1 G}f��RB"�c��x�-tZEc����ę�L>�3W��HLQ��]j�;Ƒ�#��@�N�d*T��1�W�se��P�ӻ�5�z��Fsr��s��z١^t���L�;��5�yxo��ǰ��l�����.�w�/SVZ�8#��/t��9@S� WG5f�=��>�%M�[�J�
��p��7U�}C/D׬[�t��Z
�!��P���{��*���iͳD\֊����HbD�*��s�����>�E 7�M`q��&�h�nKi�����?nn��9� ���/���)`��<�Ji/�G��xΐ�E�p������w����������9����湼׹����8�d������C�Cˀ�v�g�U<��q~�����g��'�ǒ��־�	�O����|�IU5��-�~���������B ���1]SG�����>dB��v(�����#��w3]��dO۾��Ҵל�@PW��2C�@�)`��(X��arζ&���P��L]�Q�8����B�k�Tۢ��M��5h:߂5j��7�ų��fg�oⴜ�V��9�_T�<�~J�~�O(�3n�n��j>z^��yҵ�n-�ku�ǿ���k�R
S�C�4w�����U��?mI'{�1n�y�$�(�a[������Y䛁���Oz����Fۜ�Ī�{G�V�?��/�߼��YE��YI�V�F����^�I��YQdPTaR�U�gRf�c��o������ihn���w���?��FFfzf��������]m����KM�Y�A�o������O�K��(�  �
��2��ҍ>��_�u�&��������=-H�/o�������L̔��̠�gbd�?, �t��'���w��m��(�[����@���������#BS]O�H��Y����3�^�?5=����/�&jj�KNd����'=h��HK����o�L@-#=Í��7���Jm�/<�Q����4�?7��������?����!EmU5MտK���?5�Ѐ�������������@ZjJ&Z -#�o�?-%-5#5�N3����hADK�����jm�������g���~�������]]Y��O��_���9%̓������a�y^�S}E
#UcU��м�!�>�CJe|�GT�0�D�xyI�)��)�����@I�y����@����J����4r�i`�uT�X`��t�4q��������JEE#e
����_�)�����*�����i��@Ƌ������<���������dfdf2���r�������[��tLԌ?��+Z DKO{����Wk�������cj����h���V����7�z��::��j:���&���&�t�*��z��J�z�3F|M=P^1q!:Z*�'�^1:Z|e
�6t7���n���w83]�Ù�����������7����������_W�O�p������������䰁 �4
���JGS�JG�r���lP�S�|���e�|
�^,�myJ�ۛ�̍4MT/�)��Zh� ~�?�T7U4R�>�ᕧ��䟋Ƀ����&�F�B�:�z��J:��u��.˔�����2Y�����.����/
�!�����c\��E�:\�\.��;PH 
9��j�{ų	f�A�7 �R��/h~�O  �<8���{�q�n���;���D�s����/�S��o�`p �����`�&��!(��V$ס;H�ЍpU�0o�r�Z�~;c�:\��o� ~ ����� ?0�Y���Ki{�'(~Q�1xj]��"����` ��I  :ts_�A�:4�MB Ȯx�Fy�u�x� �o�Q��&�`@�G��~)H�	p2�Y��с��J��=��J��<���`����<��:�0q��1J&�J �w� �@��l�PrN��|����<����L�ʜ��E�I���[�DA:� N\�B�qP����/�]�շ��r��� �jS�'� #;�n�쇊���	���0���r|���n�K9k�OɲAV�o��<�B�{ Y&8�,/��O�\�.�	���m|�[�\����C7��� ��/�_���b�Z�峫�����zz��,�~��a]�~�+�X�ٟ��C�%��u������}4NA:?��MW�.d��0l�*�ү��~�_��w�d�B�C�~ Ս���qgr�]��K��v�
M��7�׺�/ӯ�s�=��}����z\�{���~x���.�t)�G0��rq}����] �:��� �/�_NI@�s���+�uj]�������lD �߮xJ�{�z�@p��=�}e��}P��l'
 ξp�e��s�m1�]��}eޔS��OW��*���c�dg���aK��"��4[{Dʂ/�\�W���8�w��5����o��s ���U8T��f�j������i*�r�	�h��}Ct-�5��u5ut4�U���T�9`.�C4O��.��8T��o_<?�g���%('6�ų���
�����b
C/�R�0�b�

/�C[A��E����; �z|~�:���?�����������b�s~~^
��N����D��`�px�0L��|p~N}m���b�®�v�/��ZAس�?
2�' ���hϷ���@�8Y��s}^{tۀ���;-Rx4���(�Uz�ŗ�Kٹ�����g�H/������:�v�-�k�#������'_@m����y�g���}�J��N�u'�'�v�-� �`��!�`bc��_�zz.������u��T@5C�Yn��n���溹n��������k=�����a�ex��y��t����r���Ӻ��>�՚�=�����J�=;��o�C/�ݮ֨'.'�Wk�ŗ�Wk�h`�ؿ\����]�����zI�f}���q���#�q�G��\�C�T>�O�M��/��tvt���2~%��e|�!/���q��Gx�����|���'�a���u�/���˂�赒���)>3%%5
�٢�w��k���Ǻ��\X��?�����=��X�؟��]��q�K�����]��X.�#����b��Z������q%�-����%)���������W�{~d�]����u���=�/�y��'>�?�̏����/oa?>�� ����'�;����>��?���>�ࣀ���W�M~�?��}~�Ћ���p%ϕXG`�������������.���	�w�?�O�K>�?�7b�y�����W����姯Ə��ϫ��w��yQ��W{~Q�ߌ�Ky������
�ߟ_��<���+���[�返{�>o.p�_�$��߃�=����C|�����+W��]Ο�M�2�#������?�� �p�
��笺��g�"?���y����� ���~w�$��v����j|޿�eOl.������v����C�>?=���'�e�W�T���������H��o�L	�!$����%@�$BXѝ�0I �?�	:��d
�Mr�;��W��&�ޢ�w3��$�5(� l�~��L�����*�6�_��}����~��ד�b�z�%�V�����H�m�]��ye�x4wcC��|��"����!������s33���L'�@���Y�uhz%��tӵ��jP^᪩q>^�zԹ���#�Z�G}cC����3+P��l��  ��tV�9��[G������M��n������2sAVvnl&���v���]��U������z׆*g��
�#!�Ӿ<�b��e�N��ݕ�Y�w��,Ҧ�(<�*Z�ʹ�XQT\�9����/q���+�t��/X�ة�+6ʵT�6��� FMԵ��"h@�H�9��V!�O�&TU�]Q�#'E�c@F�\�K䠐�Tz�J^8�W�FoG 55rr}41��e��C�J
�Y���V��b�Ġ̆M]��o���[
��"�}��W�!��~��,S�n�Q�g
��I#����W�n?S�S�����7�ʫ�9��ɕ����U�UZ��Q}��_�Q�)6����>(�m?��[�n?U�w3�)1�Dѻ,����'_��o���}Egp#�����������x���ɫ����n��r�O����	t��p�ݯ-�78���P����F���"�oF)�꿯l����
����y���z��+->	���	Xv��S�<���UvXv�m��t��Z��ò#X�IJ���/�� /��J�|�0�8Av���g�t�}NM$N�]�2/10e��J@��*�"5�ܥ�e+�2?!w���Cdߕ)?w7�t)r�3G�Oƺ�,0�M��������痽��W�=P������P�E�ܗ�ya�/������uںW]����/�M>�5��?���\���e�����'�y�ćOl=޺���i�\v���w5�8`�d�s'C')�B�N���.�hG����8zG�rt:G����}G��7|��	���`u���oa�:�#��&WW�#2���FA^c��v�O|x9�ć�J��M%>H����.3��s��B|�V�Cc�#>��]�a.PH|h��-�?�����O�gE���m���R�H���N�}ǩ�+��j��	W2�Lx%^��B&le�s��t&<�	'3�LX$��^�o��{N�3�D�e��{�bwFp,�k��(>; �b<F��`��d�O6�
���˯������m?�*�9ȥw3�%���@ۣ���A��ǲ��$ݨ��{�����.�ut|�����t�}�+�?���{�=� D�w�_��{uZ�m:��ۥ��g�R��tR��9}���w��������h
|�b����y6#@�����}dz:A��T���`%�Y�H>��a0�dΚ<
�q�H�Q\ ��N�Ey"H�|�>I�nK���w��,�3��;���M$|i\{&�K�+rd��Q{�=V�`lm��3���$��$��n�>{xl*�e|�X�[�_#�k$س��121s>Z�i]���>Ru���[�࿮���&�1k��,�%'����y��9���Ɠ� ���Y0ߚ�������k�Z��C��Z��&��XC�ϛ�ۿ&�3k�e�|��s-��?��~O2�܋��%H��G��. .k�]�����!�.p����-�q�~�Yp/���6��mW����X2%����/��
![\�c��vE��x?JӇ6�ܰԵ^~.� ���q�ed���&v��--o�c��(�p�h/rK�mvChk���� pB�
����U��pр�(�F�t�6�wA2��Q�'!l�p+��A�a?�7C��x��In�^��X��K��U�x�dϤ{��z�<)�zR�uM�ۓ�݋���<;�#hC�x��k��!,��l�"i�{_����G��g=(M���D�c��t�Ll�h�����L��n���@��^��[����W�;�.O�p�M�;67�a�����nN�J2.�Ҿ�J��jL�p��(��۟~��p���__����7����W�������������|.�ɍ3t��=��]~��cr�ܟ�w�����<](�%�y��R]����̱= ���~�Q*��T����[�c�I���|w)|m�Y�o�5�㴮>�
ϳe�����Ã��x�8�m�m�B�^ں>6�u�ݎ��$VŔ�)����C����O���gwŔyC�9a~M��
�eZL�=������E�)�E����� #�=�?��Q�J�z����4=�����G1dV*2�KA�OC)ގ�gS����O4�ΐZ!5KM��Y[�KCH���h�J��3�\�.*7uH�"��w�!	#,޺kծA��z٢� ڢ�[m�����VkKW�6�m�^�M��j�m�USC�� ��[�ϙD۾����������-��̹=�9�yng����(X����P�O��a�%=��O��lh���z�L@'�nb[��� k��X{�Ob���7�V
���� mx�~?q�`&�������o��D�%�lh����O�3�ⶰ;ܔ|��4>�-	�_ �f5�Q,��wz�n�~��ghj��D��^W��8Ս4���~K�'u�]��<7���0���J ��T+B�3ԍж÷ߐhcX�ɉ�Af��Q[�;6��;7���5>�M�R.�d�/�����l�I<.y#�en����K�;�KeKy�[~�ȆA�6���n1sAɈ<�G%%�t�b���>"����ϛݕ�\����E�$V*F6�]cY��h��<C;i>�[�!]������f�u� m�຃�R�Z
*
+�~��)ƿ7;�C�d?-e�|�7�O
�>�k�dX��L����<��#��9��5�}κ����,���Z�P����(���#Z���o��2��%wFsKs$�lJ�#��=���K��w�|��3��U�|�`�,zhy�fa�u�P`�Ō�P|}� M���oU�fr����f� ��"��=��n���O^��,d�8���|)�Y��#!����1j����<�� &}6��+z$�YN��'�L�ԳY��M�z��d�E�D�D3����Nw�
�Y�>T��,��e�WO�z�bS��z� ��X�nݻ�:�Q|~OR��B�z
]-�<V#u�1��tX
ɻ\_�P�n5L��n%����r���#�g1����2"p��b��4%$?�"���
�}���'Sv�i��H����̹Ԡ.���	:�Ȟ�V�'��>Љ4s���*�	� ��߆9f���D��Ê&V�5k����YQ��rT\���"��wL�/X�X"�C�Ui�`���������?���r�Ā,�EH�ǎ�F�>��
Wܯq��Z�!D{�&��1������:Z��{��^��@�A�Q�Zn�t@	�ւ�R^t��[�Ȍ�nw��͚�����\
�-(y�`嫬�O���.Y��7~���bk��ֱ���X�%x�HB���pc�囍��p��#Sِ�� =.Y��?VP�� �>�}@���|w�jD���<�Ka���{�i"=Vy��+(&b7����S�n�z;����޺��Sxhr�<�U�
��6�R-���|�_��%G����qBŽx�ٸPF}�c㶐����O�J����+F�&����w�̄&�dƀ�I\]䓼�>�������:�o��]�r1w~�y��HK%���<o�o�.F��r��Y0���u���8z�k��uV���߲n���,�u)�N.Q�PV��,��ͦ��DD~εf<�%�P�?QR�Uz^�!��mA;��(�;�&[��@�
��Ц�#���F��9+BA�#m����/x�A���7u��b��Jߖu�V�>�"��7�s�byz	���*���A܎e	��`pCL&~Ҟ�ah��"���L�\��B̚�e�����t�3��|�&8'8%�mJvP�V�T�6�
{�ň�1M�@�Y#m��FZ$�����`�e��!9����?�㬾��='�sO%O���R6"�qc,�V>š֏P�L=J�^�]�6����0�2����
��W��4N�{a�Ѯ��+"���ij�J6�d�OK�F��8	�J�R��M[,���_�
'1������}���7�w�����, ��	��ĸ�ܪ�z�n�z�d����t�k���F��vׁ
�t�]��dX�d���V$�ɤ}!�m`�Qr�-���)Q�V����2A�Y`���|}����H�$�2���
3����m�hV�1�$��>��$��@.G���'6R�^N힑X��6�h\�g.�L�P�[[_%XtX	]�0[W+�\|�S@E%G^b&}� �ʿd�����HBė�Z��Q�咱g0/�"/@A�^�dB�k���_�n2�8�##�s��}�Mu�i�s"�?#wf���,ű�?G�T.��Ĺ�@˃�;aTЎ�#7�1"�ם����������Qf� ��IE<�҉{��ĥu��[~ ��F�@�V�8�*� � �j�` i�ֹI���$ � &��Y�gL^�~_�X�����a��tx����C�ՠ�#MF��j1�~�x��EA�m�
$��y��ui1X�-VaS^v��|xڕ	P��~�͢�Aǥ�V��U��G�8^d�����8p��|�U��?�x�?��[��>ک�'|ަ�M�V���_�Y񮼖�^�%�Q�!��.���FZ^6��u�t|�o�KR�˃�D��.�wt	]{�0� }YC!}�'y�p�ƞ$0�=���ﻪ�94K0������{{-E������s�X�GX$W �z���8�c���[/����y��}:���[�M���λ��ƠM2�P��zc|�*yХ���x)�!�Ej��9��Ż�z�jߑ[/��9�%d2
��D^32�4
ցD�<m!���t�e�pmxI��2�Cq�-�������	�#��ܰ�?<I@z�I���bv�p��Pxch��BhF;�����3��X��l��]��D5Q{֫�y��H��pmZ���]X���X+�9/�D�|�����D���r�����j�̩��"r��������h�3(��@�G�@'.	����U�w�d�z	�z]���_��Ob�!����1��)�T�іN�{>��@_Q��Do7H���тJKY�Œ�$s#MjK$+?�8ďc�"��E��m�>��1�Sh�Ze6�O�)̤��`��q>��!�͎�51��b+�a�x����8/����g�Pf��*�G
�M��.�ץ4+���wk8��M�M�Ak�(��%�����
��A����@����^�KPªXo�N�Ot�!�Ⱦ�{��d�!A��R=�'B�
	L�m5�#Vw�fn���qq��L��e��q엎8�И���l2b
�V�҂�ab���9�1�j2ڂ��N�����
-Z.��v ��w�!7��F�w|���ǡ](��Q�0$�ú"!���b	D����(N
�s�@.��5�%��P���sk�FD["9��� �L	�Pr�b#�^�z�6�1Er�g�'T�g�8�d�>��`e�;,`o�������	ҳɀ{	-����S������:��9��"��r,@"�D^Y}qN"��4)����)1}�?M��/��1�yZ*�?�O���@|���:A����H��~(Yn�o�	av�Xs9"Q�4g:��CRPB0���/Ϧ,B�l	Iq�˕�����/Z��kTN�E'^A˰�����_�s4p���ֈ<���F ��i}��b|'|
�n�o��\p�n�
7R����9��<��lm&gq�^�R�te^T :fS��҄^m�:C=�QE�[YIk������R]"��~�[Bۓ��z�<h$2��x�Y!�{΀G���9&������q^w��pl�I�ɟmJ&�g�S�t�� ��(��]6����S`�5a���50�	�F���^)��cP/�u�� [
�g�T ��*���o�����)�|��XI#�I�m+)nȓLn	m��A0V`_rX3H�
X���/[�!��@'�}A�G���@ߗ�����zS��v7��͟/5g�=<'ڒw�s�|�K�%��[�h�uH���D��K��!蓆�yP��?i@�
�V����'��dNl��K	�Yn�mA��XKCH�����S��,hu�=��t�����gA���֞�x\��:%�9�x��_H.5/ �S$i\`��ɫ�r��D��&SJ"����D��������J4n��e����P�E�q<G�%g�¸��u��Q	�B.��-
c��#���Դ����?�qΟ�/�b��ql���W�nT��6��o��P��ߧbI�x�m�5��JLf���4EJ}�Trq�1����9jA��9/�\���u�u�Ơ�i\+7��f�(�|W`v�����6aMຸiE��A*(��E��:~���~�xR���qR����?>|���y��cp}��_7|�� b.pō�҉ù}�qp���_�sWe�Ź\��a��ʊ�7��چ���hNn�����^Cm�>C�����ai>~����q��J"����zJ���J�h����T����X/p�R
k���K��

<`]Nfc��a��
�?	!`}8Ĺ��PDr�Y��U�P�v��Ŕ�!�D	��ނG���H�b|� �.����x�C c��L��5�RGMI��.F�x���gwC�����k"3��+�g3t`��7̛��.�}N�%T2}��������w����ަė��� �g�Zտ�((��H���gg��	���Y��a�!&'ά�����`vx�ġ�^Y�Y��ˋQ\T�>9Ѧת�ș8�x{�!��bm�&H,�i�ʖ�Һ=��
�5�G{�*x5��|����l,'H�9�O#���t�9�%����5�P��l�4$]ܻ�we�Ye}��+x5��hVN3�A��^a�*�J���^�hh��j;�)Jb��Z�`��5�o��&���y��H�Ӽ� `L�F�U�� 7��'C��*�����@m&P�j��:�}�W�x��]��p�cPk(�
�K�o)�[ҫ60ωl�Zį�6�4�,��!���yߞ�{�'�-���yy^c�c~�gy�G�r�~�Y��?z���,4#��e�S�>�x1�������_ٗ���vّ8���#�4۷3Uֿ3����ݳ=̀vj����B��n=�L��sg�r��jWrێ�N��ŵT��,�/��8�~޾���Fi^d���r�I��1��N���e�>��uj�:�{�0�Ȧ��ύ� Ϫ*	g#�Rz�#w�v��F�E�������'H@��Ha'S�;>���v��[C�8���u�:I����N�C?��u�m�3�m32[}R��iiУ�Ś�U�ڭ#7��h�G�9��IJǈ\57"��@�@�-:�dkP�N�v�U6R���փ�l�Hzd��06�= ������_��X��7�v�s�٥�
�4ga��|��a&`Q�ˣ����K��Na���l�=���u�Ҭ̉�rJjJ��.�d6���h�Y#
����E%(��
�)Y(�h�s*SF8������x������>���Վ��_j�;��'q(~^yu�b��t6�Y+���J$8:�8���۾'��n5��r����$�Y�謾��h��//Wۉ��I��2Q]>܉��������p@޷���v�U�y�I�;�<DW�&���S���!��)�y��H���Xr��?��ͯ�hs@�kQ@��-F�B�; Bc��N��J&��Lǁ"�փ����~��`���:�v���-0b�MK�/����os ���v����)�/�F[/�)J�v��[k�d�ҐΘ�d֊kT�$N�F�ʩs�4(E?$���F�S�L9�+�
Z	�r�Z�Si_DXېm�q�V)>3q���a�K�O��r�r�G�k.�.7��y�,tK?K�Pe�Q���(36#�/_��d�[�������@i�滍��".�Fy|�
n���̭)F]�5�h���[��H���������t��!��W}��#�6��o�&�$�Jnm\ߎ��Tߌ���;��g��P�
R09���"��h=�R6�����ʗ��ؿ[�\DL�*�eE��ז�/�0e�h4���re�s�z��?8ɚWd3.�m�P;���I���j�ʥ�S�մ�b
�s�#Y�Z��*���'y�[^KYZnJ	?���'{����<у{�i:Ӊ�qP���H��*�]�%nҌ4��.���Cnk�cL8���@u���Ǉ��cF�;p�Ɏ{(��}Ё>���z�˭���?c�ע�:�n�ǋ�7�c�;wi҃sy'/�F@jBK��T
�����Pc�p���6�&4�_b\-��ƷЭ����!���պ1�=��
��f*];׭���W�Pzmm�����4s
d� O{H��Q�Z��-kx�q�=\�y_�cqE�WQ�p���S��y�Ej�j��|��G�S�Mx�/��t,[o�2��9�n|��u���_oaI�f�Ch��Vv5�A廓�]����ߵ�����vd��2u�#����WE�~�h��G	J�<WoܲF$�{r����pӅ��q�v��?wSI ���4ѢOa[���^q̋�!~{��M�rS���,� �ԙ<�����Q(��M�A��8"�,���g	�_����>b/�#^�v���m�d/���)�6�?g��:X{	>\��ȋq��Z)�9�����lB�
��x���'i�7�`��\�� �y8�2*ۋ�ߚ�F�Dk������<[2���4��?�������������{s/�9E�9
��Id}c��:{
��U�9�,�x����O5��<8LגՓn��'�!��D�����{x���}�	�qnT ���O#���Q�ڭ�ʊ�,�8֋�M�]8=b���O�Xf�N7}��tx����_o���5�}�U�{!�A�.�7t
�م1;
�NFܲ�Sm`
kn�6�#h;�֒�`��O��6b�מ��D�� ��A�V�
��O�ڍn)U<ϣ
�3҆gSe��Δ��3J�7�7֍⓸Dj�>�F�qK��=>܁�J0��c�������.�J����L�Ax�UB�`,G�#�Ҋ�.�쇳���Fw�R�M�;tp�[]��F#���:�������i�"��B�(����[)����!�My��^�Jkl�E�g�n
Խ/���������a�48Ҟ� eC�绥C��g(�{��|�iп��f�� G����{υ��&sW���~�pc+�
|>��ꎒ�G[��	���>�5�⬹8�Ђ�����S�_�q�$(��m��ؗ����q�mGo�ث��E�.�~�廛�<�������
vA�U(o͏s�{&�9a#DL�T���9���^��T�3����,�}AK�_Ǻ ������s�̕a���Y���;��ԋ)?}VH�yǱ�� k�I퀙,ukV���+� }[r�5|�)���L}�>S̶��\	�	<c>���z���D_�i�1`L����j'���U��෧:)n�s�V=:+��G<�R���U�J�M�}�^���Y~��H�xF�Ct��@!���#���C���UE"�z޲!h1�i<a��#�~�\TImV��H#�4�`^(<F,��qvL)m�5�69[<��M��ڰl�wϧ!I~���5Sm��ŝSFc?7ߒ!�0.%X)���bL�+e�����5#�'C�}���H�Xbb��\W�/����G�ݠ��-8
4��������|�M>�@���+�u/5!8�Ԑ8��i3����� I�g��p��W�Z,�Tź�s���w��֥`�=bpB�'#����z-�PݳC�wcU�'�yC��L��'��h����Iv��=s
��C�<�-kD
���ɧm�=>J�>=�x�.�1�ѫa����6$��i"3�x� �t�{,҃���Σ�F����6�(5��;v�)ՐO��9(�O�c�q�K.U`��6<^��?y�6X��]r�ȑ�wL�P/��Y��G�q;�a��>nK9��%9+�owW���:��|.���J���9d�[�L��޹Fwh�ѭ�<�f�h[��߀oD�m�x��h<����C�mZgS�m�.��S��mu�)�=^��06���I�~{�;�g�
��Ҵ���	��*ow��V<*���;բ+~G��څ�i���<H�r�����6�v,z�)���b�U?����
�k�{.x2���m
��I�_
�o�K�"��}~I~�7?�B>��:��dx%$z%�Ox�0O�(���G^��dhB��6�H���9��)�ʏ|Ǧ�D�??�u�GT'�x���������Q��-�ot���K�Vm:֪��)>����������܁z��w��ݼ?�/��z�in{͊�Qrs�n�`�NJ���j������\F�V�[�:=�zn5�R����Ft�=�f�oH�l�q��ri��M���}YFNc�EC�v�+�I�E��5�J#�� ��Ey|���Z	u�e%�@o@Zʹ͠����,��"�����|H񌣝�3��w���Pn@m��"-����Dh�v��j��܆�&;JcU#:7w�?u������hj�����
b��B��\U��.#k`�.r�,9i�iދ�J�`�H#H�\,��_����H�N�m�S�Nv�:P���pc��=�L>�_��1�n){$r�8wV��z���JNi���_"�D�ݐ�H��x+S������/�y�@o����>�k��2,��X�&"�ݮ��w;7��_�,�*bF���@h�n��.u����!2�*�h
�Ŕ�K�&�z��L�
�l�v����kFa�t�#�g�"j��5�����H��}�uD_eh<�JC�0�McC\5Y/^>�!UZ�VWSV�er���.��H��.rb�i���7hP~g��7�Ґ{f9��ɰ��o|ȶN���P��_Ǽ����i(��xX����{��򡠙_܋K�?*��6d�%$�01p&��!>蘿������{�O�dHj�)���q�L��4$\��=	]���KG�?��ﾨ��~N]���l)�ON�S��4�{�,�Ԣc�[� >�K������N����e��2l�ş���p
�*�	��,e��]�*�D�4y���e�e���k�C�D����2��kQscB�;Z`��gH��E�G�.�ϖp��rcB�P��2�tF�p��΢/�o#X��e�ȷ���;I�j=E,�*�l7I�|mY`y��%�}�"��0�/��#��TzDTZ�i���M���7����%Y�~YvE䈾����Zb�y�����,�P��a�3]�c?T�S���7�
>TΏ9 m}����e�g����g\�,� _?��<|}��._�LfN�y�2C��%'��xf̢/|Ԫ�B�Q�v�l��(.���J"�nU��/S޲.PzB�I�O$�!J;�%v ~^��o��%j��V���~%D�:�uU@������ܲ0nj�c��U��tJ@V\��(�G�����3��s�L��ӦOۃ�`��Y]��|\�1V|Ϗ+;ۊ�9&����a��ς\�vV������ۛ<!!��Vk�G���_m#x� �,a^�I���lK����
������'<�@�_��u�\%J�+7�J:y��d�����,$g!Y�Up_	��*@n�Z��A�n ��r�
,���koD��9Q:�\�k&`�`���οC�Y(�=��V�ĴY�M�	�����s�K0ǻ�6:b��7?���Ӝ֍��-z��0����ފ�)��liǲ�zD4��'n�Uu	�	��)�/	�/0�_7-̴��"�h�5�T�/��G��K�z��m�ܽY1�vW�����u]�Q+ܘ�<�2hP����=�@�J;�+[��\&po����nЭgU�Nh��(?��!���,����ƍ�@u�Ӡ� K
�mN����U���]�̳�8��܋.�lb3a��`s���Ae1sF�6���w�TD���ۊ*
>+:S�����qɶ'*�|�ę%A˩���ƥۖW,�l���z�~�~�󺴠�R��cՓ�ϫ�$f�= =��y:Mn?/���
�@\�� ��F�~a��ޮ
��xh�|��u߸0V �0 ���ɗ/��J�*���%��m%���&��>o8Jz�~��b)��(e�=��ba���R�.��XC��Ǭ����e��G-��ʆD������\������Chb�B���]�jXz2��
���K�X��p�StJ�'
zϊ�(~�Q����M5���;����Oj9��eO�L<�-�g�|��#q��	trp��ղ�䳰�ʒ����"�H�,}���6xz�l��b�O�Z�ñ�/�RG�7�wl<�5{�s�@��ݟ� k�t��x]��V� �hK��0��a�
�Җ`<�a��S ����K��jE5
�����o�a ϸO���a@	�rg�^u�2C�N��L0�9�A�U{��"��^}����]�����<�W�7x��-�@Y$������tg\�5�
:�I
!xUٛ�H�mCqD�r�Z �iQ����ܺ����I��26ڥ�{-�i�N�gF�q�azU����y�&�� �,�4�-A���&�?gQ�ҽ(l�bN�Zlo�~�4Jr�J�"�q+=�Q9.�����&n��7mS�;:��N&dN�.��JX����
,5������@Cq���o�9<���M~�t5`Y�]I���X%�)�&��8.x���ɬ�<�8��SЗ�z/��8��	����ܬ�;�E)�m��g��&�j�����{�c���hV�+�}m�9!q�9a���]�´~[�G�9�k�hf�yV 
ඦ�\���ofz�!�Kx�u�p"�����ĵ'X�B�BL�",k&2��>4=pP�Ԝ��oQ��s��*��GXuK���ׯ����^[Nx��-?ޗW'���k믻]�_�_ٟ�Y�_ȟu
w�=	�ҫ���N]�6VS�9/���B<�Z�y|S�u`��y%��u�6��^
%����W��M��O����O�n�8�ϧ*�
[�$/���m~��E�����\D]��1�кCX����_���s�RB�����T<���zq��eq__�,ۋ]�ϚY�-}��E�w�;?g/���D��7ˑu���uD:�6��>;@�ށ��-�~+鰨�rB�7;X�J�����ˉZ�����{�/���c߼
Qڔ{�u��$��Ǒo�:��q��AW���n��h�P�1��!2��㹕8���6D�*��T��h�{��,#��Q�{
o��̩]X�r���CHvA���:<�����:<���,�R��5R�RW���|�׫���&�U_�Xvҍ��R��w"�1�1��C"����T�d����$�b����w![3���=�i�'���c��X��b�y����n����a�D�!��]b�-���]_��Z�hx�rO�d_���B"o}N�T}��� ;1ui��<���Z����x\"��O~!�S�ɯ�ؐ�@�Y�NA���N��P
u�(
�E��,����\}����ƫ&�>nUCq�-
��������G6S54�k4���j6�����=�2��	�X���}(^qZ]S�ǻ����ʃW*\6��ߺ��+3���J��,;'L�
z9��F;o�����bM6S�S��&a��f�h�Ikagw���x�$pu��v{����A��F��QM"s1���A��H	�1�K�������"�x���	p�xH�3Q�ݾ��x����g-��~<�kë��M���:?���ޢ0]��U��b:^����s���b/�*�L�g7�/�F|׾����s�
��tį/AuX㨲�}�h}��r�>��7�Љ-ޘ&й��7��̬|�7�_��#↛�/#~�O��Kw�DE����z2�Its�|����*U
��"~��{0���?Q�$>��}y��G�5�N�*���s��kf��
;��d}ޫ�:]� Aĸ?f��*�W�*_��{���)�%(�����LVYE�X��0�)�=���m�0�)0�I�Y%Ң����z���!��7(�_{zƊ�;=�� ;�.���/~I�ۋ�u̹�e��9{]�O^�v�|�z��5����W|���]W�*�����6��c�-���g�4��+�\U����e'�W_�j��R%0�Ib��aV�=�|��S�i��R�?J�ʊU:_�3	t@�9 �{�G��2�l�݃�c�
��g�*����w�+N�A�R��ū.��Z$�b��$�����C�$5���4�B|u%ڡ�r�#~wdS�����r�����I������˻�9�\�-=�X��|^I�]��,��}ӅF�,��"�t�g

���ܝ	%����/��"�:�{�=������ҥ���<��Ԫ��/	j�����,B|dw��A3�+v��)����S�����ϔA6c���4fz��my���H#��;���\��C�*���ḿ�������@���r7��J,o�Ս��d�u����g]�݊=���U��:��[�a�m�sW��N����O~��Kz�,��`
hX��vE���T�\�4Kaƣ����H�߷��}:����<�Kg}�P�a,MH�s���5���ly���}���8��ys���!�'�R�ϻ�xd���3����]u���ǎǳ���{]��ÇC R/�&��4��~Y;'���}�e�@�+���o���d@1
r�K��� O�8{(O����Q�=J�5ˤ_L1Uqh�L�y�b�~�X���u�m���tRѥ݊��L�j-S6Ɣ�$��>[���@������:.p�X^��|a�͛��M?� _�����b�s�&}��~����م�arE^#��*�jU���#��[��|i�1��5�M�a��s!B����;-�-�γ���d�/���e��p�s!&��u�yԎ�X^5|.���^�6��(���vq�����K�g!�D;\V5��Y�ͅ���lK�k^u)2h�y��A�z)�)H�����@]ڭz��]�q�2k{AUB�{�Qv������I��>ox�Q�d�Ak7����zII��!��S!�,���_�hsP)�
����b��t�%/d��5���h�1�'�gd���˺�l4ɮѿ�!�%�I2��N�<4u�AO�R"�.}�`�.��h=��X�E���9B<���A�W#
��{�kDgY�D�BEw�Ew!�ÄZ����eЌ(v�!߭�Ʉ��\��5 �����9�����F��`��=�o�GW"���D#:�vV�r�Az%k 
�B�l.�=4wS��K�[gP���滣��.����,����u�S�*�l�����1����5�;Dm$;���7��(l#`�̦8�P��O�@�:1������D��z	��L�8���G����_�u�X�iV���l��n��K�!����}��fY�.)��+(W��S�N�^)�	X��P�^}ۓq��ʙ0���2
l޷|�[�*�w/�V�R�m��CH�B�j���pt�B�� ~I���$��w=�������s�@c�;tk=�H扠b�ATk�*������9S��A�� �҈k���fi:�m�K,�z���^�t�_bը���x�B�����2����w��/�p�EAE�w�GvԢ]��(e"��
���:N>�]��r5��]z�m�;���=;
����-*-� ��דxǛO�V`�}*�:���k���o| o󑑜������R��BnD��Mvdn��!��l1���ATw{�M��Y���ſ�mf#&�b�H؏���B%��1�iy,b�qK-&!A�q#���f���B��#��R��5�.��c��m��.�߯�ؚ\�w�Eru#�PO���n���g	t��������K�I�K��K}�ߵDژ$�b��\�O����HlT�� y��DR7](���kz����O��W}�����A�7G�n���*3�)$�
��!I��z7A��L���w<P�l�z����N�nԋ
9u�QP-�Q� �������Oǒ|�*�8�B��^f���X�;g8f���p鐇��y��3�o,kMq&�d�G��3Pm�#R�Njw4�(�w-����2�b+�TA�ｽo���z� )P2u�h�u���|I��ʻ��a��_	���D]����{�����j�	�TqO�<;Ҩ�+��_����i�)���v#ل�؋��M+�J�6k�3\9g߬�/�G|)�tI#�>�챠6mYx���U��$a�\�}
�-�L���9:��ˤh�X�ȗ*Xc}�����[1!I��ї��O[���s����lй�z���a� [%��~�4W��g?���-_���ҍ��@O[��l�\N>��k�wB/޹��fH�����uZA���1��{���ɦ�ğ�ⱬ�3��i�P.�2�{Ĳ���ĉ�T��y��%֜��C��G��t͊�dM���}�eg�7!�5�wJ|so����獺 �F���"o�8nj)�~�ζ�-xֹ0')�R�hYr	K4푓G]FVíg�-K����@����"f�	��3A^���/��<n��lW�.p��8����U���,���w~���G�������gs��bJ�a
��ܪ"��R
��w������*Y��;{&�1���o�3�d;�[(�ua���b.6ݹ�v=���L/���0��\8w��;X̽~��TP��"t�v5�I�4E��E�'��,�v�毩��T��k�&���0ԧB$��(2�S!����nw��|���|�h���~'�s���M�{�����	����a�~B~bD���	��=��qH^�C��YH~1�o.����$��I_)�p�AR�D*S���G242*:&v��)L�F�0�tW�����5����c���}�!�`BLA�L���Q#��֟��B�����T�K#&�)�@$����G�$HDt g�!j��b�lS�����q��h$%�]$����~?�n���H�	�9p~����Y�W�W��*�%*����F��(��֫we��?��/ ��z���z�FE1J>%���2�t������J��wQe��fȣ�~����ňm�2Ҳq��B��w�PmR�A"�IX��E���eds_��i�)��D��
 �������2j�t=&�JѨ�2$�cB1���f�I���#$�3�ЋrO�Q؏�������gU�<(p�C�ʪ�
�-�!'�b[�W�NՄ~�� ��x���E��/��o��I�F0?-d���vA��8�O6�U��H� 5�
``Ș>��_�����������c������ �
��8��y ��� \�w�@w ����� �=~�k��?V=���a��� r�V�����x�Ae�
R;��ĸ�ָ{c�q��^?
�y���,Y+��$q���8h�"�J�w�{�-����4��Ej)�rqj�J�0u����%���y
��	���!��Y7p�������}����72~����:a��G�VMo�����i�s�Wnٺ��R���;w����=5�{�ƌ�x{��%W(�T��C���N���{�R�|O�o x�[n�^��俛�/�$������I�5}�Aܛ&`2�I��'Mє��xp������I��U�__JH�I�H�����m���7���MѾ����M�M�/|_:��A���4A+��A�߽wvo��/-�K���e�i9uoZAߋOy���Ҫ�҃�Kߗ��:`�p��00MB��0����'-���O:�?q�������������K��K�/|_��t��b��<�$B@!bH).��j�$�`0�b!W�oс�-����`�8�����w��*j&X�b��(�ʃc��<8.����Z�;����]i������-�6��R~�[�O���7����!�q ��E��{��70�l9���ܟ�� �p}�����~
�}rͺ�~��u���e��WckOރ��g�1p>c��t���<Ģ�U���2B�
V!�ش�q�'L��i0��X�u^����
E�W�_�b��5s�_ΪǊV�ۀ�=T���?7g>\��B������������3���x�n�������y��_υ���3�x?�e|���	�����p�_߫{�U�?<�78g���\eDV�
�W&~�*�ȟ���h3�Y�����I��/3�/^�(Y�nC�q��Ic�fe�����},�#`tѪգaT�f	��|ʔ��Z%�/,)Z7 [�Zʭf4��55S�j�S�k�
�i֯Z�j�S��_'�_U���I]9��o�L�x|�(��V+����0�Y�f�'��/�/�IM-^S�j]��6�3��k��>�h�>n=r��Xq�<���%kVr�
׮e��i��+������-3dYO�� �V���<��q�ڥk���1Ek�5�W��U�r�L�Od�.c4p�F��k�6d��^<7��9Ƭ��G�aF��R��2f���?&g��9�2���2h0H[��).X]@��i��M���t�����p� O=����0�<1kE����+����,Z��hm��U�p�#��D�
��֭_���;Y���nX��p%T�0N�R�;N������y�0o`fbI�)AI�|�$����3pp�W���?�B�ܿV�Z.+\���`�rߵc��ￆ˄�}x���r�Y�v�h�@nRׯ+Z������(�[Eq�Z�e���o4?�l��L�5��L�ΪU�������V��V�H޽hSqQ�~ä���jpm��z���_��l�R)�����e�h(�������5E+��(������5g�.�G���>��?11�(9���d�F��_2��n��i���H�	_�;��?a�w�f��_������t]z��q��e��������I��?�u�t;Z7i\�W��,����ߤqJh��g��[��O���nm����2���~��p������_iVK��N��=��PZȷN��F�&�Ap��#)��'�ֻ�|���,����.2����Xt�p���������^���$������=l'����;�?���0o�����{>��M�ێ����i��y��s�0� L��|?�����w���-Ӏ��o��u����7+��l����
t﹯���N�_��������M��s���YQ�d|Ƙ�RW�Z_�Z2q|����kW�N�K��=�筙Fw_;���4.�3䕏���VN��P�4�/��`Ӻ>D�N�^܈����Be���4G�_V�G|x{���4 ���������|���g�L�C?���g�?�����I?���3��~&?�g��L����s���_
�o^��-�b6��H�x1x���/�/~��h�e=��-�]�n�T�z�����[�~-�
֭^���X���..\���/^���`1�IVm,�$�w���E��Sk`��V�/Qь��qq���������y3�ʡ���
�̛i\��yKV�揯\�*�v���OV�K9��
�����8�����'e�O��M��E�)@��:EA������I�OqA���Й��<rd"t��pa���!���r�
RAy䀘�MDС�\U�S��O�i�8ͷ�^���8��{^�2<�c&nZDT�{��^)^��&f��%5Oz_��p���� T��p�J����;]bQ�G���'C���+�]z���p~NzӜ[��mD�s����K� _>_ᯮ�~�r����hz�K��E�῿�B��nOcn�\�]��˒�����'����:\�{� f�3ZD+�8��[�W�b���p��~��Ԓǟ�(��wCO��~���_ǿ������<vʈ��*�����kF��y������22�6|VI��0�n�M�盘��L�� 655�!I?���j�n?��u{�S��Wa�h'�EǮ�c[X�(_��׎����:;&�����x���*�'N�=S(�_���oox��7��N�f���v��>z����_���{;�t��x�#r6�,��q��z�xI�70��A[5|���O���q6�9�C9�C_q��������A�=}];��eh�B���T 	i(���]����H\ݟ��[��1=�e���GR�۸�;W�V-V����M���U�5��]D�U R�Vy6�o���~�o���],��$� ���Px���Ba�Fkae���
m^*vCX�Q����������� �a��q�=گ��v�ZT�ซ�x�P�z�`[��s�B����
w��͸��wn�˔������f����f����f|��/�x�џ�x��o��B���E�M��XA���rS�GY�T[�Ն���1�3~��fe���؇oƗ)mwX�ˍ�Ɍ�l�Kf|����(�}��R1�d��[d���x����~P��EdΪV���>��K�?"᭤��<|��&�K�0��LI|�I�R}����{��vV.�����1|�z�!�[��n��*��L�1֯x5^cw	���N����;,�\��i?\��|J��n7��t|��²U+�V��
���4�SӲ�$T؟�Č&V�ځ:`��
Ȣ7�d��p=���*!�p:���;S�X:jߌ�yj��V3�k��k-g��M0��������*%�0�`�M�2z�4!y)\"t-����gb���
��֍fGb��������Ư���
ı���$#1�����VI��W_��=�=Y��J�O��D�x�>Edk�[�X��@��ht�I�Ep�X���pBK�lD���*�� �0�jl��8�q���8^< ���Z�������~~�o��`��r�Y�kbb��|�ǽ�֡��
	1�r����p��rDs�#��M�ڸ�nmc_	���������4�h�C0~������Q���������$��Vt�ߺ�8�o�y��l���&��f��y��e��]�2f�
��:��l㽱e_:���!{��9!�\z�9<s�1s�@�F���s�0�|B�;m���/�a��