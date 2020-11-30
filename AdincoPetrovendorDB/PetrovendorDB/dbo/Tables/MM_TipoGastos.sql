CREATE TABLE [dbo].[MM_TipoGastos] (
    [IdTipoGasto] INT            IDENTITY (1, 1) NOT NULL,
    [TipoGasto]   NVARCHAR (300) NULL,
    [CreadoEl]    DATETIME       NULL,
    [Descripción] NVARCHAR (300) NULL,
    CONSTRAINT [PK_MM_TipoCoste] PRIMARY KEY CLUSTERED ([IdTipoGasto] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

