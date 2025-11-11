#!/bin/bash
function secret_script() {


    printf "\n%s\n\n" "================================================================ Secret Scanning ================================================================"

#    read -p " Do you want to perform Secret Scanning? (y/n):" RUN_SS
 #   if [[ "$RUN_SS" =~ ^[Yy]$ ]]; then

        # scan .java files with trufflehog
        echo "🔍Scanning decompiled Java files with trufflehog ..."
        export TRUFFLEHOG_REPORT="$OUTPUT_DIR/trufflehog_report.json"
	$USER_USED_TO_RUN_DOCKER run --rm -v "$OUTPUT_DIR:/src" trufflesecurity/trufflehog:latest filesystem "/src/decompiled-by-$DEC_TOOL_NAME" --json >"$TRUFFLEHOG_REPORT"


  #  else
  #     echo "Skipping Secret Scanning stage"
  #  fi
}
