CREATE TABLE [dbo].[MM_ProcedimientoProcura] (
    [IdProcedimientoProcura] INT            IDENTITY (10000, 1) NOT NULL,
    [ProcedimientoProcura]   NVARCHAR (MAX) NULL,
    [Descripcion]            NVARCHAR (MAX) NULL,
    [Activo]                 BIT            NULL,
    CONSTRAINT [PK_MM_ProcedimientoProcura] PRIMARY KEY CLUSTERED ([IdProcedimientoProcura] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

