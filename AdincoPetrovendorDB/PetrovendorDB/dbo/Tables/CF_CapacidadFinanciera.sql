CREATE TABLE [dbo].[CF_CapacidadFinanciera] (
    [Actual]                BIT        NOT NULL,
    [Anio]                  INT        NOT NULL,
    [CapacidadFinanciera]   FLOAT (53) NOT NULL,
    [IdCapacidadFinanciera] INT        IDENTITY (1, 1) NOT NULL,
    [IdProveedor]           INT        NOT NULL,
    [IdTipoMoneda]          INT        NOT NULL
);

