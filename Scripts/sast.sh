#!/bin/bash

function sast_script() {
    printf "\n%s\n\n" "================================================================ SAST ================================================================"

    if [[ -z "$DEC_TOOL_NAME" && ! -d "$OUTPUT_DIR/decompiled-by-jd" && ! -d "$OUTPUT_DIR/decompiled-by-cfr" ]]; then
    	echo -e "\n ❌ No decompiled code found to scan!"
	return 1
    fi

   # ==================== SEMGREP ====================
    echo -e "\n\033[1;97m==== SEMGREP ====\033[0m"

    local DECOMPILED_PATH="/src/decompiled-by-$DEC_TOOL_NAME"
    local SEMGREP_OUTPUT="$OUTPUT_DIR/semgrep_output.json"
    

    if [[ "$CUSTOM_RULES" =~ ^[Yy]$ ]]; then
        read -p "   Enter full path to rule directory: " RULE_PATH

        if [[ ! -d "$RULE_PATH" ]]; then
            echo -e "\n⚠️ Rule directory not found: $RULE_PATH"
            echo "   Using default rules instead..."
            CUSTOM_RULES="n"
        fi
    fi

    if [[ "$CUSTOM_RULES" =~ ^[Yy]$ ]]; then
        echo -e "\n🔍 Running Semgrep with custom rules...\n"
        $USER_USED_TO_RUN_DOCKER run --rm \
            -v "$OUTPUT_DIR:/src" \
            -v "$RULE_PATH:/rules" \
            returntocorp/semgrep \
            semgrep --config /rules "$DECOMPILED_PATH" \
            --max-target-bytes=0 --json -o /src/semgrep_output.json
    else
        echo -e "\n🔍 Running Semgrep with default rules...\n"
        $USER_USED_TO_RUN_DOCKER run --rm \
            -v "$OUTPUT_DIR:/src" \
            returntocorp/semgrep \
            semgrep "$DECOMPILED_PATH" \
            --max-target-bytes=0 --json -o /src/semgrep_output.json
    fi

    local semgrep_exit=$?

    # ==================== OPENGREP ====================
    echo -e "\n\033[1;97m=== OPENGREP ===\033[0m"

    local opengrep_bin="./opengrep_manylinux_x86"

    if [[ -x "$opengrep_bin" ]]; then
        "$opengrep_bin" scan \
            --sarif-output="$OUTPUT_DIR/opengrep_report.json" \
            "$OUTPUT_DIR/decompiled-by-$DEC_TOOL_NAME" \
            --config "$(pwd)/rules" 2>&1 | awk '{print} /Code Findings/ {exit}'
    else
        echo -e "\n⚠️  OpenGrep binary not found at: $opengrep_bin"
        echo -e "⚠️  Skipping OpenGrep scan..."
    fi


    echo -e "\n✅ Analysis completed!"
    echo -e "\n📁 Results directory: $OUTPUT_DIR"

}



}

