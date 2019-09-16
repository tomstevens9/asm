FROM alpine

# install as and ld
RUN apk add build-base  

# copy scripts directory and add it to the path
COPY scripts /scripts
ENV PATH="/scripts:${PATH}"

# set workdir to directory used for mouting volume
WORKDIR /app
