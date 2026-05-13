--Modificado 05-dic-2017 ahora se muestran todos los usuarios del proveedor logueado
CREATE PROCEDURE [db_accessadmin].sp_JACargarParticipantesSolPedExternos
(
    @IdTopic INT,
    @IdSolPed INT
)
AS
BEGIN
    SELECT IdParticipante, NombreParticipante, CorreoParticipanteExterno
    FROM dbo.JA_Participantes
    WHERE Activo is NULL
          AND IdParticipante IN (
                                    SELECT relPart.IdParticipante
                                    FROM dbo.JA_TopicAclaraciones topic
                                        INNER JOIN dbo.JA_RelacionParticipantes relPart
                                            ON topic.IdTopic = relPart.IdTopic
                                        INNER JOIN dbo.JA_Participantes parti
                                            ON parti.IdParticipante = relPart.IdParticipante
                                    WHERE topic.IdSolPed = @IdSolPed
                                          AND relPart.IdTopic = @IdTopic
                                )
END
