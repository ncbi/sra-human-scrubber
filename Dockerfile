FROM google/cloud-sdk:latest as build
COPY . /opt/scrubber/
ENV PATH="/usr/bin:/opt/scrubber/bin:/opt/scrubber/scripts;${PATH}"
WORKDIR /opt/scrubber
RUN ldconfig

