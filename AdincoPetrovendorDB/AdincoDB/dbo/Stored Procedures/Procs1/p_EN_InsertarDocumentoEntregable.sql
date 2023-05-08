CREATE PROCEDURE [dbo].[p_EN_InsertarDocumentoEntregable]
    @pAWSDocumentoId INT OUT,
    @ContratoEntregableId INT,
    @InstanciaEntregable INT,
    @pNombreArchivo VARCHAR(250),
    @pFolder VARCHAR(100),
    @pUUIDAmazon UNIQUEIDENTIFIER,
    @pMeta VARCHAR(50),
    @pBucket VARCHAR(50),
    @pCreadoPor INT,
    @pAWSDocumentoPadreId INT,
    @TextoDocumento VARCHAR(MAX),
    @idTipoArchivo INT,
	@FechaRealEvidencia DATETIME = NULL,
	@Comentario VARCHAR(500) = NULL
AS
DECLARE @idLineaTiempo INT;

SELECT @pAWSDocumentoId = ISNULL(MAX(DocumentoEntregableId), 0) + 1
FROM EN_EntregableDocumento;

SET @pNombreArchivo = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@pNombreArchivo, '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','');

IF (@ContratoEntregableId = 0)
BEGIN
    SELECT @ContratoEntregableId = IdContratoEntregable
    FROM EN_InstanciasEntregable
    WHERE idInstanciaEntregable = @InstanciaEntregable;
END;

IF (@idTipoArchivo IN ( 10001, 10002, 10003, 10004 ))
BEGIN
    SELECT @pNombreArchivo = Nombre + '-' + @pNombreArchivo
    FROM AP_Usuario
    WHERE UsuarioID = @pCreadoPor;
END;

INSERT INTO EN_EntregableDocumento (DocumentoEntregableId,
                                    idContratoEntregable,
                                    idInstanciaEntregable,
                                    NombreArchivo,
                                    UUIDAmazon,
                                    Meta,
                                    Bucket,
                                    CreadoPor,
                                    CreadoEl,
                                    ModificadoPor,
                                    ModificadoEl,
                                    Folder,
                                    Activo,
                                    TextoDocumentoEntregble,
                                    idTipoArchivo,
									FechaRealEvidencia,
									Comentario)
SELECT @pAWSDocumentoId,
       @ContratoEntregableId,
       @InstanciaEntregable,
       @pNombreArchivo,
       @pUUIDAmazon,
       @pMeta,
       @pBucket,
       @pCreadoPor,
       GETDATE(),
       NULL,
       NULL,
       @pFolder,
       1,
       @TextoDocumento,
       @idTipoArchivo,
	   @FechaRealEvidencia,
	   @Comentario;

IF (ISNULL(@pAWSDocumentoPadreId, 0) > 0)
BEGIN

    INSERT INTO [dbo].[EN_EntregableRelacion]
    SELECT @pAWSDocumentoPadreId,
           @pAWSDocumentoId,
           GETDATE(),
           @pCreadoPor,
           NULL,
           NULL,
           1;
END;

IF (@idTipoArchivo IN ( 10001, 10002, 10003, 10004 ))
BEGIN
    SELECT @idLineaTiempo = MAX(IdLineaTiempo)
    FROM dbo.EN_HistorialAprobacionesLineaTiempo
    WHERE idInstanciaEntregable = @InstanciaEntregable;

    INSERT INTO EN_DocumentoVersion (DocumentoEntregableId,
                                     idInstanciaEntregable,
                                     N_version,
                                     CreadoPor,
                                     CreadoEl,
                                     ModificadoPor,
                                     ModificadoEl,
                                     Activo)
    VALUES (@pAWSDocumentoId, @InstanciaEntregable, @idLineaTiempo, @pCreadoPor, GETDATE(), @pCreadoPor, GETDATE(), 1);
    IF (@idTipoArchivo = 10002)
    BEGIN
        UPDATE dbo.EN_InstanciasEntregable
        SET BitContieneAcuse = 1
        WHERE idInstanciaEntregable = @InstanciaEntregable;
    END;


END;