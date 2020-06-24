
// From GHRU MLST Pipeline

def help_or_version(Map params, String version){
    // Show help message
    if (params.help){
        version_message(version)
        help_message()
        System.exit(0)
    }

    // Show version number
    if (params.version){
        version_message(version)
        System.exit(0)
    }
}

def check_mandatory_parameter(Map params, String parameter_name){
    if ( !params[parameter_name]){
        println "You must specifiy a " + parameter_name
        System.exit(1)
    } else {
        return params[parameter_name]
    }
}

def check_optional_parameters(Map params, List parameter_names){
    if (parameter_names.collect{name -> params[name]}.every{param_value -> param_value == false}){
        println "You must specifiy at least one of these options: " + parameter_names.join(", ")
        System.exit(1)
    }
}

def check_parameter_value(String parameter_name, String value, List value_options){
    if (value_options.any{ it == value }){
        return value
    } else {
        println "The value (" + value + ")  supplied for " + parameter_name + " is not valid. It must be one of " + value_options.join(", ")
        System.exit(1)
    }
}

def rename_params_keys(Map params_to_rename, Map old_and_new_names) {
    old_and_new_names.each{ old_name, new_name ->
        if (params_to_rename.containsKey(old_name))  {
            params_to_rename.put( new_name, params_to_rename.remove(old_name ) )
        }
    }
    return params_to_rename
}





========================================================================================
 nf-core/hlatyping Analysis Pipeline.
 #### Homepage / Documentation
 https://github.com/nf-core/hlatyping

 #### Authors
 Sven Fillinger sven1103 <sven.fillinger@qbic.uni-tuebingen.de> - https://github.com/sven1103>
 Christopher Mohr christopher-mohr <christopher.mohr@uni-tuebingen.de>
 Alexander Peltzer <alexander.peltzer@qbic.uni-tuebingen.de> - https://github.com/apeltzer
----------------------------------------------------------------------------------------
*/
def readParamsFromJsonSettings() {
    List paramsWithUsage
    try {
        paramsWithUsage = tryReadParamsFromJsonSettings()
    } catch (Exception e) {
        println "Could not read parameters settings from Json. $e"
        paramsWithUsage = Collections.emptyMap()
    }
    return paramsWithUsage
}

def tryReadParamsFromJsonSettings() throws Exception{
    def paramsContent = new File(config.params_description.path).text
    def paramsWithUsage = new groovy.json.JsonSlurper().parseText(paramsContent)
    return paramsWithUsage.get('parameters')
}

def formatParameterHelpData(param) {
	result = [ name: param.name, value: '', usage: param.usage ]
	// value descibes the expected input for the param
	result.value = (param.type == boolean.toString()) ? '' : param.choices ?: param.type ?: ''
	return result
}

String prettyFormatParamGroupWithPaddingAndIndent (List paramGroup,
                                                   String groupName,
                                                   Integer padding=2,
                                                   Integer indent=4) {
	    def maxParamNameLength = paramGroup.collect { it.name.size() }.max()
        def paramChoices = paramGroup.findAll{ it.choices }.collect { it.choices }
        def maxChoiceStringLength = paramChoices.collect { it.toString().size()}.max()
        def maxTypeLength = paramGroup.collect { (it.type as String).size() }.max()

        print maxChoiceStringLength

	    def paramsFormattedList = paramGroup.sort { it.name }.collect {
				Map param ->
					paramHelpData = formatParameterHelpData(param)
					sprintf("%${indent}s%-${maxParamNameLength + padding}s%-${maxChoiceStringLength + padding}s %s\n", "", "--${paramHelpData.name}","${paramHelpData.value}", "${paramHelpData.usage}")
			}
		return String.format("%s:\n%s", groupName.toUpperCase(), paramsFormattedList.join()).stripIndent()
}

// choose the indent depending on the spacing in this file
// in this example there are 4 spaces for every intendation so we choose 4
String prettyFormatParamsWithPaddingAndIndent(List paramsWithUsage, Integer padding=2, Integer indent=4) {

		def groupedParamsWithUsage = paramsWithUsage.groupBy { it.group }
		def formattedParamsGroups = groupedParamsWithUsage.collect {
			prettyFormatParamGroupWithPaddingAndIndent ( it.value, it.key, padding, indent)
		}
		return formattedParamsGroups.join('\n')
}

def helpMessage(paramsWithUsage) {
		def helpMessage = String.format(
		"""\
    =========================================
     nf-core/hlatyping v${workflow.manifest.version}
    =========================================
    Usage:

    The typical command for running the pipeline is as follows:
    nextflow run nf-core/hlatyping --reads '*_R{1,2}.fastq.gz' -profile docker

    Options:

    %s
    """.stripIndent(), prettyFormatParamsWithPaddingAndIndent(paramsWithUsage, 2, 4))
    log.info helpMessage
}

/*
 * SET UP CONFIGURATION VARIABLES
 */
def paramsWithUsage = readParamsFromJsonSettings()

// Show help emssage
if (params.help){
    helpMessage(paramsWithUsage)
    exit 0
}
