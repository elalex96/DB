-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_PeriodosPorContrato] 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        IdPeriodo, IdContrato, NombrePeriodo, Inicio, Fin
FROM            CO_PeriodoContrato
WHERE        (IdContrato = @IdContrato)

order by Inicio asc
END
