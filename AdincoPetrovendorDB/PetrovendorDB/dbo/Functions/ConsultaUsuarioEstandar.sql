create function ConsultaUsuarioEstandar()
returns table
as
return (select U.IdUsuario, U.Nombre, U.Correo, U.Contrasena, U.IdTipoUsuario, TU.NombreTipoUsuario, U.Activo  
from   S_Usuario as U 
inner join S_TipoUsuario as TU on U.IdTipoUsuario = TU.IdTipoUsuario
inner join S_UsuarioProveedor as UP on U.IdUsuario = UP.IdUsuario
where UP.IsAdmin = 0)