#!/bin/bash
set -e

BUCKET="your-deploy-bucket"
APP_DIR="/var/www/html"
ARTIFACT="app.tar.gz"

echo "--- Pulling artifact from S3 ---"
aws s3 cp s3://${BUCKET}/${ARTIFACT} /tmp/${ARTIFACT}

echo "--- Extracting app ---"
rm -rf ${APP_DIR}/*
tar -xzf /tmp/${ARTIFACT} -C ${APP_DIR}

echo "--- Reloading Nginx ---"
nginx -t && systemctl reload nginx

echo "--- Deploy complete ---"
