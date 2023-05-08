CREATE TABLE [dbo].[AD_TipoEliminacion] (
    [IdTipoEliminacion]  INT            NOT NULL,
    [TipoEliminacion]    NVARCHAR (100) NULL,
    [DetalleEliminacion] NVARCHAR (200) NULL,
    UNIQUE NONCLUSTERED ([IdTipoEliminacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

