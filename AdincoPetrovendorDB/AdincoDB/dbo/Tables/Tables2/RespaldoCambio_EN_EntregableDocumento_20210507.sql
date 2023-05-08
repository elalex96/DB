CREATE TABLE [dbo].[RespaldoCambio_EN_EntregableDocumento_20210507] (
    [DocumentoEntregableId]   INT              NOT NULL,
    [idContratoEntregable]    INT              NULL,
    [idInstanciaEntregable]   INT              NULL,
    [Bucket]                  NVARCHAR (MAX)   NULL,
    [Folder]                  NVARCHAR (MAX)   NULL,
    [UUIDAmazon]              UNIQUEIDENTIFIER NULL,
    [NombreArchivo]           NVARCHAR (MAX)   NULL,
    [Meta]                    NVARCHAR (MAX)   NULL,
    [CreadoPor]               INT              NULL,
    [CreadoEl]                DATETIME         NULL,
    [ModificadoPor]           INT              NULL,
    [ModificadoEl]            DATETIME         NULL,
    [Activo]                  BIT              NULL,
    [TextoDocumentoEntregble] NVARCHAR (MAX)   NULL,
    [idTipoArchivo]           INT              NULL,
    [FechaRealEvidencia]      DATETIME         NULL,
    [Comentario]              VARCHAR (500)    NULL
);

