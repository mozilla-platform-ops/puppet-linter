FROM alpine:3.6

LABEL maintainer="dividehex@gmail.com"

ENV BUILD_PACKAGES bash wget curl tar make gcc alpine-sdk zlib zlib-dev readline 
ENV GEM_PACKAGES openssl openssl-dev libxml2-dev libxslt-dev

# Install apk packages
RUN apk update && \
    apk upgrade && \
    apk --no-cache add tzdata \
    $BUILD_PACKAGES $GEM_PACKAGES && \
    cp /usr/share/zoneinfo/US/Pacific /etc/localtime && \
    apk del tzdata

# build ruby
RUN wget -q -O ruby-1.8.7-p374.tar.gz https://cache.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p374.tar.gz && \
    tar -zxvf ruby-1.8.7-p374.tar.gz && \
    rm ruby-1.8.7-p374.tar.gz

WORKDIR ruby-1.8.7-p374
RUN ./configure --disable-install-doc
RUN make
RUN make install

# install rubygems
WORKDIR /
RUN wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz && \
    tar -zxvf rubygems-1.3.7.tgz && \
    rm rubygems-1.3.7.tgz
WORKDIR rubygems-1.3.7
RUN ruby setup.rb

# install gems
COPY root/ /
RUN gem install json_pure -v 1.6.3
RUN gem install puppet -v 3.7.0
RUN gem install puppet-lint -v 2.2.1

# Install python, pip, and pyyaml
RUN apk add --no-cache python
ADD https://bootstrap.pypa.io/get-pip.py /sbin/get-pip.py
RUN python /sbin/get-pip.py
RUN pip install pyyaml

# Clean up image
RUN apk del $BUILD_PACKAGES
RUN rm -rf /rubygems-1.3.7
RUN rm -rf /ruby-1.8.7-p374

VOLUME ["/puppet"]

WORKDIR /puppet

ENTRYPOINT exec setup/test_puppetcode.py

