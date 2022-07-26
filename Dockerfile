FROM google/cloud-sdk:latest as build
COPY . /opt/scrubber/
WORKDIR /opt/scrubber
RUN /opt/scrubber/init_db.sh
RUN ls .
RUN pwd
RUN ls -l /opt/scrubber/data/*
ENV PATH="/usr/bin:/opt/scrubber/bin:/opt/scrubber/scripts:${PATH}"
RUN ldconfig
RUN apt-get update && apt-get install -qqy python3-pip
RUN ./scripts/scrub.sh test
