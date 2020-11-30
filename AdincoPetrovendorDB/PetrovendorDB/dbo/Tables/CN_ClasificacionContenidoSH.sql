CREATE TABLE [dbo].[CN_ClasificacionContenidoSH] (
    [IdClasificacionSH]    INT            IDENTITY (1, 1) NOT NULL,
    [ClasificacionNombreL] NVARCHAR (MAX) NULL,
    [ClasificacionNombreC] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CN_ClasificacionContenidoSH] PRIMARY KEY CLUSTERED ([IdClasificacionSH] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

