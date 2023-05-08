-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <07-11-2018>
-- Description:	<Se cambia la subactividad por un grupo de campos concatenados por debido a la card 687 ticket 846>
-- =============================================

CREATE procedure [dbo].[MM_SP_ConsultaDetalleSolicitudPedidoLineaPresupuesto]
	@IdSolicitudPedidoDetalle INT

AS
BEGIN
	SELECT s.IdSolicitudPedidoDetalleLineaPresupuesto, cc.CentroCosto, i.NombreInstalacion, dbo.Fn_RetornarMesProgramadoActividadConcat(lp.IdLineaPresupuestoMes) AS SubActividad
	FROM dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS s
		LEFT JOIN Petrovendor.dbo.CC_CentroCosto AS cc ON cc.IdCentroCosto = s.IdCentroCosto
		LEFT JOIN Adinco.dbo.CO_Instalacion AS i ON i.IdInstalacion = s.IdInstalacion
		LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS lp ON lp.IdLineaPresupuestoMes = s.IdLineaPresupuesto
		LEFT OUTER JOIN Adinco.dbo.CO_TareaPetrolera AS t ON t.IdTareaPetrolera = lp.IdTareaPetrolera
	WHERE s.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
END


