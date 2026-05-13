
-- =============================================
-- Author:	Daniel AC
-- Create date: <09-01-2018>
-- Description:	<Recupero el IdTarea para la firma electronica
-- =============================================

CREATE procedure [dbo].[TA_SP_ConsutaIdTareaPorOperacionUsuario]
	@IdUsuario INT,
	@IdOperacion INT,
    @IdContrato    INT = null,   
    @FechaRegistro DATETIME = null

AS
BEGIN
	    SELECT T.IdTarea 
		FROM TA_Tarea AS T		
		WHERE IdAprobador = @IdUsuario 
		AND IdOperacion = @IdOperacion
END