
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <26/03/2018>
-- Description:	<Se consulta la bitacora de consulta en el catalogo de proveedores>
-- =============================================

CREATE procedure S_SP_ConsultaBitacoraCatalogoProveedores
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT b.IdBitacora,
		p.IdProveedor,
		p.RazonSocial,
		b.IdUsuario,
		u.Nombre,
		b.FechaConsulta,
		b.Motivo
	FROM dbo.S_BitacoraConsultaCatalogoProveedor b
		INNER JOIN dbo.S_Proveedor p ON p.IdProveedor = b.IdProveedorConsultado
		INNER JOIN dbo.S_Usuario u ON u.IdUsuario = b.IdUsuario
	ORDER BY b.FechaConsulta DESC
END