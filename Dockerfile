FROM google/dart:1.24.3

WORKDIR /build/
ADD pubspec.yaml /build
RUN dart pub get
ARG BUILD_ARTIFACTS_AUDIT=/build/pubspec.lock
FROM scratch

