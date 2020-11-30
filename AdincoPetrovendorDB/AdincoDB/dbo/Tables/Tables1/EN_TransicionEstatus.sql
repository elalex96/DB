CREATE TABLE [dbo].[EN_TransicionEstatus] (
    [IdTransicion]        INT            IDENTITY (10000, 1) NOT NULL,
    [IdEstadoActual]      INT            NULL,
    [IdEstadoSiguiente]   INT            NULL,
    [NombreCambioEstado]  NVARCHAR (MAX) NULL,
    [ComentarioRequerido] BIT            NULL,
    [CreadoPor]           INT            NULL,
    PRIMARY KEY CLUSTERED ([IdTransicion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdEstadoActual]) REFERENCES [dbo].[EN_Estatus] ([idEstatus]),
    FOREIGN KEY ([IdEstadoSiguiente]) REFERENCES [dbo].[EN_Estatus] ([idEstatus])
);

