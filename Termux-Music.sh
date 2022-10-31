#!/data/data/com.termux/files/usr/bin/bash
BINPATH=/data/data/com.termux/files/usr/bin/termux-media-player
BINNOT=/data/data/com.termux/files/usr/bin/termux-notification
BINNOTRE=/data/data/com.termux/files/usr/bin/termux-notification-remove
FFMPEG=/data/data/com.termux/files/usr/bin/ffmpeg
DIR=`cd $(dirname $0); pwd`
NOW="$DIR/termuxmusic/now"
MusicFile="$DIR/termuxmusic/musicpath"
imge="$DIR/termuxmusic/封面"
function MainNot(){
    STR=$1
    if [[ $STR = sp ]]
    then
        MusicNow
        now=$?
        if [[ $now -eq 1 || $now -eq 3 ]];then
            Num;Now;Music $num pause;return
        else
            $BINPATH pause;killpid;return
        fi
    elif [[ $STR = lasts ]]
    then
        Num;Now
        if test $num -eq 1;then num=$(( $len + 1 ));fi
        if test $num -gt $len;then num=2;fi
        num=$(expr $num - 1 );STR=$num;killpid;Music;return
    elif [[ $STR = lets ]]
    then
        Num;Now;if test $num -ge $len;then num=0;fi;num=$(expr $num + 1 );STR=$num;killpid;Music;return
    fi
}
function Main(){
    if [[ $(($STR+1)) != 1 ]]
    then
        killpid;Now;Music;return
    elif [[ $STR = n ]]
    then
        changeNot;return
    elif [[ $STR = s ]]
    then
        MusicNow;now=$?;Num;Now;Music $num pause;return
    elif [[ $STR = p ]]
    then
        $BINPATH pause;killpid;return
    elif [[ $STR = c ]]
    then
        Sing;now=$?
        if test $now -eq 33;then
            MusicNow;nows=$?
            if test $nows -eq 2;then
                Num;killpid;sleept;Now
                if test $num -ge $len;then
                    num=0
                fi
                num=$(expr $num + 1);Music $num play;return
            elif test $nows -eq 3;then
                Num;Now;Music $num pause;return
            fi
        elif test $now -eq 22;then
            MusicNow;nows=$?
            if test $nows -eq 2;then 
                Num;killpid;sleept;Now;SingPlay;return
            elif test $nows -eq 3;then
                Num;Now;SingPlay pause;return
            fi
        fi
    elif [[ $STR = stop ]]
    then
        $BINPATH stop
        killpid;return
    fi
}
function Music(){
    if test "$2" = "play";then
        STR=$1
    fi
    if test "$2" = "pause";then
        STR=$1
        if test "$now" = 1;then
            $BINPATH play "${array[$STR]}";sleept
        else
            $BINPATH play;sleept
        fi
        if test $num -ge $len;then
            num=0
        fi
        STR=$(expr $STR + 1)
    fi
    while :;do
        sed -i '2c '"$STR"'' $NOW
        $BINPATH play "${array[$STR]}"
        NotificationStatus
        if test $? -eq 60;then NOT;fi
        Single
        if test $? -eq 55;then
            STR=$(expr $STR - 1)
            sleept
            let STR++
        else
            if test $STR -ge $len;then STR=0;fi
            sleept
            let STR++
        fi
    done
}
function SingPlay(){
    if test "$1" = "pause";then echo -e "序列号$num\n播放:${array[$num]}";$BINPATH play;sleept;fi
    while :;do
        $BINPATH play "${array[$num]}"
        sleept
    done
    return
}
function NOT(){
    name=${array[$STR]##*/}
    name=${name%.*}
    if test -f $FFMPEG;then
        if test ! -d $imge;then mkdir -p $imge;fi
        if test ! -f "$imge/$name.jpg";then
            $FFMPEG -loglevel quiet -i "${array[$STR]}" -an -vcodec copy "$imge/$name.jpg"
            if test $? -eq 0;then
                $BINNOT -t "$name" --priority high -i 23 --ongoing --button1 "上一曲" --button1-action "(bash $DIR/termuxmusic.sh tt lasts)" --button2 "播放/暂停" --button2-action "(bash $DIR/termuxmusic.sh tt sp)" --button3 "下一曲" --button3-action "(bash $DIR/termuxmusic.sh tt lets)" --image-path "$imge/$name.jpg"
                return
            else
                $BINNOT -t "$name" --priority high -i 23 --ongoing --button1 "上一曲" --button1-action "(bash $DIR/termuxmusic.sh tt lasts)" --button2 "播放/暂停" --button2-action "(bash $DIR/termuxmusic.sh tt sp)" --button3 "下一曲" --button3-action "(bash $DIR/termuxmusic.sh tt lets)"
                return
            fi
        fi
    else
     $BINNOT -t "$name" --priority high -i 23 --ongoing --button1 "上一曲" --button1-action "(bash $DIR/termuxmusic.sh tt lasts)" --button2 "播放/暂停" --button2-action "(bash $DIR/termuxmusic.sh tt sp)" --button3 "下一曲" --button3-action "(bash $DIR/termuxmusic.sh tt lets)"
        return
    fi
}
function Num(){
    num=`sed -n '2p' "$NOW"`
    return
}
function Now(){
    unset array;unset len;
    if test -f "$NOW";then
        path=$(cat $NOW|sed -n 1p)
        if test -d $path;then
             readarray -O 1 -t array <<< `find $path -maxdepth 1 -iname "*.mp3" -o -iname "*.flac" -o -iname "*.m4a"`
             len=${#array[@]}
             return 10
        else
            readarray -O 1 -t array <<< `cat $DIR/termuxmusic/$(cat $NOW|sed -n 1p)`
            len=${#array[@]}
            return 11
        fi
    else
        cat $MusicFile|sed -n 1p >$NOW;return
    fi
}
function Single(){
    if [[ $(sed -n 3p "$NOW") = "单曲循环" ]]
    then
        return 55
    elif [[ $(sed -n 3p "$NOW") = "顺序播放" ]]
    then
        return 44
    fi
}
function NotificationStatus(){
    if [[ $(sed -n 4p "$NOW") = "显示" ]]
    then
        return 60
    elif [[ $(sed -n 4p "$NOW") = "隐藏" ]]
    then
        return 70
    fi
}
function changeNot(){
    if test "`sed -n 4p "$NOW"`" = "显示"
    then
        sed -i '4c 隐藏' $NOW
        $BINNOTRE 23
    else
        sed -i '4c 显示' $NOW
        Num;STR=$num;Now;NOT
    fi
    return
}
function MusicNow(){
    music=$($BINPATH info)
    if [[ "$music" = "Status: Paused"* ]]
    then
        return 3
    elif [[ "$music" = "No track currently!" ]]
    then
        return 1
    else
        return 2
    fi
}
function Sing(){
    if test "`sed -n 3p "$NOW"`" = "单曲循环"
    then
        sed -i '3c 顺序播放' $NOW
        return 33
    else
        sed -i '3c 单曲循环' $NOW
        return 22
    fi
}
function sleept(){
    i=1
    for var in $($BINPATH info |grep -oE '[0-9]+:[0-9]+ / [0-9]+:[0-9]+' |grep -oE '[0-9]+')
    do
        i[$i]=$var
        let i++
    done
    minute=$(( ${i[1]} *  60 ))
    minutes=$(( ${i[3]} *  60 ))
    timess=$(( $minutes + ${i[4]} - ${i[2]} - $minute ))
    sleep $timess
    return
}
function killpid(){
    paths=$0
    paths=${paths##*/}
    pid=`ps -ef |grep "$paths"|grep -v $$|awk '{print $2}'`
    pid2=`ps -ef |grep "$pid"|grep -v $$|awk '{print $2}'|sed -n 2p`
    (kill -9 $pid)
    (kill -9 $pid2)
}
STR=$1
if test $STR = tt;then
    MainNot $2
else
    Main
fi
