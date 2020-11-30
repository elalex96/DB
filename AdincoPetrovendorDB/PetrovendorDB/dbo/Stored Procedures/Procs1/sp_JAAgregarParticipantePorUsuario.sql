CREATE PROCEDURE [dbo].[sp_JAAgregarParticipantePorUsuario]
(
    @IdUsuario INT,
    @IdProveedor INT,
	@IdusuarioCreador INT
)
AS
BEGIN
    INSERT INTO dbo.JA_Participantes
    (
        IdUsuario,
        IdProveedor,
		CreadoPor,
		FechaCreado
    )
    VALUES
    (   @IdUsuario, -- IdUsuario - int
        @IdProveedor,
		@IdusuarioCreador,
		GETDATE()
    )

	--retorno el idParticipante que se inserto
	SELECT @@IDENTITY
END
