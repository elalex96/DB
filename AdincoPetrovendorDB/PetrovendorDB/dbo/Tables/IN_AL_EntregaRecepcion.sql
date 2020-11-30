CREATE TABLE [dbo].[IN_AL_EntregaRecepcion] (
    [CantidadRecepcionDesc]    DECIMAL (14, 2) NOT NULL,
    [CreadoEl]                 DATETIME        NOT NULL,
    [CreadoPor]                INT             NOT NULL,
    [IdMovimientoDetEntrega]   INT             NOT NULL,
    [IdMovimientoDetRecepcion] INT             NOT NULL,
    [IsEliminado]              BIT             CONSTRAINT [DF__IN_AL_Ent__IsEli__2CDF35F4] DEFAULT ((0)) NULL
);

