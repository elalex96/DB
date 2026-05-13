CREATE TABLE [dbo].[MM_AceptacionNotaCredito] (
    [IdAceptacionNotaCredito] INT            IDENTITY (10000, 1) NOT NULL,
    [IdFacturaNotaCredito]    INT            NULL,
    [IdAceptacionPedido]      INT            NULL,
    [TipoRelacion]            NVARCHAR (50)  NULL,
    [CFDIRelacionados]        NVARCHAR (MAX) NULL,
    [NoParcialidad]           INT            NULL,
    [CreadoEl]                DATETIME       NULL,
    [CreadoPor]               INT            NULL,
    [Activo]                  BIT            NULL,
    [IdEstatusEliminada]      INT            NULL,
    [IdEliminado]             INT            NULL,
    PRIMARY KEY CLUSTERED ([IdAceptacionNotaCredito] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

