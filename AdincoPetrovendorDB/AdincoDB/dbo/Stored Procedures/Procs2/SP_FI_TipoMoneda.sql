-- =============================================
-- Author:		Manuel CD
-- ALTER date: 28-08-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_TipoMoneda] 
	-- Add the parameters for the stored procedure here
	@DatoBancarioID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TM.IdMoneda,TM.TipoMonedaCorto FROM PV_CuentaBancaria CB
	JOIN PV_TipoMoneda TM ON CB.TipoMonedaID = TM.IdMoneda
	WHERE DatoBancarioID = @DatoBancarioID
END
--EXEC SP_FI_TipoMoneda 1222
