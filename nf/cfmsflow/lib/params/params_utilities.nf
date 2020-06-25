// From GHRU MLST Pipeline
def check_mandatory_parameter(Map params, String parameter_name){
    if ( !params[parameter_name]){
        println "You must specify a " + parameter_name
        System.exit(1)
    } else {
        return params[parameter_name]
    }
}

def validate_params(Map params, List paramsWithUsage){
    //println params
    //println paramsWithUsage

    // https://stackoverflow.com/a/49674409
    def appliedMap = {property, idValue-> 
        return paramsWithUsage.find{it[property] == idValue}
    }   

    def valuesWithUsage = []
   
    // Find each param in the paramsWithUsage Json
    def usage = params.each { first ->
       def p = appliedMap('name', first.key) ?: ["none":"none"]

       // Combine input param (first.value) with usage values
       // Making a new list of lists
       def p2 = [
           'name':first.key,
           'input_value':first.value,
           'label': p.find{ it.key == "label" }?.value ?: "none",
           'choices': p.find{ it.key == "choices" }?.value ?: "none",
       'type': p.find{ it.key == "type" }?.value ?: "none"
       ]
       valuesWithUsage += p2
        
    } 

    return valuesWithUsage
}


// Do this one for the inputs!
def check_optional_parameters(Map params, List parameter_names){
    if (parameter_names.collect{name -> params[name]}.every{param_value -> param_value == false}){
        println "You must specify at least one of these options: " + parameter_names.join(", ")
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



/*
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


def readParamsFromJsonSettings(Map params) {
    List paramsWithUsage
    try {
        paramsWithUsage = tryReadParamsFromJsonSettings(params['params_description'])
    } catch (Exception e) {
        println "Could not read parameters settings from Json. $e"
        paramsWithUsage = Collections.emptyMap()
    }
    return paramsWithUsage


}
def tryReadParamsFromJsonSettings(String params_description) throws Exception{
    def paramsContent = new File(params_description).text
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
     cfmsflow v${workflow.manifest.version}
    =========================================
    Usage:

    The typical command for running the pipeline is as follows:
    nextflow main.nf -params-file user_params_template.json 

    Options:

    %s
    """.stripIndent(), prettyFormatParamsWithPaddingAndIndent(paramsWithUsage, 2, 4))
    log.info helpMessage
}

