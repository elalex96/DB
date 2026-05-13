CREATE TABLE [dbo].[FI_VSM] (
    [IdVSM]         INT      IDENTITY (10000, 1) NOT NULL,
    [IdFechaIni]    DATETIME NULL,
    [IdFechaFin]    DATETIME NULL,
    [Valor]         MONEY    NULL,
    [Activo]        BIT      NULL,
    [CreadoEn]      DATETIME NULL,
    [CreadoPor]     INT      NULL,
    [ModificadoEn]  DATETIME NULL,
    [ModificadoPor] INT      NULL,
    CONSTRAINT [PK_FI_VSM] PRIMARY KEY CLUSTERED ([IdVSM] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

