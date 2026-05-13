-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_IndicadoresSolicitudes]
	-- Add the parameters for the stored procedure here
	@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @SOLPED INT = ( SELECT COUNT(*) FROM TA_Operacion WHERE IdProveedor = @IdProveedor AND IdTipoOperacion = 2 AND IdEstatusOperacion = 1)

  DECLARE @SOLOFER INT =(SELECT COUNT(*) FROM MM_SolicitudPedido AS SP WHERE SP.IdProveedor = @IdProveedor AND SP.PeticionEnviada = 1)

  DECLARE @OFERTPEN INT = (SELECT COUNT(SP.IdSolicitudPedido)
		FROM MM_SolicitudPedido AS SP
		INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido
		INNER JOIN TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido AND O.IdTipoOperacion = 6
		INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = o.IdVigencia
		INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
		LEFT JOIN MM_PeticionOferta AS PO ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		WHERE SP.IdProveedor= @IdProveedor  AND (DATEDIFF(MINUTE,O.FechaFinalizacion, GETDATE()) <=0))

	SELECT @SOLPED, @SOLOFER, @OFERTPEN
END

