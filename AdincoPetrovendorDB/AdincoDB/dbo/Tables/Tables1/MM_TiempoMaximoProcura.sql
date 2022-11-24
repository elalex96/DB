CREATE TABLE [dbo].[MM_TiempoMaximoProcura] (
    [IdTiempoMaximoProcura]  INT   IDENTITY (10000, 1) NOT NULL,
    [IdProcedimientoProcura] INT   NULL,
    [MontoMinimo]            MONEY NULL,
    [MontoMaximo]            MONEY NULL,
    [IdMoneda]               INT   NULL,
    [DiasMaximo]             INT   NULL,
    [Activo]                 BIT   NULL,
    CONSTRAINT [PK_MM_TiempoMaximoProcura] PRIMARY KEY CLUSTERED ([IdTiempoMaximoProcura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

