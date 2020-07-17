import groovy.json.JsonSlurper
import groovy.json.JsonOutput


def readJson(String fname){

    def jsonSlurper = new JsonSlurper()
    String string_JSON = new File(fname).text
    json = jsonSlurper.parseText(string_JSON) 
    return json
 


}


def combine_params(List user_steps, Map params){


   
    def all_json = readJson("lib/params/global_params.json")
    entry_fname = "lib/params/entry_params_step" + user_steps[0] + ".json"
    def entry_json = readJson(entry_fname)
    all_json = all_json + entry_json
   
    if ( 3 in user_steps || 5 in user_steps ){

         if (params.generate_labels == true ){
             gs_json = readJson("lib/params/default_params_gen_labels.json")
         }
         if (params.generate_labels == false){
             gs_json = readJson("lib/params/default_params_old_labels.json")
         }
      all_json = all_json + gs_json
    }


    for (String step : user_steps) {
        System.out.println(step)
        fname = "lib/params/default_params_step" + step + ".json"
        def step_json = readJson(fname) 
        all_json = all_json + step_json
        println all_json 
    }

    if ( params.output_json == true ) {
       def json = JsonOutput.toJson(all_json)
       def pretty_json = JsonOutput.prettyPrint(json)
       new File("output.json").write(pretty_json)
       exit 0
    } 
 
    return(all_json)


}


// CDM
def validate_params(Map params, List paramsWithUsage){

    // Combine user params with parameter usage definitions
    valuesWithUsage = get_usage(params, paramsWithUsage)
    
    errors = []
    

   
    // Check that usage is correct 
    valuesWithUsage.each { p ->
  
        choices = p.find{ it.key == "choices" }?.value  
        input_value = p.find{ it.key == "input_value" }?.value 
        name = p.find{ it.key == "name" }?.value 
        type = p.find{ it.key == "type" }?.value 

        // check choices 
        if(choices){
            error = check_parameter_choices(name, input_value, choices)
            if (error != null){errors += error}
        }

        // check typing
        if(type){
            error = check_parameter_typing(name, input_value, type)
            if (error != null){errors += error}
        } 

    }    
    return errors
}

// CDM
def get_usage(Map params, List paramsWithUsage){

    // Function from https://stackoverflow.com/a/49674409
    def appliedMap = {property, idValue-> 
        return paramsWithUsage.find{it[property] == idValue}
    }   

    def valuesWithUsage = []
   
    // Match user params with parameter definitions
    params.each { first ->
       def param_usage = appliedMap('name', first.key) ?: ["none":"none"] // change this

       // Combine param definition with user input value
       def usage = param_usage + ['input_value':first.value]

       valuesWithUsage += usage
        
    } 

    return valuesWithUsage
}


// CDM
def check_parameter_typing(String parameter_name, value, type){
    if ( ( value instanceof String && type != "string"   ) ||
         ( value instanceof Integer && type != "integer" ) ||
         ( value instanceof Boolean && type != "boolean" ) ||
         ( value instanceof List && type != "list"       ) ){

        return "The value (" + value + ")  supplied for " + parameter_name + " is not valid. It must be of type " + type
    }
}

// Modified from MLST
def check_parameter_choices(String parameter_name, value, List value_options){
    if ( ! value_options.any{ it == value }){
        return "The value (" + value + ")  supplied for " + parameter_name + " is not valid. It must be one of " + value_options.join(", ")
    }
}


// Unused at the moment from MLST
def check_optional_parameters(Map params, List parameter_names){
    if (parameter_names.collect{name -> params[name]}.every{param_value -> param_value == false}){
        println "You must specify at least one of these options: " + parameter_names.join(", ")
        System.exit(1)
    }
}

// From GHRU MLST Pipeline
def check_mandatory_parameter(Map params, String parameter_name){
    if ( !params[parameter_name]){
        println "You must specify a " + parameter_name
        System.exit(1)
    } else {
        return params[parameter_name]
    }
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

// Modified by CDM to not access config (Deprecated)
def readParamsFromJsonSettings(Map params, Map relevantParams) {
    List paramsWithUsage
    try {
        paramsWithUsage = tryReadParamsFromJsonSettings(params['params_description'])
    } catch (Exception e) {
        println "Could not read parameters settings from Json. $e"
        paramsWithUsage = Collections.emptyMap()
    }

    // This is where I'd filter params to only those needed for the steps chosen

    paramsWithUsage = paramsWithUsage.findAll { it.name in relevantParams.keySet() }

    return paramsWithUsage

}

// Modified by CDM to not access config (Deprecated)
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
        print "bet this is "
        print maxChoiceStringLength

        // Added because if a group has no parameters with choices, erorr out 
        if ( maxChoiceStringLength == null){ 
          maxChoiceStringLength = 0
        }

// Added one point of padding
	    def paramsFormattedList = paramGroup.sort { it.name }.collect {
				Map param ->
					paramHelpData = formatParameterHelpData(param)
					sprintf("%${indent}s%-${maxParamNameLength + padding + 1 }s%-${maxChoiceStringLength + padding}s %s\n", "", "--${paramHelpData.name}","${paramHelpData.value}", "${paramHelpData.usage}")
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

