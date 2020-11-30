-- =============================================
-- Author:		Miguel Gomez
-- Create date: 6 noviembre 2014
-- Description:	Obtiene las versiones de presupuesto para un año contractual
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaPresupuestos] 
	-- Add the parameters for the stored procedure here
	@AnioContractual int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT        CO_Presupuesto.IdPresupuesto, CO_Presupuesto.IdAnioContractual, CO_Presupuesto.Version, CO_Presupuesto.Nombre, CO_Presupuesto.Comentario, CO_Presupuesto.FechaAprobacionPEP, 
                         CO_Presupuesto.Activo, CO_AnioContractual.Anio, CO_AnioContractual.Inicio, CO_AnioContractual.Termino
FROM            CO_Presupuesto INNER JOIN
                         CO_AnioContractual ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
WHERE        (CO_Presupuesto.IdAnioContractual = @AnioContractual) AND (CO_Presupuesto.Activo = 1)
END

