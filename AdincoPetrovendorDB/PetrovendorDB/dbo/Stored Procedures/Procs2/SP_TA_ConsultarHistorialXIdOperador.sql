-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 04-01-17
-- Description:	 Consultar Historial recibiendo el IdOperador
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarHistorialXIdOperador] 
	-- Add the parameters for the stored procedure here
	@IdOperacion INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
				--Obtener la información del flujo 
			SELECT  TH.Fecha,EF.NombreEstado,TH.Descripcion
			FROM TA_HistorialFlujoTarea AS TH
			INNER JOIN TA_EstadoFlujoTarea AS EF ON EF.IdEstado=TH.IdEstadoFlujo
			WHERE  TH.IdOperacion = @IdOperacion
			ORDER BY IdHistorial ASC 
		
END


