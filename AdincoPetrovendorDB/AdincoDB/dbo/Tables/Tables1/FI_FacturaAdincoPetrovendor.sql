CREATE TABLE [dbo].[FI_FacturaAdincoPetrovendor] (
    [IdFacturaAdincoPetrovendor] INT      IDENTITY (1, 1) NOT NULL,
    [IdFacturaPetrovendor]       INT      NULL,
    [IdFacturaAdinco]            INT      NULL,
    [FechaIntercambio]           DATETIME NULL,
    [Activo]                     BIT      NULL,
    CONSTRAINT [PK_FI_FacturaAdincoPetrovendor] PRIMARY KEY CLUSTERED ([IdFacturaAdincoPetrovendor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

