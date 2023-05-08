CREATE TABLE [dbo].[RelacionCartaCNPedidoModificado] (
    [Id]                 INT      IDENTITY (1, 1) NOT NULL,
    [IdPedido]           INT      NOT NULL,
    [IdAceptacionPedido] INT      NOT NULL,
    [PedirCartaAnterior] BIT      NOT NULL,
    [ModificadoEl]       DATETIME NOT NULL
);

