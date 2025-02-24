#!/bin/bash

echo "Start Downloading Package !"
echo "Current Path: $PWD"

# 仓库连接: https://github.com/sirpdboy/luci-app-lucky/
# 架构名: x86_64
# 版本号: lucky v2.8.3   # releases 则为最新，如果需要指定版本号则填写版本号 (如 v2.10.8)
# 配置变量

REPO_URL="https://github.com/asvow/luci-app-tailscale"  # 仓库地址
ARCH="all"                                             # 架构名
VERSION="releases"                                       # 版本号 (releases 表示最新)

# 提取仓库 OWNER 和 REPO 名
OWNER=$(echo "$REPO_URL" | cut -d '/' -f 4)
REPO=$(echo "$REPO_URL" | cut -d '/' -f 5)

# 创建下载目录
mkdir -p packages/

# 根据版本号确定 API 路径
if [ "$VERSION" = "releases" ]; then
  echo "Fetching latest release URL for $REPO_URL..."
  # 查询最新版本的所有 .ipk 文件
  DOWNLOAD_URLS=$(curl -s "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" | grep "browser_download_url.*${ARCH}.*\.ipk" | cut -d '"' -f 4)
else
  echo "Fetching specific version $VERSION for $REPO_URL..."
  # 查询指定版本的所有 .ipk 文件
  DOWNLOAD_URLS=$(curl -s "https://api.github.com/repos/${OWNER}/${REPO}/releases/tags/${VERSION}" | grep "browser_download_url.*${ARCH}.*\.ipk" | cut -d '"' -f 4)
fi

# 检查 DOWNLOAD_URLS 是否为空
if [ -z "$DOWNLOAD_URLS" ]; then
  echo "Error: No matching .ipk files found for $ARCH in $VERSION"
  exit 1
fi

# 下载所有找到的 .ipk 文件
echo "Found $(echo "$DOWNLOAD_URLS" | wc -l) package(s) to download"
while IFS= read -r url; do
  if [ -n "$url" ]; then
    FILENAME=$(basename "$url")
    echo "Downloading $FILENAME from: $url"
    wget -O "packages/$FILENAME" "$url" || {
      echo "Error: Failed to download $FILENAME"
      exit 1
    }
  fi
done <<< "$DOWNLOAD_URLS"

echo "Package Download Completed!"
echo "Files downloaded to packages/ directory:"
ls -l packages/
