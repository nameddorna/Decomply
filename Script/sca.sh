#!/bin/bash

function sca_script() {
	printf "\n%s\n\n" "================================================================ SCA (Software Composition Analysis) ==============================================================="

    VOLUME_NAME="${VOLUME_NAME:-trivy_database}"
    export TRIVY_REPORT="$OUTPUT_DIR/trivy_report"
    JAR_DIR="$(dirname "$JAR_PATH")"
    JAR_NAME="$(basename "$JAR_PATH")"

    COMMON_DOCKER_OPTS="run --rm -v $VOLUME_NAME:/root/.cache/trivy -v /opt/analysis-result:/opt/analysis-result -v $(pwd):/workdir -v $JAR_DIR:/jar-path -w /workdir aquasec/trivy:latest"
    TRIVY_OPTS="--timeout 60m --skip-db-update --skip-java-db-update --skip-check-update --scanners vuln"


    echo "Choose output format for trivy:"
    echo "1. html"
    echo "2. json"

    read -p "Enter your choice (1, 2): " OUTPUT_FORMAT

    if [[ "$OUTPUT_FORMAT" == "1" ]]; then
        echo "Scanning JAR file with Trivy (HTML)..."
        $USER_USED_TO_RUN_DOCKER $COMMON_DOCKER_OPTS -f template -t @/workdir/html-template-trivy.tpl --output $TRIVY_REPORT.html -d rootfs $TRIVY_OPTS /jar-path/$JAR_NAME

    elif [[ "$OUTPUT_FORMAT" == "2" ]]; then
        echo "Scanning JAR file with Trivy (JSON)..."
        $USER_USED_TO_RUN_DOCKER $COMMON_DOCKER_OPTS --format json --output $TRIVY_REPORT.json -d rootfs $TRIVY_OPTS /jar-path/$JAR_NAME

    else
        echo "Invalid choice. Skipping SCA."
    fi
}

