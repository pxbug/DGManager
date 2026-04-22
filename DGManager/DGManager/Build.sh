#!/bin/sh
#==============================

# 获取脚本所在的绝对目录路径
script_dir="$(cd "$(dirname "$0")" && pwd)"
# 提取最后一级目录名称
targetname=$(basename "$script_dir")
echo "当前脚本所在目录的目录名: $targetname"

# 直接指定目标路径
target="/Users/yunzhinetco.ltd/Library/Developer/Xcode/DerivedData/DGManager-grbzbgcdaojlysdrutgnorifjihh/Build/Products/Debug-iphoneos"

echo "📌 切换到目录: $target"

cd "$target" || { echo "目录不存在，退出。"; exit 1; }

#==============================
# 处理 Payload 文件夹及应用
echo "开始处理 Payload 文件夹及应用..."
rm -rf Payload

echo "创建 Payload 文件夹"
mkdir Payload

echo "删除 $targetname.tipa 文件"
rm -rf $targetname.tipa

echo "移动 $targetname.app 文件夹"
cp -R $targetname.app Payload/$targetname.app

echo "提取可执行文件"
strip -x Payload/$targetname.app/$targetname
# 对应用签名（请根据实际情况调整 ldid 命令及签名配置文件路径）
echo "对应用签名"
ldid -S"${script_dir}/ent.plist" Payload/$targetname.app/$targetname
# 获取 ldid 执行结果
if [ $? -eq 0 ]; then
    echo "✅ 签名成功！"
else
    echo "❌ 签名失败！"
    exit 1
fi

# 清理隐藏文件（示例中 sudo 密码为 "0000"，请根据实际情况修改或采用免密配置）
echo "清理隐藏文件"
sudo -p '请输入管理员（电脑）密码:' find . -type f \( -name ".DS_Store" -o -name ".localized" \) -print -exec rm -v {} +

echo "删除 embedded.mobileprovision 文件"
rm -rf Payload/$targetname.app/embedded.mobileprovision

echo "删除 PkgInfo 文件"
rm -rf Payload/$targetname.app/PkgInfo

echo "删除 Build.sh 文件"
rm -rf Payload/$targetname.app/Build.sh

echo "删除 _CodeSignature 文件夹"
rm -rf Payload/$targetname.app/_CodeSignature

# 压缩生成 ipa 文件（示例中使用后缀 .tipa，可根据实际需求修改为 .ipa）
echo "压缩生成 ipa 文件"
zip -rq $targetname.tipa Payload

echo "✅ $targetname.tipa 已生成！"

#==============================
# 使用 AppleScript 模拟选中 $targetname.tipa 文件并激活 Finder 窗口
osascript <<EOF
-- 获取当前工作目录，并构造完整的文件路径
set currentDir to do shell script "pwd"
set filePath to currentDir & "/${targetname}.tipa"

-- 检查文件是否存在
tell application "System Events"
    if not (exists disk item filePath) then
        display dialog "文件不存在：" & filePath
        return
    end if
end tell

-- 尝试将 POSIX 路径转换为 alias
try
    set theFile to POSIX file filePath as alias
on error errMsg number errNum
    display dialog "转换文件为 alias 时出错: " & errMsg
    return
end try

-- 在 Finder 中定位该文件并激活 Finder 窗口
tell application "Finder"
    reveal theFile
    activate
end tell
EOF
