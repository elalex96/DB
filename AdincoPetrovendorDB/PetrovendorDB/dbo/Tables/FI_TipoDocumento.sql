CREATE TABLE [dbo].[FI_TipoDocumento] (
    [id_TipoDocumento] INT           NOT NULL,
    [TipoDocumento]    VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_FI_TipoDocumento] PRIMARY KEY CLUSTERED ([id_TipoDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    UNIQUE NONCLUSTERED ([id_TipoDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

