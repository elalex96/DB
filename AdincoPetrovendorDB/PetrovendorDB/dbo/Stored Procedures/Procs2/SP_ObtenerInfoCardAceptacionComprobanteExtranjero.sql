use Petrovendor
go
drop procedure if exists SP_ObtenerInfoCardAceptacionComprobanteExtranjero
go
--SE MODIFICA PARA MOSTRAR EL MONTO YA SUMADO
CREATE PROC SP_ObtenerInfoCardAceptacionComprobanteExtranjero
@IdProveedor INT, 
@IdAceptacionPedido INT
AS
BEGIN
		DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE RTRIM(LTRIM(NombreOperacion)) = 'Aprobación Pedimento/Comprobante Extranjero');
		DECLARE @IdSolicitudPedido INT, @MontoAceptadoTotal FLOAT;
		DECLARE @MontoTotalOC FLOAT = (SELECT 
											SUM((PD.Cantidad * PrecioUnitario))
										FROM dbo.MM_PedidoDetalle AS PD (NOLOCK)
										JOIN dbo.MM_Pedido AS P (NOLOCK)
											ON PD.IdPedido = P.IdPedido
										JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
											ON P.IdPedido = AP.IdPedido
										WHERE AP.IdAceptacionPedido = @IdAceptacionPedido 
										AND PD.Activo = 1);
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
			  TipoMoneda NVARCHAR(200),
			  IdEstatus Int,
			  Estatus varchar(200)
			  )

		-- Obtener el numero de solicitud de pedido para traer todas las aceptaciones de pedido
		SELECT		@IdSolicitudPedido = p.IdSolicitudPedido
		FROM		dbo.MM_AceptacionPedido ap (NOLOCK)
		JOIN	dbo.MM_Pedido p (NOLOCK)
			ON ap.IdPedido = p.IdPedido 
		WHERE
		ap.IdAceptacionPedido = @IdAceptacionPedido
		AND ISNULL ( ap.IdEstatusEliminado, 0 ) <> 1

		-- Obtener todas las aceptacion de pedido de esta solped
		INSERT INTO @TablaAcPedido
			( 
			IdAceptacionPedido, IdPedido, Comentario, LugarEntrega, TipoDomicilio, IdPedidoGral, IdTipoPedido ,
			  TipoPedido , IdSolicitudPedido, MotivoUrgencia, MontoAceptado, IdMoneda, TipoMoneda
			  ,IdEstatus,Estatus 
			  )
		SELECT		AP.IdAceptacionPedido, AP.IdPedido, AP.Comentario ,					
					CONCAT (
						LE.[Calle], ' ', LE.[NoExterior], ' ', LE.[NoInterior], ' ', LE.[Colonia], ' ', LE.[Municipio] ,
						' ' , LE.[Estado], ' ', PAIS.Pais ) AS LugarEntrega, TD.TipoDomicilio ,
					PG.IdPedido AS IdPedidoGeneral, PG.IdTipoPedido, TP.TipoPedido, MP.IdSolicitudPedido ,
					sp.MotivoUrgencia, SUM ( apd.Cantidad * pd.PrecioUnitario ) AS MontoAceptacion, pd.IdMoneda ,
					tm.TipoMonedaCorto, O.IdEstatusOperacion, E.Nombre

		FROM		MM_AceptacionPedido AS AP (NOLOCK)
		JOIN	MM_Pedido AS MP (NOLOCK)
			ON  AP.IdPedido = MP.IdPedido 
			AND @IdProveedor = AP.IdProveedor
			AND @IdSolicitudPedido = MP.IdSolicitudPedido
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
			 AND	MP.IdProveedorCompras = PG.IdProveedorCliente
			 AND PG.IdTipoPedido in (2,4,6) -->CTES 
		LEFT JOIN	dbo.MM_TipoPedido AS TP (NOLOCK)
			ON PG.IdTipoPedido = TP.IdTipoPedido 
		LEFT JOIN	dbo.MM_SolicitudPedido sp (NOLOCK)
			ON MP.IdSolicitudPedido = sp.IdSolicitudPedido
		LEFT JOIN	dbo.PV_TipoMoneda tm (NOLOCK)
			ON pd.IdMoneda = tm.IdMoneda 
		JOIN FI_AceptacionPedido_PedimentoComprobante AS AP_PC 
			ON AP.IdAceptacionPedido = AP_PC.IdAceptacionPedido
		JOIN FI_PedimentoComprobante PC 
			ON AP_PC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		JOIN TA_Operacion O 
			ON PC.IdPedimentoComprobante  = O.IdDocumento 
			AND O.IdTipoOperacion = @TipoOperacionId
		JOIN TA_ESTATUS AS E
			ON E.IdEstatus = O.IdEstatusOperacion
		WHERE		ISNULL ( AP.IdEstatusEliminado, 0 ) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS						
		GROUP BY	
		LE.Calle, 
		LE.NoExterior, 
		LE.NoInterior, 
		LE.Colonia, 
		LE.Municipio, 
		LE.Estado, 
		PAIS.Pais ,
		AP.IdAceptacionPedido, 
		AP.IdPedido, 
		AP.Comentario, 
		TD.TipoDomicilio, 
		PG.IdPedido, 
		PG.IdTipoPedido ,
		TP.TipoPedido, 
		MP.IdSolicitudPedido, 
		sp.MotivoUrgencia,
		pd.IdMoneda, 
		tm.TipoMonedaCorto,
		O.IdEstatusOperacion, E.Nombre
		ORDER BY	IdAceptacionPedido DESC
	
		SET @MontoAceptadoTotal = (SELECT SUM(MontoAceptado) from @TablaAcPedido)
		SELECT		
		ac.IdAceptacionPedido, 
		ac.IdPedido, 
		ac.Comentario, 
		ac.LugarEntrega, 
		ac.TipoDomicilio, 
		ac.IdPedidoGral ,
		ac.IdTipoPedido, 
		ac.TipoPedido, 
		ac.IdSolicitudPedido, 
		ac.MotivoUrgencia, 
		ac.IdPedido, 
		ac.MontoAceptado,
		ac.IdMoneda, 
		ac.TipoMoneda,
		ISNULL(RPRPO.IdAdjuntoPO,0) AS IdAdjuntoPO,
		@MontoTotalOC AS MontoTotalOC,
		ac.IdEstatus,
		ac.Estatus,
		@MontoAceptadoTotal
		FROM		@TablaAcPedido ac
		LEFT JOIN dbo.DEA_Relacion_PR_PO AS RPRPO (NOLOCK)
			ON ac.IdPedido = RPRPO.IdPedido 
		GROUP BY 
		ac.IdAceptacionPedido, 
		ac.IdPedido,
		ac.Comentario, 
		ac.LugarEntrega, 
		ac.TipoDomicilio, 
		ac.IdPedidoGral, 
		ac.IdTipoPedido, 
		ac.TipoPedido,
		ac.IdSolicitudPedido, 
		ac.MotivoUrgencia, 
		ac.MontoAceptado, 
		ac.IdMoneda, 
		ac.TipoMoneda,
		RPRPO.IdAdjuntoPO,
		ac.IdEstatus,
		ac.Estatus
		ORDER BY	ac.IdPedido
END
