cfapi
=====

Para escribir un recurso para la api, todo lo que necesitas es escribir un componente dentro de la carpeta resources, por ejemplo:

clients.cfc

Con este archivo, ahora podrías llamar la url:

http://localhost:8000/cfapi/index.cfm/clients

Por último, tienes que considerar que cada componente debe heredar del fichero resource.cfc:

```coldfusion
<cfcomponent extends="resource">
</cfcomponent>
```


Heredar resource te será de mucha ayuda ya que proporciona variables de utilidad:

* ws (path a next_ws)
* route (path a nextapi)
* resource
* id (solo usado en los verbos GET, PUT, DELETE)
* REQ (la información mandada al recurso via url o post, p.e. REQ.atributo es lo mismo que URL.atributo ó FORM.atributo)

Posteriormente, dentro del componente solo basta con que escribas las funciones correspondientes a los verbos http que quieras que este recurso responda:

* GET :id - get
* GET - get_all
* POST - create
* PUT :id - update
* DELETE :id - delete

Para que tu recurso responda a los 4 verbos, tu código debería quedar de la siguiente forma:

```coldfusion
<cfcomponent extends="resource">

  <cffunction name="get">
  </cffunction>

  <cffunction name="get_all">
  </cffunction>

  <cffunction name="create">
  </cffunction>

  <cffunction name="update">
  </cffunction>

  <cffunction name="delete">
  </cffunction>

</cfcomponent>
```

Cada metodo puede acceder directamente al objeto REQ, que tiene todos los parametros que han sido pasados al recurso.

Dentro de cada método deberas escribir la logica y devolver estructuras, en todo momento, esto debido a que como norma se manejará json para esta api.
