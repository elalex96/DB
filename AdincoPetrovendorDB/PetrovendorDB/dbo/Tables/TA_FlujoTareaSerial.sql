CREATE TABLE [dbo].[TA_FlujoTareaSerial] (
    [IdFlujoTareaSerial] INT IDENTITY (1, 1) NOT NULL,
    [IdEstadoOrigen]     INT NULL,
    [IdEstadoDestino]    INT NULL,
    [IdEstatusNecesario] INT NULL,
    CONSTRAINT [PK_TaFlujoTareaSerial] PRIMARY KEY CLUSTERED ([IdFlujoTareaSerial] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TaFlujoTareaSerial_TaEstadosAprobacionSerial] FOREIGN KEY ([IdEstadoDestino]) REFERENCES [dbo].[TA_EstadoFlujoTarea] ([Idestado])
);

