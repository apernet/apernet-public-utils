#!/bin/bash

echo "光圈美西谷歌避免reCAPTCHA脚本"

google=("2001:4860::/32" "2404:6800::/32" "2404:f340::/32" "2600:1900::/28" "2606:73c0::/32" "2607:f8b0::/32" "2620:120:e000::/40" "2800:3f0::/32" "2a00:1450::/29" "2a00:79e0::/31" "2c0f:fb50::/32")

if echo "$(ip -6 a)" | grep -q "2602:feda:30:cafe"; then
  gw="2602:feda:30:cafe::c001"
elif echo "$(ip -6 a)" | grep -q "2602:feda:30:ae86"; then
  gw="2602:feda:30:ae86::30"
else
  echo "未检测到 IPv6 地址，或是不支持的 IPv6 网段。"
  exit 1
fi

for pfx in ${google[@]}; do
  ip -6 r replace $pfx via $gw
done
