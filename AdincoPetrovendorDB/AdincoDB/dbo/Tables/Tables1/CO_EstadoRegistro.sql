CREATE TABLE [dbo].[CO_EstadoRegistro] (
    [IdEstadoRegistro] INT            IDENTITY (10000, 1) NOT NULL,
    [NombreEstado]     NVARCHAR (MAX) NULL,
    [Descripción]      NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_EstadoRegistro] PRIMARY KEY CLUSTERED ([IdEstadoRegistro] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

