-- =============================================
-- Author:		<Alexander G>
-- Create date: <13/09/2017>
-- Description:	<Consultar todas las ofertas>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ContarOfertas] 
	-- Add the parameters for the stored procedure here
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
  DECLARE @OFERTASTOTAL INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 6)
  DECLARE @OFERTASENAPROBA INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 6 AND IdEstatusOperacion = 1)
  DECLARE @OFERTASAPROBADA INT = (SELECT COUNT(*) FROM TA_Operacion WHERE IdTipoOperacion = 6 AND IdEstatusOperacion = 2)

  SELECT @OFERTASTOTAL AS TOALOFERTAS, @OFERTASENAPROBA AS ENAPROBACION, @OFERTASAPROBADA AS APROBADAS

END


