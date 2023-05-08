-- =============================================
-- Author:	Pedro Acuña
-- Create date: 16-07-2018
-- Description:	SP que obtiene Las requisiciones aprobadas y  pendientes por enviar a cotizar (pendientes por mercadear)
-- =============================================
-- Author:	Marcos Garcia
-- Create date: 30-05-2019
-- Description:	Se CONCATENA el Nombre del Presupuesto e IdPresupuestoCNH en la linea de Motivo de Urgencia
-- =============================================

CREATE PROCEDURE [dbo].[SP_RptRequisicionesAprobadasPendCotizar] @IdProveedor INT, @IdContrato INT
AS
	BEGIN
		SELECT 
			SP.IdSolicitudPedido,
			CONCAT('Referente al Presupuesto: ',CP.Nombre COLLATE Modern_Spanish_CI_AS,' [', CP.IdPresupuestoCNH COLLATE Modern_Spanish_CI_AS, '] | Con Justificacion: ',SP.MotivoUrgencia) AS MotivoUrgencia,
			TSP.TipoSolicitudPedido, 
			PSP.Prioridad, 
			SP.FechaAlta ,
					( CASE SP.UnaSolaEntregaRequerida
					  WHEN 1 THEN
						  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 103 )
					  WHEN 0 THEN
						  CONCAT (
							  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 103 ), ' -- ' ,
							  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 103 ))
					  END ) AS FechaEntrega, U.Nombre, CASE WHEN SP.PeticionEnviada = 1 THEN
																'Enviada'
													   WHEN ISNULL(SP.PeticionEnviada, 0) = 0 THEN
														   'Pendiente de Enviar'
													   END AS EstatusOferta ,
					ISNULL ( SP.IdTipoProceso, 0 ) AS IdTipoProceso ,
					ISNULL ( TP.TipoPedido, 'Sin clasificación' ) AS NombreTipo
		FROM		dbo.MM_SolicitudPedido AS SP
		LEFT JOIN Adinco.dbo.CO_Presupuesto AS CP ON CP.IdPresupuesto = SP.IdPresupuesto
		INNER JOIN	dbo.MM_TipoSolicitudPedido AS TSP
			ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
		INNER JOIN	dbo.MM_PrioridadSolicitudPedido AS PSP
			ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
		INNER JOIN	dbo.TA_Operacion AS OT
			ON OT.IdDocumento = SP.IdSolicitudPedido
		INNER JOIN	dbo.S_Usuario AS U
			ON U.IdUsuario = OT.IdAsignador
		LEFT JOIN	dbo.MM_TipoPedido TP
			ON TP.IdTipoPedido = SP.IdTipoProceso
		WHERE
					SP.IdProveedor = @IdProveedor
					AND OT.IdEstatusOperacion = 2
					AND OT.IdTipoOperacion = 2
					AND SP.Activo = 1
					AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
					AND TP.TipoPedido IS NULL
					AND SP.IdContrato = @IdContrato
					AND ISNULL(SP.PeticionEnviada, 0) = 0
		GROUP BY	SP.IdSolicitudPedido, CP.Nombre,CP.IdPresupuestoCNH,SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
					SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
					SP.PeticionEnviada, SP.IdTipoProceso, TP.TipoPedido, SP.IdEstatusEliminado
		ORDER BY	SP.IdSolicitudPedido DESC
	END
