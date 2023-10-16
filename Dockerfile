ARG BUILDER_IMAGE=swift:5.9-jammy
ARG RUNTIME_IMAGE=swift:5.9-jammy-slim

# Builder image
FROM ${BUILDER_IMAGE} AS builder
RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libncurses5-dev \
    libsqlite3-dev \
 && rm -r /var/lib/apt/lists/*
WORKDIR /workdir/
COPY Sourcery Sourcery/
COPY SourceryExecutable SourceryExecutable/
COPY SourceryFramework SourceryFramework/
COPY SourceryJS SourceryJS/
COPY SourceryRuntime SourceryRuntime/
COPY SourceryStencil SourceryStencil/
COPY SourcerySwift SourcerySwift/
COPY SourceryTests SourceryTests/
COPY SourceryUtils SourceryUtils/
COPY Plugins Plugins/
COPY Templates Templates/
COPY Tests Tests/
COPY Package.* ./

RUN swift package update
ARG SWIFT_FLAGS="-c release"
RUN swift build $SWIFT_FLAGS --product sourcery
RUN mv `swift build $SWIFT_FLAGS --show-bin-path`/sourcery /usr/bin
RUN sourcery --version

# Runtime image
FROM ${RUNTIME_IMAGE}
LABEL org.opencontainers.image.source https://github.com/krzysztofzablocki/Sourcery
RUN apt-get update && apt-get install -y \
    libcurl4 \
    libsqlite3-0 \
    libxml2 \
 && rm -r /var/lib/apt/lists/*
COPY --from=builder /usr/bin/sourcery /usr/bin

RUN sourcery --version

CMD ["sourcery"]
