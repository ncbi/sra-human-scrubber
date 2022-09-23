FROM ${CI_REGISTRY}/pd/do/ci/public-docker-images/centos:7.9.2009 AS base
COPY . /opt/scrubber/
WORKDIR /opt/scrubber
RUN /opt/scrubber/init_db.sh
ENV PATH="/usr/bin:/opt/scrubber/bin:/opt/scrubber/scripts:${PATH}"
RUN ldconfig
RUN ./scripts/scrub.sh -p 6 -t
