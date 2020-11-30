CREATE TABLE [dbo].[CO_TransicionEstado] (
    [IdTransicion]        INT            IDENTITY (1, 1) NOT NULL,
    [IdEstadoActual]      INT            NULL,
    [IdEstadoSiguiente]   INT            NULL,
    [NombreCambioEstado]  NVARCHAR (MAX) NULL,
    [ComentarioRequerido] BIT            NULL,
    [CreadoPor]           INT            NULL,
    CONSTRAINT [PK_Transicion] PRIMARY KEY CLUSTERED ([IdTransicion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

