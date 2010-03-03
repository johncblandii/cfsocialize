<!--- 
 TestCore.cfc
 @author johncblandii
 @description Core test cfc to setup test(s)
 --->
<cfcomponent extends="mxunit.framework.TestCase">
	<cfset this.socialize = "" />
	<cfset this.testCFC = "" /> <!--- REQUIRED FOR TESTS TO WORK --->
	
	<!--- TEST CONFIG INFO --->
	<cfset this.apiKey = "" />
	<cfset this.secretKey = "" />
	<cfset this.userid = "1" />
	<cfset this.protocol = "http" />
	
<!--- SETUP/TEARDOWN --->
	<cffunction name="setUp" access="public" returntype="void">
		<cfset this.socialize = createobject("component", "cfcs.com.johncblandii.socialize.Socialize").init(this.apiKey, this.secretKey, this.protocol, true) />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void">
	</cffunction>
</cfcomponent>