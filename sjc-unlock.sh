#!/bin/bash

echo "光圈美西解锁脚本"

country=("美国" "新加坡" "香港" "台湾" "日本" "韩国" "英国" "德国" "加拿大" "阿根廷" "土耳其" "巴基斯坦" "埃及")
nflx=("2607:fb10::/32" "2620:0:ef0::/48" "2620:10c:7000::/44" "2a00:86c0::/32" "2a03:5640::/32")

if echo "$(ip -6 a)" | grep -q "2602:feda:30:cafe"; then
  suffix=("c001" "14" "bada" "cafe" "12" "111" "120" "121" "122" "123" "124" "17" "126")
  prefix="2602:feda:30:cafe:"
elif echo "$(ip -6 a)" | grep -q "2602:feda:30:ae86"; then
  suffix=("991" "14" "990" "992" "12" "111" "120" "121" "122" "123" "124" "17" "126")
  prefix="2602:feda:30:ae86:"
else
  echo "未检测到 IPv6 地址，或是不支持的 IPv6 网段。"
  exit 1
fi

i=0
echo -e "输入需要解锁的地区："
for str in ${country[@]}; do
  echo -e "[$i] $str"
  i=$(($i+1))
done

read -p "请输入数字：" num

gateway="$prefix:${suffix[num]}"

for pfx in ${nflx[@]}; do
  ip -6 r replace $pfx via $gateway
done

UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

echo -e "检测 Netflix 区域中..."

region=$(curl -6 --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1)
result1=$(curl -6 --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81280792" 2>&1)

[ -z "$region" ] && region="us"

echo $region
echo $result1
