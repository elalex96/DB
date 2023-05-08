CREATE TABLE [dbo].[CO_RelacionEmpresas] (
    [IdRelacionEmpresas] INT      IDENTITY (1, 1) NOT NULL,
    [IdContratista]      INT      NULL,
    [IdRelacionada]      INT      NULL,
    [CreadoPor]          INT      NULL,
    [CreadoEl]           DATETIME NULL,
    [ModificadoPor]      INT      NULL,
    [ModificadoEl]       DATETIME NULL,
    [Activo]             BIT      NULL,
    CONSTRAINT [PK_CO_RelacionEmpresas] PRIMARY KEY CLUSTERED ([IdRelacionEmpresas] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

