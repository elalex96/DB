-- =============================================
-- Author:		Daniel AC
-- Create date: 15-09-201717
-- Description:	Consultar lista de todos los Pedidos por filtro
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaListaTodosLosPedidos]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @Filtro NVARCHAR(MAX),
    @F_IdProveedorPedido INT,
    @F_IdUsuarioCompras INT,
    @F_IdUsuarioRequitor INT,
    @F_TipoPedido NVARCHAR(350),
    @F_FechaInicio DATE,
    @F_FechaFin DATE,
    @ValidacionFecha BIT,
    @F_TipoMoneda INT,
    @F_MontoInicio MONEY,
    @F_MontoFin MONEY
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @SQL_QUERY NVARCHAR(MAX);
    DECLARE @SQL_PROVEEDOR NVARCHAR(MAX) = '';
    DECLARE @SQL_TIPO_PEDIDO NVARCHAR(MAX) = '';
    DECLARE @SQL_REQUISITOR NVARCHAR(MAX) = '';
    DECLARE @SQL_PERIODO NVARCHAR(MAX) = '';
    DECLARE @SQL_COMPRAS NVARCHAR(MAX) = '';
    DECLARE @SQL_INNER_REQUISITOR NVARCHAR(MAX) = '';
    DECLARE @SQL_MONTO NVARCHAR(MAX) = '';
    DECLARE @SQL_TIPO_MONEDA NVARCHAR(MAX) = '';


    DECLARE @FECHA_INICIO NVARCHAR(MAX);
    DECLARE @FECHA_FIN NVARCHAR(MAX);

    DECLARE @MONTO_INICIO NVARCHAR(MAX);
    DECLARE @MONTO_FIN NVARCHAR(MAX);

	---#Busca todos los pedidos sin requerimientos 
    IF @Filtro = 'TODOS'
    BEGIN

		SELECT * FROM (
        --#MERCADEO
		 	
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.CreadoEl AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(RazonSocial,'') + ' ' + ISNULL(RegimenCapital,'') AS Proveedor,
               --CASE ISNULL(P.RecepcionServicio,0) WHEN 1 THEN 'Confirmado' ELSE 'En Recepción' END AS RecepcionServicio,
               E.Nombre,
               P.Version,
               P.RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               'Mercadeo' AS TIPO,
               O.IdOperacion AS IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral
        FROM MM_Pedido AS P
            LEFT JOIN MM_PedidoDetalle AS PD
                ON PD.IdPedido = P.IdPedido
            LEFT JOIN MM_PeticionOferta AS PO
                ON PO.IdPeticionOferta = P.IdPeticionOferta
            LEFT JOIN S_Proveedor AS PV
                ON PV.IdProveedor = P.IdSubcontratista
            LEFT JOIN TA_Operacion AS O
                ON O.IdDocumento = P.IdSolicitudPedido
            LEFT JOIN TA_Prioridad AS PR
                ON PR.IdPrioridad = O.IdPrioridad
            LEFT JOIN TA_Vencimiento AS V
                ON V.IdVencimiento = O.IdVigencia
            LEFT JOIN TA_TipoOperacion AS TTO
                ON TTO.IdTipoOperacion = O.IdTipoOperacion
            LEFT JOIN TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion
            LEFT JOIN MM_HorasVigenciaPedido AS HV
                ON P.IdPedido = HV.IdPedido
            LEFT JOIN PV_TipoMoneda AS TM
                ON TM.IdMoneda = P.IdMoneda
			LEFT JOIN MM_Pedidos AS PG 
				ON P.IdPedido = PG.IdIdentificador 
				AND PG.IdTipoPedido = 2 
				AND PG.IdProveedorCliente = @IdProveedor
        WHERE O.IdTipoOperacion = 9
              AND O.IdProveedor = @IdProveedor
             AND P.Version = O.NoVersion
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.CreadoEl,
                 RazonSocial,
                 RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 O.IdOperacion,
				 PG.IdPedido

       
        UNION ALL
        --#COMPRA DIRECTA
        SELECT coRegistro.IdRegistro AS IdPedido,
               coRegistro.IdFactura AS IdSolicitudPedido,
               TAO.FechaRegistro AS FechaEnvioPedido,
               fiFact.SubTotal AS TotalPedido,
               ISNULL(P.RazonSocial,'') + ' ' + ISNULL(P.RegimenCapital,'') AS Proveedor,
               TE.Nombre,
               NULL AS Version,
               NULL AS RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               'Compra directa' AS TIPO,
               TAO.IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral
        FROM dbo.CO_Registro AS coRegistro
            LEFT JOIN dbo.FI_Factura AS fiFact
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO
                ON TAO.IdDocumento = coRegistro.IdFactura
            LEFT JOIN TA_Estatus AS TE
                ON TE.IdEstatus = TAO.IdEstatusOperacion
            LEFT JOIN dbo.CC_CentroCosto centroCosto
                ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
            LEFT JOIN dbo.DG_CuentaContable cuentaContable
                ON cuentaContable.Id = coRegistro.CuentaContable
            LEFT JOIN dbo.CO_LineaPresupuestoMes linea
                ON linea.IdLineaPresupuestoMes = coRegistro.IdLineaPresupuestoMes
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
                ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion
                ON instalacion.IdInstalacion = coRegistro.IdInstalacion
            LEFT JOIN PV_TipoMoneda AS TM
                ON TM.IdMoneda = fiFact.IdMoneda
            LEFT JOIN dbo.S_Proveedor AS P
                ON P.RFC = fiFact.Emisor
			LEFT JOIN dbo.MM_Pedidos PG
				ON PG.IdIdentificador =fiFact.IdFactura
				 AND PG.IdTipoPedido=1 AND PG.IdProveedorCliente=@IdProveedor
        WHERE TAO.IdTipoOperacion = 14
              AND TAO.IdProveedor = @IdProveedor

		) Pedidos ORDER BY FechaEnvioPedido DESC
    END;

    --- IdTipoOperacion = 7--> Pedido
    --- IdTipoOperacion = 14-> Orden de compra
	---#Busca solo pedidos de un tipo con lo requeirmientos solicitados 
    IF @Filtro = 'FILTRO'
    BEGIN

        IF @F_TipoPedido = 'Mercadeo'
        BEGIN

            IF @F_IdProveedorPedido <> 0
            BEGIN
                SET @SQL_PROVEEDOR = 'AND P.IdSubcontratista =  ' + CAST(@F_IdProveedorPedido AS NVARCHAR(350)) + ' ';
            END;


            IF @F_IdUsuarioCompras <> 0
            BEGIN
                SET @SQL_COMPRAS = ' AND P.CreadoPor =  ' + CAST(@F_IdUsuarioCompras AS NVARCHAR(350)) + ' ';
            END;

            IF @F_IdUsuarioRequitor <> 0
            BEGIN
                SET @SQL_INNER_REQUISITOR
                    = 'INNER JOIN  dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido ';
                SET @SQL_REQUISITOR
                    = 'AND SP.IdUsuarioSolicitante =  ' + CAST(@F_IdUsuarioRequitor AS NVARCHAR(350)) + ' ';
            END;

            IF @F_IdUsuarioRequitor <> 0
            BEGIN
                SET @SQL_INNER_REQUISITOR
                    = 'INNER JOIN  dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido ';
                SET @SQL_REQUISITOR
                    = 'AND SP.IdUsuarioSolicitante =  ' + CAST(@F_IdUsuarioRequitor AS NVARCHAR(350)) + ' ';
            END;

            IF @ValidacionFecha <> 0
            BEGIN
                SET @FECHA_INICIO
                    = (CAST(DATEPART(YEAR, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(MONTH, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(DAY, @F_FechaInicio) AS NVARCHAR(350)) + ' 00:00:00 '
                      );
                SET @FECHA_FIN
                    = (CAST(DATEPART(YEAR, @F_FechaFin) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(MONTH, @F_FechaFin) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(DAY, @F_FechaFin) AS NVARCHAR(350)) + ' 23:59:59 '
                      );
                SET @SQL_PERIODO = 'AND P.CreadoEl BETWEEN ''' + @FECHA_INICIO + ''' AND ''' + @FECHA_FIN + ''' ';
            END;

            IF @F_TipoMoneda <> 0
            BEGIN
                SET @SQL_TIPO_MONEDA = ' AND TM.IdMoneda =  ' + CAST(@F_TipoMoneda AS NVARCHAR(350)) + ' ';
            END;

			IF @F_MontoFin <> 0   
			BEGIN 
				SET @SQL_MONTO = ' HAVING SUM(PD.Subtotal) BETWEEN  ' + CAST(@F_MontoInicio AS NVARCHAR(500)) + ' AND '+ CAST(@F_MontoFin AS NVARCHAR(500)) +' '
			END 


            SET @SQL_QUERY
                = ('SELECT P.IdPedido, ' 
				   + 'P.IdSolicitudPedido, ' 
				   + 'P.CreadoEl AS FechaEnvioPedido, '
                   + 'SUM(PD.Subtotal) AS TotalPedido,	' 				  
				   + 'ISNULL(RazonSocial,'''') + ''  ''+ ISNULL(RegimenCapital,'''') AS Proveedor, '
                   + 'E.Nombre, ' + 'P.Version, ' 
				   + 'P.RecepcionServicio, ' 
				   + 'TM.TipoMonedaCorto AS TipoMoneda, '
                   + '''Mercadeo'' AS TIPO, ' 
				   + 'O.IdOperacion AS IdOperacion, ' 
				   + 'PG.IdPedido AS IdPedidoGeneral '
				   + 'FROM MM_Pedido AS P '
                   + 'LEFT JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido '
                   + 'LEFT JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta '
                   + 'LEFT JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista '
                   + 'LEFT JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido '
                   + 'LEFT JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad '
                   + 'LEFT JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia '
                   + 'LEFT JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion '
                   + 'LEFT JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion '
                   + 'LEFT JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido '
				   + 'LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda ' 
				   + 'LEFT JOIN MM_Pedidos AS PG 
					  ON P.IdPedido = PG.IdIdentificador 
				      AND PG.IdTipoPedido = 2 
				      AND PG.IdProveedorCliente = '+ CAST(@IdProveedor AS NVARCHAR(350))+' '
				   + '##SQL_INNER_REQUISITOR## '
                   + 'WHERE  ' + 'O.IdTipoOperacion = 9  ' 
				   + 'AND O.IdProveedor = ' + CAST(@IdProveedor AS NVARCHAR(350)) 
				   + '  ' + 'AND P.Version=O.NoVersion ' 
				   + '##SQL_PROVEEDOR## '
                   + '##SQL_COMPRAS## ' + '##SQL_REQUISITOR## ' + '##SQL_PERIODO## ' + '##SQL_TIPO_MONEDA## ' 
                   + 'GROUP BY  ' + 'P.IdPedido, ' + 'P.IdSolicitudPedido,  ' + 'P.CreadoEl,  ' + 'RazonSocial, '
                   + 'RegimenCapital,  ' + 'P.RecepcionServicio,   ' + 'E.Nombre, ' + 'P.Version, '
                   + 'TM.TipoMonedaCorto, ' + 'O.IdOperacion, ' +' PG.IdPedido '
				   + '##SQL_MONTO## '
				   + ' ORDER BY PG.IdPedido DESC '
                  );

            ---SELECT @SQL_QUERY

            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_PROVEEDOR##', @SQL_PROVEEDOR)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_COMPRAS##', @SQL_COMPRAS)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_REQUISITOR##', @SQL_REQUISITOR)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_INNER_REQUISITOR##', @SQL_INNER_REQUISITOR)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_PERIODO##', @SQL_PERIODO)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_TIPO_MONEDA##', @SQL_TIPO_MONEDA)
            );
			 SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_MONTO##', @SQL_MONTO)
            );
			--SELECT @SQL_QUERY
            EXECUTE sp_executesql @SQL_QUERY;

        END;

        IF @F_TipoPedido = 'Compra directa'
        BEGIN

            IF @F_IdProveedorPedido <> 0
            BEGIN
                SET @SQL_PROVEEDOR = 'AND P.IdProveedor =   ' + CAST(@F_IdProveedorPedido AS NVARCHAR(350)) + ' ';
            END;


            IF @F_IdUsuarioCompras <> 0
            BEGIN
                SET @SQL_COMPRAS
                    = ' AND TAO.IdAsignador =   ' + CAST(@F_IdUsuarioCompras AS NVARCHAR(350)) + ' ';
            END;

            IF @F_IdUsuarioRequitor <> 0
            BEGIN
                SET @SQL_REQUISITOR
                    = 'AND TAO.IdAsignador = ' + CAST(@F_IdUsuarioRequitor AS NVARCHAR(350)) + ' ';
            END;

            IF @ValidacionFecha <> 0
            BEGIN
                SET @FECHA_INICIO
                    = (CAST(DATEPART(YEAR, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(MONTH, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(DAY, @F_FechaInicio) AS NVARCHAR(350)) + ' 00:00:00 '
                      );
                SET @FECHA_FIN
                    = (CAST(DATEPART(YEAR, @F_FechaFin) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(MONTH, @F_FechaFin) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(DAY, @F_FechaFin) AS NVARCHAR(350)) + ' 23:59:59 '
                      );
                SET @SQL_PERIODO
                    = 'AND coRegistro.FecMovto  BETWEEN ''' + @FECHA_INICIO + ''' AND ''' + @FECHA_FIN + ''' ';
            END;
            IF @F_TipoMoneda <> 0
            BEGIN
                SET @SQL_TIPO_MONEDA = ' AND TM.IdMoneda =  ' + CAST(@F_TipoMoneda AS NVARCHAR(350)) + ' ';
            END;
			
			IF @F_MontoFin <> 0   
			BEGIN 
				SET @SQL_MONTO = ' AND  fiFact.SubTotal BETWEEN  ' + CAST(@F_MontoInicio AS NVARCHAR(500)) + ' AND '+ CAST(@F_MontoFin AS NVARCHAR(500)) +' '
			END 

			SET @SQL_QUERY
                = 'SELECT 
			 coRegistro.IdRegistro AS IdPedido,
			 coRegistro.IdFactura AS IdSolicitudPedido,
			 TAO.FechaRegistro AS FechaEnvioPedido,
			 fiFact.SubTotal AS TotalPedido,'
			 + 'ISNULL(P.RazonSocial,'''') + ''  ''+ ISNULL(P.RegimenCapital,'''') AS Proveedor, '
    		 +'  TE.Nombre ,
			   NULL AS Version,
			   NULL AS RecepcionServicio,
			   TM.TipoMonedaCorto AS TipoMoneda,
			   ''Compra directa'' AS TIPO	,
			   TAO.IdOperacion, 
			   PG.IdPedido AS IdPedidoGeneral
			    FROM dbo.CO_Registro AS coRegistro
					LEFT JOIN dbo.FI_Factura AS fiFact
						ON coRegistro.IdFactura = fiFact.IdFactura
					LEFT JOIN TA_Operacion AS TAO
						ON TAO.IdDocumento = coRegistro.IdFactura
					LEFT JOIN TA_Estatus AS TE
						ON TE.IdEstatus = TAO.IdEstatusOperacion
					LEFT JOIN dbo.CC_CentroCosto centroCosto
						ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
					LEFT JOIN dbo.DG_CuentaContable cuentaContable
						ON cuentaContable.Id = coRegistro.CuentaContable
					LEFT JOIN dbo.CO_LineaPresupuestoMes linea
						ON linea.IdLineaPresupuestoMes = coRegistro.IdLineaPresupuestoMes
					LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
						ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
					LEFT JOIN dbo.CO_Instalacion instalacion
						ON instalacion.IdInstalacion = coRegistro.IdInstalacion
					LEFT JOIN PV_TipoMoneda AS TM
						ON TM.IdMoneda = fiFact.IdMoneda
					LEFT JOIN  dbo.S_Proveedor AS P ON P.RFC = fiFact.Emisor
					LEFT JOIN dbo.MM_Pedidos PG
					ON PG.IdIdentificador =fiFact.IdFactura
					AND PG.IdTipoPedido=1 
					AND PG.IdProveedorCliente= '  + CAST(@IdProveedor AS NVARCHAR(350))+ ' '+
				'WHERE TAO.IdTipoOperacion = 14 ' + ' ##SQL_PROVEEDOR## ' + ' ##SQL_COMPRAS## ' + ' ##SQL_REQUISITOR## '
                  + ' ##SQL_PERIODO## ' + ' ##SQL_TIPO_MONEDA##  ##SQL_MONTO## AND TAO.IdProveedor= '
                  + CAST(@IdProveedor AS NVARCHAR(350))
				  +' ORDER BY PG.IdPedido DESC '

            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_PROVEEDOR##', @SQL_PROVEEDOR)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_COMPRAS##', @SQL_COMPRAS)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_REQUISITOR##', @SQL_REQUISITOR)
            );

            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_PERIODO##', @SQL_PERIODO)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_TIPO_MONEDA##', @SQL_TIPO_MONEDA)
            );
			 SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_MONTO##', @SQL_MONTO)
            );
            EXECUTE sp_executesql @SQL_QUERY;

        END;

        IF @F_TipoPedido = 'Licitación'
        BEGIN

            IF @F_IdProveedorPedido <> 0
            BEGIN
                SET @SQL_PROVEEDOR = 'AND P.IdSubcontratista =  ' + CAST(@F_IdProveedorPedido AS NVARCHAR(350)) + ' ';
            END;


            IF @F_IdUsuarioCompras <> 0
            BEGIN
                SET @SQL_COMPRAS = ' AND P.CreadoPor =  ' + CAST(@F_IdUsuarioCompras AS NVARCHAR(350)) + ' ';
            END;

            IF @F_IdUsuarioRequitor <> 0
            BEGIN
                SET @SQL_INNER_REQUISITOR
                    = 'LEFT JOIN  dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido ';
                SET @SQL_REQUISITOR
                    = 'AND SP.IdUsuarioSolicitante =  ' + CAST(@F_IdUsuarioRequitor AS NVARCHAR(350)) + ' ';
            END;

            IF @ValidacionFecha <> 0
            BEGIN
                SET @FECHA_INICIO
                    = (CAST(DATEPART(YEAR, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(MONTH, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(DAY, @F_FechaInicio) AS NVARCHAR(350)) + ' 00:00:00 '
                      );
                SET @FECHA_FIN
                    = (CAST(DATEPART(YEAR, @F_FechaFin) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(MONTH, @F_FechaFin) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(DAY, @F_FechaFin) AS NVARCHAR(350)) + ' 23:59:59 '
                      );
                SET @SQL_PERIODO = 'AND P.CreadoEl BETWEEN ''' + @FECHA_INICIO + ''' AND ''' + @FECHA_FIN + ''' ';
            END;

            IF @F_TipoMoneda <> 0
            BEGIN
                SET @SQL_TIPO_MONEDA = ' AND TM.IdMoneda =  ' + CAST(@F_TipoMoneda AS NVARCHAR(350)) + ' ';
            END;

			IF @F_MontoFin <> 0   
			BEGIN 
				SET @SQL_MONTO = ' HAVING SUM(PD.Subtotal) BETWEEN  ' + CAST(@F_MontoInicio AS NVARCHAR(500)) + ' AND '+ CAST(@F_MontoFin AS NVARCHAR(500)) +' '
			END 		


             SET @SQL_QUERY
                = ('SELECT P.IdPedido, ' 
				   + 'P.IdSolicitudPedido, ' 
				   + 'P.CreadoEl AS FechaEnvioPedido, '
                   + 'SUM(PD.Subtotal) AS TotalPedido,	' 				  
				   + 'ISNULL(RazonSocial,'''') + ''  ''+ ISNULL(RegimenCapital,'''') AS Proveedor, '
                   + 'E.Nombre, ' + 'P.Version, ' 
				   + 'P.RecepcionServicio, ' 
				   + 'TM.TipoMonedaCorto AS TipoMoneda, '
                   + '''Mercadeo'' AS TIPO, ' 
				   + 'O.IdOperacion AS IdOperacion, ' 
				   + 'PG.IdPedido AS IdPedidoGeneral '
				   + 'FROM MM_Pedido AS P '
                   + 'LEFT JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido '
                   + 'LEFT JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta '
                   + 'LEFT JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista '
                   + 'LEFT JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido '
                   + 'LEFT JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad '
                   + 'LEFT JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia '
                   + 'LEFT JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion '
                   + 'LEFT JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion '
                   + 'LEFT JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido '
				   + 'LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda ' 
				   + 'LEFT JOIN MM_Pedidos AS PG 
					  ON P.IdPedido = PG.IdIdentificador 
				      AND PG.IdTipoPedido = 2 
				      AND PG.IdProveedorCliente = '+ CAST(@IdProveedor AS NVARCHAR(350))+' '
				   + '##SQL_INNER_REQUISITOR## '
                   + 'WHERE  ' + 'O.IdTipoOperacion = 9  ' 
				   + 'AND O.IdProveedor = ' + CAST(@IdProveedor AS NVARCHAR(350)) 
				   + '  ' + 'AND P.Version=O.NoVersion ' 
				   + '##SQL_PROVEEDOR## '
                   + '##SQL_COMPRAS## ' + '##SQL_REQUISITOR## ' + '##SQL_PERIODO## ' + '##SQL_TIPO_MONEDA## ' 
                   + 'GROUP BY  ' + 'P.IdPedido, ' + 'P.IdSolicitudPedido,  ' + 'P.CreadoEl,  ' + 'RazonSocial, '
                   + 'RegimenCapital,  ' + 'P.RecepcionServicio,   ' + 'E.Nombre, ' + 'P.Version, '
                   + 'TM.TipoMonedaCorto, ' + 'O.IdOperacion, ' +' PG.IdPedido '
				   + '##SQL_MONTO## '
				   + ' ORDER BY PG.IdPedido DESC '
                  );

            ---SELECT @SQL_QUERY

            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_PROVEEDOR##', @SQL_PROVEEDOR)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_COMPRAS##', @SQL_COMPRAS)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_REQUISITOR##', @SQL_REQUISITOR)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_INNER_REQUISITOR##', @SQL_INNER_REQUISITOR)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_PERIODO##', @SQL_PERIODO)
            );

            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_TIPO_MONEDA##', @SQL_TIPO_MONEDA)
            );
			SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_MONTO##', @SQL_MONTO)
            );

            EXECUTE sp_executesql @SQL_QUERY;

        END;

		IF @F_TipoPedido = 'Adjudicación directa'
        BEGIN

            IF @F_IdProveedorPedido <> 0
            BEGIN
                SET @SQL_PROVEEDOR = 'AND P.IdSubcontratista =  ' + CAST(@F_IdProveedorPedido AS NVARCHAR(350)) + ' ';
            END;


            IF @F_IdUsuarioCompras <> 0
            BEGIN
                SET @SQL_COMPRAS = ' AND P.CreadoPor =  ' + CAST(@F_IdUsuarioCompras AS NVARCHAR(350)) + ' ';
            END;

            IF @F_IdUsuarioRequitor <> 0
            BEGIN
                SET @SQL_INNER_REQUISITOR
                    = 'INNER JOIN  dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido ';
                SET @SQL_REQUISITOR
                    = 'AND SP.IdUsuarioSolicitante =  ' + CAST(@F_IdUsuarioRequitor AS NVARCHAR(350)) + ' ';
            END;

            IF @F_IdUsuarioRequitor <> 0
            BEGIN
                SET @SQL_INNER_REQUISITOR
                    = 'INNER JOIN  dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido ';
                SET @SQL_REQUISITOR
                    = 'AND SP.IdUsuarioSolicitante =  ' + CAST(@F_IdUsuarioRequitor AS NVARCHAR(350)) + ' ';
            END;

            IF @ValidacionFecha <> 0
            BEGIN
                SET @FECHA_INICIO
                    = (CAST(DATEPART(YEAR, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(MONTH, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(DAY, @F_FechaInicio) AS NVARCHAR(350)) + ' 00:00:00 '
                      );
                SET @FECHA_FIN
                    = (CAST(DATEPART(YEAR, @F_FechaFin) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(MONTH, @F_FechaFin) AS NVARCHAR(350)) + '/'
                       + CAST(DATEPART(DAY, @F_FechaFin) AS NVARCHAR(350)) + ' 23:59:59 '
                      );
                SET @SQL_PERIODO = 'AND P.CreadoEl BETWEEN ''' + @FECHA_INICIO + ''' AND ''' + @FECHA_FIN + ''' ';
            END;

            IF @F_TipoMoneda <> 0
            BEGIN
                SET @SQL_TIPO_MONEDA = ' AND TM.IdMoneda =  ' + CAST(@F_TipoMoneda AS NVARCHAR(350)) + ' ';
            END;

			IF @F_MontoFin <> 0   
			BEGIN 
				SET @SQL_MONTO = ' HAVING SUM(PD.Subtotal) BETWEEN  ' + CAST(@F_MontoInicio AS NVARCHAR(500)) + ' AND '+ CAST(@F_MontoFin AS NVARCHAR(500)) +' '
			END 


            SET @SQL_QUERY
                = ('SELECT P.IdPedido, ' 
				   + 'P.IdSolicitudPedido, ' 
				   + 'P.CreadoEl AS FechaEnvioPedido, '
                   + 'SUM(PD.Subtotal) AS TotalPedido,	' 				  
				   + 'ISNULL(RazonSocial,'''') + ''  ''+ ISNULL(RegimenCapital,'''') AS Proveedor, '
                   + 'E.Nombre, ' + 'P.Version, ' 
				   + 'P.RecepcionServicio, ' 
				   + 'TM.TipoMonedaCorto AS TipoMoneda, '
                   + '''Adjudicación directa'' AS TIPO, ' 
				   + 'O.IdOperacion AS IdOperacion, ' 
				   + 'PG.IdPedido AS IdPedidoGeneral '
				   + 'FROM MM_Pedido AS P '
                   + 'LEFT JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido '
                   + 'LEFT JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta '
                   + 'LEFT JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista '
                   + 'LEFT JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido '
                   + 'LEFT JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad '
                   + 'LEFT JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia '
                   + 'LEFT JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion '
                   + 'LEFT JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion '
                   + 'LEFT JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido '
				   + 'LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda ' 
				   + 'LEFT JOIN MM_Pedidos AS PG 
					  ON P.IdPedido = PG.IdIdentificador 
				      AND PG.IdTipoPedido = 2 
				      AND PG.IdProveedorCliente = '+ CAST(@IdProveedor AS NVARCHAR(350))+' '
				   + '##SQL_INNER_REQUISITOR## '
                   + 'WHERE  ' + 'O.IdTipoOperacion = 9  ' 
				   + 'AND O.IdProveedor = ' + CAST(@IdProveedor AS NVARCHAR(350)) 
				   + '  ' + 'AND P.Version=O.NoVersion ' 
				   + '##SQL_PROVEEDOR## '
                   + '##SQL_COMPRAS## ' + '##SQL_REQUISITOR## ' + '##SQL_PERIODO## ' + '##SQL_TIPO_MONEDA## ' 
                   + 'GROUP BY  ' + 'P.IdPedido, ' + 'P.IdSolicitudPedido,  ' + 'P.CreadoEl,  ' + 'RazonSocial, '
                   + 'RegimenCapital,  ' + 'P.RecepcionServicio,   ' + 'E.Nombre, ' + 'P.Version, '
                   + 'TM.TipoMonedaCorto, ' + 'O.IdOperacion, ' +' PG.IdPedido '
				   + '##SQL_MONTO## '
				   + ' ORDER BY PG.IdPedido DESC '
                  );

            ---SELECT @SQL_QUERY

            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_PROVEEDOR##', @SQL_PROVEEDOR)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_COMPRAS##', @SQL_COMPRAS)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_REQUISITOR##', @SQL_REQUISITOR)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_INNER_REQUISITOR##', @SQL_INNER_REQUISITOR)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_PERIODO##', @SQL_PERIODO)
            );
            SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_TIPO_MONEDA##', @SQL_TIPO_MONEDA)
            );
			 SET @SQL_QUERY =
            (
                SELECT REPLACE(@SQL_QUERY, '##SQL_MONTO##', @SQL_MONTO)
            );
			--SELECT @SQL_QUERY
            EXECUTE sp_executesql @SQL_QUERY;

        END;
    END;


	--#Busca todos los pedidos con los requerimientos solicitados 
    IF @Filtro = 'TODO_FILTRO'
    BEGIN
		
        --#Mercadeo
		DECLARE @SQL_MERCADEO NVARCHAR(MAX)=''
		DECLARE @SQL_COMPRA_DIRECTA NVARCHAR(MAX)=''

        IF @F_IdProveedorPedido <> 0
        BEGIN
            SET @SQL_PROVEEDOR = 'AND P.IdSubcontratista =  ' + CAST(@F_IdProveedorPedido AS NVARCHAR(350)) + ' ';
        END;


        IF @F_IdUsuarioCompras <> 0
        BEGIN
            SET @SQL_COMPRAS = ' AND P.CreadoPor =  ' + CAST(@F_IdUsuarioCompras AS NVARCHAR(350)) + ' ';
        END;

        IF @F_IdUsuarioRequitor <> 0
        BEGIN
            SET @SQL_INNER_REQUISITOR
                = 'LEFT JOIN  dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido ';
            SET @SQL_REQUISITOR
                = 'AND SP.IdUsuarioSolicitante =  ' + CAST(@F_IdUsuarioRequitor AS NVARCHAR(350)) + ' ';
        END;

        IF @ValidacionFecha <> 0
        BEGIN
            SET @FECHA_INICIO
                = (CAST(DATEPART(YEAR, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                   + CAST(DATEPART(MONTH, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                   + CAST(DATEPART(DAY, @F_FechaInicio) AS NVARCHAR(350)) + ' 00:00:00 '
                  );
            SET @FECHA_FIN
                = (CAST(DATEPART(YEAR, @F_FechaFin) AS NVARCHAR(350)) + '/'
                   + CAST(DATEPART(MONTH, @F_FechaFin) AS NVARCHAR(350)) + '/'
                   + CAST(DATEPART(DAY, @F_FechaFin) AS NVARCHAR(350)) + ' 23:59:59 '
                  );
            SET @SQL_PERIODO = 'AND P.CreadoEl BETWEEN ''' + @FECHA_INICIO + ''' AND ''' + @FECHA_FIN + ''' ';
        END;

        IF @F_TipoMoneda <> 0
        BEGIN
            SET @SQL_TIPO_MONEDA = ' AND TM.IdMoneda =  ' + CAST(@F_TipoMoneda AS NVARCHAR(350)) + ' ';
        END;

		IF @F_MontoFin <> 0   
			BEGIN 
				SET @SQL_MONTO = ' HAVING SUM(PD.Subtotal) BETWEEN  ' + CAST(@F_MontoInicio AS NVARCHAR(500)) + ' AND '+ CAST(@F_MontoFin AS NVARCHAR(500)) +' '
			END 		


        SET @SQL_MERCADEO
            = ('SELECT P.IdPedido, ' + 'P.IdSolicitudPedido, ' + 'P.CreadoEl AS FechaEnvioPedido, '
               + 'SUM(PD.Subtotal) AS TotalPedido,	'
			   + 'ISNULL(RazonSocial,'''') + ''  ''+ ISNULL(RegimenCapital,'''') AS Proveedor, '
               + 'E.Nombre, ' + 'P.Version, ' + 'P.RecepcionServicio, ' + 'TM.TipoMonedaCorto AS TipoMoneda, '
               + '''Mercadeo'' AS TIPO, ' + 'O.IdOperacion AS IdOperacion, '  + ' PG.IdPedido AS IdPedidoGeneral ' 
			   + 'FROM MM_Pedido AS P '
               + 'LEFT JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido '
               + 'LEFT JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta '
               + 'LEFT JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista '
               + 'LEFT JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido '
               + 'LEFT JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad '
               + 'LEFT JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia '
               + 'LEFT JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion '
               + 'LEFT JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion '
               + 'LEFT JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido '
               + 'LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda ' 
			   + 'LEFT JOIN MM_Pedidos AS PG 
					  ON P.IdPedido = PG.IdIdentificador 
				      AND PG.IdTipoPedido = 2 
				      AND PG.IdProveedorCliente = '+ CAST(@IdProveedor AS NVARCHAR(350))+' '
			   + '##SQL_INNER_REQUISITOR## '
               + 'WHERE  ' + 'O.IdTipoOperacion = 9  ' + 'AND O.IdProveedor = ' + CAST(@IdProveedor AS NVARCHAR(350))
               + '  ' + 'AND P.Version=O.NoVersion ' + '##SQL_PROVEEDOR## ' + '##SQL_COMPRAS## '
               + '##SQL_REQUISITOR## ' + '##SQL_PERIODO## ' + ' ##SQL_TIPO_MONEDA## ' + 'GROUP BY  ' + 'P.IdPedido, '
               + 'P.IdSolicitudPedido,  ' + 'P.CreadoEl,  ' + 'RazonSocial, ' + 'RegimenCapital,  '
               + 'P.RecepcionServicio,   ' + 'E.Nombre, ' + 'P.Version, ' + 'TM.TipoMonedaCorto, ' + 'O.IdOperacion, '
			   + ' PG.IdPedido ' 
			   + '##SQL_MONTO## '
              );



        SET @SQL_MERCADEO =
        (
            SELECT REPLACE(@SQL_MERCADEO, '##SQL_PROVEEDOR##', @SQL_PROVEEDOR)
        );
        SET @SQL_MERCADEO =
        (
            SELECT REPLACE(@SQL_MERCADEO, '##SQL_COMPRAS##', @SQL_COMPRAS)
        );
        SET @SQL_MERCADEO =
        (
            SELECT REPLACE(@SQL_MERCADEO, '##SQL_REQUISITOR##', @SQL_REQUISITOR)
        );
        SET @SQL_MERCADEO =
        (
            SELECT REPLACE(@SQL_MERCADEO, '##SQL_INNER_REQUISITOR##', @SQL_INNER_REQUISITOR)
        );
        SET @SQL_MERCADEO =
        (
            SELECT REPLACE(@SQL_MERCADEO, '##SQL_PERIODO##', @SQL_PERIODO)
        );

        SET @SQL_MERCADEO =
        (
            SELECT REPLACE(@SQL_MERCADEO, '##SQL_TIPO_MONEDA##', @SQL_TIPO_MONEDA)
        );
		 SET @SQL_MERCADEO =
            (
                SELECT REPLACE(@SQL_MERCADEO, '##SQL_MONTO##', @SQL_MONTO)
            );

      --  SET @SQL_QUERY = (@SQL_QUERY + ' UNION ');
        --#COMPRA DIRECTA 
        DECLARE @SQL_PROVEEDOR_CD NVARCHAR(MAX) = '';
        DECLARE @SQL_TIPO_PEDIDO_CD NVARCHAR(MAX) = '';
        DECLARE @SQL_REQUISITOR_CD NVARCHAR(MAX) = '';
        DECLARE @SQL_PERIODO_CD NVARCHAR(MAX) = '';
        DECLARE @SQL_COMPRAS_CD NVARCHAR(MAX) = '';
        DECLARE @SQL_TIPO_MONEDA_CD NVARCHAR(MAX) = '';
		DECLARE @SQL_MONTO_CD NVARCHAR(MAX) = '';

        IF @F_IdProveedorPedido <> 0
        BEGIN
            SET @SQL_PROVEEDOR_CD = 'AND P.IdProveedor =   ' + CAST(@F_IdProveedorPedido AS NVARCHAR(350)) + ' ';
        END;


        IF @F_IdUsuarioCompras <> 0
        BEGIN
            SET @SQL_COMPRAS_CD
                = 'AND TAO.IdAsignador = ' + CAST(@F_IdUsuarioCompras AS NVARCHAR(350)) + ' ';
        END;

        IF @F_IdUsuarioRequitor <> 0
        BEGIN
            SET @SQL_REQUISITOR_CD
                = 'AND TAO.IdAsignador =  ' + CAST(@F_IdUsuarioRequitor AS NVARCHAR(350)) + ' ';
        END;

        IF @ValidacionFecha <> 0
        BEGIN
            SET @FECHA_INICIO
                = (CAST(DATEPART(YEAR, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                   + CAST(DATEPART(MONTH, @F_FechaInicio) AS NVARCHAR(350)) + '/'
                   + CAST(DATEPART(DAY, @F_FechaInicio) AS NVARCHAR(350)) + ' 00:00:00 '
                  );
            SET @FECHA_FIN
                = (CAST(DATEPART(YEAR, @F_FechaFin) AS NVARCHAR(350)) + '/'
                   + CAST(DATEPART(MONTH, @F_FechaFin) AS NVARCHAR(350)) + '/'
                   + CAST(DATEPART(DAY, @F_FechaFin) AS NVARCHAR(350)) + ' 23:59:59 '
                  );
            SET @SQL_PERIODO_CD
                = 'AND coRegistro.FecMovto  BETWEEN ''' + @FECHA_INICIO + ''' AND ''' + @FECHA_FIN + ''' ';
        END;

        IF @F_TipoMoneda <> 0
        BEGIN
            SET @SQL_TIPO_MONEDA_CD = ' AND TM.IdMoneda =  ' + CAST(@F_TipoMoneda AS NVARCHAR(350)) + ' ';
        END;

		IF @F_MontoFin <> 0   
			BEGIN 
				SET @SQL_MONTO_CD = ' AND  fiFact.SubTotal BETWEEN  ' + CAST(@F_MontoInicio AS NVARCHAR(500)) + ' AND '+ CAST(@F_MontoFin AS NVARCHAR(500)) +' '
			END 

        SET @SQL_COMPRA_DIRECTA
            = @SQL_COMPRA_DIRECTA
              + 'SELECT 
			 coRegistro.IdRegistro AS IdPedido,
			 coRegistro.IdFactura AS IdSolicitudPedido,
			 TAO.FechaRegistro AS FechaEnvioPedido,
			 fiFact.SubTotal AS TotalPedido, '			
			  + 'ISNULL(P.RazonSocial,'''') + ''  ''+ ISNULL(P.RegimenCapital,'''') AS Proveedor, ' +
    		  ' TE.Nombre ,
			   NULL AS Version,
			   NULL AS RecepcionServicio,
			   TM.TipoMonedaCorto AS TipoMoneda,
			   ''Compra directa'' AS TIPO	,
			   TAO.IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral 
			    FROM dbo.CO_Registro AS coRegistro
					LEFT JOIN dbo.FI_Factura AS fiFact
						ON coRegistro.IdFactura = fiFact.IdFactura
					LEFT JOIN TA_Operacion AS TAO
						ON TAO.IdDocumento = coRegistro.IdFactura
					LEFT JOIN TA_Estatus AS TE
						ON TE.IdEstatus = TAO.IdEstatusOperacion
					LEFT JOIN dbo.CC_CentroCosto centroCosto
						ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
					LEFT JOIN dbo.DG_CuentaContable cuentaContable
						ON cuentaContable.Id = coRegistro.CuentaContable
					LEFT JOIN dbo.CO_LineaPresupuestoMes linea
						ON linea.IdLineaPresupuestoMes = coRegistro.IdLineaPresupuestoMes
					LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
						ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
					LEFT JOIN dbo.CO_Instalacion instalacion
						ON instalacion.IdInstalacion = coRegistro.IdInstalacion
					LEFT JOIN PV_TipoMoneda AS TM
						ON TM.IdMoneda = fiFact.IdMoneda
					LEFT JOIN  dbo.S_Proveedor AS P ON P.RFC = fiFact.Emisor 
					LEFT JOIN dbo.MM_Pedidos PG
					ON PG.IdIdentificador =fiFact.IdFactura
					AND PG.IdTipoPedido=1 
					AND PG.IdProveedorCliente= '  + CAST(@IdProveedor AS NVARCHAR(350))+ ' '+
				'WHERE TAO.IdTipoOperacion = 14 ' + ' ##SQL_PROVEEDOR## ' + ' ##SQL_COMPRAS## ' + ' ##SQL_REQUISITOR## '
              + ' ##SQL_PERIODO## ' + '##SQL_TIPO_MONEDA## ##SQL_MONTO## ' + 'AND TAO.IdProveedor= '
              + CAST(@IdProveedor AS NVARCHAR(350));

        SET @SQL_COMPRA_DIRECTA =
        (
            SELECT REPLACE(@SQL_COMPRA_DIRECTA, '##SQL_PROVEEDOR##', @SQL_PROVEEDOR_CD)
        );
        SET @SQL_COMPRA_DIRECTA =
        (
            SELECT REPLACE(@SQL_COMPRA_DIRECTA, '##SQL_COMPRAS##', @SQL_COMPRAS_CD)
        );
        SET @SQL_COMPRA_DIRECTA =
        (
            SELECT REPLACE(@SQL_COMPRA_DIRECTA, '##SQL_REQUISITOR##', @SQL_REQUISITOR_CD)
        );

        SET @SQL_COMPRA_DIRECTA =
        (
            SELECT REPLACE(@SQL_COMPRA_DIRECTA, '##SQL_PERIODO##', @SQL_PERIODO_CD)
        );

        SET @SQL_COMPRA_DIRECTA =
        (
            SELECT REPLACE(@SQL_COMPRA_DIRECTA, '##SQL_TIPO_MONEDA##', @SQL_TIPO_MONEDA_CD)
        );
				
        SET @SQL_COMPRA_DIRECTA =
        (
            SELECT REPLACE(@SQL_COMPRA_DIRECTA, '##SQL_MONTO##', @SQL_MONTO_CD)
        );

        --#Licitación	
		--#UNIO ALL DE PEDIDOS
		
		SET @SQL_QUERY='SELECT * FROM '
		SET @SQL_QUERY = @SQL_QUERY + '('
		SET @SQL_QUERY = @SQL_QUERY + @SQL_MERCADEO
		SET @SQL_QUERY = @SQL_QUERY + ' UNION ALL  '
		SET @SQL_QUERY = @SQL_QUERY + @SQL_COMPRA_DIRECTA
		SET @SQL_QUERY = @SQL_QUERY + ') Pedidos ORDER BY FechaEnvioPedido DESC'			
				
			
        EXECUTE sp_executesql @SQL_QUERY;
    END;
END;




