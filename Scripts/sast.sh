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






}

