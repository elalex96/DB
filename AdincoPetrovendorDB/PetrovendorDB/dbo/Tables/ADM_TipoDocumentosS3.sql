CREATE TABLE [dbo].[ADM_TipoDocumentosS3] (
    [IdDocumento]   INT            IDENTITY (1, 1) NOT NULL,
    [TipoDocumento] NVARCHAR (MAX) NULL,
    [Aplicacion]    INT            NULL,
    [Descripcion]   NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

