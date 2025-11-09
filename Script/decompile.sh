#!/bin/bash

function decompile_script() {

	export JAR_NAME=$(basename "$JAR_PATH" | sed -E 's/\.(jar|war)$//')	
	export OUTPUT_DIR="/opt/analysis-result/${JAR_NAME}_analysis"
	mkdir -p "$OUTPUT_DIR"

	echo -e "\nChoose one of decompilers below:   \n1. jd-cli   \n2. cfr   \n3.Skip (already decompiled)"
	read  -p "" DEC_TOOL


	if [ "$DEC_TOOL" == "1" ]; then


		DEC_TOOL_NAME="jd"
		docker run -it --rm -v "$(pwd)":/workdir -v "$(dirname "$JAR_PATH")":/jar-path -v "/opt/analysis-result":/opt/analysis-result -w /workdir  kwart/jd-cli "/jar-path/$(basename "$JAR_PATH")" -od "$OUTPUT_DIR/decompiled-by-jd"



		# Was Decompilation successful?
		if [ $? -ne 0 ]; then
			echo "Error: Decompilation failed."
			exit 1
		fi


	elif [ "$DEC_TOOL" == "2" ]; then
		DEC_TOOL_NAME="cfr"
		echo -e "\ndecompiling with cfr..."
		
		$USER_USED_TO_RUN_DOCKER run --rm -v "$(pwd)":/workdir -v "$(dirname "$JAR_PATH")":/jar-path -v "/opt/analysis-result":/opt/analysis-result -w /workdir cfr-decompiler "/jar-path/$(basename "$JAR_PATH")" --outputdir "$OUTPUT_DIR/decompiled-by-cfr" --trackbytecodeloc true --showversion false  --removeboilerplate false  --hideutf false --silent false --recover true  --sugarenums false --arrayiter false


	elif [[ "$DEC_TOOL" == "3" && ! -d "$OUTPUT_DIR/decompiled-by-jd" && ! -d "$OUTPUT_DIR/decompiled-by-cfr" ]]; then
		echo -e "\nNo decompiled code found!"
  		exit 1

	elif [[ "$DEC_TOOL" == "3" && -d "$OUTPUT_DIR/decompiled-by-jd" && -d "$OUTPUT_DIR/decompiled-by-cfr" ]]; then
   		echo -e "\nMore than one decompilation result exists. Pick one: 1.jd or 2.cfr: "
		read -p "" DEC_TOOL
		if [[ "$DEC_TOOL" == "1" ]]; then
		        DEC_TOOL_NAME="jd"
		elif [[ "$DEC_TOOL" == "2" ]]; then
		        DEC_TOOL_NAME="cfr"
		else
		        echo "Invalid choice"
		        exit 1
		fi

	elif [[ "$DEC_TOOL" == "3" && ( -d "$OUTPUT_DIR/decompiled-by-jd" || -d "$OUTPUT_DIR/decompiled-by-cfr" ) ]]; then
		
		echo -e "\nSkipping decompiling step ...."
		if [[ -d "$OUTPUT_DIR/decompiled-by-jd" ]]; then DEC_TOOL_NAME="jd"
		elif [[ -d "$OUTPUT_DIR/decompiled-by-cfr" ]]; then DEC_TOOL_NAME="cfr"
		fi

	else
		echo -e "\ninvalid choice!!"
		exit 1

	fi


}
