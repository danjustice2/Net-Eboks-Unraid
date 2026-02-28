FROM debian:bookworm-slim

LABEL maintainer="Net-Eboks Docker"
LABEL description="POP3 proxy for e-Boks (Danish national digital mail) with MitID authentication"

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    perl \
    cpanminus \
    make \
    gcc \
    libssl-dev \
    libexpat1-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Perl module dependencies
RUN cpanm --notest --quiet \
    LWP::UserAgent \
    LWP::Protocol::https \
    LWP::ConnCache \
    DateTime \
    'IO::Lambda@1.33' \
    IO::Lambda::HTTP \
    IO::Lambda::HTTP::Server \
    IO::Lambda::HTTP::Client \
    IO::Lambda::HTTP::UserAgent \
    IO::Lambda::Socket \
    MIME::Entity \
    MIME::Base64 \
    XML::Simple \
    Getopt::Long \
    Digest::SHA \
    IO::Socket::SSL \
    Crypt::OpenSSL::RSA \
    JSON::XS \
    URI \
    URI::QueryParam \
    HTTP::Request::Common

WORKDIR /app
COPY . .

# Build and install the Net::Eboks module
RUN perl Makefile.PL && make && make install

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# POP3 proxy port (default)
EXPOSE 8110
# MitID authentication web UI port (auth mode only)
EXPOSE 9999

ENTRYPOINT ["/entrypoint.sh"]
