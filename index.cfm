<cfprocessingdirective pageEncoding="utf-8">
<cfheader name="Access-Control-Allow-Origin" value="*">
<cfheader name="Access-Control-Allow-Headers" value="*">
<cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
<cfheader name="Access-Control-Allow-Credentials" value="true">
<cfinvoke component="router" method="init" returnVariable="json">
<cfoutput>#serializeJSON(json)#</cfoutput>