#!/bin/bash

echo "Start Downloading Package !"
echo "Current Path: $PWD"

# 仓库连接: 
# 架构名: x86_64
# 版本号: releases   # releases 则为最新，如果需要指定版本号则填写版本号 (如 v2.10.8)

# 配置变量
REPO_URL="https://github.com/nikkinikki-org/OpenWrt-nikki"  # 仓库地址
ARCH="x86_64"                                          # 架构名
VERSION="releases"                                     # 版本号 (releases 表示最新)

# 提取仓库 OWNER 和 REPO 名
OWNER=$(echo "$REPO_URL" | cut -d '/' -f 4)
REPO=$(echo "$REPO_URL" | cut -d '/' -f 5)

# 根据版本号确定 API 路径
if [ "$VERSION" = "releases" ]; then
  echo "Fetching latest release URL for $REPO_URL..."
  # 查询最新版本
  DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" | grep "browser_download_url.*${ARCH}.*\.tar\.gz" | head -n 1 | cut -d '"' -f 4)
else
  echo "Fetching specific version $VERSION for $REPO_URL..."
  # 查询指定版本
  DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/${OWNER}/${REPO}/releases/tags/${VERSION}" | grep "browser_download_url.*${ARCH}.*\.tar\.gz" | head -n 1 | cut -d '"' -f 4)
fi

# 检查 DOWNLOAD_URL 是否为空
if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: No matching .tar.gz file found for $ARCH in $VERSION"
  exit 1
fi

# 下载 package 包
echo "Downloading package from: $DOWNLOAD_URL"
wget -O package.tar.gz "$DOWNLOAD_URL" || {
  echo "Error: Failed to download package"
  exit 1
}

# 解压 package 包
echo "Extracting package to packages/ directory..."
tar -xzvf package.tar.gz -C packages/ || {
  echo "Error: Failed to extract package"
  exit 1
}

# 清理临时文件
echo "Cleaning up..."
rm -f package.tar.gz

echo "Package Download and Extraction Completed!"
