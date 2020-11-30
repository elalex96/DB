CREATE TABLE [dbo].[IN_AL_TipoMovimiento] (
    [IdTipoMovimiento] TINYINT      NOT NULL,
    [Nombre]           VARCHAR (50) NOT NULL,
    [EsEntrada]        BIT          NULL,
    [EsSalida]         BIT          NULL,
    CONSTRAINT [PK_IN_AL_TipoMovimiento] PRIMARY KEY CLUSTERED ([IdTipoMovimiento] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

