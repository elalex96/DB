CREATE TABLE [dbo].[WDEA_PedidosPendientesCorreosConfirmacion] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido]   INT           NULL,
    [IdOperacion]         INT           NULL,
    [IdAprobador]         INT           NULL,
    [Purchasing_Document] VARCHAR (300) NULL,
    [IdTarea]             INT           NULL,
    [IdPedidoActual]      INT           NULL,
    [IdPedidoGeneral]     INT           NULL,
    [Procesado]           BIT           NULL,
    [CreadoEl]            DATETIME      NULL,
    [ProcesadoEl]         DATETIME      NULL,
    [IdBitacoraLectura]   INT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

