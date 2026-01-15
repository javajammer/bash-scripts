#!/bin/bash
# Wrapper untuk menjalankan laravel-security-scan.sh (dalam container multi-php)

IMAGE_NAME="infokes-cve-scanner"   # ganti sesuai nama image hasil docker build
PROJECT_DIR=$(pwd)       # direktori project saat ini
PHP_VERSION=${PHP_VERSION:-8.2}

usage() {
  echo "Usage: scan [--php 7.3|8.2] [--token <snyk_token>] [command]"
  echo
  echo "Examples:"
  echo "  scan --php 7.3             # scan dengan PHP 7.3"
  echo "  scan --php 8.2             # scan dengan PHP 8.2 (default)"
  echo "  scan --token ABC123        # jalankan dengan SNYK_TOKEN"
  exit 1
}

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --php)
      PHP_VERSION="$2"
      shift 2
      ;;
    --token)
      export SNYK_TOKEN="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      break
      ;;
  esac
done

# Jalankan docker run dengan opsi yang tepat
docker run --rm \
  -e PHP_VERSION="$PHP_VERSION" \
  ${SNYK_TOKEN:+-e SNYK_TOKEN="$SNYK_TOKEN"} \
  -v "$PROJECT_DIR":/project \
  "$IMAGE_NAME" \
  /usr/local/bin/scan-all.sh "$@"
