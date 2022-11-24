CREATE TABLE [dbo].[CargaProgramadaTrabajo] (
    [IdCargaProgramadaTrabajo] INT             NOT NULL,
    [Actividad]                VARCHAR (200)   NULL,
    [Unidad]                   VARCHAR (100)   NULL,
    [Cantidad]                 DECIMAL (10, 2) NULL,
    [UnidadesActividad]        DECIMAL (10, 2) NULL,
    [UnidadesTrabajo]          DECIMAL (10, 2) NULL,
    [Estatus]                  VARCHAR (100)   NULL,
    [IdContrato]               INT             NULL,
    [Fecha]                    SMALLDATETIME   NULL,
    [IdUsuario]                INT             NULL,
    CONSTRAINT [PK_CargaProgramadaTrabajo] PRIMARY KEY CLUSTERED ([IdCargaProgramadaTrabajo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CargaProgramadaTrabajo_AP_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

