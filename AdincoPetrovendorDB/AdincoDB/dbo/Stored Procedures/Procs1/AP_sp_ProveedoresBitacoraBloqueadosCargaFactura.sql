USE PETROVENDOR 
GO
--Modifier: Luis David
-- Modifier date: 24-06-2021
-- Description: Extrae proveedores bloqueados
DROP PROCEDURE IF EXISTS AP_sp_ProveedoresBitacoraBloqueadosCargaFactura
go
CREATE PROCEDURE AP_sp_ProveedoresBitacoraBloqueadosCargaFactura --907
@IdProveedor int
AS
BEGIN
	select bf.Id as Folio, 
	p.RazonSocial, p.RFC, bf.CreadoEl as Fecha,u.Nombre as Usuario, bf.Motivo as Comentario,bf.Descripcion as Operacion, bf.Bloqueado from 
	AP_BitacoraBloqueoFactura bf
	join S_Proveedor p on 
	bf.IdProveedorBloqueado = p.IdProveedor
	join S_Usuario u on
	bf.CreadoPor = u.IdUsuario
	where bf.IdProveedor = @IdProveedor
	order by bf.CreadoEl 
	desc
END
