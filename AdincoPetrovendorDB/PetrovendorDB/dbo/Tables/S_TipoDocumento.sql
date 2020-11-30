CREATE TABLE [dbo].[S_TipoDocumento] (
    [IdTipoDocumento]     INT             IDENTITY (1, 1) NOT NULL,
    [NombreTipoDocumento] NVARCHAR (1000) NULL,
    [Requerido]           BIT             NULL,
    CONSTRAINT [PK_S_TipoDocumento] PRIMARY KEY CLUSTERED ([IdTipoDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

