CREATE TABLE [dbo].[TA_HistorialFlujoTarea] (
    [IdHistorial]   INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]   NVARCHAR (MAX) NULL,
    [IdOperacion]   INT            NULL,
    [Fecha]         DATETIME       NULL,
    [IdEstadoFlujo] INT            NULL,
    CONSTRAINT [PK_TA_FlujoTareaHistorial] PRIMARY KEY CLUSTERED ([IdHistorial] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

