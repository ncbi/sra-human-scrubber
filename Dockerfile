ARG CI_REGISTRY
FROM ${CI_REGISTRY}/pd/do/p2/ci/ci/runtime/python:python-3.9-production AS base
COPY . /opt/scrubber/
WORKDIR /opt/scrubber
RUN /opt/scrubber/init_db.sh
ENV PATH="/usr/bin:/opt/scrubber/bin:/opt/scrubber/scripts:${PATH}"
RUN ldconfig
RUN ./scripts/scrub.sh -p 6 -t
