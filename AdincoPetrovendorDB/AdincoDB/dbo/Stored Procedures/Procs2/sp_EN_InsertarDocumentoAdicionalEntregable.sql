CREATE PROCEDURE[dbo].[sp_EN_InsertarDocumentoAdicionalEntregable]
    @pAWSDocumentoId INT OUT,
    @InstanciaEntregable INT,
    @pNombreArchivo VARCHAR(250),
    @pFolder VARCHAR(100),
    @pUUIDAmazon UNIQUEIDENTIFIER,
    @pMeta VARCHAR(50),
    @pBucket VARCHAR(50),
    @idUsuario INT,
	@idContrato INT,
    @idTipoArchivo INT,
	@idLineaTiempo INT
AS
BEGIN
set language  Spanish;

DECLARE @ContratoEntregableId INT;

SELECT @pAWSDocumentoId = ISNULL(MAX(DocumentoEntregableId), 0) + 1
FROM EN_EntregableDocumento;


SELECT @ContratoEntregableId = IdContratoEntregable
FROM EN_InstanciasEntregable
WHERE idInstanciaEntregable = @InstanciaEntregable;


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
                                    idTipoArchivo)
SELECT @pAWSDocumentoId,
       @ContratoEntregableId,
       @InstanciaEntregable,
       @pNombreArchivo,
       @pUUIDAmazon,
       @pMeta,
       @pBucket,
       @idUsuario,
       GETDATE(),
       NULL,
       NULL,
       @pFolder,
       1,
       @idTipoArchivo;

    INSERT INTO EN_DocumentoVersion (DocumentoEntregableId,
                                     idInstanciaEntregable,
                                     N_version,
                                     CreadoPor,
                                     CreadoEl,
                                     ModificadoPor,
                                     ModificadoEl,
                                     Activo)
    VALUES (@pAWSDocumentoId, @InstanciaEntregable, @idLineaTiempo, @idUsuario, GETDATE(), @idUsuario, GETDATE(), 1);

IF((SELECT COUNT(1) FROM EN_HistorialAprobacionesLineaTiempo WHERE idInstanciaEntregable	=	@InstanciaEntregable AND IdLineaTiempo	= @IdLineaTiempo AND idTipoOperacion	=	8)	=	0)
	BEGIN
	INSERT INTO EN_HistorialAprobacionesLineaTiempo (
													IdLineaTiempo,
													idInstanciaEntregable,
													idContrato,
													Comentario,
													Rechazado,
													idTipoOperacion,
													CreadoPor,
													CreadoEn,
													ModificadoPor,
													ModificadoEn,
													Activo,
													ActualizadoByApp,
													URLRepositorio,
													ContieneURLRepositorio)
	VALUES (@IdLineaTiempo,@InstanciaEntregable,@idContrato,'Fechas de ingreso de documentos:'+ FORMAT (getdate(), 'dd-MM-yy hh:mm tt'),0,8,@idUsuario,GETDATE(),@idUsuario,GETDATE(),1,0,'En este paso no se ingresa URL',0);
	END
	ELSE
	BEGIN
		UPDATE 
			EN_HistorialAprobacionesLineaTiempo
			SET 
				ModificadoPor	=	@idUsuario,
				ModificadoEn	=	GETDATE(),
				Comentario	=	Comentario	+ ',' + FORMAT (getdate(), 'dd-MM-yy hh:mm tt')
			WHERE 
				idInstanciaEntregable	=	@InstanciaEntregable 
				AND IdLineaTiempo	= @IdLineaTiempo 
				AND idTipoOperacion	=	8
	END


END;



