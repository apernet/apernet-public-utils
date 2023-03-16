#!/bin/bash

read -p "IPv6 出站将变更为随机地址。同时将失去 IPv6 入站能力。是否确认？（确认：Y/y）" confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
  if echo "$(ip -6 a)" | grep -q "2602:feda:30:cafe"; then
    gw="2602:feda:30:cafe::c001"
  elif echo "$(ip -6 a)" | grep -q "2602:feda:30:ae86"; then
    gw="2602:feda:30:ae86::30"
  else
    echo "未检测到 IPv6 地址，或是不支持的 IPv6 网段。"
    exit 1
  fi
  ip -6 r replace default via $gw metric 1
  echo "IPv6 出站随机化已启用。测试效果："
  for i in {1..5}
  do
    curl -6 ip.sb
  done
else
  echo "已取消。"
fi
