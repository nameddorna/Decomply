# Use OpenJDK 17 as the base image (CFR supports Java 8+)
FROM eclipse-temurin:17-jre-alpine

# Install wget if needed (slim image might not have it)
RUN apk add --no-cache wget

# Download the latest CFR JAR (replace with specific version if needed, e.g., 0.152)
RUN wget https://github.com/leibnitz27/cfr/releases/latest/download/cfr-0.152.jar -O /opt/cfr.jar

# Set working directory
WORKDIR /app

# Create entrypoint script to run CFR
RUN echo '#!/bin/sh' > /usr/local/bin/cfr && \
    echo 'java -jar /opt/cfr.jar "$@"' >> /usr/local/bin/cfr && \
    chmod +x /usr/local/bin/cfr

# Default command
ENTRYPOINT ["cfr"]

