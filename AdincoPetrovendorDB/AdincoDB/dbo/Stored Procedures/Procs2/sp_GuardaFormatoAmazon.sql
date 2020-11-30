
/****** Object:  StoredProcedure [dbo].[p_EN_InsertarDocumentoEntregable]    Script Date: 10/11/2018 06:53:05 p. m. ******/
CREATE PROCEDURE [dbo].[sp_GuardaFormatoAmazon]
    @FormatoAmazonID INT OUT,
    @pNombreArchivo VARCHAR(250),
    @pFolder VARCHAR(100),
    @pUUIDAmazon UNIQUEIDENTIFIER,
    @pMeta VARCHAR(50),
    @pBucket VARCHAR(50),
    @idUsuario INT,
    @idContrato INT,
    @MesReporte DATE,
    @opcionreporte INT
AS
BEGIN
    --SELECT * FROM Delete from SCOC_FormatoAmazon
    INSERT INTO SCOC_FormatoAmazon
    (
        MesReporte,
        OpcionReporte,
        idContrato,
        Bucket,
        Folder,
        UUIDAmazon,
        NombreArchivo,
        Meta,
        CreadoPor,
        CreadoEl,
        Activo
    )
    VALUES
    (@MesReporte, @opcionreporte, @idContrato, @pBucket, @pFolder, @pUUIDAmazon, @pNombreArchivo, @pMeta, @idUsuario,
     GETDATE(), 1);

  
END;
