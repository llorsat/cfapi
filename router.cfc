<!-- --->
<cfcomponent displayname="router" output="false">
  
    <cfset resources = "resources">
    <cfset verb = cgi.request_method>
    <cfset uri = cgi.PATH_INFO>
    <cfset uriData = StructNew()>
    <cfset data = "">
  
    <cffunction name="init" access="remote" returntype="any" returnformat="json" output="false">
        <cfset uriComponents = uri.split('/')>
        <cfset data = FORM>
        <cfif arrayLen(uriComponents) GT 3>
            <cfset uriData.ds = uriComponents[2]>
            <cfset uriData.company_id = uriComponents[3]>
            <cfset uriData.username = uriComponents[4]>
            <cfset uriData.token = uriComponents[5]>
            <cfset uriData.resource = uriComponents[6]>
            <cfset response = resource(uriData, data)>
            <cfreturn response>
        <cfelse>
            <cfif verb EQ "POST">
                <cfinvoke component="#resources#.sessions" method="signin" data="#data#" returnVariable="response">
                <cfreturn response>
            <cfelse>
                <cfreturn "Access Denied">
            </cfif>
        </cfif>
    </cffunction>
  
    <cffunction name="resource" output="false">

        <cfargument name="params" required="true" type="any">
        <cfargument name="data" required="false" type="any">
        <cfset response = StructNew()>

        <cftry>
            <cfswitch expression="#verb#">
                <cfcase value="GET">
                    <cfif arrayLen(uriComponents) GT 6>
                        <cfset params.identifier = uriComponents[7]>
                        <cfinvoke component="#resources#.#params.resource#" method="get" returnvariable="response">
                    <cfelse>
                        <cfinvoke component="#resources#.#params.resource#" method="get_all" returnvariable="response">
                    </cfif>
                </cfcase>
                <cfcase value="POST">
                    <cfinvoke component="#resources#.#params.resource#" data="#data#" method="create" returnVariable="response">
                </cfcase>
                <cfcase value="PUT">
                    <cfinvoke component="#resources#.#params.resource#" method="update" returnVariable="response">
                </cfcase>
                <cfcase value="DELETE">
                    <cfinvoke component="#resources#.#params.resource#" method="delete" returnVariable="response">
                </cfcase>
                <cfcase value="OPTIONS"></cfcase>
                <cfdefaultcase>
                    <cfinvoke component="#resources#.#params.resource#" method="get_all" returnVariable="response">
                </cfdefaultcase>
            </cfswitch>

        <cfcatch type="Application">
            <cfheader statuscode="500" statustext="InternalServerError">
            <cfset a = structInsert(response, "Type",  #cfcatch.Type#)>
            <cfset a = structInsert(response, "Detail",  #cfcatch.Detail#)>
            <cfset a = structInsert(response, "Message",  #cfcatch.Message#)>
            <cfrethrow>
        </cfcatch>
        <cfcatch type="Any">
            <cfrethrow>
        </cfcatch>
        </cftry>
        <cfreturn response>
    </cffunction>

</cfcomponent>
