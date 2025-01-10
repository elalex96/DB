USE [Adinco]
GO
IF OBJECT_ID('Adinco..USP_INS_AP_InsertarNotificacionTareaBitacora') IS NOT NULL
BEGIN
DROP PROCEDURE USP_INS_AP_InsertarNotificacionTareaBitacora;
END
/****** Object:  StoredProcedure [dbo].[USP_INS_AP_InsertarNotificacionTareaBitacora]    Script Date: 08/01/2025 07:45:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/01/2025>
-- Description:	<Guardado de acciones del envio de notificaciones>
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_AP_InsertarNotificacionTareaBitacora]
	-- Add the parameters for the stored procedure here
	@IdTareaBitacora int out,
	@HostNameTarea varchar(100),
	@IPTarea varchar(15),
	@TieneError bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	WAITFOR DELAY '00:00:05';

	select @IdTareaBitacora = isnull(max(IdTareaBitacora),0)+1
	from [S_NotificacionTareaBitacora]

	INSERT INTO [dbo].[S_NotificacionTareaBitacora]
			   ([IdTareaBitacora]
			   ,[InicioEjecucion]
			   ,[FinEjecucion]
			   ,[HostNameTarea]
			   ,[IPTarea]
			   ,TieneError)
		 VALUES
			   (@IdTareaBitacora, 
			   getdate(), 
			   null, 
			   @HostNameTarea, 
			   @IPTarea,
			   @TieneError
			   )

	SELECT @IdTareaBitacora
END
