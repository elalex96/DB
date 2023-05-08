CREATE PROCEDURE [dbo].[EN_GuardaDocumentosPorVersion]--12,10006,10061,3
    @idVersion INT,
    @InstanciaEntregableId INT,
    @idUsuario INT,
    @idContrato INT 
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO EN_DocumentoVersion
    (
        DocumentoEntregableId,
        idInstanciaEntregable,
        N_version,
        CreadoPor,
        CreadoEl,
        Activo
    )
    (SELECT DocumentoEntregableId,
            @InstanciaEntregableId,
            @idVersion,
            @idUsuario,
            GETDATE(),
            1
     FROM EN_EntregableDocumento
     WHERE idInstanciaEntregable = @InstanciaEntregableId
           AND Activo = 1 
           AND idTipoArchivo=10000);
END;