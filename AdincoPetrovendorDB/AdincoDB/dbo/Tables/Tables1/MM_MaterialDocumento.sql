CREATE TABLE [dbo].[MM_MaterialDocumento] (
    [IdDocumentoMaterial] INT            IDENTITY (10000, 1) NOT NULL,
    [Documento]           NVARCHAR (MAX) NULL,
    [Activo]              BIT            NULL,
    CONSTRAINT [PK_MM_MaterialDocumento] PRIMARY KEY CLUSTERED ([IdDocumentoMaterial] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

