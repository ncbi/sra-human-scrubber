FROM google/cloud-sdk:latest as build
COPY . /opt/scrubber/
WORKDIR /opt/scrubber
RUN /opt/scrubber/init_db.sh
ENV PATH="/usr/bin:/opt/scrubber/bin:/opt/scrubber/scripts:${PATH}"
RUN ldconfig

