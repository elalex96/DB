CREATE TABLE [dbo].[EN_ExcepcionesFechaBitacora] (
    [IdExcepcionBitacora]              INT           IDENTITY (10000, 1) NOT NULL,
    [IdInstanciaEntregable]            INT           NULL,
    [FechaCalculadaEntregaRegAnterior] VARCHAR (300) NULL,
    [UsuarioId]                        INT           NULL,
    [ContratoId]                       INT           NULL,
    [FechaMovimiento]                  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdExcepcionBitacora] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([ContratoId]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    FOREIGN KEY ([UsuarioId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

