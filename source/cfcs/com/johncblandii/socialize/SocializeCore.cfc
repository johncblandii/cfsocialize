<!---
	Name         : SocializeCore
	Author       : John C. Bland II
	Created      : March 3, 2010
	Last Updated : 3/3/2010
	Purpose	   : Core Socialize API functionality; intended to be overwritten
	
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
<cfcomponent displayname="Gigya Socailize API" hint="Guts to the Gigya Socialize REST API" output="false">
	<!--- GENERAL PROPERTIES --->
	<cfset variables.loggingEnabled = false />
	
	<!--- URL PROPERTIES --->
	<cfset variables.protocol = "http" /> <!--- http or https --->
	<cfset variables.baseUrl = "{protocol}://socialize.api.gigya.com/{method}?apiKey={apiKey}&nonce={nonce}&timestamp={timestamp}&uid={uid}&sig={signature}" />
	<cfset variables.apiKey = "" />
	<cfset variables.secretKey = "" />
	
	<cffunction name="init">
		<cfargument name="apiKey" required="true" type="string" hint="Gigya Socialize API Key" />
		<cfargument name="secretKey" required="true" type="string" hint="A base64 encoded secret string shared by Gigya" />
		<cfargument name="protocol" required="false" type="string" hint="http or https" default="#variables.protocol#" />
		
		<cfargument name="enableLogging" required="false" type="boolean" default="false" hint="At the moment it purely uses cftrace" />
		
		<cfscript>
			//store arguments
			variables.apiKey 		= arguments.apiKey;
			variables.protocol		= arguments.protocol;
			variables.secretKey		= arguments.secretKey;
			variables.loggingEnabled	= arguments.enableLogging;
		</cfscript>
		
		<cfreturn this />
	</cffunction>
	
<!--- PRIVATE METHODS --->
	<cffunction name="getNonce" access="private" returntype="String">
		<cfreturn DateFormat(now(), "mmddyyyy") & TimeFormat(now(), "HHssl") />
	</cffunction>
	
	<cffunction name="getTimestamp" access="private" returntype="Numeric">
		<cfreturn getTickCount() />
	</cffunction>
	
	<cffunction name="getSignature" access="private" returntype="String">
		<cfargument name="nonce" type="string" required="true" />
		<cfargument name="timestamp" type="numeric" required="true" />
		<cfset var result = arguments.nonce & arguments.timestamp />
		<cfreturn toBase64(HMAC_SHA1(ToString(ToBinary(variables.secretkey)), result)) />
	</cffunction>
	
	<!---
		Props to @yakhnov: http://www.coldfusiondeveloper.com.au/go/note/2008/01/18/hmac-sha1-using-java/
	--->
	<cffunction name="HMAC_SHA1" returntype="binary" access="public" output="false">
	   <cfargument name="signKey" type="string" required="true" />
	   <cfargument name="signMessage" type="string" required="true" />
	
	   <cfset var jMsg = JavaCast("string",arguments.signMessage).getBytes("iso-8859-1") />
	   <cfset var jKey = JavaCast("string",arguments.signKey).getBytes("iso-8859-1") />
	
	   <cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") />
	   <cfset var mac = createObject("java","javax.crypto.Mac") />
	
	   <cfset key = key.init(jKey,"HmacSHA1") />
	
	   <cfset mac = mac.getInstance(key.getAlgorithm()) />
	   <cfset mac.init(key) />
	   <cfset mac.update(jMsg) />
	
	   <cfreturn mac.doFinal() />
	</cffunction>
	
	<cffunction name="$prepUrl" access="private">
		<cfargument name="method" type="string" required="true" />
		<cfargument name="uid" type="string" required="true" />
		<cfargument name="targetUrl" type="string" required="true" />
		<cfset var nonce = getNonce() />
		<cfset var timestamp = getTimestamp() />
		<cfset var signature = getSignature(nonce, timestamp) />
		<cfset arguments.targetUrl = rereplace(arguments.targetUrl, "{protocol}", variables.protocol, "all") />
		<cfset arguments.targetUrl = rereplace(arguments.targetUrl, "{apiKey}", variables.apiKey, "all") />
		<cfset arguments.targetUrl = rereplace(arguments.targetUrl, "{method}", arguments.method, "all") />
		<cfset arguments.targetUrl = rereplace(arguments.targetUrl, "{uid}", arguments.uid, "all") />
		<cfset arguments.targetUrl = rereplace(arguments.targetUrl, "{nonce}", nonce, "all") />
		<cfset arguments.targetUrl = rereplace(arguments.targetUrl, "{timestamp}", timestamp, "all") />
		<cfset arguments.targetUrl = rereplace(arguments.targetUrl, "{signature}", urlencodedformat(signature), "all") />
		<cfreturn arguments.targetUrl /> 
	</cffunction>
	
	<cffunction name="$getData" access="private">
		<cfargument name="method" type="string" required="true" />
		<cfargument name="uid" type="string" required="true" />
		<cfargument name="targetUrl" type="string" required="true" />
		<cfset var result = "" />
		
		<cfset arguments.targetUrl = $prepUrl(arguments.method, arguments.uid, arguments.targetUrl) />
		
		<cfif variables.loggingEnabled>
			<cftrace category="cfsocialize" text="Loading data from #targetUrl#" />
		</cfif>
		<cfhttp url="#arguments.targetUrl#" method="get" result="result"  charset="utf-8">
			<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0"> 
	     	<cfhttpparam type="Header" name="TE" value="deflate;q=0">
		</cfhttp>
		
		<cfreturn CreateObject("SocializeResult").init(xmlparse(result.filecontent, false)) />
	</cffunction>
	
	<cffunction name="$postData" access="private">
		<cfargument name="method" type="string" required="true" />
		<cfargument name="targetUrl" type="string" required="true" />
		<cfargument name="postArgs" type="struct" required="true" />
		<cfset var result = "" />
		
		<cfset arguments.targetUrl = $prepUrl(arguments.targetUrl, arguments.format) />
		
		<cfif variables.loggingEnabled>
			<cftrace category="cfsocialize" text="Loading data from #targetUrl#" />
		</cfif>
		
		<cfset arguments.postArgs["login"] = variables.login />
		<cfset arguments.postArgs["token"] = variables.token />
		
		<cfhttp url="#arguments.targetUrl#" method="post" result="result" charset="utf-8">
			<cfloop collection="#arguments.postArgs#" item="item">
				<cfif variables.loggingEnabled>
					<cftrace category="cfsocialize" text="#tab# #lcase(item)# - #arguments.postArgs[item]#" />
				</cfif>
				<cfhttpparam type="formfield" name="#lcase(item)#" value="#arguments.postArgs[item]#" />
			</cfloop>
		</cfhttp>
		
		<cfif trim(result.responseheader.status_code) NEQ 200>
			<cfthrow errorcode="#result.responseheader.status_code#" type="Custom" message="#result.statuscode#" detail="Attempted url: #arguments.targetUrl# <br />#result.filecontent.toString()#">
		</cfif>
		<cfreturn xmlparse(result.filecontent, false) />
	</cffunction>
</cfcomponent>