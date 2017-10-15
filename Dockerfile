# Start with Ubuntu base image
FROM ubuntu

MAINTAINER Guy <guyht@me.com>

# Base folder
RUN mkdir dcss
WORKDIR dcss

# Install dependencies
RUN apt-get update -y
RUN apt-get install -y git curl build-essential libncursesw5-dev bison flex liblua5.1-0-dev libsqlite3-dev libz-dev pkg-config
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs

# Checkout crawl
RUN git clone https://github.com/crawl/crawl.git
WORKDIR /dcss/crawl
RUN git checkout 0.20.1
RUN git submodule init && git submodule update

# Uberhack
# Because monster-main does not recognise nodejs as a tty, it wont include the
# right color codes.  Small hack to force tty type responses which are
# correctly parsed by node-tty
WORKDIR /dcss/crawl/crawl-ref/source/util/monster
RUN sed -i 's/isatty(1)/true/' monster-main.cc

WORKDIR /dcss/crawl

# Make monster
RUN make monster

# Base dir
WORKDIR /dcss

# Checkout lookup code
ADD . /dcss/lookup
WORKDIR /dcss/lookup

# Symlink monster-trunk
RUN ln -s ../crawl/crawl-ref/source/util/monster/monster monster-stable

# Install dependencies
RUN npm install -g gulp
RUN npm install
RUN gulp coffee

# Expose 8080
EXPOSE 8080

# Setup entrypoint
CMD ["node", "lib/index"]

