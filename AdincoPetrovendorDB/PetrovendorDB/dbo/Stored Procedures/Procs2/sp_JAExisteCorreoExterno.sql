CREATE PROCEDURE [dbo].[sp_JAExisteCorreoExterno] (@Correo NVARCHAR(MAX), @IdProveedor INT)
AS
BEGIN
    SELECT CorreoParticipanteExterno
    FROM dbo.JA_Participantes
    WHERE NombreParticipante IS NOT NULL
          AND CorreoParticipanteExterno = @Correo
		  AND IdProveedor = @IdProveedor
END
