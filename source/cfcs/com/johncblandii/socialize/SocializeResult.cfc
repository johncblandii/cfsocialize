<!---
	Name         : SocializeResult
	Author       : John C. Bland II
	Created      : March 3, 2010
	Last Updated : 3/3/2010
	Purpose	   : A result model object containing the basics of a Socialize request
	
	LICENSE 
	Copyright 2010 John C. Bland II
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	   http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
--->
<cfcomponent displayname="Gigya Socialize Result" hint="Result from a Socialize REST API call" output="false">
	<!--- PROPERTIES --->
	<cfset this.statusCode = "" />
	<cfset this.statusReason = "" />
	<cfset this.callId = "" />
	<cfset this.errorCode = "" />
	<cfset this.errorMessage = "" />
	
	<cffunction name="init" access="public" returntype="SocializeResult">
		<cfargument name="resultXML" type="xml" required="false" />
		<cfif structKeyExists(arguments, "resultXML")>
			<cfset parseResult(arguments.resultXML) />
		</cfif>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="parseResult" access="public" returntype="SocializeResult">
		<cfargument name="resultXML" type="xml" required="true" />
		<cfset var childNodes = resultXML.xmlRoot.xmlChildren />
		<cfset var item = "" />
		<cfloop from="1" to="#ArrayLen(childNodes)#" index="i">
			<cfset item = childNodes [i] />
			<cfset this[item.XmlName] = item.XmlText />
		</cfloop>
		<cfreturn this />
	</cffunction>
</cfcomponent>