CREATE TABLE [dbo].[MM_FiltrosPeticionOferta] (
    [IdFiltro] INT           IDENTITY (1, 1) NOT NULL,
    [Proceso]  NVARCHAR (50) NULL,
    [Valor]    INT           NULL,
    [Filtro]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_MM_FiltrosPeticionOferta] PRIMARY KEY CLUSTERED ([IdFiltro] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

