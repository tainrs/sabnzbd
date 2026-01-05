# Dockerfile for SABnzbd on AMD64 architecture

# Define build arguments
ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_AMD64

# Use upstream base image
FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_AMD64}

# Expose SABnzbd port
EXPOSE 8080

# Set environment variables
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="8080/tcp,8080/udp"

# Install system dependencies
# Note: Using Alpine's par2cmdline instead of compiling par2cmdline-turbo for simplicity
# Using 7zip for RAR extraction (unrar not available in Alpine)
RUN apk add --no-cache \
    python3 \
    py3-pip \
    7zip \
    par2cmdline \
    ca-certificates \
    openssl

# Set version build arguments
ARG VERSION
ARG PAR2TURBO_VERSION
ARG PACKAGE_VERSION=${VERSION}

# Download SABnzbd source and install Python dependencies
# SABnzbd requires Python 3.9+ and pip installation from requirements.txt
RUN set -e ;\
    mkdir -p "${APP_DIR}/bin" ;\
    curl -fsSL "https://github.com/sabnzbd/sabnzbd/releases/download/${VERSION}/SABnzbd-${VERSION}-src.tar.gz" | tar xzf - -C "${APP_DIR}/bin" --strip-components=1 ;\
    python3 -m pip install --no-cache-dir --break-system-packages -r "${APP_DIR}/bin/requirements.txt"

# Create package info file
RUN echo -e "PackageVersion=${PACKAGE_VERSION}\nPackageAuthor=[tainrs](https://github.com/tainrs)\nUpdateMethod=Docker\nBranch=stable" > "${APP_DIR}/package_info"

# Set permissions
RUN set -e ;\
    chmod -R u=rwX,go=rX "${APP_DIR}" ;\
    chmod +x "${APP_DIR}/bin/SABnzbd.py"

# Copy runtime scripts
COPY root/ /
