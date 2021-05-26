-- =============================================
-- Author:		Pedro Acuña
-- Create date: 29-11-18
-- Description:	Obtener la informacion de la card reporte que se encuentra en la aceptacion de la factura
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 01-02-2019
-- Description:	se agrega la agrupacion para que no se repita el numero de aceptacion, ya que al pasar a adinco se pueden generar mas
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21-10-2020
-- Description:	se agrega el idadjuntoPO para su visualizacion en la pantalla de factura
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 26-05-2021
-- Description:	se agrega la variable @MontoTotalOC para almacenar el total del pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_ObtenerInfoCardAceptacionFactura] @IdProveedor INT, @IdAceptacionPedido INT
AS
	BEGIN
		SET NOCOUNT ON

		DECLARE @IdSolicitudPedido INT
		DECLARE @MontoTotalOC FLOAT = (SELECT 
											SUM((PD.Cantidad * PrecioUnitario))
										FROM dbo.MM_PedidoDetalle AS PD
										JOIN dbo.MM_Pedido AS P ON PD.IdPedido = P.IdPedido
										JOIN dbo.MM_AceptacionPedido AS AP ON P.IdPedido = AP.IdPedido
										WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND PD.Activo = 1
										GROUP BY PD.Cantidad,PrecioUnitario);

		DECLARE @TablaAcPedido TABLE
			( IdAceptacionPedido INT ,
			  IdPedido INT ,
			  Comentario NVARCHAR(MAX) ,
			  LugarEntrega NVARCHAR(MAX) ,
			  TipoDomicilio NVARCHAR(MAX) ,
			  IdPedidoGral INT ,
			  IdTipoPedido INT ,
			  TipoPedido NVARCHAR(300) ,
			  IdSolicitudPedido INT ,
			  MotivoUrgencia NVARCHAR(MAX) ,
			  MontoAceptado FLOAT ,
			  IdMoneda INT ,
			  TipoMoneda NVARCHAR(200))

		DECLARE @TablaFacturado TABLE
			( IdAceptacionPedido INT ,
			  IdPedido INT ,
			  FechaRegistro DATETIME ,
			  Proveedor NVARCHAR(MAX) ,
			  EstatusFactura NVARCHAR(MAX) ,
			  IdEstatusFactura INT ,
			  IdPedidoGral INT ,
			  TipoPedido NVARCHAR(300) ,
			  TotalFacturado FLOAT ,
			  TipoMoneda NVARCHAR(100) ,
			  RFC NVARCHAR(100) ,
			  IdSolicitudPedido INT ,
			  IdFactura INT )

		DECLARE @TablaTransferencia TABLE(IdFactura INT, MontoTransferencia float)
		-- Obtener el numero de solicitud de pedido para traer todas las aceptaciones de pedido
		SELECT		@IdSolicitudPedido = p.IdSolicitudPedido
		FROM		dbo.MM_AceptacionPedido ap
		INNER JOIN	dbo.MM_Pedido p
			ON p.IdPedido = ap.IdPedido
		WHERE
					ap.IdAceptacionPedido = @IdAceptacionPedido
					AND ISNULL ( ap.IdEstatusEliminado, 0 ) <> 1

		--> MOSTRAR ACEPTACIONES NO ELIMINADAS	


		-- Obtener todas las aceptacion de pedido de esta solped
		INSERT INTO @TablaAcPedido
			( IdAceptacionPedido, IdPedido, Comentario, LugarEntrega, TipoDomicilio, IdPedidoGral, IdTipoPedido ,
			  TipoPedido , IdSolicitudPedido, MotivoUrgencia, MontoAceptado, IdMoneda, TipoMoneda )
		SELECT		AP.IdAceptacionPedido, AP.IdPedido, AP.Comentario ,
					-- AP.Creado,
					CONCAT (
						LE.[Calle], ' ', LE.[NoExterior], ' ', LE.[NoInterior], ' ', LE.[Colonia], ' ', LE.[Municipio] ,
						' ' , LE.[Estado], ' ', PAIS.Pais ) AS LugarEntrega, TD.TipoDomicilio ,
					PG.IdPedido AS IdPedidoGeneral, PG.IdTipoPedido, TP.TipoPedido, MP.IdSolicitudPedido ,
					sp.MotivoUrgencia, SUM ( apd.Cantidad * pd.PrecioUnitario ) AS MontoAceptacion, pd.IdMoneda ,
					tm.TipoMonedaCorto
		FROM		MM_AceptacionPedido AS AP
		INNER JOIN	MM_Pedido AS MP
			ON MP.IdPedido = AP.IdPedido
		INNER JOIN	dbo.MM_PedidoDetalle pd
			ON pd.IdPedido = MP.IdPedido
		INNER JOIN	dbo.MM_AceptacionPedidoDetalle apd
			ON apd.IdAceptacionPedido = AP.IdAceptacionPedido
			   AND	apd.IdPedidoDetalle = pd.IdPedidoDetalle
		INNER JOIN	DG_Domicilio AS LE
			ON LE.IdDomicilio = AP.IdDomicilioEntrega
		INNER JOIN	DG_TipoDomicilio AS TD
			ON TD.IdTipoDomicilio = LE.IdTipoDomicilio
		INNER JOIN	PV_PaisRepublica AS PAIS
			ON PAIS.id = LE.IdPais
		INNER JOIN	S_Proveedor AS P
			ON P.IdProveedor = MP.IdSubcontratista
		INNER JOIN	MM_Pedidos AS PG
			ON MP.IdPedido = PG.IdIdentificador
			   AND	PG.IdProveedorCliente = MP.IdProveedorCompras
		LEFT JOIN	dbo.MM_TipoPedido AS TP
			ON TP.IdTipoPedido = PG.IdTipoPedido
		LEFT JOIN	dbo.MM_SolicitudPedido sp
			ON sp.IdSolicitudPedido = MP.IdSolicitudPedido
		LEFT JOIN	dbo.PV_TipoMoneda tm
			ON tm.IdMoneda = pd.IdMoneda
		WHERE
					AP.IdProveedor = @IdProveedor
					AND ISNULL ( AP.IdEstatusEliminado, 0 ) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS	
					AND MP.IdSolicitudPedido = @IdSolicitudPedido
		GROUP BY	LE.Calle, LE.NoExterior, LE.NoInterior, LE.Colonia, LE.Municipio, LE.Estado, PAIS.Pais ,
					AP.IdAceptacionPedido, AP.IdPedido, AP.Comentario, TD.TipoDomicilio, PG.IdPedido, PG.IdTipoPedido ,
					TP.TipoPedido, MP.IdSolicitudPedido, sp.MotivoUrgencia, pd.IdMoneda, tm.TipoMonedaCorto
		ORDER BY	IdAceptacionPedido DESC

		-- Obtener los montos aceptados de los pedidos y su moneda
		----INSERT INTO @TablaMontoPedido
		----	( IdPedido, MontoAceptado, IdMoneda, TipoMoneda )
		----SELECT		*
		----FROM		dbo.MM_AceptacionPedidoDetalle apd
		----INNER JOIN	dbo.MM_PedidoDetalle pd
		----	ON pd.IdPedidoDetalle = apd.IdPedidoDetalle

		--SELECT		p.IdPedido, SUM ( pd.Subtotal ) AS MontoAceptado, pd.IdMoneda, tm.TipoMonedaCorto
		--FROM		dbo.MM_Pedido p
		--INNER JOIN	dbo.MM_PedidoDetalle pd
		--	ON pd.IdPedido = p.IdPedido
		--LEFT JOIN	dbo.PV_TipoMoneda tm
		--	ON tm.IdMoneda = pd.IdMoneda
		--WHERE
		--			ISNULL ( p.IdEstatusEliminado, 0 ) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS	
		--			AND p.IdProveedorCompras = @IdProveedor
		--			AND p.IdSolicitudPedido = @IdSolicitudPedido
		--			AND pd.RecepcionPedido = 1	--> Solo los que hayan sido aceptados
		--GROUP BY	pd.IdMoneda, tm.TipoMonedaCorto, p.IdPedido

		INSERT INTO @TablaTransferencia
		SELECT fa.IdFactura, SUM(transf.MontoPagado) FROM dbo.MM_AceptacionFactura af INNER JOIN dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = af.IdAceptacionPedido
		INNER JOIN dbo.MM_Pedido p ON p.IdPedido = ap.IdPedido
		INNER JOIN dbo.FI_Factura f ON f.IdFactura = af.IdFactura
		INNER JOIN Adinco.dbo.FI_FacturaAdincoPetrovendor fact ON f.IdFactura = fact.IdFacturaPetrovendor
		INNER JOIN Adinco.dbo.FI_Factura fa ON fact.IdFacturaAdinco = fa.IdFactura
		LEFT JOIN Adinco.dbo.FI_TransferFactura transFact ON transFact.IdFactura = fa.IdFactura
		LEFT JOIN Adinco.dbo.FI_Transfer transf ON transf.IdTransferencia = transFact.IdTransfer
		WHERE p.IdSolicitudPedido = @IdSolicitudPedido
		GROUP BY fa.IdFactura

		-- obtener todas las facturas de la solped
		INSERT INTO @TablaFacturado
			( IdAceptacionPedido, IdPedido, FechaRegistro, Proveedor, EstatusFactura, IdEstatusFactura, IdPedidoGral ,
			  TipoPedido , TotalFacturado, TipoMoneda, RFC, IdSolicitudPedido, IdFactura )
		SELECT		AF.IdAceptacionPedido, Pe.IdPedido, O.FechaRegistro ,
					PR.RazonSocial + ' ' + ISNULL ( Pr.RegimenCapital, '' ) AS Proveedor, E.Nombre, E.IdEstatus ,
					PG.IdPedido AS IdPedidoGeneral, TP.TipoPedido, f.SubTotal AS TotalFacturado, f.Moneda AS Moneda ,
					PR.RFC, PE.IdSolicitudPedido, AF.IdFactura
		FROM		MM_AceptacionFactura AS AF
		INNER JOIN	TA_Operacion AS O
			ON O.IdDocumento = AF.IdAceptacionFactura
		INNER JOIN	TA_Estatus AS E
			ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN	MM_AceptacionPedido AS AP
			ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		INNER JOIN	dbo.MM_AceptacionPedidoDetalle AS APD
			ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
		INNER JOIN	MM_Pedido AS PE
			ON PE.IdPedido = AP.IdPedido
		INNER JOIN	MM_PedidoDetalle AS PED
			ON PED.IdPedido = PE.IdPedido
			   AND	APD.IdPedidoDetalle = PED.IdPedidoDetalle
		INNER JOIN	MM_Pedidos AS PG
			ON PE.IdPedido = PG.IdIdentificador
			   AND	PG.IdProveedorCliente = @IdProveedor
		INNER JOIN	S_Proveedor AS PR
			ON PR.IdProveedor = PE.IdSubcontratista
		INNER JOIN	dbo.PV_TipoMoneda AS TM
			ON TM.IdMoneda = PE.IdMoneda
		LEFT JOIN	dbo.MM_TipoPedido AS TP
			ON TP.IdTipoPedido = PG.IdTipoPedido
		LEFT JOIN	dbo.FI_Factura f
			ON f.IdFactura = AF.IdFactura
		WHERE
					O.IdTipoOperacion = 10
					AND PE.IdProveedorCompras = @IdProveedor
					AND ISNULL ( AF.IdEstatusEliminado, 0 ) <> 1 --> QUE NO ESTE CON ESTATUS ELIMINADO
					AND PE.IdSolicitudPedido = @IdSolicitudPedido
		GROUP BY	AF.IdAceptacionPedido, Pe.IdPedido, O.FechaRegistro, PR.RazonSocial, Pr.RegimenCapital, E.Nombre ,
					PG.IdPedido, TP.TipoPedido, PR.RFC, AF.IdEstatusEliminado, PE.IdSolicitudPedido, E.IdEstatus ,
					AF.IdFactura, f.SubTotal, f.Moneda
		ORDER BY	AF.IdAceptacionPedido DESC


		--Retorno a la vista
		-- sin el filtro se obtiene desde las aceptaciones de servicio
		-- estatus -1 se refiere a que fue pagada la factura ya tiene una relacion con una transferencia
		SELECT		ac.IdAceptacionPedido, ac.IdPedido, ac.Comentario, ac.LugarEntrega, ac.TipoDomicilio, ac.IdPedidoGral ,
					ac.IdTipoPedido, ac.TipoPedido, ac.IdSolicitudPedido, ac.MotivoUrgencia, ac.IdPedido, ac.MontoAceptado ,
					ac.IdMoneda, ac.TipoMoneda, f.IdAceptacionPedido, f.IdPedido, f.FechaRegistro, f.Proveedor ,
					CASE WHEN transf.PDF IS NOT NULL THEN 'Pagado' ELSE f.EstatusFactura END AS EstatusFactura ,
					f.IdPedidoGral, f.TipoPedido, ISNULL(f.TotalFacturado, 0), ISNULL(f.TipoMoneda, ''), f.RFC, f.IdSolicitudPedido ,
					CASE WHEN transf.PDF IS NOT NULL THEN -1 ELSE f.IdEstatusFactura END AS IdEstatusFactura ,
					Proceso = CASE WHEN transf.PDF IS NULL THEN
									   'No pagado'
							  WHEN transf.PDF IS NOT NULL THEN
								  'Pagado'
							  WHEN aFact.IdFactura IS NULL THEN
								  'En proceso'
							  END, f.IdFactura, ISNULL(ttransf.MontoTransferencia, 0) AS MontoTransferencia,
					ISNULL(RPRPO.IdAdjuntoPO,0) AS IdAdjuntoPO,
					@MontoTotalOC AS MontoTotalOC
		FROM		@TablaAcPedido ac
		LEFT JOIN	@TablaFacturado f
			ON f.IdAceptacionPedido = ac.IdAceptacionPedido
			   AND	f.IdPedido = ac.IdPedido
		LEFT JOIN	Adinco.dbo.FI_FacturaAdincoPetrovendor relFact
			ON f.IdFactura = relFact.IdFacturaPetrovendor
		LEFT JOIN	Adinco.dbo.FI_Factura aFact
			ON aFact.IdFactura = relFact.IdFacturaAdinco
			   AND	aFact.Activa = 1
		LEFT JOIN	Adinco.dbo.FI_TransferFactura transFac
			ON transFac.IdFactura = aFact.IdFactura
		LEFT JOIN	Adinco.dbo.FI_Transfer transf
			ON transf.IdTransferencia = transFac.IdTransfer
			   AND	transf.PDF IS NOT NULL
		LEFT JOIN @TablaTransferencia ttransf ON ttransf.IdFactura = aFact.IdFactura
		LEFT JOIN dbo.DEA_Relacion_PR_PO AS RPRPO 
			ON RPRPO.IdPedido = ac.IdPedido
		WHERE		f.IdAceptacionPedido IS NOT NULL	--> Solo mostrar los que ya tienen facturas cargadas 
		GROUP BY transf.PDF, f.EstatusFactura, f.IdEstatusFactura, aFact.IdFactura, ac.IdAceptacionPedido, ac.IdPedido ,
		  ac.Comentario, ac.LugarEntrega, ac.TipoDomicilio, ac.IdPedidoGral, ac.IdTipoPedido, ac.TipoPedido ,
		  ac.IdSolicitudPedido, ac.MotivoUrgencia, ac.MontoAceptado, ac.IdMoneda, ac.TipoMoneda, f.IdAceptacionPedido ,
		  f.IdPedido, f.FechaRegistro, f.Proveedor, f.IdPedidoGral, f.TipoPedido, f.TipoMoneda , f.TotalFacturado,
		  f.RFC, f.IdSolicitudPedido, f.IdFactura, ttransf.MontoTransferencia, RPRPO.IdAdjuntoPO
		ORDER BY	ac.IdPedido
	END