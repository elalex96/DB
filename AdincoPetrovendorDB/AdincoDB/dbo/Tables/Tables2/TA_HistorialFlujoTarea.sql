CREATE TABLE [dbo].[TA_HistorialFlujoTarea] (
    [IdHistorial]   INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]   NVARCHAR (MAX) NULL,
    [IdOperacion]   INT            NULL,
    [Fecha]         DATETIME       NULL,
    [IdEstadoFlujo] INT            NULL,
    CONSTRAINT [PK_TA_FlujoTareaHistorial] PRIMARY KEY CLUSTERED ([IdHistorial] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_FlujoTareaHistorial_TA_FlujoTareaHistorial] FOREIGN KEY ([IdOperacion]) REFERENCES [dbo].[TA_Operacion] ([IdOperacion]),
    CONSTRAINT [FK_TA_HistorialFlujoTarea_TA_EstadoFlujoTarea] FOREIGN KEY ([IdEstadoFlujo]) REFERENCES [dbo].[TA_EstadoFlujoTarea] ([Idestado])
);

