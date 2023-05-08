-- =============================================
 -- Modified: DANIEL AC 
-- Updated date: 02/01/2017 
-- Description: Agregue campos IdProveedorCreador,IdContratoCreador,ModificadoPor,ModificadoEl
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAModificarJuntaAclaracion]
(
    @FechaHora DATETIME,
    @Comentario NVARCHAR(MAX),
    @IdDomicilio INT,
    @IdUsuarioCreador INT,
    @IdSolPed INT,
    @IdTopic INT
)
AS
BEGIN
    INSERT INTO dbo.JA_TopicAclaracionesHistorico
    (
        IdTopic,
        IdDomicilio,
        FechaHoraJunta,
        Comentario,
        IdSolPed,
        IdOferta,
        CreadoPor,
        FechaCreado,
        IdProveedorCreador,
		IdContratoCreador,
		ModificadoPor,
		ModificadoEl
    )
    SELECT IdTopic,
           IdDomicilio,
           FechaHoraJunta,
           Comentario,
           IdSolPed,
           IdOferta,
           CreadoPor,
           FechaCreado,
		   IdProveedorCreador,
		   IdContratoCreador,
		   ModificadoPor,
		   ModificadoEl
    FROM dbo.JA_TopicAclaraciones
    WHERE IdTopic = @IdTopic

    UPDATE dbo.JA_TopicAclaraciones
    SET IdDomicilio = @IdDomicilio,
        FechaHoraJunta = @FechaHora,
        Comentario = @Comentario,
        ModificadoEl = GETDATE(),
        ModificadoPor = @IdUsuarioCreador
    WHERE IdTopic = @IdTopic

    --Se retorna el id topic para agregar a los participantes y los documentos
    SELECT @IdTopic
END
 