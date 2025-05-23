#!/bin/bash

sphnctl fizz stop
docker container prune -f
docker volume prune -f
docker system df
docker volume ls -f dangling=true
docker volume ls
docker ps -a --filter volume=node-storage
docker volume rm node-storage


# 卸载配置文件路径
UNINSTALL_LIST=(
    "/usr/local/bin/sphnctl"
    "${HOME}/.cache/sphnctl"
    "/etc/profile.d/sphnctl.sh"
)

# 停止可能运行的后台进程
echo "停止相关服务..."
pkill -f sphnctl

# 执行文件删除
echo "开始删除安装文件..."
for target in "${UNINSTALL_LIST[@]}"; do
    if [ -f "$target" ] || [ -d "$target" ]; then
        echo "正在移除: $target"
        sudo rm -rf "$target"
    fi
done

# 环境变量清理
echo "清理Shell环境配置..."
sed -i.bak '/sphnctl/d' "${HOME}/.bashrc" "${HOME}/.zshrc" 2>/dev/null

# 包管理器残留清理 (针对不同系统)
case "$(uname -s)" in
    Linux)
        echo "清理Linux系统残留..."
        sudo apt-get purge sphnctl 2>/dev/null
        sudo yum remove sphnctl 2>/dev/null
        ;;
    Darwin)
        echo "清理macOS系统残留..."
        brew uninstall sphnctl 2>/dev/null
        ;;
esac

# 权限修复
echo "修复目录权限..."
sudo chmod 755 /usr/local/bin

# 验证清理结果
echo -e "\n验证清理结果："
if ! command -v sphnctl &> /dev/null; then
    echo "✅ sphnctl 已成功移除"
else
    echo "❌ 检测到残留文件，请手动检查："
    which sphnctl
fi

echo -e "\n建议执行以下命令更新环境："
echo "source ~/.bashrc && hash -r"
