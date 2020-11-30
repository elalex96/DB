-- =============================================
-- Author:		Pedro Acuña
-- Create date: 03/01/2019
-- Description:	Obtener los idPedido por mes de las ordenes de compra generadas
-- =============================================

CREATE PROCEDURE [dbo].[SP_ReporteDescargaMasivaOC_bckp] @IdProveedor INT, @MesAnio DATETIME
AS
	BEGIN
		DECLARE @DiaAnterior DATETIME, @MesSiguiente DATETIME

		SELECT @DiaAnterior	 = DATEADD ( MINUTE, -1, @MesAnio )

		SELECT @MesSiguiente  = DATEADD ( MONTH, 1, @MesAnio )

		SELECT		P.IdPedido, P.CreadoEl
		FROM		MM_Pedido AS P
		INNER JOIN	MM_PedidoDetalle AS PD
			ON PD.IdPedido = P.IdPedido
		INNER JOIN	MM_PeticionOferta AS PO
			ON PO.IdPeticionOFerta = P.IdPeticionOferta
		INNER JOIN	S_Proveedor AS PV
			ON PV.IdProveedor = P.IdSubcontratista
		INNER JOIN	TA_Operacion AS O
			ON O.IdDocumento = P.IdSolicitudPedido
		INNER JOIN	TA_Prioridad AS PR
			ON PR.IdPrioridad = O.IdPrioridad
		INNER JOIN	TA_Vencimiento AS V
			ON V.IdVencimiento = O.IdVigencia
		INNER JOIN	TA_TipoOperacion AS TTO
			ON TTO.IdTipoOperacion = O.IdTipoOperacion
		INNER JOIN	TA_Estatus AS E
			ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN	MM_HorasVigenciaPedido AS HV
			ON P.IdPedido = HV.IdPedido
		INNER JOIN	PV_TipoMoneda AS TM
			ON TM.IdMoneda = P.IdMoneda
		INNER JOIN	MM_Pedidos AS PG
			ON P.IdPedido = PG.IdIdentificador
			   AND	PG.IdProveedorCliente = @IdProveedor
		LEFT JOIN	dbo.MM_TipoPedido AS TP
			ON TP.IdTipoPedido = PG.IdTipoPedido
		WHERE
					O.IdTipoOperacion = 9
					AND O.IdProveedor = @IdProveedor
					AND P.Version = O.NoVersion
					AND ISNULL ( P.IdEstatusEliminado, 0 ) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
					AND P.CreadoEl BETWEEN @DiaAnterior
								   AND	   @MesSiguiente
		GROUP BY	P.IdPedido, P.CreadoEl
	END