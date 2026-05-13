-- =============================================
-- Author:		Daniel AC
-- Create date: 26/08/2019
-- Description:	Consutla detalle de información de correo con adjuntos  
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ConsultarInfoReenvioCorreo] --46164
@IdNotificacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  
	N.Para,
	N.Asunto,
	N.Mensaje,
	EN.EnviadoPor,
	N.De,
	EN.IdCorreo,
	EN.IdIdentificacion,	
	CS.SMTP,
	CS.Puerto,
	CS.Contrasena,
	CS.CuentaRegistro
	FROM Adinco.dbo.S_Notificacion N (NOLOCK)
	INNER JOIN dbo.TA_EnvioCorreo EN
	LEFT JOIN dbo.TA_CorreoServidor CS ON CS.IdServidor=1
	ON EN.IdEnvioAdinco = N.IdNotificacion
	WHERE N.IdNotificacion = @IdNotificacion;

	DECLARE @ASUNTO NVARCHAR(1000) = (SELECT Asunto FROM Adinco.dbo.S_Notificacion WHERE IdNotificacion = @IdNotificacion);

	DECLARE @REPLACE1 INT = CHARINDEX('- Aceptacion No.',@ASUNTO);
	
	IF ISNULL(@REPLACE1,0) <> 0
	BEGIN
	     
		DECLARE @REPLACE2 NVARCHAR(1000) = SUBSTRING(@ASUNTO,@REPLACE1,1000);
		DECLARE @REPLACE3 NVARCHAR(1000) = REPLACE(@ASUNTO,@REPLACE2,'');

	END
	DECLARE @REPLACE4 NVARCHAR(1000) = REPLACE(@REPLACE3,'Factura PO','');
  
	SELECT 
		ISNULL('Factura PO ' + dbo.fn_StripCharacters(@REPLACE4, '^0-9') + RIGHT(N.NombreArchivo,4),N.NombreArchivo) AS NombreArchivo, 
		Adjunto
	FROM Adinco.dbo.S_NotificacionAdjunto N (NOLOCK) 
	INNER JOIN dbo.TA_EnvioCorreo EN
	ON EN.IdEnvioAdinco = N.IdNotificacion
	WHERE N.IdNotificacion = @IdNotificacion
	
END
