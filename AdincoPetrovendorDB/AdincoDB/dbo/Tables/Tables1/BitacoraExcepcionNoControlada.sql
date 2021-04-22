create table BitacoraExcepcionNoControlada
(Id int identity, 
StackTrace nvarchar(max), 
InnerException nvarchar(max), 
Mensaje nvarchar(max),
Pagina nvarchar(max),
FechaAlta datetime)


