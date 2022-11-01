# Termux-Music
简介:

这是一个基于Termux-API播放本地音乐的脚本,用termux-media-player命令播放本地音乐,简单实现了顺序播放和单曲循环,以及自定义歌单和通知效果(termux-notification),如果有安装ffmpeg,那么会尝试从音乐中提取封面到通知显示,目前添加了三种音乐格式:
Mp3,M4a,Flac,这三种格式都是支持的,如果需要添加其他格式可自己修改下代码,Main中在67行,另一个文件135行,当然得Termux-Api支持的格式(说实话我也不太清楚支持哪些,都是自己尝试的)

在打开通知开关后可从通知控制上一曲下一曲暂停播放,关闭通知需要从控制台键n手动关闭,控制台播放后可0键退出控制台后台播放

需要Termux-API自启权限以及锁定后台才不会被一键清理杀死,由于Termux-Api没有提供主界面,所以需要去手动设置,MIUI手机一般在手机管家/优化加速右上的设置锁定里,其他手机我不清楚
Termux拉取

`git clone https://github.com/Mr-Nobody-s/Termux-Music`

控制台授予运行权限

`chmod +x Termux-Music/Music-Main.sh`

bash运行

`bash Termux-Music/Music-Main.sh`

termux无法输入中文问题：在../usr/etc/profile头部添加代码
`LANG=”zh_CN.UTF-8”
LC_MESSAGES=”zh_CN.eucCN”
export LANG LC_MESSAGES`

