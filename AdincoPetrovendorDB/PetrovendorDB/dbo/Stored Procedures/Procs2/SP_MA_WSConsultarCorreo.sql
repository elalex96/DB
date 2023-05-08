-- =============================================
-- Author: Pedro Acu�a
-- Create date: 28/04/2018
-- Description: se recuperan los datos del correo para enviarlos
-- =============================================

CREATE PROCEDURE SP_MA_WSConsultarCorreo ( @IdCorreo INT )
AS
	BEGIN
		SET DATEFORMAT DMY
		SELECT	correo.IdCorreo, correo.HTML, correo.Asunto, servidor.CuentaRegistro, servidor.Contrasena ,
				servidor.SMTP, servidor.Puerto, servidor.BBC
		FROM	Adinco.dbo.MA_Correo correo
		 JOIN Adinco.dbo.MA_ServidorDeCorreo servidor
			ON servidor.IdServidor = correo.IdServidor
		WHERE	correo.IdCorreo = @IdCorreo
	END

--------------------------------------------------------------------------------------------------------------