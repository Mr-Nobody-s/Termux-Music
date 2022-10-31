#!/data/data/com.termux/files/usr/bin/bash
BINPATH=/data/data/com.termux/files/usr/bin/termux-media-player
DIR=`cd $(dirname $0); pwd`
MusicFile="$DIR/termuxmusic/musicpath"
NOW="$DIR/termuxmusic/now"
FILE="Termux-Music.sh"
function key(){
    while :;do
        clear;Now;printf "%s\n" "${list[@]##*/}"|nl;MusicNow
        read STR
        case $STR in
        ([1-9]|[1-9][0-9]|[1-9][0-9][0-9]|\))
            if test $STR -le $len;then
                (nohup bash "$DIR/$FILE" $STR >/dev/null 2>&1 &)
            fi
            continue
        ;;
       s|p|c|n)
            (nohup bash "$DIR/$FILE" $STR >/dev/null 2>&1 &)
            continue
       ;;
       0)
            exit
        ;;
        00)
            (nohup bash "$DIR/$FILE" stop >/dev/null 2>&1 &)
            exit
        ;;
        x|X)
            Operate
        ;;
        *)
            continue
        ;;
        esac
    done
}
function MusicNow(){
    $BINPATH info
    echo "当前"`sed -n '2p' "$NOW"`
    echo `sed -n '3p' "$NOW"`
    echo -e "\n输入序列号播放\n\n   0.退出 00.退出并停止播放 s.播放 p.暂停 x.菜单 c.单曲循环开/关  n.通知开关\n"
}
function Operate(){
    while :;do
        echo "          1.音乐目录操作 2.歌单操作 0.返回"
        read  option
        case $option in
            1)
                MusicPathOperate
                continue
            ;;
            2)
                PlayList
                continue
            ;;
            0)
            break;return
            ;;
            esac
    done
}
function Now(){
    if test -f "$NOW";then
        path=$(cat $NOW|sed -n 1p)
        if test -d $path;then
             readarray -O 1 -t list <<< `find $path -maxdepth 1 -iname "*.mp3" -o -iname "*.flac" -o -iname "*.m4a"`
             len=${#list[@]}
             return 10
        else
            readarray -O 1 -t list <<< `cat $DIR/termuxmusic/$(cat $NOW|sed -n 1p)`
            len=${#list[@]}
            return 11
        fi
    else
        cat $MusicFile|sed -n 1p >$NOW;
        key
    fi
}
function AddPlayList(){
    while :;do
        echo -e "\n输入此歌单名字，重名则追加写入，0.返回"
        read name
        case $name in
        0)
            break;return
        ;;
        *)
            songlistname=$name.list
            AddPlayLists
        ;;
        esac
    done
}
function AddPlayLists(){
    Now;printf "%s\n" "${list[@]##*/}"|nl
    while read -p "输入要添加的歌曲序号，空格分隔，0返回。" -a num;do
        case $num in
        0)
           break;return
        ;;
        ([1-9]|[1-9][0-9]|[1-9][0-9][0-9]|\))
            lens=${#num[@]}
            Now
            if test $? = 10;then
                for ((i=0;i<$lens;i++))
                do
                    cat >> $DIR/termuxmusic/$songlistname <<< $(echo "${list[${num[$i]}]}")
                    echo "${list[${num[$i]}]}"
                done
                echo -e "歌单歌曲添加完成。"
                sleep 1
                break
            else
                if test "$songlistname" != "$(cat $NOW|sed -n 1p)";then
                    for ((i=0;i<$lens;i++))
                    do
                        if test ! -z "${list[${num[$i]}]}";then cat >> $DIR/termuxmusic/$songlistname <<< $(echo "${list[${num[$i]}]}");fi
                    done
                    echo -e "\n歌单歌曲添加完成。"
                    sleep 1
                    break
                else
                    echo "错误，不能添加自身歌单到自身歌单里面，一秒后返回";
                    sleep 1
                fi
            fi
        ;;
        *)
            continue
        ;;
        esac
    done
}
#歌单管理
function PlayList(){
    while :;do
        readarray -O 1 -t playlist <<< $(find $DIR/termuxmusic -maxdepth 1 -name "*.list")
        if [[ -z "${playlist[@]}" ]];then echo -e "\n没有歌单，先添加一个吧";AddPlayList;return;fi
         playlistlen=${#playlist[@]}
        printf "%s\n" "${playlist[@]##*/}"|sed s/.list//|nl
        echo -e "\n输入序列号切换并进入，0.返回 i.添加歌单\n   m加歌单序列号进入歌单歌曲管理模式，d加歌单序列号删除歌单\n示例 d1 m1"
        while read select;do
               case $select in
                0)
                    break 2;return
                ;;
                ([1-9]|[1-9][0-9]|[1-9][0-9][0-9]|\))
                    if test $select -le $playlistlen;then
                        name=$(echo ${playlist[$select]##*/})
                        sed -i '1c '"$name"'' $NOW
                        unset list;key;return
                    else 
                        echo "请输入正确的序列号，当前最高$playlistlen，重新输入"
                        sleep 1
                        continue
                    fi
                ;;
                i)
                    AddPlayList
                    break
                ;;
                (m[1-9]|m[1-9][0-9]|m[1-9][0-9][0-9]|\))
                    select=$(echo $select|grep -oE '[0-9]+')
                    if test $select -le $playlistlen;then
                        SongListM
                        break
                    else echo "请输入正确的序列号，当前最高$playlistlen，重新输入";continue;fi
                ;;
                (d[1-9]|d[1-9][0-9]|d[1-9][0-9][0-9]|\))
                    select=$(echo $select|grep -oE '[0-9]+')
                    if test $select -le $playlistlen;then
                        if [[ $(echo $DIR/termuxmusic/$(cat $NOW|sed -n 1p)) = ${playlist[$select]} ]];
                        then
                            echo "错误，歌单正在使用，重新输入";continue
                        else 
                            rm -f ${playlist[$select]};echo "已删除序列号 $select";unset playlist;unset playlistlen;PlayList;fi
                    else
                        echo "请输入正确的序列号，当前最高$playlistlen，重新输入";continue;fi
                ;;
                *)
                    echo "输入错误"
                    break
                ;;
                esac
        done
    done
}
#歌单歌曲管理
function SongListM(){
    clear
    while :;do
        readarray -O 1 -t songs <<< $(cat ${playlist[$select]})
        printf "%s\n" "${songs[@]##*/}"|nl
        echo -e "\nd.删除模式，i.添加正在播放列表的歌曲到此歌单。0返回"
        read selects
        case $selects in
        0)
            unset songs;break;return
        ;;
        i)
            songlistname=$(echo ${playlist[$select]##*/})
            AddPlayLists
            unset songs;
            continue
        ;;
        d)
            unset selects;unset songs
            DeleteSong
            continue
        ;;
        *)
            echo "输入错误"
            continue
        ;;
        esac
    done
}
#删除歌单音乐
function DeleteSong(){
    while :;do
        echo "输入序列号删除，空格分隔。0.返回"
         read -a nums
         case $nums in
         0)
            unset nums;break;return
         ;;
         *)
            len=${#nums[@]}
            len1=$[$len-1]
            b=0;
          #这里得遍历一下从大到小排序删除。
            for ((k=0;k<=$len;k++));do
              for ((j=0;j<=${len1};j++));do
                    let c=$j+1
                    panduan=${nums[$j]}
                    panduan1=${nums[$c]}
                     if [[ $panduan -lt $panduan1 ]];then
                           b=$panduan1
                           nums[$j+1]=$panduan
                           nums[$j]=$b
                     fi
              done
            done
            echo "${nums[*]}"
            for ((i=0;i<$len;i++));do
                echo "删除${nums[$i]}"
                sed -i "${nums[$i]}"d ${playlist[$select]}
            done
           echo "已删除，立即生效需要回主界面任意播放操作刷新一下参数，"
           sleep 2
           unset len;unset len1;unset songs;
           break
         ;;
         esac
     done
}
#添加音乐路径
function AddMusicPath(){
    while :;do
        echo -e "\n输入音乐文件夹路径，0.返回"
        read -r path
        case $path in
        0)
            break;return
        ;;
         *)  
           if test -d "$path";then echo "$path" >> $MusicFile;echo -e "添加完成，路径:$path"
                unset path;Now;sleep 1;unset line;MusicPathOperate
           else
                echo "错误，路径不存在:$path" 
            continue
           fi
        ;;
        esac
    done
}
#音乐路径操作
function MusicPathOperate(){
    while :;do
        echo -e "\n已添加的音乐目录:\n"
        line=$(cat "$MusicFile" |wc -l)
        nl $MusicFile
        echo -e "\n输入序列号切换并进入 d.删除模式 i.添加 0.返回\n"
         read select
         case $select in
         0)
            unset select;unset line;break;return
          ;;
          ([1-9]|[1-9][0-9]|[1-9][0-9][0-9]|\))
            num=$select
            if [[ $num -le $line ]];then
                path=$(cat $MusicFile |sed -n "$num"p)
                sed -i '1c '"$path"'' $NOW
                unset list;unset num;unset line;unset select;key;return
            else 
                echo "输入错误$num,最高$line"
                continue
            fi
          ;;
         d)
            DeleteMusicPath
            continue
         ;;
         i)
            AddMusicPath
            continue
         ;;
          *)
            echo "或许输入错误"
            sleep 1
            continue
          ;;
          esac
    done
}
function DeleteMusicPath(){
    while read -p "输入要删除的序列号，0.返回" num;do
        case $num in
        0)
            unset num;break;return
        ;;
        ([1-9]|[1-9][0-9]|[1-9][0-9][0-9]|\))
            if [[ $num -le $line ]];then
                if [[ $(echo  `cat $NOW|sed -n 1p`) = $(echo `cat $MusicFile|sed -n "$num"p`) ]];then
                    echo "错误，目录正在使用"
                    continue
                else
                    sed -i "$num"d $MusicFile
                    nl $MusicFile
                    echo "$?已删除$num:"
                    sleep 1
                   continue
                fi
            else
                echo "错误。"
                sleep 1
                continue
            fi
       ;;
        *)
            echo "输入错误"
            sleep 1
            continue
        ;;
        esac
    done
}
#开始
function start(){
    if [[ ! -f $BINPATH ]];then
        echo "错误，没有找到$BINPATH文件"
    fi
    if [[ ! -d $DIR/termuxmusic ]];then
        echo "会在工作目录$DIR生成一个termuxmusic文件夹，用来存放状态和路径信息。"
        sleep 1
        mkdir -p $DIR/termuxmusic
    fi
    if [[ -f $MusicFile || -f $NOW ]];then  
            key;return
    else
        echo "" >$NOW
        sed -i 1a\ "1" "$NOW"
        sed -i 2a\ "顺序播放" "$NOW"
        sed -i 3a\ "隐藏" "$NOW"
         AddMusicPath;return
    fi
}
start
