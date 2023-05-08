-- =============================================
-- Author: Pedro Acu�a
-- Create date: 11/06/2018
-- Description: obtener el estatus general por operacion
-- =============================================

CREATE FUNCTION Fn_ObtenerEstatusSolPed
	( @IdOperacion INT )
RETURNS INT
AS
	BEGIN
		DECLARE @EstatusGeneral INT

		SELECT		@EstatusGeneral = TOO.IdEstatusOperacion
		FROM		TA_Operacion AS TOO
		INNER JOIN	TA_FlujoTarea AS FT
			ON FT.IdFlujoTarea = TOO.IdFlujoTarea
		INNER JOIN	TA_TipoFlujoTarea AS TFT
			ON TFT.IdTipoFlujoTarea = FT.IdTipoFlujo
		INNER JOIN	TA_EstadoFlujoTarea AS EFT
			ON TOO.IdEstadoFlujo = EFT.IdEstado
		INNER JOIN	TA_TipoOperacion AS TTO
			ON TTO.IdTipoOperacion = TOO.IdTipoOperacion
		INNER JOIN	TA_Estatus AS TAE
			ON TAE.IdEstatus = TOO.IdEstatusOperacion
		INNER JOIN	S_Usuario AS U
			ON U.IdUsuario = TOO.IdAsignador
		INNER JOIN	TA_Prioridad AS TP
			ON TP.IdPrioridad = TOO.IdPrioridad
		INNER JOIN	TA_Vencimiento AS TV
			ON TV.IdVencimiento = TOO.IdVigencia
		LEFT JOIN	TA_ComentariosTareaCancelada AS TCC
			ON TCC.IdOperacion = TOO.IdOperacion
		LEFT JOIN	dbo.MM_Pedidos AS PS
			ON PS.IdIdentificador = TOO.IdDocumento
			   AND	TOO.IdProveedor = PS.IdProveedorCliente
			   AND	PS.IdTipoPedido = 1 -- ORDEN DE COMPRA DIRECTA 
		WHERE		TOO.IdOperacion = @IdOperacion

		RETURN @EstatusGeneral
	END