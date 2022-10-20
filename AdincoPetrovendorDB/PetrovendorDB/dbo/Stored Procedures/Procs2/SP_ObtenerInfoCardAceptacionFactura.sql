USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_ObtenerInfoCardAceptacionFactura]    Script Date: 20/10/2022 12:16:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
ALTER PROCEDURE [dbo].[SP_ObtenerInfoCardAceptacionFactura]
@IdProveedor INT, 
@IdAceptacionPedido INT
AS
	BEGIN
		SET NOCOUNT ON

		DECLARE @IdSolicitudPedido INT
		DECLARE @MontoTotalOC FLOAT = (SELECT 
											SUM((PD.Cantidad * PrecioUnitario))
										FROM dbo.MM_PedidoDetalle AS PD (NOLOCK)
										JOIN dbo.MM_Pedido AS P (NOLOCK)
											ON PD.IdPedido = P.IdPedido
										JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
											ON P.IdPedido = AP.IdPedido
										WHERE AP.IdAceptacionPedido = @IdAceptacionPedido 
										AND PD.Activo = 1
										);

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
			  MotivoUrgencia NVARCHAR(MAX),
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
		FROM		dbo.MM_AceptacionPedido ap (NOLOCK)
		JOIN	dbo.MM_Pedido p (NOLOCK)
			ON ap.IdPedido = p.IdPedido 
		WHERE
		ap.IdAceptacionPedido = @IdAceptacionPedido
		AND ISNULL ( ap.IdEstatusEliminado, 0 ) <> 1

		--> MOSTRAR ACEPTACIONES NO ELIMINADAS	


		-- Obtener todas las aceptacion de pedido de esta solped
		INSERT INTO @TablaAcPedido
			( IdAceptacionPedido, IdPedido, Comentario, LugarEntrega, TipoDomicilio, IdPedidoGral, IdTipoPedido ,
			  TipoPedido , IdSolicitudPedido, MotivoUrgencia, MontoAceptado, IdMoneda, TipoMoneda )
		SELECT		AP.IdAceptacionPedido, AP.IdPedido, AP.Comentario ,					
					CONCAT (
						LE.[Calle], ' ', LE.[NoExterior], ' ', LE.[NoInterior], ' ', LE.[Colonia], ' ', LE.[Municipio] ,
						' ' , LE.[Estado], ' ', PAIS.Pais ) AS LugarEntrega, TD.TipoDomicilio ,
					PG.IdPedido AS IdPedidoGeneral, PG.IdTipoPedido, TP.TipoPedido, MP.IdSolicitudPedido ,
					sp.MotivoUrgencia, SUM ( apd.Cantidad * ISNULL(apd.PrecioUnitario,pd.PrecioUnitario) ) AS MontoAceptacion, pd.IdMoneda ,
					tm.TipoMonedaCorto
		FROM		MM_AceptacionPedido AS AP (NOLOCK)
		JOIN	MM_Pedido AS MP (NOLOCK)
			ON  AP.IdPedido = MP.IdPedido 
			AND AP.IdProveedor = @IdProveedor
			AND MP.IdSolicitudPedido = @IdSolicitudPedido
		JOIN	dbo.MM_PedidoDetalle pd (NOLOCK)
			ON MP.IdPedido = pd.IdPedido 
		JOIN	dbo.MM_AceptacionPedidoDetalle apd (NOLOCK)
			ON AP.IdAceptacionPedido = apd.IdAceptacionPedido 
			   AND	pd.IdPedidoDetalle = apd.IdPedidoDetalle 
		JOIN	DG_Domicilio AS LE (NOLOCK)
			ON AP.IdDomicilioEntrega = LE.IdDomicilio 
		JOIN	DG_TipoDomicilio AS TD (NOLOCK)
			ON LE.IdTipoDomicilio = TD.IdTipoDomicilio 
		JOIN	PV_PaisRepublica AS PAIS (NOLOCK)
			ON LE.IdPais = PAIS.id 
		JOIN	S_Proveedor AS P (NOLOCK)
			ON MP.IdSubcontratista = P.IdProveedor 
		JOIN	MM_Pedidos AS PG (NOLOCK)
			ON MP.IdPedido = PG.IdIdentificador
			 AND	PG.IdProveedorCliente = MP.IdProveedorCompras
			 AND PG.IdTipoPedido in (2,4,6) -->CTES 
		LEFT JOIN	dbo.MM_TipoPedido AS TP (NOLOCK)
			ON PG.IdTipoPedido = TP.IdTipoPedido 
		LEFT JOIN	dbo.MM_SolicitudPedido sp (NOLOCK)
			ON MP.IdSolicitudPedido = sp.IdSolicitudPedido
		LEFT JOIN	dbo.PV_TipoMoneda tm (NOLOCK)
			ON pd.IdMoneda = tm.IdMoneda 
		WHERE		ISNULL ( AP.IdEstatusEliminado, 0 ) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS						
		GROUP BY	LE.Calle, LE.NoExterior, LE.NoInterior, LE.Colonia, LE.Municipio, LE.Estado, PAIS.Pais ,
					AP.IdAceptacionPedido, AP.IdPedido, AP.Comentario, TD.TipoDomicilio, PG.IdPedido, PG.IdTipoPedido ,
					TP.TipoPedido, MP.IdSolicitudPedido, sp.MotivoUrgencia, pd.IdMoneda, tm.TipoMonedaCorto
		ORDER BY	IdAceptacionPedido DESC
	

		INSERT INTO @TablaTransferencia
		SELECT fa.IdFactura, SUM(transf.MontoPagado) 
		FROM dbo.MM_AceptacionFactura af (NOLOCK)
		JOIN dbo.MM_AceptacionPedido ap (NOLOCK)
			ON af.IdAceptacionPedido = ap.IdAceptacionPedido 
		JOIN dbo.MM_Pedido p (NOLOCK)
			ON ap.IdPedido = p.IdPedido 
			AND p.IdSolicitudPedido = @IdSolicitudPedido
		JOIN dbo.FI_Factura f (NOLOCK)
			ON af.IdFactura = f.IdFactura 
		JOIN Adinco.dbo.FI_FacturaAdincoPetrovendor fact 
			ON f.IdFactura = fact.IdFacturaPetrovendor
		JOIN Adinco.dbo.FI_Factura fa (NOLOCK)
			ON fact.IdFacturaAdinco = fa.IdFactura
		LEFT JOIN Adinco.dbo.FI_TransferFactura transFact (NOLOCK)
			ON fa.IdFactura = transFact.IdFactura 
		LEFT JOIN Adinco.dbo.FI_Transfer transf (NOLOCK)
			ON transf.IdTransferencia = transFact.IdTransfer
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
		FROM		MM_AceptacionFactura AS AF (NOLOCK)
		JOIN	TA_Operacion AS O (NOLOCK)
			ON AF.IdAceptacionFactura =	O.IdDocumento 
			AND O.IdTipoOperacion = 10 --> APROBACIÓN DE FACTURA		
		JOIN	MM_AceptacionPedido AS AP (NOLOCK)
			ON AF.IdAceptacionPedido	=	AP.IdAceptacionPedido 
		JOIN	dbo.MM_AceptacionPedidoDetalle AS APD (NOLOCK)
			ON AP.IdAceptacionPedido	=	APD.IdAceptacionPedido 
		JOIN	MM_Pedido AS PE (NOLOCK)
			ON AP.IdPedido	=	PE.IdPedido 
			AND PE.IdProveedorCompras = @IdProveedor
		JOIN	TA_Estatus AS E (NOLOCK)
			ON O.IdEstatusOperacion = E.IdEstatus 
		JOIN	MM_PedidoDetalle AS PED (NOLOCK)
			ON PE.IdPedido	=	 PED.IdPedido
			   AND	APD.IdPedidoDetalle = PED.IdPedidoDetalle
		JOIN	MM_Pedidos AS PG (NOLOCK)
			ON PE.IdPedido = PG.IdIdentificador
			   AND	PG.IdProveedorCliente = @IdProveedor
			   AND  PG.IdTipoPedido in (2,4,6) -->CTES 
		JOIN	S_Proveedor AS PR (NOLOCK)
			ON PE.IdSubcontratista = PR.IdProveedor 
		JOIN	dbo.PV_TipoMoneda AS TM (NOLOCK)
			ON  PE.IdMoneda = TM.IdMoneda
		LEFT JOIN	dbo.MM_TipoPedido AS TP (NOLOCK)
			ON  PG.IdTipoPedido = TP.IdTipoPedido
		LEFT JOIN	dbo.FI_Factura f (NOLOCK)
			ON  AF.IdFactura = f.IdFactura
		WHERE	
					ISNULL ( AF.IdEstatusEliminado, 0 ) <> 1 --> QUE NO ESTE CON ESTATUS ELIMINADO
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
			ON ac.IdAceptacionPedido = f.IdAceptacionPedido 
			   AND	ac.IdPedido = f.IdPedido 
		LEFT JOIN	Adinco.dbo.FI_FacturaAdincoPetrovendor relFact (NOLOCK)
			ON f.IdFactura = relFact.IdFacturaPetrovendor
		LEFT JOIN	Adinco.dbo.FI_Factura aFact (NOLOCK)
			ON aFact.IdFactura = relFact.IdFacturaAdinco
			   AND	aFact.Activa = 1 -->CTE
		LEFT JOIN	Adinco.dbo.FI_TransferFactura transFac (NOLOCK)
			ON aFact.IdFactura = transFac.IdFactura 
		LEFT JOIN	Adinco.dbo.FI_Transfer transf (NOLOCK)
			ON transFac.IdTransfer = transf.IdTransferencia 
			   AND	transf.PDF IS NOT NULL
		LEFT JOIN @TablaTransferencia ttransf  
			ON aFact.IdFactura = ttransf.IdFactura 
		LEFT JOIN dbo.DEA_Relacion_PR_PO AS RPRPO (NOLOCK)
			ON ac.IdPedido = RPRPO.IdPedido 
		WHERE		f.IdAceptacionPedido IS NOT NULL	--> Solo mostrar los que ya tienen facturas cargadas 
		GROUP BY transf.PDF, f.EstatusFactura, f.IdEstatusFactura, aFact.IdFactura, ac.IdAceptacionPedido, ac.IdPedido ,
		  ac.Comentario, ac.LugarEntrega, ac.TipoDomicilio, ac.IdPedidoGral, ac.IdTipoPedido, ac.TipoPedido ,
		  ac.IdSolicitudPedido, ac.MotivoUrgencia, ac.MontoAceptado, ac.IdMoneda, ac.TipoMoneda, f.IdAceptacionPedido ,
		  f.IdPedido, f.FechaRegistro, f.Proveedor, f.IdPedidoGral, f.TipoPedido, f.TipoMoneda , f.TotalFacturado,
		  f.RFC, f.IdSolicitudPedido, f.IdFactura, ttransf.MontoTransferencia, RPRPO.IdAdjuntoPO
		ORDER BY	ac.IdPedido
	END