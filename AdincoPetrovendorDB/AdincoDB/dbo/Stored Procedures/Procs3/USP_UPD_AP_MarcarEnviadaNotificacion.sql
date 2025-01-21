USE [Adinco]
GO
IF OBJECT_ID('Adinco..USP_UPD_AP_MarcarEnviadaNotificacion') IS NOT NULL
BEGIN
DROP PROCEDURE USP_UPD_AP_MarcarEnviadaNotificacion;
END
/****** Object:  StoredProcedure [dbo].[USP_UPD_AP_MarcarEnviadaNotificacion]    Script Date: 08/01/2025 07:46:07 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/01/2025>
-- Description:	<Actualizar notificacion>
-- =============================================
CREATE PROCEDURE [dbo].[USP_UPD_AP_MarcarEnviadaNotificacion]
	-- Add the parameters for the stored procedure here
	@IdNotificacion INT,
	@ModificadoPor INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE AP_Notificacion WITH (ROWLOCK)
	SET Enviada = 1,
		ModificadoPor = CASE WHEN @ModificadoPor > 0 THEN @ModificadoPor ELSE NULL END,
		ModificadoEl = getdate(),
		FechaEnvio = getdate()
	WHERE IdNotificacion = @IdNotificacion
END
