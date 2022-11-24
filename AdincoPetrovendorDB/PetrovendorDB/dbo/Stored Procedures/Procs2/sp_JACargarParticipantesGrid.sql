CREATE PROCEDURE sp_JACargarParticipantesGrid (@IdTopic INT)
AS
BEGIN
    DECLARE @TablaAuxiliar TABLE
    (
        IdParticipante INT,
        NombreParticipante NVARCHAR(MAX),
        Correo NVARCHAR(MAX)
    )

    INSERT INTO @TablaAuxiliar
    (
        IdParticipante,
        NombreParticipante,
        Correo
    )
    SELECT particip.IdParticipante,
           particip.NombreParticipante,
           particip.CorreoParticipanteExterno
    FROM dbo.JA_RelacionParticipantes relacionP
        INNER JOIN dbo.JA_Participantes particip
            ON particip.IdParticipante = relacionP.IdParticipante
    WHERE relacionP.IdTopic = @IdTopic
          AND particip.NombreParticipante IS NOT NULL

--Retorno a la vista
    SELECT IdParticipante,
           NombreParticipante,
           Correo
    FROM @TablaAuxiliar
END


