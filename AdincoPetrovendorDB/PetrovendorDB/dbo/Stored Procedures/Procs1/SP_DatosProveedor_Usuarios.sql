CREATE PROCEDURE [dbo].[SP_DatosProveedor_Usuarios] (@Idproveedor int)
AS
BEGIN
SELECT S_Proveedor.IdProveedor, S_Nacionalidad.Nacionalidad, S_Proveedor.RFC, S_TipoRegimen.TipoRegimen, S_Proveedor.RazonSocial, S_Proveedor.RegimenCapital, S_Proveedor.FechaConstitucion, S_Proveedor.FechaOperacion, S_Proveedor.SituacionContribuyente, S_Proveedor.FechaCambioSituacion, S_Proveedor.Pais, S_Proveedor.Entidad, S_Proveedor.Municipio, S_Proveedor.Colonia, S_Proveedor.TipoVialidad, S_Proveedor.NumExterior, S_Proveedor.NumInterior, S_Proveedor.CodigoPostal, S_Proveedor.Alias, S_Proveedor.Giro, S_Proveedor.IMSS, PV_TipoMoneda.TipoMoneda, 
S_Proveedor.Telefono, S_Proveedor.CURP, S_Proveedor.RPPC, S_Proveedor.CorreoProveedor, S_Usuario.Nombre, S_Rol.Rol
FROM S_Proveedor
left join S_Nacionalidad on S_Proveedor.IdNacionalidad = S_Nacionalidad.IdNacionalidad
left join PV_TipoMoneda on S_Proveedor.IdTipoMoneda = PV_TipoMoneda.IdMoneda
left join S_TipoRegimen on S_Proveedor.IdTipoRegimen = S_TipoRegimen.IdTipoRegimen
left join S_UsuarioProveedor on S_Proveedor.IdProveedor = S_UsuarioProveedor.IdProveedor
left join S_Usuario on S_UsuarioProveedor.IdUsuario = S_Usuario.IdUsuario
left join S_UsuarioRol on S_Usuario.IdUsuario = S_UsuarioRol.IdUsuario
left join S_Rol on S_UsuarioRol.IdRol = S_Rol.IdRol
where  S_Proveedor.idProveedor = @IdProveedor
END
