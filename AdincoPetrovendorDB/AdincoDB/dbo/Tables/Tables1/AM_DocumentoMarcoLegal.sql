CREATE TABLE [dbo].[AM_DocumentoMarcoLegal] (
    [IdDocumentoML]   INT            IDENTITY (1, 1) NOT NULL,
    [IdMarcoLegal]    INT            NULL,
    [NombreDocumento] NVARCHAR (MAX) NULL,
    [Url]             NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AM_DocumentoMarcoLegal] PRIMARY KEY CLUSTERED ([IdDocumentoML] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AM_DocumentoMarcoLegal_AM_MarcoLegal] FOREIGN KEY ([IdMarcoLegal]) REFERENCES [dbo].[AM_MarcoLegal] ([IdMarcoLegal])
);

