<!---    
@resource sessions
@description authentication resource description 
@tags Sesion, Acceso, Nexth5
@module Auth
--->

<cfcomponent>

  <!--- 
  @path /
  @method GET
  @description get user session
  @tags nx_utilerias.doLogin, nx_utilerias.getMenuPrincipa, etc
  @args username: string
  @args password: string
  --->
  <cffunction name="get_all">
    <cfreturn StructNew()>
  </cffunction>

</cfcomponent>