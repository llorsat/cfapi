<!---    
@resource sessions
@description authentication resource description 
@tags Sesion, Acceso, Nexth5
@module Auth
--->

<cfcomponent>

  <!--- 
  @path /
  @method POST
  @description get user session
  @tags nx_utilerias.doLogin, nx_utilerias.getMenuPrincipa, etc
  @args company_id: string
  @args ds: string
  @args method: string
  @args password: string
  @args username: string
  --->

  <cffunction name="signin" access="remote" returntype="any" returnformat="json">
    <cfreturn structNew()>
  </cffunction>

  <!--- 
  @path /
  @method GET
  @description get user session
  @tags nx_utilerias.doLogin, nx_utilerias.getMenuPrincipa, etc
  @args company_id: string
  @args ds: string
  @args method: string
  @args password: string
  @args username: string
  --->

</cfcomponent>