USE [Adinco]
GO
IF OBJECT_ID('Adinco..USP_INS_AP_InsertarNotificacionError') IS NOT NULL
BEGIN
DROP PROCEDURE USP_INS_AP_InsertarNotificacionError;
END
/****** Object:  StoredProcedure [dbo].[USP_INS_AP_InsertarNotificacionError]    Script Date: 08/01/2025 07:45:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/01/2025>
-- Description:	<Guardado de error al enviar notificaciones>
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_AP_InsertarNotificacionError]
	-- Add the parameters for the stored procedure here
	@IdNotificacion INT,
	@Error varchar(350)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @IdNotificacionError int

	select @IdNotificacionError = isnull(max(IdNotificacionError),0) + 1
	from [S_NotificacionError]

	insert into [dbo].[S_NotificacionError](
		IdNotificacionError,
		IdNotificacion,
		Error,
		FechaRegistro
	)
	values(
		@IdNotificacionError,
		@IdNotificacion,
		@Error,
		getdate()
	)
END
