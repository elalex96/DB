-- =============================================
-- Author:		Daniel AC
-- Create date: 12-05-17
-- Description:	Procedimiento que calcula los totales de IVA, SUBTOTAL, TOTAL de las PeticionesOfertaDetalles Agregados al Pedido Temporal
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_CalcularTotalesPedidoTemp]
	-- Add the parameters for the stored procedure here

	@IdSolicitudPedido int 
	 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;

	DECLARE @TOTAL FLOAT = 0
	DECLARE @SUBTOTAL FLOAT = 0 
	DECLARE @MONTOIVA FLOAT = 0

	SELECT ISNULL(cast((SUM(POD.AddSubTotalTemp * POD.AddCantidadTemp) ) AS DECIMAL(16,2)),0) AS SubTotal, 
	 ISNULL(CAST( ( SUM(POD.CantidadIVa* POD.AddCantidadTemp) ) AS DECIMAL(16,2)),0) AS MontoIVA, 
	ISNULL( CAST(((SUM(POD.AddSubTotalTemp * POD.AddCantidadTemp) + ( SUM(POD.CantidadIVa * POD.AddCantidadTemp)) ))  AS DECIMAL(16,2) ),0) AS Total
	FROM MM_PeticionOferta AS PO
	INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	WHERE PO.IdSolicitudPedido = @IdSolicitudPedido AND POD.AddPedidoTemp=1 AND POD.AddValidado=1
	GROUP by SubTotal 
	
	
END
