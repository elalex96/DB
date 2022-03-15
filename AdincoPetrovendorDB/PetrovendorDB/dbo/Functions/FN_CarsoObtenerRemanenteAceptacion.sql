USE [Petrovendor]
GO

IF object_id('FN_CarsoObtenerRemanenteAceptacion', 'FN') IS NOT NULL
BEGIN
   DROP FUNCTION [dbo].[FN_CarsoObtenerRemanenteAceptacion]
END
GO

/****** Object:  UserDefinedFunction [dbo].[FN_CarsoObtenerRemanenteAceptacion]    Script Date: 14/03/2022 06:04:48 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 08/JUL/2019
-- Description: Retorna el monto remanente que tiene la aceptacion de servicio
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 14/03/2022
-- Description: Se agrega condicion de que la aceptación no este eliminada
-- =============================================
CREATE FUNCTION [dbo].[FN_CarsoObtenerRemanenteAceptacion]
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
