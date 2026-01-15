FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Paket dasar
RUN apt-get update && apt-get install -y \
    curl wget gnupg lsb-release ca-certificates unzip software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# 2. PPA Ondřej (support multi PHP)
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -y \
        php7.3-cli php7.3-mbstring php7.3-xml php7.3-curl \
        php8.2-cli php8.2-mbstring php8.2-xml php8.2-curl \
    && rm -rf /var/lib/apt/lists/*

# 3. Buat alias biner agar bisa dipanggil sebagai php73 & php82
RUN update-alternatives --install /usr/bin/php73 php73 /usr/bin/php7.3 73 \
 && update-alternatives --install /usr/bin/php82 php82 /usr/bin/php8.2 82

# 4. Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

# 5. Composer (menggunakan php8.2 default, tapi Anda bisa override dengan php73)
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

# 6. Security tools
RUN curl -L https://github.com/fabpot/local-php-security-checker/releases/latest/download/local-php-security-checker.phar \
    -o /usr/local/bin/security-checker && chmod +x /usr/local/bin/security-checker \
 && curl -L https://github.com/google/osv-scanner/releases/latest/download/osv-scanner_linux_x86_64 \
    -o /usr/local/bin/osv-scanner && chmod +x /usr/local/bin/osv-scanner \
 && npm install -g snyk

WORKDIR /project
COPY scan-all.sh /usr/local/bin/scan-all.sh
RUN chmod +x /usr/local/bin/scan-all.sh
ENTRYPOINT ["/usr/local/bin/scan-all.sh"]
