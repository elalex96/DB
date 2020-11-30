CREATE TABLE [dbo].[PR_TiposTanques] (
    [IdTipoTanque] INT           NOT NULL,
    [Descripcion]  VARCHAR (250) NULL,
    [Activo]       BIT           NULL,
    CONSTRAINT [PK_PR_TiposTanques] PRIMARY KEY CLUSTERED ([IdTipoTanque] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

