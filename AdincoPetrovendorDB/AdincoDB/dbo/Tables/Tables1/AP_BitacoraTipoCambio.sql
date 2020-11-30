CREATE TABLE [dbo].[AP_BitacoraTipoCambio] (
    [BitacoraTipoCambioId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Fecha]                DATETIME      NULL,
    [Estatus]              BIT           NULL,
    [FilasAfectadas]       INT           NULL,
    [MensajeError]         VARCHAR (300) NULL,
    PRIMARY KEY CLUSTERED ([BitacoraTipoCambioId] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

