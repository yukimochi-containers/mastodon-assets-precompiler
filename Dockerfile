FROM ruby:2.6-slim-buster

LABEL maintainer="https://github.com/yukimochi/mastodon-assets-precompiler"

ENV RAILS_ENV=production NODE_ENV=production

WORKDIR /mastodon

RUN apt-get update \
    && apt-get -y install --no-install-recommends curl gnupg2 \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get -y install --no-install-recommends build-essential git libicu-dev libidn11-dev libtool libpq-dev libprotobuf-dev python \
    && apt-get -y install --no-install-recommends ca-certificates ffmpeg file libicu63 imagemagick libidn11 libpq5 libprotobuf17 openssl protobuf-compiler tzdata wget nodejs yarn cmake \
    && apt-get -y autoremove --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cd ~ \
    && git clone https://github.com/google/brotli.git \
    && cd brotli \
    && mkdir out \
    && cd out \
    && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./installed .. \
    && cmake --build . --config Release --target install \
    && cp installed/bin/brotli /usr/local/bin/ \
    && cd /mastodon \
    && rm -rf ~/brotli/

RUN wget https://dl.minio.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc

RUN git clone -b v2.9.2 https://github.com/tootsuite/mastodon.git .

RUN bundle install --deployment --without test development \
    && yarn --pure-lockfile \
    && yarn cache clean
