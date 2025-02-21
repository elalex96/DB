USE [Adinco]
GO
IF OBJECT_ID('Adinco..UPS_UPD_AP_ActualizarFinNotificacionTareaBitacora') IS NOT NULL
BEGIN
DROP PROCEDURE UPS_UPD_AP_ActualizarFinNotificacionTareaBitacora;
END
/****** Object:  StoredProcedure [dbo].[UPS_UPD_AP_ActualizarFinNotificacionTareaBitacora]    Script Date: 22/01/2025 10:03:39 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/01/2025>
-- Description:	<Actualizacion final del la bitacora de notificaciones>
-- =============================================
CREATE PROCEDURE [dbo].[UPS_UPD_AP_ActualizarFinNotificacionTareaBitacora]
	-- Add the parameters for the stored procedure here
	@IdTareaBitacora int,
	@TieneError bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [S_NotificacionTareaBitacora]
	SET [FinEjecucion] = getdate(),
		TieneError = @TieneError
	WHERE IdTareaBitacora = @IdTareaBitacora
END
