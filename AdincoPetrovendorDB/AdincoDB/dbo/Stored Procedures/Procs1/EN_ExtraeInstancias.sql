-- =============================================
-- Author:		Reyna olvera
-- ALTER date: 20/04/201
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EN_ExtraeInstancias]
	-- Add the parameters for the stored procedure here
	@idContrato int,
	@idUsuario int,
	@idEntregable int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET LANGUAGE Spanish;
Select idInstanciaEntregable,Concat( (DAY(FechasLimiteaprobacion)),'-',DATENAME(MONTH, FechasLimiteaprobacion),'-', DATENAME(year, FechasLimiteaprobacion)) as Fecha
from EN_InstanciasEntregable
Where idContratoEntregable=(Select TOP 1 idContratoEntregable from EN_ContratoEntregable
Where idContrato=@IdContrato and idEntregable =@idEntregable)

END

