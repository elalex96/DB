-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/05/2019
-- Description:	Consulta de años contractuales
-- =============================================
CREATE PROCEDURE [dbo].[SP_CN_RPT_AnioContractual] --10007
	-- Add the parameters for the stored procedure here
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FechaEfectiva AS DATE;

         /**/

    SELECT @FechaEfectiva = InicioVigencia
    FROM Adinco.dbo.CO_Contrato
    WHERE IdContrato = @IdContrato;

	SELECT YEAR(C.IdFecha) AS IdAnio, 
		   YEAR(C.IdFecha) AS Anio
    FROM Adinco.dbo.AP_Calendario C
    WHERE C.Dia = 1
       AND C.IdFecha BETWEEN DATEADD(month, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP--DATEFROMPARTS(2019, 12, 31)
	GROUP BY YEAR(C.IdFecha),
             YEAR(C.IdFecha)
    ORDER BY YEAR(C.IdFecha) DESC;

END
