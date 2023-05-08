-- =============================================
-- Author:		luis david 
-- Create date: 17-07-2019
-- Description:	Consulta los periodos de un contrato
-- =============================================
-- Modificado Por: Neri del Angel
-- Create date:    04 de Abril del 2022
-- Description:	   Se quita la unión de Todos, 
--				   ya que se solicita sea necesario 
--				   seleccionar algún Periodo del
--				   contrato en sesión 
-- =============================================
CREATE PROCEDURE [dbo].[p_MPY_CO_ConsultaPeriodosContrato] 
	@IdContrato	INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SELECT        
		IdPeriodo, 
		NombrePeriodo AS NombreParaMostrar
	FROM            
		CO_PeriodoContrato (NOLOCK)
	WHERE        
		IdContrato = @IdContrato
END

