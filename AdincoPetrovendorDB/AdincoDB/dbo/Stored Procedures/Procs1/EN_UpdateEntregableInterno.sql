-- =============================================
-- Author:		Reyna Olvera
-- Create date: 18/05/2019
-- Description:Guarda entregables internas
-- =============================================
CREATE PROCEDURE dbo.EN_UpdateEntregableInterno
    @idUsuario INT,
    @idContrato INT,
    @pDocumentoEntregable NVARCHAR(MAX),
    @pDescripcion NVARCHAR(MAX),
    @pIsActivo BIT,
    @pConsecutivo NVARCHAR(MAX),
    @pIdEntregable INT,
    @IdReceptorEntregable INT,
    @IdFrecuenciaEntregable INT,
    @EsDeProceso BIT,
    @idMarcoLegal INT,
    @Articulo VARCHAR(MAX),
    @Referencia VARCHAR(MAX),
    @Condicion VARCHAR(MAX),
    @TiempoEntrega VARCHAR(MAX),
    @actividad VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.EN_Entregable
    SET DocumentoEntregable = @pDocumentoEntregable,
        Descripcion = @pDescripcion,
        CreadoPor = @idUsuario,
        CreadoEn = GETDATE(),
        ModificadoPor = @idUsuario,
        ModificadoEn = GETDATE(),
        IsActivo = @pIsActivo,
        IsEliminado = IsEliminado,
        -- Consecutivo = @pConsecutivo,
        IdReceptorEntregable = CASE @IdReceptorEntregable
                                   WHEN 0 THEN
                                       NULL
                                   ELSE
                                       @IdReceptorEntregable
                               END,
        IdFrecuenciaEntregable = @IdFrecuenciaEntregable,
        EsDeProceso = @EsDeProceso,
        IdMarcoLegal = CASE @idMarcoLegal
                           WHEN 0 THEN
                               NULL
                           ELSE
                               @idMarcoLegal
                       END,
        Articulo = @Articulo,
        Apartado = @Referencia,
        Observaciones = @Condicion,
        TiempoEntrega = @TiempoEntrega,
        Actividad = @actividad
    WHERE IdEntregable = @pIdEntregable;
    IF @@ERROR <> 0
        SELECT CAST(@@ERROR AS NVARCHAR(8)) AS error;
    ELSE
        SELECT '' AS error;
END;

