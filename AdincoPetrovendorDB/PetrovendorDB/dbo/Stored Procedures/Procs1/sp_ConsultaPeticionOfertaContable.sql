-- =============================================
-- Author:		Alexander G
-- Create date: 27-06-17
-- Description:	Consultar Peticiones de oferta para contar por estatus 
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConsultaPeticionOfertaContable]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @PENDIENTES INT = (
		SELECT COUNT(*) FROM
		(SELECT SP.IdSolicitudPedido
		FROM MM_SolicitudPedido AS SP
		INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido
		INNER JOIN TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido AND O.IdTipoOperacion = 6
		INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = o.IdVigencia
		INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
		LEFT JOIN MM_PeticionOferta AS PO ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		WHERE SP.IdProveedor= @IdProveedor  AND (DATEDIFF(MINUTE,O.FechaFinalizacion, GETDATE()) <=0)
		GROUP BY  SP.IdSolicitudPedido, TSP.TipoSolicitudPedido, O.Descripcion, O.FechaRegistro,O.FechaFinalizacion) AS total)

	DECLARE @APROBADOS INT =(
		SELECT COUNT(*) FROM
		(SELECT SP.IdSolicitudPedido
		FROM MM_SolicitudPedido AS SP
		INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido
		INNER JOIN TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido AND O.IdTipoOperacion = 6
		INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = o.IdVigencia
		INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
		LEFT JOIN MM_PeticionOferta AS PO ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		WHERE SP.IdProveedor= @IdProveedor  AND (DATEDIFF(MINUTE,O.FechaFinalizacion, GETDATE()) >0)
		GROUP BY  SP.IdSolicitudPedido) AS TOTAL)

	DECLARE @TOTAL INT = (@APROBADOS + @PENDIENTES)
	
	
	SELECT @TOTAL, @APROBADOS, @PENDIENTES
	

END
