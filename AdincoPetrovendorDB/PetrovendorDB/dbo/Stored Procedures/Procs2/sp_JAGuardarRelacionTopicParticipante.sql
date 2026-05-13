-- =============================================
-- Author:		PEDRO A
-- Create date: 29/12/2017
-- Description:	ACTUALIZACIÓN DAC
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAGuardarRelacionTopicParticipante]
(
    @IdTopic INT,
    @IdParticipante INT = 0, --si el idParticipante es 0 entonces es correo externo
    @IdUsuarioCreador INT,
    @NombreExterno NVARCHAR(MAX),
    @CorreoExterno NVARCHAR(MAX),
	@IdProveedor INT 
)
AS
BEGIN
    DECLARE @IdExterno INT  

    --Si tiene participantes externos primero insertarlos y despues guardar la relacion

    IF (@CorreoExterno != '')
    BEGIN
        INSERT INTO dbo.JA_Participantes
        (
            NombreParticipante,
            CorreoParticipanteExterno,
            IdProveedor,
            IdUsuario,
            CreadoPor,
            FechaCreado,
            Activo
        )
        VALUES
        (   @NombreExterno,    -- NombreParticipante - nvarchar(150)
            @CorreoExterno,    -- CorreoParticipanteExterno - nvarchar(200)
            @IdProveedor,      -- IdProveedor - int
            @IdUsuarioCreador, -- IdUsuario - int
            @IdUsuarioCreador, -- CreadoPor - int
            GETDATE(),         -- FechaCreado - smalldatetime
            NULL               -- Activo - bit
        )
        SELECT @IdExterno = @@IDENTITY
    END

    IF (@IdParticipante = 0)
        SELECT @IdParticipante = @IdExterno

    INSERT INTO dbo.JA_RelacionParticipantes
    (
        IdTopic,
        IdParticipante,
        CreadoPor,
        FechaCreado
    )
    VALUES
    (   @IdTopic,        -- IdTopic - int
        @IdParticipante, -- IdParticipante - int
        @IdUsuarioCreador,
        GETDATE()
    )
END
