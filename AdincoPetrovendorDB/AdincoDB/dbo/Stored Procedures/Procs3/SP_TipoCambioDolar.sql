-- =============================================
-- Author:		Reyna Olvera
-- Create date: 12/01/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TipoCambioDolar]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set language spanish
    -- Insert statements for procedure here
	Select top 500 idTipoCambio,TipoMoneda,
	DateName(DAY,fecha)+' '+DateName(month,fecha)+' '+DateName(year,fecha) as Fecha,
	TipoCambio
	from co_tipoCambioDiario TPCD
	Inner join pv_tipoMoneda PTM on tpcd.idmoneda=ptm.idMoneda
	Where TPCD.idMoneda=1
	order by IdTipoCambio desc


	
END
