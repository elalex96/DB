CREATE PROCEDURE [dbo].[sp_JAAgregarNombreParticipante]
(
    @IdProveedor INT,
    @Participante NVARCHAR(MAX),
    @Correo NVARCHAR(200),
	@IdUsuarioCreador INT
)
AS
BEGIN
    INSERT INTO dbo.JA_Participantes
    (
        NombreParticipante,
        IdProveedor,
        CorreoParticipanteExterno,
		CreadoPor,
		FechaCreado
    )
    VALUES
    (   @Participante, -- NombreParticipante - nvarchar(150)
        @IdProveedor,  -- IdProveedor - int
        @Correo,
		@IdUsuarioCreador,
		GETDATE()
    )

    --Retorno el idParticpante para seleccionarlo en la lista
    SELECT @@IDENTITY
END
