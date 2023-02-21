################# BASE IMAGE ######################
FROM --platform=linux/amd64 ubuntu:20.04 as build

################## METADATA ######################
LABEL base_image="tool:VERSION"
LABEL version="1.0.0"
LABEL software="ea-utils"
LABEL software.version="1.04.807"
LABEL about.summary="Command-line tools for processing biological sequencing data. Barcode demultiplexing, adapter trimming, etc."
LABEL about.home="https://expressionanalysis.github.io/ea-utils/"
LABEL about.documentation="https://github.com/ExpressionAnalysis/ea-utils/tree/master"
LABEL about.license_file=""
LABEL about.license=""

################## MAINTAINER ######################
MAINTAINER Matthew Galbraith <matthew.galbraith@cuanschutz.edu>

################## INSTALLATION ######################
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES tar wget ca-certificates libgsl0-dev zlib1g-dev build-essential

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and extract ea-utils
# export PERL5LIB=`pwd` prevents errors related to perl test files see https://github.com/ExpressionAnalysis/ea-utils/issues/49
RUN wget https://github.com/ExpressionAnalysis/ea-utils/archive/refs/tags/1.04.807.tar.gz && \
	tar -xzvf 1.04.807.tar.gz && \
    cd ea-utils-1.04.807/clipper/ && \
    export PERL5LIB=`pwd` && \
    # make PREFIX=/eautils/ && \
    make && \
    BINDIR=/usr/bin/eautils make install
    # default install copies binaries to /usr/bin/



################## 2ND STAGE ######################
FROM --platform=linux/amd64 ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
# ENV PACKAGES 

# RUN apt-get update && \
#     apt-get install -y --no-install-recommends ${PACKAGES} && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build usr/bin/eautils/* /usr/bin/