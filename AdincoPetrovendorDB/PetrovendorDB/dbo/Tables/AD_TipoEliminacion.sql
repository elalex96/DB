CREATE TABLE [dbo].[AD_TipoEliminacion] (
    [IdTipoEliminacion]  INT            NOT NULL,
    [TipoEliminacion]    NVARCHAR (100) NULL,
    [DetalleEliminacion] NVARCHAR (200) NULL,
    UNIQUE NONCLUSTERED ([IdTipoEliminacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

