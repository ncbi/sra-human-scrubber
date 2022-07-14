FROM google/cloud-sdk:latest as build
COPY . /opt/scrubber/
WORKDIR /opt/scrubber/data
RUN /opt/scrubber/init_db.sh
ENV PATH="/usr/bin:/opt/scrubber/bin:/opt/scrubber/scripts:${PATH}"
WORKDIR /opt/scrubber
RUN ldconfig

