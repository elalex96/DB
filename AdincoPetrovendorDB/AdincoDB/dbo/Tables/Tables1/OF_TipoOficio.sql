CREATE TABLE [dbo].[OF_TipoOficio] (
    [idTipoOficio]     INT          IDENTITY (10000, 1) NOT NULL,
    [NombreTipoOficio] VARCHAR (50) NULL,
    [CreadoPor]        INT          NULL,
    [CreadoEl]         DATETIME     NULL,
    [ModificadoPor]    INT          NULL,
    [ModificadoEl]     DATETIME     NULL,
    [Activo]           BIT          NULL,
    CONSTRAINT [PK__OF_TipoO__B07036F042ABAFEC] PRIMARY KEY CLUSTERED ([idTipoOficio] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

