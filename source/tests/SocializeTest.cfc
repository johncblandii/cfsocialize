<!--- 
 SocializeTest.cfc
 @author johncblandii
 @description Tests Socialize calls
 --->
<cfcomponent extends="tests.TestCore">
	<cffunction name="disconnect" output="false">
		
	</cffunction>
	
	<cffunction name="getFriendsInfo" output="false">
		
	</cffunction>
	
	<cffunction name="getRawData" output="false">
		
	</cffunction>
	
	<cffunction name="getSessionInfo" output="false">
		
	</cffunction>
	
	<cffunction name="getUserInfo" output="false">
		
	</cffunction>
	
	<cffunction name="linkAccounts" output="false">
		<cfset var result = this.socialize.linkAccounts("1", "123456789") />
		<cfset debug(result) />
		<cfset assertTrue(result.statusCode EQ "200", "statusCode != 200") />
	</cffunction>
	
	<cffunction name="publishUserAction" output="false">
		
	</cffunction>
	
	<cffunction name="sendNotification" output="false">
		
	</cffunction>
	
	<cffunction name="setStatus" output="false">
		
	</cffunction>
	
	<cffunction name="unlinkAccounts" output="false">
		
	</cffunction>
</cfcomponent>