-- =============================================
-- Author: Pedro Acuña
-- Create date: 22/06/2018
-- Description: obtener la fecha enq ue se aprobo la requisicion
-- =============================================

CREATE FUNCTION Fn_ObtenerFechaAprobacionRequisicion
	( @IdSolicitudPedido INT ,
	  @IdProveedor INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @FechaRetorno DATETIME

		SELECT		@FechaRetorno = MAX(t.FechaCambioEstatus)
		FROM		TA_Operacion AS O
		INNER JOIN	TA_TipoOperacion AS OT
			ON OT.IdTipoOperacion = O.IdTipoOperacion
		INNER JOIN	TA_Estatus AS E
			ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN	TA_TareaOperacion AS TTO
			ON TTO.IdOperacion = O.IdOperacion
		INNER JOIN	TA_Tarea AS T
			ON T.IdTarea = TTO.IdTarea
		WHERE
					O.IdTipoOperacion = 2
					AND O.IdEstatusOperacion = 2
					AND O.IdProveedor = @IdProveedor
					AND O.IdDocumento = @IdSolicitudPedido

		RETURN @FechaRetorno
	END