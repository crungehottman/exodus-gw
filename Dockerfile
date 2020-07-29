#FROM centos:8
FROM registry.access.redhat.com/ubi8/ubi-minimal

# Add sources
COPY . /usr/local/src/exodus-gw/

# Install extra requirements specific to container deployment
RUN \
    # Install shadow-utils for adduser functionality
    microdnf -y install shadow-utils \
    # Install extra commands needed for build
    && microdnf -y install python3 python3-devel gcc make \
    && cd /usr/local/src/exodus-gw \
    # Install application itself
    && pip3 install --require-hashes -r requirements.txt \
    && pip3 install --no-deps . \
    # Clean up unnecessary data
    && microdnf clean all && rm -rf /var/yum/cache && rm -rf /usr/local/src/exodus-gw

# Run as a non-root user
RUN adduser exodus-gw
USER exodus-gw

# Enable communication via port 8080
EXPOSE 8080

# Run the application
ENTRYPOINT ["uvicorn", "exodus_gw:application", "--host", "0.0.0.0", "--port", "8080"]
