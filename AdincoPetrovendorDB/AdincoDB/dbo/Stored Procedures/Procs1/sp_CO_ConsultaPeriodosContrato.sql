-- =============================================
-- Author:		Miguel Gomez
-- Create date: 4-01-2017
-- Description:	Consulta los periodos de un contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaPeriodosContrato] 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT        IdPeriodo,  NombrePeriodo  as NombreParaMostrar
FROM            CO_PeriodoContrato
WHERE        (IdContrato = @IdContrato)

order by  Fin asc
END
