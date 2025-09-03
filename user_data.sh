#!/bin/bash
set -eux


# Amazon Linux 2023 / 2
if command -v dnf >/dev/null 2>&1; then
dnf -y update || true
dnf -y install nginx
systemctl enable nginx
echo "<h1>CONGRATS YOUR CODE IS RUNNING</h1>" > /usr/share/nginx/html/index.html
systemctl start nginx
else
yum -y update || true
amazon-linux-extras enable nginx1 || true
yum -y install nginx
systemctl enable nginx
echo "<h1>CONGRATS YOUR CODE IS RUNNING</h1>" > /usr/share/nginx/html/index.html
systemctl start nginx
fi