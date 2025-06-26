CREATE TABLE APP_Preferencias(
Id	int identity (1,1),
Nombre	varchar(1000),
EsDeContratista	bit,
Descripcion	varchar(1000),
RequiereValor	bit,
Constraint  PK_APP_Preferencias primary key(Id)
)