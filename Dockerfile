# ================================
# Build image
# ================================
FROM swift:6.1-noble AS build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Copy entire repo into container
COPY . .

RUN mkdir /staging

# Build the application, with optimizations, with static linking, and using jemalloc
# N.B.: The static version of jemalloc is incompatible with the static Swift runtime.
RUN --mount=type=cache,target=/build/.build \
    swift build -c release \
        --product GrowBitAppServer \
        --static-swift-stdlib \
        -Xlinker -ljemalloc && \
    # Copy main executable to staging area
    cp "$(swift build -c release --show-bin-path)/GrowBitAppServer" /staging && \
    # Copy resources bundled by SPM to staging area
    find -L "$(swift build -c release --show-bin-path)" -regex '.*\.resources$' -exec cp -Ra {} /staging \;

# Switch to the staging area
WORKDIR /staging

# Copy static swift backtracer binary to staging area
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

# Copy any resources from the public directory and views directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; }; \
    [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; }; \
    # Make it executable
    chmod +x GrowBitAppServer; \
    # Create the vapor user and group with /vapor home directory
    useradd --user-group --create-home --system --skel /dev/null --home-dir /vapor vapor

# Switch to the new home directory
WORKDIR /vapor

# Copy built executable and any staged resources from staging area
RUN cp --archive /staging/* ./

# Ensure all files are readable by vapor user
RUN chown -R vapor:vapor /vapor

USER vapor:vapor

# Start the Vapor service when the image is run, default to listening on 8080 in production environment
ENTRYPOINT ["./GrowBitAppServer"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]