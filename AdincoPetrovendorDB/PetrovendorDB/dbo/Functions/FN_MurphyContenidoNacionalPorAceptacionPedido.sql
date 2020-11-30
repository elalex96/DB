

-- =============================================
-- Author:		Pedro Acu�a
-- Create date: 22/05/2019
-- Description: Retorna el porcentaje del calculo de contenido nacional por Aceptacion de Pedido
-- =============================================

CREATE FUNCTION FN_MurphyContenidoNacionalPorAceptacionPedido ( @IdAceptacionPedido INT )
RETURNS FLOAT
AS
    BEGIN
        DECLARE
            @PCNPonderado FLOAT, @TotalPCN FLOAT


        DECLARE @TablaPonderacion TABLE ( PCNDetalle FLOAT, ValorFactura FLOAT, PCNFactura FLOAT )

        DECLARE @ValorFacturaTotal FLOAT


        INSERT INTO
            @TablaPonderacion ( PCNDetalle, ValorFactura, PCNFactura )
        SELECT
                ROUND(ISNULL(APD.PCN, 0), 4),
                ISNULL(V.ValorFactura, 0),
                ROUND(ISNULL(APD.PCN, 0), 4) * ISNULL(V.ValorFactura, 0)
        FROM
                dbo.MPY_MM_AceptacionPedidoDetalle APD
            LEFT JOIN
                dbo.MPY_MM_AceptacionPedido        AP
                    ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
            LEFT JOIN
                dbo.MPY_MM_PCN_ValoresPesos        V
                    ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
        WHERE
                AP.IdAceptacionPedido = @IdAceptacionPedido


        SELECT
            @ValorFacturaTotal = SUM(ISNULL(ValorFactura, 0)),
            @TotalPCN          = SUM(ISNULL(PCNFactura, 0))
        FROM
            @TablaPonderacion
		

        IF ( @TotalPCN = 0 OR  @TotalPCN IS NULL) RETURN 0
        ELSE
            BEGIN
                SELECT
                    @PCNPonderado
                    = ROUND(
                          ISNULL(@TotalPCN, 0)
                          / ISNULL(@ValorFacturaTotal, 0), 4)
            END


        RETURN @PCNPonderado
    END