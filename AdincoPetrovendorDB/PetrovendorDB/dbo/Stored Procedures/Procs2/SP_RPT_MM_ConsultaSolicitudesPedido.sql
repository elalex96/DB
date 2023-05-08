-- =============================================
-- Author:		Daniel AC
-- Create date: 05-06-18
-- Description:	Consultar Solicitudes de Pedido  y filtro de activo o eliminado
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 22-10-18
-- Description:	se agregan columnas solicitadas (Si fue Cotizado, Sol Oferta Enviada, Fecha de Vencimiento Cotizacion, Proveedores a cotizar
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/07/2020
-- Description:	se optimizo la consulta eliminando relaciones y campos que no son necesarios en la vista
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_MM_ConsultaSolicitudesPedido]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT, @IdUsuario INT, @IdContrato INT = NULL, @FechaRegistro DATETIME = NULL
AS
	BEGIN
		SET NOCOUNT ON

SELECT 
	SP.IdSolicitudPedido, 
	SP.MotivoUrgencia, 
	TSP.TipoSolicitudPedido, 
	SP.FechaAlta ,
	U.Nombre AS NombreUsuario, 
	TAO.Descripcion, 
	TE.Nombre,
	CASE 
		WHEN ISNULL(SP.IdEstatusEliminado,0) <> 1 THEN 'Activo'
		ELSE 'Eliminado'
	END AS Activo
FROM MM_SolicitudPedido AS SP
JOIN MM_TipoSolicitudPedido AS TSP
	ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
JOIN TA_Operacion AS TAO
	ON TAO.IdDocumento = SP.IdSolicitudPedido
	AND TAO.IdTipoOperacion = 2
JOIN TA_Estatus AS TE
	ON TE.IdEstatus = TAO.IdEstatusOperacion
JOIN S_Usuario AS U
			ON SP.IdUsuarioSolicitante = U.IdUsuario
JOIN dbo.MM_PeticionOferta PO
	ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
WHERE
	SP.IdProveedor = @IdProveedor
	AND ISNULL ( SP.Visible, 1 ) = 1
GROUP BY	
	SP.IdSolicitudPedido, 
	SP.MotivoUrgencia, 
	TSP.TipoSolicitudPedido, 
	SP.FechaAlta, 
	U.Nombre ,
	SP.MotivoUrgencia, 
	TE.Nombre, 
	SP.IdEstatusEliminado, 
	SP.IdProveedor, 
	SP.PeticionEnviada,
	TAO.Descripcion
ORDER BY SP.FechaAlta DESC

END