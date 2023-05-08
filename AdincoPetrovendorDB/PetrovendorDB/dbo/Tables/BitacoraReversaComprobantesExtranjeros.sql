CREATE TABLE [dbo].[BitacoraReversaComprobantesExtranjeros] (
    [IdBitacoraReversaComprobanteExtranjero] INT           NOT NULL,
    [Motivo]                                 VARCHAR (MAX) NULL,
    [Fecha]                                  DATETIME      NULL,
    [IdOperacion]                            INT           NULL,
    CONSTRAINT [PK_BitacoraReversaComprobantesExtranjeros] PRIMARY KEY CLUSTERED ([IdBitacoraReversaComprobanteExtranjero] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

