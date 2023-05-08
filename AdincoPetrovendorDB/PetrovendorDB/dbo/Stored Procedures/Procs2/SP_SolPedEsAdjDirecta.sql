-- =============================================
-- Author:	Pedro Acuña
-- Create date: 25-07-2018
-- Description:	SP para saber si la solciitud de pedido es de adjudicacion directa
-- =============================================

CREATE PROCEDURE SP_SolPedEsAdjDirecta @IdSolicitudPedido INT
AS
	BEGIN
		DECLARE @IdTipoProceso INT

		SELECT	@IdTipoProceso = IdTipoProceso
		FROM	dbo.MM_SolicitudPedido
		WHERE	IdSolicitudPedido = @IdSolicitudPedido

		IF ( @IdTipoProceso = 4 ) 
			SELECT 1	  
		ELSE 
			SELECT 0
	END