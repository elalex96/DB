-- =============================================
-- Author:		Pedro Acuña
-- Create date: 08/JUL/2019
-- Description: Retorna el monto remanente que tiene la aceptacion de servicio
-- =============================================

CREATE FUNCTION FN_CarsoObtenerRemanenteAceptacion
(
    @RecId VARCHAR(8000),
    @DataAreaId VARCHAR(8000),
    @IdPedido INT,
    @IdOC VARCHAR(4000),
	@Asiento VARCHAR(8000)
)
RETURNS DECIMAL
AS
BEGIN
    DECLARE @RetornoRemanente DECIMAL(20, 2)


    SELECT @RetornoRemanente = SUM(ISNULL(pd.Cantidad, 0)) - SUM(ISNULL(apd.Cantidad, 0))
    FROM dbo.MM_AceptacionPedido ap
        INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
            ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
        INNER JOIN dbo.MM_PedidoDetalle pd
            ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
               AND ISNULL(pd.IdEstatusEliminado, 0) = 0
    WHERE ap.IdOcCarso = @IdOC
		  AND ap.Asiento = @Asiento
          AND ISNULL(apd.IdEliminado, 0) = 0


    RETURN @RetornoRemanente
END
