CREATE TABLE [dbo].[PCM_MontosPresupuestoPedidos] (
    [IdPedido]                 INT            NULL,
    [IdPedidoDetalle]          INT            NULL,
    [IdAceptacionpedido]       INT            NULL,
    [DescripcionLarga]         NVARCHAR (MAX) NULL,
    [Cantidad]                 FLOAT (53)     NULL,
    [Monto_Total]              FLOAT (53)     NULL,
    [MonedaPedido_Aceptado]    NVARCHAR (100) NULL,
    [MonedaPedido_AceptadoDLS] FLOAT (53)     NULL,
    [Fecha_Aceptacion]         DATETIME       NULL,
    [Usuario_Acepto]           NVARCHAR (MAX) NULL,
    [subtareaSolped]           NVARCHAR (MAX) NULL,
    [subtareaAcepta]           NVARCHAR (MAX) NULL,
    [tipoCambio]               FLOAT (53)     NULL
);

