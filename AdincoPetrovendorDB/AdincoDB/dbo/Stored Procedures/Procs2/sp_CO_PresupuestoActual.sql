-- =============================================
-- Author:		Miguel Gomez
-- Create date: 01.01.2015
-- Description:	Lista presupuesto actual
-- =============================================
CREATE PROCEDURE sp_CO_PresupuestoActual 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT        SUM(CO_LineaPresupuestoMes.Monto) AS Monto, CO_LineaPresupuestoMes.AC_PRESUP_MES
FROM            CO_LineaPresupuestoMes INNER JOIN
                         CO_Presupuesto ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto INNER JOIN
                         CO_AnioContractual ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
WHERE        (CO_AnioContractual.IdContrato = @IdContrato) AND (CO_Presupuesto.Actual = 1)
GROUP BY CO_LineaPresupuestoMes.AC_PRESUP_MES
END
