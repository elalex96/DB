CREATE TABLE [dbo].[IN_AL_RecepcionReingreso] (
    [CantidadMovimiento]       DECIMAL (14, 2) NULL,
    [CreadoEl]                 DATETIME        NOT NULL,
    [CreadoPor]                INT             NOT NULL,
    [IdMovimientoDetEntrega]   INT             NULL,
    [IdMovimientoDetRecepcion] INT             NOT NULL,
    [IdMovimientoDetReingreso] INT             NOT NULL,
    [IdRecepcionReingreso]     INT             IDENTITY (1, 1) NOT NULL
);

