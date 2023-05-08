CREATE TABLE [dbo].[EN_TipoDocumentoEntregable] (
    [IdTipoDocumentoEntregable] INT            IDENTITY (1, 1) NOT NULL,
    [TipoDocumento]             NVARCHAR (MAX) NULL,
    [CreadoPor]                 INT            NULL,
    CONSTRAINT [PK_Cat_General_TipoDocumentoEntregable] PRIMARY KEY CLUSTERED ([IdTipoDocumentoEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

