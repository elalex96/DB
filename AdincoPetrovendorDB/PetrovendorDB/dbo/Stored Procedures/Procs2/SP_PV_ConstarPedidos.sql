-- =============================================
-- Author:		<Alexander G>
-- Create date: <13/09/2017>
-- Description:	<Consultar todos los Pedidos>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConstarPedidos] 
	-- Add the parameters for the stored procedure here
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @PEDIDOT INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 9)
	DECLARE @PEDIDOA INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 9 AND IdEstatusOperacion = 1)
	DECLARE @PEDIDOEA INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 9 AND IdEstatusOperacion = 2)
	DECLARE @PEDIDOER INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 9 AND IdEstatusOperacion = 3)

	SELECT @PEDIDOT AS TOTAL, @PEDIDOA AS APROBADAS, @PEDIDOEA AS ENAPORBACION, @PEDIDOER AS RECHAZADA

END

