-- =============================================
-- Author:		Pedro Acuña
-- Create date: 08/JUL/2019
-- Description: Retorna el monto remanente que tiene la aceptacion de servicio
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 12/05/2022
-- Description: Se AGREGA QUE RETORNE UN VALOR FLOAT
-- =============================================
CREATE FUNCTION [dbo].[FN_CarsoObtenerRemanenteAceptacion]
(
    @RecId VARCHAR(8000),
    @DataAreaId VARCHAR(8000),
    @IdPedido INT,
    @IdOC VARCHAR(4000),
	@Asiento VARCHAR(8000)
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @RetornoRemanente FLOAT
	
    SELECT @RetornoRemanente = SUM(ISNULL(pd.Cantidad, 0)) - SUM(ISNULL(apd.Cantidad, 0))
    FROM dbo.MM_AceptacionPedido ap
        INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
            ON  ap.IdAceptacionPedido = apd.IdAceptacionPedido
        INNER JOIN dbo.MM_PedidoDetalle pd
            ON apd.IdPedidoDetalle =  pd.IdPedidoDetalle 
               AND ISNULL(pd.IdEstatusEliminado, 0) = 0
    WHERE ap.IdOcCarso = @IdOC
		  AND ap.Asiento = @Asiento
          AND ISNULL(apd.IdEliminado, 0) = 0
		  AND ISNULL(ap.IdEstatusEliminado,0)= 0

    RETURN @RetornoRemanente
END
