-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 04-01-17
-- Description:	 Consultar Historial recibiendo el IdOperador
-- =============================================
-- Author:		Luis David De La Cruz
-- Create date: 20/03/2021
-- Description:	Se optimiza la consulta para la pantalla detalle_pedido del issue 984
-- =============================================
IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = 'SP_TA_ConsultarHistorialXIdOperador')
    DROP PROCEDURE SP_TA_ConsultarHistorialXIdOperador
go
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
			INNER JOIN TA_EstadoFlujoTarea AS EF 
				ON TH.IdEstadoFlujo = EF.IdEstado
			WHERE  TH.IdOperacion = @IdOperacion
			ORDER BY IdHistorial ASC 
		
END