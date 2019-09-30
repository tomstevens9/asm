FROM fedora

# install as and ld
RUN dnf groupinstall -y 'Development Tools'
RUN dnf install -y gdb

# copy scripts directory and add it to the path
COPY scripts /scripts
ENV PATH="/scripts:${PATH}"

# set workdir to directory used for mouting volume
WORKDIR /app
