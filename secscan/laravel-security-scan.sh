#!/bin/bash
set -e

# Pilih versi PHP: default = 8.2, override dengan:  -e PHP_VERSION=7.3
PHP_VERSION=${PHP_VERSION:-8.2}

case "$PHP_VERSION" in
  7.3)
    PHP_BIN="php73"
    COMPOSER_RUN="$PHP_BIN /usr/local/bin/composer"
    ;;
  8.2)
    PHP_BIN="php82"
    COMPOSER_RUN="$PHP_BIN /usr/local/bin/composer"
    ;;
  *)
    echo "❌ Invalid PHP_VERSION: $PHP_VERSION (use 7.3 or 8.2)"
    exit 1
    ;;
esac

echo "🔍 CVE Scanner for composer.lock"
echo "⚙️  Using PHP $PHP_VERSION"
echo "📁 Working directory: $(pwd)"
echo

if [ ! -f composer.lock ]; then
    echo "❌ ERROR: composer.lock not found in /project!"
    echo "💡 Mount your project directory with: -v \$PWD:/project"
    exit 1
fi

# 1. Composer Audit
echo "=== 🧪 1. Running: composer audit (PHP $PHP_VERSION) ==="
$COMPOSER_RUN audit
echo

# 2. Local PHP Security Checker
echo "=== 🛡️ 2. Running: local-php-security-checker (via PHP $PHP_VERSION) ==="
$PHP_BIN /usr/local/bin/security-checker
echo

# 3. OSV Scanner
echo "=== 🕵️ 3. Running: osv-scanner ==="
osv-scanner -lockfile=composer.lock
echo

# 4. Snyk
if [ -n "${SNYK_TOKEN}" ]; then
    echo "=== 🌐 4. Running: Snyk ==="
    snyk test --file=composer.lock --package-manager=composer
    echo
else
    echo "⚠️  Skipping Snyk (set SNYK_TOKEN to enable)"
    echo
fi

echo "✅ Scan completed with PHP $PHP_VERSION!"
