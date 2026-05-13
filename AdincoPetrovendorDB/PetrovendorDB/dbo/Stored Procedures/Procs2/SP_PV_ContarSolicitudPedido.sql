-- =============================================
-- Author:		<Alexander G>
-- Create date: <13/09/2017>
-- Description:	<Consultar todas las ofertas>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ContarSolicitudPedido] 
	-- Add the parameters for the stored procedure here
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
  DECLARE @SOLPEDTOTAL INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 2)
  DECLARE @SOLPEDENAPROBA INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 2 AND IdEstatusOperacion = 1)
  DECLARE @SOLPEDAPROBADA INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 2 AND IdEstatusOperacion = 2)
  DECLARE @SOLPEDCANCELADAPORASIG INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 2 AND IdEstatusOperacion = 6)


  SELECT @SOLPEDTOTAL AS TOTAL, @SOLPEDENAPROBA AS ENAPROBACION, @SOLPEDAPROBADA AS APROBADAS, @SOLPEDCANCELADAPORASIG AS CANCELADAS

END


