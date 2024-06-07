
#!/bin/bash

# Directorio de salida para los archivos XML exportados
OUTPUT_DIR="jenkins_jobs7"
mkdir -p $OUTPUT_DIR
set +e

list_jobs() {

    local var_path="$1"
	echo "current path $var_path"
    # Llamar a jenkins-cli para listar los trabajos y guardar la salida en jobs.txt
	local jobs_list_before
    local jobs_list

    jobs_list=$(java -jar jenkins-cli.jar -s https://jenkins-sistemas.apps.ocp-icn-pub-01.msc.es/ -auth usr-a.gcastrod:san900900T list-jobs "$var_path" 2>&1)
    local result=$?

    # Comprobar si hubo un error

	echo "JOBLIST: $jobs_list"
	# Directorio de salida

	if [ -n "$var_path" ]; then
		export_jobs "$var_path"
	fi

	# Crear el directorio de salida si no existe
	if [ $result -ne 0 ]; then
		echo "Error listing jobs for path '$var_path': $jobs_list"
		return 1

	fi	
	

	job_array=[]

	printf "Longitud de la variable jobs_list: %s\n" "${#jobs_list}"
	#mapfile -t job_array <<< "$jobs_list"
	IFS=$'\n' read -r -d '' -a job_array <<< "$jobs_list"
	echo "Número de trabajos/carpeta encontrados: ${#job_array[@]}"
	for job_name in "${job_array[@]}"; do
		echo "Procesando trabajo: $job_name"
		# Aquí puedes llamar a export_jobs o realizar otra acción con el trabajo
		if [ "$job_name" != "" ]; then
	
			list_jobs "${var_path}/${job_name}"				
			
		else
			list_jobs $job_name			
		fi
	done


}

export_jobs() {
    local job_name="$1"
	local job_file="$1"
	

    # Exportar el trabajo actual a un archivo XML y capturar errores

    # Desactivar modo de salida en error
 
    # Exportar el trabajo actual a un archivo XML y capturar errores
	echo "jobname: ${job_name}"
	mkdir -p "$OUTPUT_DIR/$job_name"
    java -jar jenkins-cli.jar -s https://jenkins-sistemas.apps.ocp-icn-pub-01.msc.es/ -auth usr-a.gcastrod:san900900T get-job "${job_name}" > "$OUTPUT_DIR/$job_file/output.xml" 2>/dev/null
    result=$?
    # Reactivar modo de salida en error
	
	
	#set -e
    if [ $? -eq 0 ]; then
        echo "Exported job: $job_name"
    else
        echo "Failed to export job: $job_name" >&2
    fi
}

list_jobs
echo "Todos los trabajos han sido exportados en el directorio '$OUTPUT_DIR'"
