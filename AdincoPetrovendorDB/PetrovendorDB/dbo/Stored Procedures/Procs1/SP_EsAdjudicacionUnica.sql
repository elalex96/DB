-- ============================================= 
-- Author:		Pedro Acuña
-- Create date: 05/Jun/2018
-- Description:	se revisa si es adjudicacion unica o parcial
-- =============================================

CREATE PROCEDURE SP_EsAdjudicacionUnica @IdPedido INT, @IdProveedor INT
AS
	BEGIN
		IF EXISTS
			(	SELECT		1
				FROM		MM_Pedido AS p
				INNER JOIN	dbo.MM_SolicitudPedido solPed
					ON solPed.IdSolicitudPedido = p.IdSolicitudPedido
				WHERE
							solPed.IdProveedor = @IdProveedor
							AND p.IdPedido = @IdPedido
							AND solped.AdjudicableParcialmente = 0 ) -- 0 se refiere a adjudicacion unica
			SELECT 1	--Es adjudicacion unica
		ELSE SELECT 0	-- es adjudicacion parcial
	END
