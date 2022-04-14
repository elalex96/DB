USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'TA_SP_ConsultarInfoReenvioCorreoAdjuntos'
)
    DROP PROCEDURE TA_SP_ConsultarInfoReenvioCorreoAdjuntos;
/****** Object:  StoredProcedure [dbo].[SP_DEA_ConsultarInfoReenvioCorreo]    Script Date: 13/04/2022 08:59:05 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 26/08/2019
-- Description:	Consutla detalle de información de correo con adjuntos  
-- =============================================
CREATE PROCEDURE [dbo].[TA_SP_ConsultarInfoReenvioCorreoAdjuntos] --46164
@IdNotificacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		N.NombreArchivo AS NombreArchivo, 
		Adjunto
	FROM Adinco.dbo.S_NotificacionAdjunto N (NOLOCK) 	
	WHERE N.IdNotificacion = @IdNotificacion
	
END
