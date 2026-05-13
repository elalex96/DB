CREATE TABLE [dbo].[IN_AL_MovimientoDetalleDoc] (
    [CreadoEl]               DATETIME      NOT NULL,
    [CreadoPor]              INT           NOT NULL,
    [FileName]               VARCHAR (100) NOT NULL,
    [IdMovimientoDetalle]    INT           NOT NULL,
    [IdMovimientoDetalleDoc] INT           NOT NULL,
    [IdDocumento]            INT           NULL
);

