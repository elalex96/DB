
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <28-05-2018>
-- Description:	<Se consulta las lineas de presupuesto que se eligieron en los conceptos de una solped>
-- =============================================

CREATE procedure MM_SP_ConsultaComboLPxSolPed --10259
	@IdPedido INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN

	SELECT DISTINCT lp.IdLineaPresupuesto,
		CONCAT(RIGHT('00'+CAST(MONTH(lpm.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', 
			DATENAME(month, lpm.AC_PRESUP_MES), ' ', YEAR(lpm.AC_PRESUP_MES)) AS Mes_Presupuestado,
		sp.[id_Sub-actividad] AS ID_CATACTIV,
		sp.SubactividadPetrolera AS Actividad,
		tp.id_Tarea AS ID_CATSUBACTIV,
		tp.TareaPetrolera AS SubActividad
	FROM dbo.MM_Pedido P
	INNER JOIN dbo.MM_Pedidos pS ON pS.IdIdentificador = P.IdPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle spd ON spd.IdSolicitudPedido = p.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto lp ON lp.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
	INNER JOIN CO_LineaPresupuestoMes lpm ON lp.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
	LEFT OUTER JOIN CO_SubactividadPetrolera sp ON lpm.IdSubactividadPetrolera = sp.IdSubactividadPetrolera
	LEFT OUTER JOIN CO_TareaPetrolera tp ON lpm.IdTareaPetrolera = tp.IdTareaPetrolera
	WHERE pS.IdPedido = @IdPedido
END
