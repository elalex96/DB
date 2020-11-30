CREATE TABLE [dbo].[CO_LogEstadoRegistro] (
    [idLogEstadoRegistro] INT            IDENTITY (1, 1) NOT NULL,
    [IdRegistro]          INT            NULL,
    [Fecha]               DATETIME       NULL,
    [Usuario]             NVARCHAR (MAX) NULL,
    [IdEstado]            INT            NULL,
    [IdEstadoAnterior]    INT            NULL,
    [CreadoPor]           INT            NULL,
    CONSTRAINT [PK_LogEstadoRegistro] PRIMARY KEY CLUSTERED ([idLogEstadoRegistro] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

