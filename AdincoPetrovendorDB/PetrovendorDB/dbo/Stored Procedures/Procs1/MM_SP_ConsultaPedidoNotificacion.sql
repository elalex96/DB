USE PETROVENDOR
GO
DROP PROC IF EXISTS MM_SP_CONSULTAPEDIDONOTIFICACION
GO
-- =============================================
-- Author:		Marcos Garcia
-- Create date: <22-04-2019>
-- Description:	<Agregar Linea Presupuesto (Tarea y Subtarea) despues de DescripcionCorta
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <06-07-2021>
-- Description:	Se modifico consulta para evitar html vacio
-- =============================================
-- Author:		David De La Cruz
-- Create date: <09-Sep-2024>
-- Description:	Se elimina consulta multiple de linea presupuesto
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_ConsultaPedidoNotificacion]
	@IdSolicitudPedido INT,
	@Version INT,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
AS
BEGIN
	SELECT 
		PE.IdSubcontratista, 
		MAX(P.RazonSocial + ' ' + ISNULL(P.RegimenCapital, '') + '.<br/> <b> Objeto del pedido(Justificación): </b>' + SP.MotivoUrgencia) AS ProveedorJustificacion,
		PG.IdPedido,
		MAX('<b>' + ISNULL(POD.MaterialCotizadoTextoC, ISNULL(M.DescripcionCorta,'')) + '</b> | Línea Presupuesto - ' + ISNULL(dbo.Fn_RetornarMesProgramadoActividadConcat(clp.IdLineaPresupuestoMes), '')) AS DescripcionCorta,
		PD.PrecioUnitario,
		PD.Cantidad,
		ISNULL(POD.UnidadProveedor, ISNULL(U.Unidad, '')) AS Unidad,
		PD.Subtotal,
		TM.TipoMonedaCorto,
		MAX(ISNULL(C.NumeroContrato,'') + ' - ' + ISNULL(AC.NombreAreaContractual,'')) AS Contrato,
		TP.TipoPedido
	FROM MM_Pedido PE
		LEFT JOIN dbo.S_Proveedor P (NOLOCK) ON PE.IdSubcontratista = P.IdProveedor 
		LEFT JOIN dbo.MM_PedidoDetalle PD (NOLOCK) ON PE.IdPedido = PD.IdPedido
		LEFT JOIN MM_PeticionOfertaDetalle POD (NOLOCK) ON PE.IdPeticionOferta = POD.IdPeticionOferta AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
		LEFT JOIN dbo.MM_Material M (NOLOCK) ON PD.IdMaterial = M.IdMaterial 
		LEFT JOIN PV_MM_MaterialUnidad U (NOLOCK) ON PD.IdUnidad = U.IdUnidad 
		LEFT JOIN dbo.PV_TipoMoneda TM (NOLOCK) ON PD.IdMoneda = TM.IdMoneda 
		LEFT JOIN dbo.MM_Pedidos PG (NOLOCK) ON PE.IdPedido = PG.IdIdentificador AND PE.IdProveedorCompras = PG.IdProveedorCliente AND PG.IdTipoPedido IN (2, 4, 6)			
		LEFT JOIN dbo.MM_SolicitudPedido SP (NOLOCK) ON PE.IdSolicitudPedido = SP.IdSolicitudPedido
		JOIN MM_SolicitudPedidoDetalle AS spd (NOLOCK) ON sp.IdSolicitudPedido = spd.IdSolicitudPedido AND POD.IdMaterial = spd.IdMaterial AND POD.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
		LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS lp (NOLOCK) ON spd.IdSolicitudPedidoDetalle = lp.IdSolicitudPedidoDetalle
		LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS clp (NOLOCK) ON lp.IdLineaPresupuesto = clp.IdLineaPresupuestoMes
		LEFT JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK) ON PE.IdContrato = C.IdContrato 
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC (NOLOCK) ON C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK) ON PG.IdTipoPedido = TP.IdTipoPedido 
	WHERE PE.IdSolicitudPedido = @IdSolicitudPedido
		AND PE.Version = @Version
	GROUP BY
		PE.IdSubcontratista, 
		PG.IdPedido,
		PD.PrecioUnitario,
		PD.Cantidad,
		ISNULL(POD.UnidadProveedor, ISNULL(U.Unidad, '')),
		PD.Subtotal,
		TM.TipoMonedaCorto,
		TP.TipoPedido
	ORDER BY PE.IdSubcontratista, PG.IdPedido, TM.TipoMonedaCorto ASC;
END;
