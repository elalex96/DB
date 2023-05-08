-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2020-11-23
-- Description:	Se toma de base el sp SP_FI_TipoMoneda perteneciente a transferencia, con finalida de filtrar por nombre de moneda corta
-- =============================================
CREATE PROCEDURE SP_FI_TipoMonedaPorTipoMonedaCorto --1284,'MXP'
	@DatoBancarioId INT,
	@TipoMonedaCorto varchar(10)
AS
BEGIN

	SET NOCOUNT ON;
	SELECT @TipoMonedaCorto  = CASE	@TipoMonedaCorto 
							   WHEN	'MXP'
							   THEN	'MXN'
							   END;

	SELECT TM.IdMoneda,TM.TipoMonedaCorto
	FROM 
		PV_CuentaBancaria CB
	JOIN 
		PV_TipoMoneda TM 
		ON CB.TipoMonedaID = TM.IdMoneda
	WHERE DatoBancarioID = @DatoBancarioID
	AND 
		TipoMonedaCorto		=	@TipoMonedaCorto;
END

