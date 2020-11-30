CREATE TABLE [dbo].[TaDocumento] (
    [IdDocumento]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreDocumento] NVARCHAR (MAX) NULL,
    [RutaDocumento]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TaDocumento] PRIMARY KEY CLUSTERED ([IdDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

