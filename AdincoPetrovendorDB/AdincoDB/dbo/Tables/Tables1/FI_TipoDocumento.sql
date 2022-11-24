CREATE TABLE [dbo].[FI_TipoDocumento] (
    [id_TipoDocumento] INT           IDENTITY (1, 1) NOT NULL,
    [TipoDocumento]    VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_FI_TipoDocumento] PRIMARY KEY CLUSTERED ([id_TipoDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

