# Start with Ubuntu base image
FROM ubuntu

MAINTAINER Guy <guyht@me.com>
RUN ls -a
# Base folder
RUN mkdir dcss
WORKDIR dcss

# Install dependencies
RUN apt-get update -y
RUN apt-get install -y git curl build-essential libncursesw5-dev bison flex liblua5.1-0-dev libsqlite3-dev libz-dev pkg-config libsdl2-image-dev libsdl2-mixer-dev libsdl2-dev libfreetype6-dev libpng-dev ttf-dejavu-core

# Checkout monster-trunk
RUN git clone https://github.com/guyht/monster-trunk.git
WORKDIR monster-trunk
RUN git checkout 6937dfd0

# Checkout crawl
RUN git clone https://gitorious.org/crawl/crawl.git crawl-ref
WORKDIR crawl-ref
RUN git submodule init && git submodule update

WORKDIR /dcss/monster-trunk

# Make monster-trunk
RUN make

# Base dir
WORKDIR ../

# Install nodejs
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs

# Checkout lookup code
ADD . /dcss/lookup
WORKDIR ./lookup

# Symlink monster-trunk
RUN ln -s ../monster-trunk/monster-stable monster-trunk

# Install dependencies
RUN npm install -g gulp
RUN npm install
RUN gulp coffee

# Expose 8080
EXPOSE 8080

# Setup entrypoint
CMD ["node", "lib/index"]
