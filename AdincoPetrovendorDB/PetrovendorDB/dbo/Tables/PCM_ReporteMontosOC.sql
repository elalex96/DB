CREATE TABLE [dbo].[PCM_ReporteMontosOC] (
    [IdPedido]           INT            NULL,
    [IdPedidoDetalle]    INT            NULL,
    [IdAceptacionPedido] INT            NULL,
    [DescripcionLarga]   NVARCHAR (MAX) NULL,
    [Cantidad]           FLOAT (53)     NULL,
    [Monto_Total]        FLOAT (53)     NULL,
    [Fecha_Aceptacion]   DATETIME       NULL,
    [Usuario_Acepto]     NVARCHAR (MAX) NULL
);

