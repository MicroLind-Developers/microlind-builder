# This Dockerfile builds an image to be used for x86 targeted host builds only
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/Stockholm

# Basic build packages, for building and analysing
RUN apt-get update && \
    apt-get install -y apt-utils \
    tzdata \
    build-essential \
    cmake \
    gdb \
    git \
    pkg-config \
    gcovr \
    lcov \
    nano \
    unzip \
    zip \
    wget \
    curl \
    patch \
    libsasl2-2 \
    libc6-i386 \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

RUN echo ". /etc/bash_completion" >> /etc/bash.bashrc

# Component dependencies from APT, generators, testing, and runtime
RUN apt-get update && \
    apt-get install -y \
    python3-venv \
    texlive-latex-base \
    python3-pip \
    clang-format \
    clang-tidy \
    cppcheck \
    libgtest-dev \
    libgmock-dev \
    libpthread-stubs0-dev \
    libnewlib-arm-none-eabi \
    && rm -rf /var/lib/apt/lists/*

# RUN pip3 install --upgrade pip --break-system-packages

# RUN pip3 install --break-system-packages --no-cache-dir \
#    setuptools-rust \
#    jsonschema

#RUN pip3 install --break-system-packages --no-cache-dir \
#    Fabric3==1.14.post1 \
#    ecdsa==0.13.3 \
#    prettyprint==0.1.5 \
#    pyparsing==2.2.0 

# Install lwtool
ARG COMPILER_NAME=lwtools
ARG COMPILER_VERSION=4.22
ARG COMPILER_PACKAGE_FILE=${COMPILER_NAME}-${COMPILER_VERSION}
RUN mkdir lwtool
ADD http://www.lwtools.ca/releases/lwtools/${COMPILER_PACKAGE_FILE}.tar.gz .
RUN tar xf ${COMPILER_PACKAGE_FILE}.tar.gz -C lwtool/
RUN rm ${COMPILER_PACKAGE_FILE}.tar.gz
RUN make -C ./lwtool/${COMPILER_PACKAGE_FILE}
RUN make -C ./lwtool/${COMPILER_PACKAGE_FILE} install
RUN rm -rf lwtool

RUN useradd -ms /bin/bash developer

# Install
ADD http://sun.hasenbraten.de/vasm/release/vasm.tar.gz .
RUN tar xf vasm.tar.gz 
RUN make -C vasm CPU=6809 SYNTAX=std
RUN cp vasm/vasm6809_std /usr/local/bin

ADD http://sun.hasenbraten.de/vlink/release/vlink.tar.gz .
RUN tar xf vlink.tar.gz 
RUN make -C
RUN cp vlink/vlink /usr/local/bin

RUN wget http://ibaug.de/vbcc/vbcc.tar.gz -P /home/developer

RUN chown developer:developer /home/developer/*.tar.gz

USER developer
WORKDIR /home/developer

RUN tar xf vbcc.tar.gz

RUN rm *.tar.gz


RUN make -C vlink


# RUN rm vasm.tar.gz
# RUN make -C ./${COMPILER_PACKAGE_FILE}/${COMPILER_PACKAGE_FILE}
# RUN make -C ./${COMPILER_PACKAGE_FILE}/${COMPILER_PACKAGE_FILE} install
# RUN rm -rf ${COMPILER_PACKAGE_FILE}

# Install vlink
# ARG COMPILER_PACKAGE_FILE=vlink
# RUN mkdir ${COMPILER_PACKAGE_FILE}

# RUN mv vlink.tar.gz /home/developer

# RUN rm vlink.tar.gz
# RUN make -C ./${COMPILER_PACKAGE_FILE}/${COMPILER_PACKAGE_FILE}
# RUN make -C ./${COMPILER_PACKAGE_FILE}/${COMPILER_PACKAGE_FILE} install
# RUN rm -rf ${COMPILER_PACKAGE_FILE}

# Install vbcc
ARG COMPILER_PACKAGE_FILE=vbcc
# RUN mkdir ${COMPILER_PACKAGE_FILE}

# RUN tar xf vbcc.tar.gz -C /home/developer/vbcc/
# RUN rm vbcc.tar.gz
# RUN make -C ./${COMPILER_PACKAGE_FILE}/${COMPILER_PACKAGE_FILE}
# RUN make -C ./${COMPILER_PACKAGE_FILE}/${COMPILER_PACKAGE_FILE} install
# RUN rm -rf ${COMPILER_PACKAGE_FILE}


# http://www.ibaug.de/vbcc/vbcc.tar.gz
# http://sun.hasenbraten.de/vasm/release/vasm.tar.gz
# http://sun.hasenbraten.de/vlink/release/vlink.tar.gz

# ARG COMPILER_PACKAGE_FILE=asl-current.tar.bz2
# RUN mkdir assembler
# ADD http://john.ccac.rwth-aachen.de:8000/ftp/as/source/c_version/${COMPILER_PACKAGE_FILE} .
# RUN tar xf ${COMPILER_PACKAGE_FILE} -C ./assembler
# RUN cp ./assembler/asl-current/Makefile.def-samples/Makefile.def-x86_64-unknown-linux ./assembler/asl-current/Makefile.def
# RUN make -C ./assembler/asl-current
# RUN make -C ./assembler/asl-current install

ENTRYPOINT ["tail", "-f", "/dev/null"]