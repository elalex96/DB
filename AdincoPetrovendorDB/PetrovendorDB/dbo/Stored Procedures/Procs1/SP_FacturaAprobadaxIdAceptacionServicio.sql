-- =============================================
-- Author:		Pedro Acuña
-- Create date: 16/04/2018
-- Description:	obtener si ya fue aprobada por todos los aprobadores la factura para enviar el correo de evaluacion del proveedor
-- =============================================

CREATE PROCEDURE SP_FacturaAprobadaxIdAceptacionServicio ( @IdAceptacionPedido INT )
AS
	BEGIN
		SELECT	 estatus.IdEstatus, estatus.Nombre
		FROM	 MM_AceptacionFactura AF
		INNER JOIN dbo.FI_Factura factura
			ON factura.IdFactura = AF.IdFactura
		INNER JOIN dbo.TA_Operacion TAO
			ON AF.IdAceptacionFactura = TAO.IdDocumento
		INNER JOIN dbo.TA_Tarea tarea
			ON tarea.IdOperacion = TAO.IdOperacion
		INNER JOIN dbo.MM_AceptacionPedido AP
			ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		INNER JOIN dbo.TA_Estatus estatus
			ON estatus.IdEstatus = TAO.IdEstatusOperacion
		WHERE	 AF.IdAceptacionPedido = @IdAceptacionPedido
		GROUP BY estatus.IdEstatus, estatus.Nombre
	END