CREATE TABLE [dbo].[AX_AsientoFactura] (
    [IdAsientoFactura]          INT           IDENTITY (1, 1) NOT NULL,
    [UUID]                      VARCHAR (100) NULL,
    [DataAreaId]                VARCHAR (MAX) NULL,
    [CuentaSectorHidrocarburos] VARCHAR (100) NULL,
    [NumeroPoliza]              INT           NULL,
    [Identificador]             INT           NULL,
    [RECID]                     VARCHAR (MAX) NULL,
    [FechaRegistro]             DATETIME      NULL,
    [FechaFechaModifica]        DATETIME      NULL,
    CONSTRAINT [PK_AX_AsientoFactura] PRIMARY KEY CLUSTERED ([IdAsientoFactura] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

