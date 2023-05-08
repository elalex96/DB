-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Consultar historial de  de flujo por aprobación
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MA_ConsultarHistorialxIdOperacion]
    -- Add the parameters for the stored procedure here
    @IdOperacion INT,
    @IdContrato INT,
    @IdUsuario INT = 0,
    @IdSubcontratista INT = 0,
    @FechaRegistro DATETIME = '25-01-2017 00:00'
AS
BEGIN
    SET NOCOUNT ON;

	SELECT MH.IdHistorialOperacion,MH.Detalle, MH.CreadoEl,ISNULL(EF.NombreEstado,'') AS EstadoFlujo
	FROM dbo.MA_HistorialOperacion AS MH
	LEFT JOIN dbo.MA_EstadoFlujoAprobacion AS EF ON EF.IdEstado= MH.IdEstadoFlujo
	WHERE IdOperacion =@IdOperacion
	ORDER BY CreadoEl asc

    
END;

