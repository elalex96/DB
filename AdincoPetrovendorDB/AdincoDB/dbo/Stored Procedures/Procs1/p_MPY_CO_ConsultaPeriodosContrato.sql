
-- Author:		luis david 
-- Create date: 17-07-2019
-- Description:	Consulta los periodos de un contrato
-- =============================================
CREATE PROCEDURE [dbo].[p_MPY_CO_ConsultaPeriodosContrato] 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 0 as 'IdPeriodo' , 'Todos'  as NombreParaMostrar 
	union
	SELECT        IdPeriodo,  NombrePeriodo  as NombreParaMostrar
	FROM            CO_PeriodoContrato
	WHERE        (IdContrato = @IdContrato)
END

