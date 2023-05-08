-- ============================================= 
-- Author:		Daniel AC
-- Create date: 18/10/2017
-- Description:	Detalle de los materiales solicitados en cuadro compativo 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarPedidosTemporalesFechaVigenciaOferta] 
	-- Add the parameters for the stored procedure here

	@IdSolicitudPedido INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	---BEGIN  TRANSACTION

	UPDATE POD 
	SET  POD.AddCantidadTemp= 0,
	 POD.AddValidado = 0, 
	 POD.AddPedidoTemp= 0,
	 POD.AddSubTotalTemp = 0
	FROM dbo.MM_PeticionOfertaDetalle AS POD
	INNER JOIN dbo.MM_PeticionOferta AS PO ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido	
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
	WHERE SP.IdSolicitudPedido=SPD.IdSolicitudPedido
	AND SP.IdSolicitudPedido= @IdSolicitudPedido
	AND POD.AddValidado = 1 
	AND POD.cOTIZADO= 1 
	AND POD.AddPedidoTemp= 1 
	AND POD.FechaVigencia < GETDATE()




		
	--ROLLBACK
	---COMMIT
END


