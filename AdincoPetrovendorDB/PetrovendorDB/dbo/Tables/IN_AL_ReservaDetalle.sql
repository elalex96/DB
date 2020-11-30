CREATE TABLE [dbo].[IN_AL_ReservaDetalle] (
    [CantidadReserva]          DECIMAL (14, 2) NOT NULL,
    [CreadoEl]                 DATETIME        NOT NULL,
    [CreadoPor]                INT             NOT NULL,
    [Id]                       INT             IDENTITY (1, 1) NOT NULL,
    [IdMovimientoDetRecepcion] INT             NULL,
    [IdMovimientoDetReserva]   INT             NOT NULL
);

