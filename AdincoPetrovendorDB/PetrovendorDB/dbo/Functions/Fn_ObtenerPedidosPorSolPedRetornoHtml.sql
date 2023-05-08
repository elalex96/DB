-- =============================================
-- Author: Pedro Acuña
-- Create date: 30/08/2018
-- Description: obtener los pedidos de cada solicitud de pedido
-- =============================================
-- Author: David
-- Create date: 06/01/2022
-- Description: optimización sp para issue #452 AdincoPetroBD
-- =============================================
create FUNCTION Fn_ObtenerPedidosPorSolPedRetornoHtml
	( @IdSolicitudPedido INT ,
	  @IdProveedor INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		--DECLARE @IdSolicitudPedido INT = 14383 ,
		-- @IdProveedor INT = 420
		DECLARE @retorno NVARCHAR(MAX)
		DECLARE @InicioTabla NVARCHAR(MAX)
			= '<div id=''demo' + CONVERT ( NVARCHAR(20), @IdSolicitudPedido )
			  + ''' class=''tablaPedidos collapse'' aria-expanded=''false'' style=''height: 0px''><table class=''tablePedido''>' ,
				@FinTabla NVARCHAR(100) = '</table></div>'
		DECLARE @contador INT= 1, @CantidadRegistros INT, @IdPedidoAux INT, @IdTipoPedidoAux INT, @IdPedidoGralAux INT ,
				@EstatusAux NVARCHAR(50), @TotalAux NVARCHAR(150), @TipoMonedaAux NVARCHAR(20), @IdEstatusAux INT ,
				@AuxEtiqueta NVARCHAR(50), @Materiales NVARCHAR(MAX), @ProveedorAux NVARCHAR(MAX)

		DECLARE @tablaAux TABLE
			( Fila INT IDENTITY ,
			  IdPedido INT ,
			  IdTipoPedido INT ,
			  IdPedidoGral INT ,
			  IdEstatus INT ,
			  Proveedor NVARCHAR(500) ,
			  Estatus NVARCHAR(50) ,
			  Total NVARCHAR(150) ,
			  TipoMoneda NVARCHAR(20))

		INSERT INTO @tablaAux
			( IdPedido, IdTipoPedido, IdPedidoGral, IdEstatus, Proveedor, Estatus, Total, TipoMoneda )
		SELECT		P.IdPedido, PG.IdTipoPedido, PG.IdPedido, E.IdEstatus, PV.RazonSocial, E.Nombre ,
					CONVERT ( VARCHAR(100), CAST(ROUND ( SUM ( PD.Subtotal ), 2 ) AS MONEY), 1 ), TM.TipoMonedaCorto
		FROM		MM_Pedido AS P
		INNER JOIN	MM_PedidoDetalle AS PD
			ON PD.IdPedido = P.IdPedido
		INNER JOIN	S_Proveedor AS PV
			ON PV.IdProveedor = P.IdSubcontratista
		INNER JOIN	TA_Operacion AS O
			ON P.IdSolicitudPedido = O.IdDocumento
			   AND	P.Version = O.NoVersion
		INNER JOIN	TA_Estatus AS E
			ON O.IdEstatusOperacion = E.IdEstatus
		INNER JOIN	PV_TipoMoneda AS TM
			ON P.IdMoneda = TM.IdMoneda
		INNER JOIN	MM_Pedidos AS PG
			ON P.IdPedido = PG.IdIdentificador
			   AND	PG.IdProveedorCliente = @IdProveedor
		WHERE
					O.IdTipoOperacion = 9
					AND O.IdProveedor = @IdProveedor
					AND ISNULL ( P.IdEstatusEliminado, 0 ) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
					AND P.IdSolicitudPedido = @IdSolicitudPedido
		GROUP BY	PG.IdPedido, E.Nombre, TM.TipoMonedaCorto, P.IdPedido, PG.IdTipoPedido, E.IdEstatus, PV.RazonSocial

		SELECT @CantidadRegistros  = COUNT ( * ) FROM @tablaAux

		SET @retorno = @InicioTabla

		WHILE ( @CantidadRegistros >= @contador )
			BEGIN
				DECLARE @tablaMateriales TABLE
					( Fila INT IDENTITY ,
					  IdMaterial INT ,
					  NombreCorto NVARCHAR(MAX) ,
					  Cantidad FLOAT )

				--Seccion de armado html del pedido
				SELECT	@IdPedidoAux = IdPedido, @IdTipoPedidoAux = IdTipoPedido, @IdPedidoGralAux = IdPedidoGral ,
						@EstatusAux = Estatus, @TotalAux = Total, @TipoMonedaAux = TipoMoneda ,
						@IdEstatusAux = IdEstatus, @ProveedorAux = Proveedor
				FROM	@tablaAux
				WHERE	Fila = @contador

				SELECT	@AuxEtiqueta = CASE WHEN @IdEstatusAux = 1 THEN
												'warning'
									   WHEN @IdEstatusAux = 2 THEN
											'success'
									   WHEN @IdEstatusAux IN ( 3, 4, 5, 6, 7, 10 ) THEN
										   'danger'
									   WHEN @IdEstatusAux = 9 THEN
										   'info'
									   END

				--Seccion del armado de los materiales
				INSERT INTO @tablaMateriales
			
		( IdMaterial, NombreCorto, Cantidad )
				SELECT		d.IdMaterial, m.DescripcionCorta, d.Cantidad
				FROM		dbo.MM_PedidoDetalle d
				LEFT JOIN	dbo.MM_Material m
					ON d.IdMaterial = m.IdMaterial
				WHERE		IdPedido = @IdPedidoAux

				--y ahora si lo divido por comas los resultados
				SELECT	@Materiales= STUFF (
						  (	  SELECT	CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), NombreCorto ) + ' - '
										+ CONVERT ( NVARCHAR(MAX), Cantidad )
							  FROM		@tablaMateriales
							  GROUP BY	NombreCorto, Cantidad, IdMaterial
							  FOR XML PATH ( '' )), 1, 1, '' )

				SELECT	@retorno += N'<tr class=''titulosTabla''><td class=''subtitulo''>Pedido Núm</td><td class=''subtitulo''>Proveedor</td><td class=''subtitulo''>Estatus del Pedido</td><td class=''subtitulo''>Total</td><td class=''subtitulo''>Moneda</td></tr>'
									+ N'<tr><td class=''value''><a onclick=''loading()'' href="../02Proveedores/PedidoDetalle.aspx?ped='
									+ CONVERT ( VARCHAR(100), @IdPedidoAux ) + N'&type='
									+ CONVERT ( VARCHAR(100), @IdTipoPedidoAux )
									+ N'"><div class="btn btn-default btn-small btnPedidos" style="text-align: center;"><strong>Ver detalle '
									+ CONVERT ( VARCHAR(100), @IdPedidoGralAux ) + N'</strong></div></a></td>'
									+ N'<td class=''value''>' + @ProveedorAux + N'</td>'
									+ N'<td class=''value''><span class=''label label-' + @AuxEtiqueta + N'''>'
									+ @EstatusAux + N'</span></td>' + N'<td class=''value''>' + @TotalAux + N'</td>'
									+ N'<td class=''value''>' + @TipoMonedaAux + N'</td>'
									+ N'<tr><td class=''subtitulo materiales''>Materiales: </td>'
									+ N'<td id=''cortarTexto'' class=''materiales'' colspan="7">'
									+ SUBSTRING ( @Materiales, 0, 200 ) + N' </td></tr>'

				SET @AuxEtiqueta = N''
				DELETE @tablaMateriales

				SET @contador += 1
			END
		SELECT @retorno	 += @FinTabla
		IF ( @CantidadRegistros = 0 ) SET @retorno = N''
		RETURN @retorno
	END