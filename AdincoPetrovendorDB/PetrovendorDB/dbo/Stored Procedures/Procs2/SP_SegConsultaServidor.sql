-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-01-17
-- Description:	Regresa a la parte web los parámetros que contiene el servidor de correos y tenga funcionalidad y puedan ser enviados
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegConsultaServidor] 

@IdCorreoServidor int

AS
BEGIN

	SELECT CuentaRegistro, Contrasena, SMTP, Puerto, BBC FROM S_CorreoServidor WHERE IdCorreoServidor =  @IdCorreoServidor

END

