CREATE PROCEDURE [dbo].[USP_SEL_CO_AdquisicionContratacionCNHPorPresupuesto]  
    @IdContrato    INT,  
    @Fechainicio   DATE,  
    @FechaFin      DATE,  
    @IdPeriodo     INT,  
    @IdPresupuesto INT,  
 @IdUsuario    INT  
AS  
    BEGIN  
        
        SET NOCOUNT ON  
  
        -- SE CREA TABLA PARA QUE NO SE REPITAN LOS DATOS EN LOS MONTOS POR HABER DUPLICADOS EN ESTA TABLA: AX_Layout  
         CREATE TABLE #AX_Layout
		   (
			IdLayoutAX	INT,
			Empresa	NVARCHAR (250),
			NoOrden	NVARCHAR (250),
			FechaRegistroCompra	NVARCHAR(1000),
			NoPedidoADINCO	NVARCHAR (250),
			Estatus	NVARCHAR(1000),
			FechaEntrega	NVARCHAR(1000)
		   )
  
        --- VALIDAR SI EL CONTRATO ES DE CARSO, EJECUTAR SP DE SP_SC_AdquisicionContratacionCNH_Carso           
        CREATE TABLE #TablaDEA  
            (  
                NumeroContrato NVARCHAR(100),   
				RelacionOperadoraProveedor NVARCHAR(100),   
				Proveedor NVARCHAR(4000),   
				MecanismoContratacion NVARCHAR(200),   
				[Nombre Contrato C-P] NVARCHAR(4000),   
				[No. Contrato] NVARCHAR(4000),   
				[Fecha Inicio Contrato] DATETIME,   
				[Fecha Termino Contrato] DATETIME,   
				[Vigencia del contrato] DATETIME,   
				[Objeto del contrato] NVARCHAR(4000),   
				MontoUSD FLOAT,   
				MontoMXN FLOAT,   
				TipoCambio FLOAT,   
				FechaTipoCambio DATETIME,   
				Comentarios NVARCHAR(4000),   
				NombreContratista NVARCHAR(4000),   
				FechaEfectiva NVARCHAR(10)  
            );  
  
        CREATE TABLE #Tabla  
            (  
				NumeroContrato NVARCHAR(1000),   
				RelacionOperadoraProveedor NVARCHAR(100),   
				Proveedor NVARCHAR(4000),   
				MecanismoContratacion NVARCHAR(200),   
				[Nombre Contrato C-P] VARCHAR(8000),   
				[No. Contrato] NVARCHAR(4000),   
				[Fecha Inicio Contrato] NVARCHAR(4000),   
				[Fecha Termino Contrato] NVARCHAR(4000),   
				[Vigencia del contrato] NVARCHAR(4000),   
				[Objeto del contrato] VARCHAR(8000),   
				MontoUSD FLOAT,   
				MontoMXN FLOAT,   
				TipoCambio NVARCHAR(4000),
				FechaTipoCambio NVARCHAR(4000),   
				Comentarios NVARCHAR(4000),   
				NombreContratista NVARCHAR(4000),   
				FechaEfectiva NVARCHAR(10)   
            );  
  
        CREATE TABLE #TablaWDEA_PurchasingDocumentsImportados  
            (  
                IdPedidoADINCO         INT,  
                PURCHASING_DOCUMENT    VARCHAR(4000),  
                CURRENCY               VARCHAR(4000),  
                NET_ORDER_VALUE        FLOAT,  
                SUM_NET_PRICE          FLOAT,  
                IDMONEDA               INT,  
                OUTLINE_AGREEMENT      VARCHAR(4000),  
                NumeroContrato         VARCHAR(4000),  
                MECANISMO_CONTRATACION VARCHAR(4000)  
            );  
  
        CREATE TABLE #MM_PedidoDetalle  
            (  
                IdPedido     INT,  
                SUM_Subtotal FLOAT  
            );  
  
        CREATE TABLE #CO_LineasPresupuestoMes (IdLineaPresupuestoMes INT);  
  
        DECLARE  
            @Peso                              INT = 1,  
            @Dolar                             INT = 2,  
            @CompraDirecta                     INT = 14,  
            @Aprobado                          INT = 2,  
            @EnAprobacion                      INT = 1,  
            @TipoPedidoCompraDirecta           INT = 1,  
            @AprobacionDePedido                INT = 9,  
            @Bloque                            VARCHAR(50),  
            @ContratistaRazonSocialDelContrato VARCHAR(300),  
            @NumeroContrato                    VARCHAR(300),  
            @FechaFirma                        date,  
            @IdContratista                     INT;  
  
        SELECT  
            @NumeroContrato                    = LEFT(CO_Contrato.NumeroContrato, 300),  
            @FechaFirma                        = CO_Contrato.FechaFirma,  
            @ContratistaRazonSocialDelContrato = LEFT(CO_Contratista.RazonSocial, 300),  
            @IdContratista                     = CO_Contrato.IdContratista  
        FROM  
            Adinco.dbo.CO_Contrato        AS CO_Contrato (NOLOCK)  
            JOIN  
                Adinco.dbo.CO_Contratista AS CO_Contratista (NOLOCK)  
                    ON CO_Contrato.IdContratista = CO_Contratista.IdContratista  
        WHERE  
            CO_Contrato.IdContrato = @IdContrato  
  
        INSERT INTO #CO_LineasPresupuestoMes  
            (  
                IdLineaPresupuestoMes  
            )  
                    SELECT  
                        IdLineaPresupuestoMes  
                    FROM  
                        Adinco.dbo.CO_LineaPresupuestoMes  
                    WHERE  
                    IdPresupuesto = @IdPresupuesto;  
  
        ---AGREGAR LOS CONTRATOS QUE ESTAN INCLUIDOS EN EL REPORTE DE CARSO --           
        --##EDITAR ID'S DE CONTRATOS##      
  
        IF ISNULL(@IdContrato, 0) IN (  
                                         10047, 10048  
                                     )  
            BEGIN  
  
                SELECT  
                    @Bloque = CASE  
                                  WHEN @IdContrato = 10047  
                                      THEN 'OP12'  
                                  ELSE  
                                      'OP13'  
                              END;  
  
                INSERT INTO #AX_Layout  
                    (  
                        IdLayoutAX,  
                        Empresa,  
                        NoOrden,  
                        FechaRegistroCompra,  
                        NoPedidoADINCO,  
                        Estatus,  
                        FechaEntrega  
                    )  
                            SELECT  
                                MAX(IdLayoutAX),  
                                Empresa,  
                                NoOrden,  
                                FechaRegistroCompra,  
                                NoPedidoADINCO,  
                                Estatus,  
                                FechaEntrega  
                            FROM  
                                Petrovendor.dbo.AX_Layout (NOLOCK)  
                            GROUP BY  
                                Empresa,  
                                NoOrden,  
                                FechaRegistroCompra,  
                                NoPedidoADINCO,  
                                Estatus,  
                                FechaEntrega  
  
                --CASO PARA COMPRAS DIRECTAS DE CARSO         
                INSERT INTO #Tabla  
                    (  
                        NumeroContrato,  
                        RelacionOperadoraProveedor,  
                        Proveedor,  
                        MecanismoContratacion,  
                        [Nombre Contrato C-P],  
                        [No. Contrato],  
                        [Fecha Inicio Contrato],  
                        [Fecha Termino Contrato],  
                        [Vigencia del contrato],  
                        [Objeto del contrato],  
                        MontoUSD,  
                        MontoMXN,  
                        TipoCambio,  
                        FechaTipoCambio,  
                        Comentarios,  
                        NombreContratista,  
                        FechaEfectiva  
                    )  
                            SELECT  
                                @NumeroContrato,  
                                CASE  
                                    WHEN PV_RelacionProveedorSubcotratista.IdRelacion IS NOT NULL  
                                        THEN 'SI'  
                                    ELSE  
                                        'NO'  
                                END                                                                                   AS RelacionOperadoraProveedor,  
								LEFT(UPPER(S_Proveedor.RazonSocial) + ' ' + ISNULL(UPPER(S_Proveedor.RegimenCapital), ''), 4000) AS Proveedor,
                                'ADJUDICACIÓN DIRECTA'                                                                AS MecanismoContratacion,  
								LEFT(UPPER(ISNULL(TA_Operacion.Descripcion, '')), 4000)								  AS 'Nombre Contrato C-P',  
                                LEFT(UPPER(CONCAT(MM_Pedidos.IdPedido, ' CD')), 4000)	                              AS 'No. Contrato',  
                                CASE  
                                    WHEN CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105) IS NULL  
                                        THEN '-'  
                                    ELSE  
                                        CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105)  
                                END                                                                                   AS 'Fecha Inicio Contrato',  
                                CASE  
                                    WHEN CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105) IS NULL  
                                        THEN '-'  
                                    ELSE  
                                        CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105)  
                                END                                                                                   AS 'Fecha Termino Contrato',  
                                CASE  
                                    WHEN CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105) IS NULL  
                                        THEN '-'  
                                    ELSE  
                                        CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105)  
                                END                                                                                   AS 'Vigencia del contrato',  
                                LEFT(UPPER(ISNULL(TA_Operacion.Descripcion, '')), 4000)							    AS 'Objeto del contrato',  
                                CASE  
                                    WHEN FI_Factura.IdMoneda = @Peso  
                                        THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(  
                                                                                          FI_Factura.SubTotal,  
                                                                                          CAST(FI_Factura.FechaTimbrado AS DATE)  
                                                                                      )  
                                    ELSE  
                                        FI_Factura.SubTotal  
                                END                                                                                   AS MontoUSD,  
                                CASE  
                                    WHEN FI_Factura.IdMoneda = @Dolar  
                                        THEN Petrovendor.dbo.FN_DolaresPesosTipoCambio(  
                                                                                          FI_Factura.SubTotal,  
                                                                                          CAST(FI_Factura.FechaTimbrado AS DATE)  
                                                                                      )  
                                    ELSE  
                                        FI_Factura.SubTotal  
                                END                                                                                   AS MontoMXN,  
                                Petrovendor.dbo.FN_ValorTipoCambioIterativo(CAST(TA_Operacion.FechaRegistro AS DATE)) AS TipoCambio,  
                                CONVERT(VARCHAR, TA_Operacion.FechaRegistro, 105)                                     AS FechaTipoCambio,  
                                LEFT(UPPER(ISNULL(TA_Operacion.Descripcion, '')), 4000)							      AS 'Comentarios',  
                                LEFT(UPPER((@ContratistaRazonSocialDelContrato)), 4000)                               AS NombreContratista,  
                                ''                                                                                    AS FechaEfectiva  
                            FROM  
                                #CO_LineasPresupuestoMes        AS TTLineasPresupuesto  
                                JOIN  
                                    Petrovendor.dbo.CO_Registro AS CO_Registro (NOLOCK)  
                                        ON TTLineasPresupuesto.IdLineaPresupuestoMes = CO_Registro.IdLineaPresupuestoMes  
                                JOIN  
                                    Petrovendor.dbo.TA_Operacion (NOLOCK)  
                                        ON CO_Registro.IdFactura = TA_Operacion.IdDocumento  
                                           AND TA_Operacion.IdTipoOperacion = @CompraDirecta  
                                           AND TA_Operacion.IdEstatusOperacion = @Aprobado  
                                           AND CONVERT(VARCHAR, TA_Operacion.FechaRegistro, 112)  
                                           BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(  
                                                                                                      VARCHAR,  
                                                                                                      @FechaFin, 112  
                                                                                                  )  
                                JOIN  
                                    Petrovendor.dbo.FI_Factura (NOLOCK)  
                                        ON ISNULL(FI_Factura.IsEliminado, 0) = 0  
                                           AND CO_Registro.IdFactura = FI_Factura.IdFactura  
                                           AND FI_Factura.IdContrato = @IdContrato  
                                JOIN  
                                    Petrovendor.dbo.MM_Pedidos (NOLOCK)  
                                        ON FI_Factura.IdFactura = MM_Pedidos.IdIdentificador  
                                           AND MM_Pedidos.IdTipoPedido = @TipoPedidoCompraDirecta  
                                           AND MM_Pedidos.IdProveedorCliente = TA_Operacion.IdProveedor  
                                JOIN  
                                    Petrovendor.dbo.S_Proveedor (NOLOCK)  
                                        ON FI_Factura.Emisor = S_Proveedor.RFC  
                                JOIN  
                                    Petrovendor.dbo.PV_RelacionProveedorSubcotratista (NOLOCK)  
                                        ON S_Proveedor.IdProveedor = PV_RelacionProveedorSubcotratista.IdProveedor  
             AND S_Proveedor.IdProveedor = PV_RelacionProveedorSubcotratista.IdProveedor  
                            WHERE  
                                TA_Operacion.IdTipoOperacion = @CompraDirecta  
                                AND TA_Operacion.IdEstatusOperacion = @Aprobado  
                                AND ISNULL(FI_Factura.IsEliminado, 0) = 0  
                                AND FI_Factura.IdContrato = @IdContrato  
                                AND CONVERT(VARCHAR, TA_Operacion.FechaRegistro, 112)  
                                BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112);  
  
  
                --#MODIFICACIÓN PARA PEDIDOS -MERCADEO - ADJ DIRECTA DE OPERADORA CARSO          
                INSERT INTO #Tabla  
                    (  
                        NumeroContrato,  
                        RelacionOperadoraProveedor,  
                        Proveedor,  
                        MecanismoContratacion,  
                        [Nombre Contrato C-P],  
                        [No. Contrato],  
                        [Fecha Inicio Contrato],  
                        [Fecha Termino Contrato],  
                        [Vigencia del contrato],  
                        [Objeto del contrato],  
                        MontoUSD,  
                        MontoMXN,  
                        TipoCambio,  
                        FechaTipoCambio,  
                        Comentarios,  
                        NombreContratista,  
                        FechaEfectiva  
                    )  
                            SELECT  
                                @NumeroContrato,  
                                CASE  
                                    WHEN PV_RelacionProveedorSubcotratista.IdRelacion IS NOT NULL  
                                        THEN 'SI'  
                                    ELSE  
                                        'NO'  
                                END                                                                                  AS RelacionOperadoraProveedor,  
                                LEFT(UPPER(S_Proveedor.RazonSocial) + ' ' + ISNULL(UPPER(S_Proveedor.RegimenCapital), ''), 4000) AS Proveedor,
                                CASE  
                                    WHEN MM_TipoPedido.TipoPedido = 'Mercadeo'  
                                        THEN 'TRES COTIZACIONES'  
                                    ELSE  
                                        LEFT(UPPER(MM_TipoPedido.TipoPedido), 4000)
                                END                                                                                  AS MecanismoContratacion,  
                                LEFT(dbo.fn_SC_AdquisicionMaterialesCarso(MM_Pedido.IdPedido), 1100)                AS 'Nombre Contrato C-P',            ---> OBTENER EL NOMBRE DE LOS MATERIALES DE LA COMPARATIVA  QUE ESTAN EN EL PEDIDO ACTUAL         
                                LEFT(#AX_Layout.NoOrden, 4000)                                                       AS 'No. Contrato',                   --> NUMERO DE PEDIDO DE AX          
                                REPLACE(#AX_Layout.FechaRegistroCompra, '/', '-')                                    AS 'Fecha Inicio Contrato',          --> FECHA DE CREACIÓN DEL PEDIDO EN AX         
                                REPLACE(#AX_Layout.FechaEntrega, '/', '-')                                           AS 'Fecha Termino Contrato',         --> FECHA DE LA PRIMERA ACEPTACIÓN DE PEDIDO DE AX          
                                REPLACE(#AX_Layout.FechaEntrega, '/', '-')                                           AS 'Vigencia del contrato',          --> DIFERENCIA PARA OBTENER LA VIGENCIA DEL CONTRATO         
                                LEFT(dbo.fn_SC_AdquisicionMaterialesCarso(MM_Pedido.IdPedido), 1100)                AS 'Objeto del contrato',            ---> OBTENER EL NOMBRE DE LOS MATERIALES DE LA COMPARATIVA  QUE ESTAN EN EL PEDIDO ACTUAL         
                                CASE  
                                    WHEN PV_TipoMoneda.IdMoneda = @Peso  
                                         AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) IS NOT NULL  
                                        THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(  
                                                                                          SUM(MM_PedidoDetalle.Subtotal),  
                                                                                          CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) AS DATE)  
                                                                                      )  
                                    WHEN PV_TipoMoneda.IdMoneda = @Dolar  
                                         AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) IS NOT NULL  
                                        THEN SUM(MM_PedidoDetalle.Subtotal)  
                                    ELSE  
                                        0  
                                END                                                                                  AS MontoUSD,  
                                CASE  
                                    WHEN PV_TipoMoneda.IdMoneda = @Dolar  
                                         AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) IS NOT NULL  
                                        THEN Petrovendor.dbo.FN_DolaresPesosTipoCambio(  
                                                                                          SUM(MM_PedidoDetalle.Subtotal),  
                                                                                          CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) AS DATE)  
                                                                                      )  
                                    WHEN PV_TipoMoneda.IdMoneda = @Peso  
                                         AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) IS NOT NULL  
                                        THEN (DBO.fn_ObtenSubtotalPedido(  
                                                                            PV_TipoMoneda.IdMoneda, MM_Pedido.IdPedido,  
                                                                            @IdContrato  
                                                                        )  
                                             )  
                                    ELSE  
                                        0  
                                END                                                                                  AS MontoMXN,  
                                CASE  
                                    WHEN dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) IS NOT NULL  
                                        THEN Petrovendor.dbo.FN_ValorTipoCambioIterativo(CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) AS DATE))  
                                    ELSE  
                                        ''  
                                END                                                                                  AS TipoCambio,  
                                REPLACE(#AX_Layout.FechaRegistroCompra, '/', '-')                                    AS FechaTipoCambio,                  --DWONG 20190712         
                                LEFT(dbo.fn_SC_AdquisicionMaterialesCarso(MM_Pedido.IdPedido), 1100)                 AS 'Comentarios',  
                                NombreContratista                                                                    = LEFT(UPPER(@ContratistaRazonSocialDelContrato), 4000),  
                                FechaEfectiva                                                                        = CONVERT(VARCHAR, @FechaFirma, 103) --DWONG 20190712         
                            FROM  
                                #CO_LineasPresupuestoMes                                      AS TTLineasPresupuesto  
                                JOIN  
                                    Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS MM_SolicitudPedidoDetalleLineaPresupuesto (NOLOCK)  
                                        ON TTLineasPresupuesto.IdLineaPresupuestoMes = MM_SolicitudPedidoDetalleLineaPresupuesto.IdLineaPresupuesto  
                                JOIN  
                                    Petrovendor.dbo.MM_SolicitudPedidoDetalle                 AS MM_SolicitudPedidoDetalle (NOLOCK)  
                                        ON MM_SolicitudPedidoDetalleLineaPresupuesto.IdSolicitudPedidoDetalle = MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle  
                                JOIN  
                                    Petrovendor.dbo.MM_SolicitudPedido                        AS MM_SolicitudPedido (NOLOCK)  
                                        ON MM_SolicitudPedidoDetalle.IdSolicitudPedido = MM_SolicitudPedido.IdSolicitudPedido  
                                           AND ISNULL(MM_SolicitudPedido.IdEstatusEliminado, 0) = 0  
                                JOIN  
                                    Petrovendor.dbo.MM_Pedido                                 AS MM_Pedido (NOLOCK)  
                                        ON MM_SolicitudPedido.IdSolicitudPedido = MM_Pedido.IdSolicitudPedido  
                                           AND MM_Pedido.IdContrato = @IdContrato  
                                JOIN  
                                    #AX_Layout  
                                        ON UPPER(LTRIM(RTRIM(#AX_Layout.Estatus))) <> UPPER('cancelado')  
                                           AND LTRIM(RTRIM(#AX_Layout.Empresa)) = @Bloque  
                                           AND CAST(MM_Pedido.IdPedido AS NVARCHAR(100)) = CAST(#AX_Layout.NoPedidoADINCO AS NVARCHAR(100))  
                                JOIN  
                                    Petrovendor.dbo.MM_PedidoDetalle (NOLOCK)  
                                        ON MM_Pedido.IdPedido = MM_PedidoDetalle.IdPedido  
                                JOIN  
                                    Petrovendor.dbo.MM_Pedidos (NOLOCK)  
                                        ON MM_Pedido.IdPedido = MM_Pedidos.IdIdentificador  
                                           AND MM_Pedido.IdProveedorCompras = MM_Pedidos.IdProveedorCliente  
                                JOIN  
                                    Petrovendor.dbo.AX_ComparativaEmpresa (NOLOCK)  
                                        ON MM_Pedidos.IdProveedorCliente = AX_ComparativaEmpresa.IdProveedor  
                                JOIN  
                                    Petrovendor.dbo.MM_PeticionOferta (NOLOCK)  
                                        ON MM_Pedido.IdPeticionOferta = MM_PeticionOferta.IdPeticionOferta  
                                           AND MM_SolicitudPedido.IdSolicitudPedido = MM_PeticionOferta.IdSolicitudPedido  
                                JOIN  
                                    Petrovendor.dbo.MM_PeticionOfertaDetalle (NOLOCK)  
                                        ON MM_PeticionOferta.IdPeticionOferta = MM_PeticionOfertaDetalle.IdPeticionOferta  
                                           AND MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle = MM_PeticionOfertaDetalle.IdSolicitudPedidoDetalle  
                                           AND MM_PedidoDetalle.IdPeticionOfertaDetalle = MM_PeticionOfertaDetalle.IdPeticionOfertaDetalle  
                                JOIN  
                                    Petrovendor.dbo.S_Proveedor (NOLOCK)  
                                        ON MM_PeticionOferta.IdSubcontratista = S_Proveedor.IdProveedor  
                                JOIN  
                                    Petrovendor.dbo.TA_Operacion (NOLOCK)  
                                        ON MM_Pedido.IdSolicitudPedido = TA_Operacion.IdDocumento  
                                           AND TA_Operacion.IdTipoOperacion = @AprobacionDePedido  
                                           AND MM_Pedido.Version = TA_Operacion.NoVersion  
                                JOIN  
                                    Petrovendor.dbo.TA_TipoOperacion (NOLOCK)  
                                        ON TA_Operacion.IdTipoOperacion = TA_TipoOperacion.IdTipoOperacion  
                                JOIN  
                                    Petrovendor.dbo.TA_Estatus (NOLOCK)  
                                        ON TA_Estatus.IdEstatus = @Aprobado  
                                           AND TA_Operacion.IdEstatusOperacion = TA_Estatus.IdEstatus  
                                JOIN  
                                    Petrovendor.dbo.PV_TipoMoneda (NOLOCK)  
                                        ON MM_Pedido.IdMoneda = PV_TipoMoneda.IdMoneda  
                                JOIN  
                                    Petrovendor.dbo.MM_TipoPedido (NOLOCK)  
                                        ON MM_Pedidos.IdTipoPedido = MM_TipoPedido.IdTipoPedido  
                                LEFT JOIN  
                                    Petrovendor.dbo.PV_RelacionProveedorSubcotratista (NOLOCK)  
                                        ON MM_SolicitudPedido.IdProveedor = PV_RelacionProveedorSubcotratista.IdProveedor  
                                           AND MM_Pedido.IdSubcontratista = PV_RelacionProveedorSubcotratista.IdSubcontratista  
                                LEFT JOIN  
                                    SC_SubContrato  
                                        ON MM_Pedido.IdPedido = SC_SubContrato.IdPedido  
                                           AND SC_SubContrato.IsActivo = 1  
                            WHERE  
                                TA_Operacion.IdTipoOperacion = @AprobacionDePedido  
                                AND TA_Estatus.IdEstatus = @Aprobado  
                                AND MM_Pedido.IdContrato = @IdContrato  
                                AND ISNULL(MM_SolicitudPedido.IdEstatusEliminado, 0) = 0  
                                AND ISNULL(MM_Pedido.IdEstatusEliminado, 0) = 0  
                                AND MM_PeticionOfertaDetalle.IdPeticionOfertaDetalle IS NOT NULL -- para que no se repita que solo se ligue a los que cotizaron         
                                AND CONVERT(  
                                               DATE,  
                                               dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra)  
                                           )  
                                BETWEEN CONVERT(DATE, @Fechainicio) AND CONVERT(DATE, @FechaFin)  
                                AND UPPER(LTRIM(RTRIM(#AX_Layout.Estatus))) <> UPPER('cancelado')  
                                AND SC_SubContrato.IdSubContrato IS NULL  
                            GROUP BY  
                                PV_RelacionProveedorSubcotratista.IdRelacion,  
                                S_Proveedor.RazonSocial,  
                                S_Proveedor.RegimenCapital,  
                                MM_TipoPedido.TipoPedido,  
                                PV_TipoMoneda.IdMoneda,  
                                MM_Pedido.IdPedido,  
                                MM_Pedidos.IdPedido,  
                                #AX_Layout.FechaRegistroCompra,  
                                #AX_Layout.NoOrden,  
                                #AX_Layout.FechaEntrega  
  
  
                --Aqui se agregan los pedidos que estan en orden abierta         
                INSERT INTO #Tabla  
                    (  
                        NumeroContrato,  
                        RelacionOperadoraProveedor,  
                        Proveedor,  
                        MecanismoContratacion,  
                        [Nombre Contrato C-P],  
                        [No. Contrato],  
   [Fecha Inicio Contrato],  
                        [Fecha Termino Contrato],  
                        [Vigencia del contrato],  
                        [Objeto del contrato],  
                        MontoUSD,  
                        MontoMXN,  
                        TipoCambio,  
                        FechaTipoCambio,  
                        Comentarios,  
                        NombreContratista,  
                        FechaEfectiva  
                    )  
                            SELECT  
                                @NumeroContrato,  
                                CASE  
                                    WHEN PV_RelacionProveedorSubcotratista.IdRelacion IS NOT NULL  
                                        THEN 'SI'  
                                    ELSE  
                                        'NO'  
                                END                                                                                  AS RelacionOperadoraProveedor,  
                                LEFT(UPPER(S_Proveedor.RazonSocial) + ' ' + ISNULL(UPPER(S_Proveedor.RegimenCapital), ''), 4000) AS Proveedor,
                                CASE  
                                    WHEN MM_TipoPedido.TipoPedido = 'Mercadeo'  
                                        THEN 'TRES COTIZACIONES'  
                                    ELSE  
                                        LEFT(UPPER(MM_TipoPedido.TipoPedido), 4000)
                                END                                                                                  AS MecanismoContratacion,  
                                LEFT(dbo.fn_SC_AdquisicionMaterialesCarso(MM_Pedido.IdPedido), 1100)                 AS 'Nombre Contrato C-P',            ---> OBTENER EL NOMBRE DE LOS MATERIALES DE LA COMPARATIVA  QUE ESTAN EN EL PEDIDO ACTUAL         
                                LEFT(#AX_Layout.NoOrden, 4000)                                                       AS 'No. Contrato',                   --> NUMERO DE PEDIDO DE AX          
                                REPLACE(#AX_Layout.FechaRegistroCompra, '/', '-')                                    AS 'Fecha Inicio Contrato',          --> FECHA DE CREACIÓN DEL PEDIDO EN AX         
                                REPLACE(#AX_Layout.FechaEntrega, '/', '-')                                           AS 'Fecha Termino Contrato',         --> FECHA DE LA PRIMERA ACEPTACIÓN DE PEDIDO DE AX          
                                REPLACE(#AX_Layout.FechaEntrega, '/', '-')                                           AS 'Vigencia del contrato',          --> DIFERENCIA PARA OBTENER LA VIGENCIA DEL CONTRATO         
                                LEFT(dbo.fn_SC_AdquisicionMaterialesCarso(MM_Pedido.IdPedido), 1100)                 AS 'Objeto del contrato',            ---> OBTENER EL NOMBRE DE LOS MATERIALES DE LA COMPARATIVA  QUE ESTAN EN EL PEDIDO ACTUAL         
                                CASE  
                                    WHEN PV_TipoMoneda.IdMoneda = @Peso  
                                         AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) IS NOT NULL  
                                        THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(  
                                                                                          SUM(MM_PedidoDetalle.Subtotal),  
                                                                                          CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) AS DATE)  
                                                                                      )  
                                    WHEN PV_TipoMoneda.IdMoneda = @Dolar  
                                         AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) IS NOT NULL  
                                        THEN SUM(MM_PedidoDetalle.Subtotal)  
                                    ELSE  
                                        0  
       END                                                                                  AS MontoUSD,  
                                CASE  
                                    WHEN PV_TipoMoneda.IdMoneda = @Dolar  
                                         AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) IS NOT NULL  
                                        THEN Petrovendor.dbo.FN_DolaresPesosTipoCambio(  
                                                                                          SUM(MM_PedidoDetalle.Subtotal),  
                                                                                          CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) AS DATE)  
                                                                                      )  
                                    WHEN PV_TipoMoneda.IdMoneda = @Peso  
                                         AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) IS NOT NULL  
                                        THEN (DBO.fn_ObtenSubtotalPedido(  
                                                                            PV_TipoMoneda.IdMoneda, MM_Pedido.IdPedido,  
                                                                            @IdContrato  
                                                                        )  
                                             )  
                                    ELSE  
                                        0  
                                END                                                                                  AS MontoMXN,  
                                CASE  
                                    WHEN dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) IS NOT NULL  
                                        THEN Petrovendor.dbo.FN_ValorTipoCambioIterativo(CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra) AS DATE))  
                                    ELSE  
                                        ''  
                                END                                                                                  AS TipoCambio,  
                                REPLACE(#AX_Layout.FechaRegistroCompra, '/', '-')                                    AS FechaTipoCambio,                  --DWONG 20190712         
                                LEFT(dbo.fn_SC_AdquisicionMaterialesCarso(MM_Pedido.IdPedido), 1100)                 AS 'Comentarios',  
                                NombreContratista                                                                   =  LEFT(UPPER(@ContratistaRazonSocialDelContrato), 4000),  
                                FechaEfectiva                                                                        = CONVERT(VARCHAR, @FechaFirma, 103) --DWONG 20190712         
                            FROM  
                                #CO_LineasPresupuestoMes                                      AS TTLineasPresupuesto  
                                JOIN  
                                    Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS MM_SolicitudPedidoDetalleLineaPresupuesto (NOLOCK)  
                                        ON TTLineasPresupuesto.IdLineaPresupuestoMes = MM_SolicitudPedidoDetalleLineaPresupuesto.IdLineaPresupuesto  
                                JOIN  
                                    Petrovendor.dbo.MM_SolicitudPedidoDetalle                 AS MM_SolicitudPedidoDetalle (NOLOCK)  
                                        ON MM_SolicitudPedidoDetalleLineaPresupuesto.IdSolicitudPedidoDetalle = MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle  
                                JOIN  
                                    Petrovendor.dbo.MM_SolicitudPedido                        AS MM_SolicitudPedido (NOLOCK)  
                                        ON MM_SolicitudPedidoDetalle.IdSolicitudPedido = MM_SolicitudPedido.IdSolicitudPedido  
                                          AND ISNULL(MM_SolicitudPedido.IdEstatusEliminado, 0) = 0  
                                JOIN  
                                    Petrovendor.dbo.MM_Pedido                                 AS MM_Pedido (NOLOCK)  
                                        ON MM_SolicitudPedido.IdSolicitudPedido = MM_Pedido.IdSolicitudPedido  
                                           AND MM_Pedido.IdContrato = @IdContrato  
                                JOIN  
                                    #AX_Layout  
                                        ON UPPER(LTRIM(RTRIM(#AX_Layout.Estatus))) = UPPER('Orden abierta')  
                                           AND LTRIM(RTRIM(#AX_Layout.Empresa)) = @Bloque  
                                           AND CAST(MM_Pedido.IdPedido AS NVARCHAR(100)) = CAST(#AX_Layout.NoPedidoADINCO AS NVARCHAR(100))  
                                           AND ISNULL(MM_Pedido.IdEstatusEliminado, 0) = 0  
                                JOIN  
                                    Petrovendor.dbo.MM_PedidoDetalle (NOLOCK)  
                                        ON MM_Pedido.IdPedido = MM_PedidoDetalle.IdPedido  
                                JOIN  
                                    Petrovendor.dbo.MM_Pedidos (NOLOCK)  
                                        ON MM_Pedido.IdPedido = MM_Pedidos.IdIdentificador  
                                           AND MM_Pedido.IdProveedorCompras = MM_Pedidos.IdProveedorCliente  
                                JOIN  
                                    Petrovendor.dbo.AX_ComparativaEmpresa (NOLOCK)  
                                        ON MM_Pedidos.IdProveedorCliente = AX_ComparativaEmpresa.IdProveedor  
                                JOIN  
                                    Petrovendor.dbo.MM_PeticionOferta (NOLOCK)  
                                        ON MM_Pedido.IdPeticionOferta = MM_PeticionOferta.IdPeticionOferta  
                                           AND MM_SolicitudPedido.IdSolicitudPedido = MM_PeticionOferta.IdSolicitudPedido  
                                JOIN  
                                    Petrovendor.dbo.MM_PeticionOfertaDetalle (NOLOCK)  
                                        ON MM_PeticionOferta.IdPeticionOferta = MM_PeticionOfertaDetalle.IdPeticionOferta  
                                           AND MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle = MM_PeticionOfertaDetalle.IdSolicitudPedidoDetalle  
                                           AND MM_PedidoDetalle.IdPeticionOfertaDetalle = MM_PeticionOfertaDetalle.IdPeticionOfertaDetalle  
                                JOIN  
                                    Petrovendor.dbo.S_Proveedor (NOLOCK)  
                                        ON MM_PeticionOferta.IdSubcontratista = S_Proveedor.IdProveedor  
                                JOIN  
                                    Petrovendor.dbo.TA_Operacion (NOLOCK)  
                                        ON TA_Operacion.IdTipoOperacion = @AprobacionDePedido  
                                           AND MM_Pedido.IdSolicitudPedido = TA_Operacion.IdDocumento  
                                           AND MM_Pedido.Version = TA_Operacion.NoVersion  
                                JOIN  
                                    Petrovendor.dbo.TA_TipoOperacion (NOLOCK)  
                                        ON TA_Operacion.IdTipoOperacion = TA_TipoOperacion.IdTipoOperacion  
                                JOIN  
                                    Petrovendor.dbo.TA_Estatus (NOLOCK)  
                                        ON TA_Estatus.IdEstatus = @EnAprobacion  
                                           AND TA_Operacion.IdEstatusOperacion = TA_Estatus.IdEstatus  
                                JOIN  
                                    Petrovendor.dbo.PV_TipoMoneda (NOLOCK)  
                                        ON MM_Pedido.IdMoneda = PV_TipoMoneda.IdMoneda  
                                JOIN  
                       Petrovendor.dbo.MM_TipoPedido (NOLOCK)  
                                        ON MM_Pedidos.IdTipoPedido = MM_TipoPedido.IdTipoPedido  
                                LEFT JOIN  
                                    Petrovendor.dbo.PV_RelacionProveedorSubcotratista (NOLOCK)  
                                        ON MM_SolicitudPedido.IdProveedor = PV_RelacionProveedorSubcotratista.IdProveedor  
                                           AND MM_Pedido.IdSubcontratista = PV_RelacionProveedorSubcotratista.IdSubcontratista  
                                LEFT JOIN  
                                    SC_SubContrato  
                                        ON MM_Pedido.IdPedido = SC_SubContrato.IdPedido  
                                           AND SC_SubContrato.IsActivo = 1  
                            WHERE  
                                TA_Operacion.IdTipoOperacion = @AprobacionDePedido  
                                AND TA_Estatus.IdEstatus = @EnAprobacion  
                                AND MM_Pedido.IdContrato = @IdContrato  
                                AND ISNULL(MM_SolicitudPedido.IdEstatusEliminado, 0) = 0  
                                AND ISNULL(MM_Pedido.IdEstatusEliminado, 0) = 0  
                                AND MM_PeticionOfertaDetalle.IdPeticionOfertaDetalle IS NOT NULL -- para que no se repita que solo se ligue a los que cotizaron         
                                AND CONVERT(  
                                               DATE,  
                                               dbo.fn_SC_AdquisicionFechaNormalizadaCarso(#AX_Layout.FechaRegistroCompra)  
                                           )  
                                BETWEEN CONVERT(DATE, @Fechainicio) AND CONVERT(DATE, @FechaFin)  
                                AND UPPER(LTRIM(RTRIM(#AX_Layout.Estatus))) = UPPER('Orden abierta')  
                                AND SC_SubContrato.IdSubContrato IS NULL  
                            GROUP BY  
                                PV_RelacionProveedorSubcotratista.IdRelacion,  
                                S_Proveedor.RazonSocial,  
                                S_Proveedor.RegimenCapital,  
                                MM_TipoPedido.TipoPedido,  
                                MM_PeticionOferta.FechaFinalizado,  
                                PV_TipoMoneda.IdMoneda,  
                                MM_Pedido.IdPedido,  
                                #AX_Layout.FechaRegistroCompra,  
                                #AX_Layout.NoOrden,  
                                #AX_Layout.FechaEntrega  
  
  
                -- AQUI SE AGREGAN LOS PEDIDOS QUE NO ESTAN EN EL LAYOUT DE AX_LAYOUT         
                INSERT INTO #Tabla  
                    (  
                        NumeroContrato,  
                        RelacionOperadoraProveedor,  
                        Proveedor,  
                        MecanismoContratacion,  
                        [Nombre Contrato C-P],  
                        [No. Contrato],  
                        [Fecha Inicio Contrato],  
                        [Fecha Termino Contrato],  
                        [Vigencia del contrato],  
                        [Objeto del contrato],  
                        MontoUSD,  
                        MontoMXN,  
                        TipoCambio,  
                        FechaTipoCambio,  
                        Comentarios,  
                        NombreContratista,  
                        FechaEfectiva  
                    )  
                            SELECT  
                                @NumeroContrato,  
                                CASE  
                                    WHEN PV_RelacionProveedorSubcotratista.IdRelacion IS NOT NULL  
                                        THEN 'SI'  
                                    ELSE  
                                        'NO'  
                                END  AS RelacionOperadoraProveedor,  
                                LEFT(UPPER(S_Proveedor.RazonSocial) + ' ' + ISNULL(UPPER(S_Proveedor.RegimenCapital), ''), 4000) AS Proveedor,
                                CASE  
                                    WHEN MM_TipoPedido.TipoPedido = 'Mercadeo'  
                                        THEN 'TRES COTIZACIONES'  
                                    ELSE  
                                        LEFT(UPPER(MM_TipoPedido.TipoPedido), 4000)
                                END                                                                                   AS MecanismoContratacion,  
                                LEFT(MM_SolicitudPedido.MotivoUrgencia, 4000)                                         AS 'Nombre Contrato C-P',  
                                LEFT(UPPER(MM_Pedidos.IdPedido), 4000)                                                AS 'No. Contrato',                   --> NUMERO DE PEDIDO DE AX          
                                CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105)                                 AS 'Fecha Inicio Contrato',          --> FECHA DE CREACIÓN DEL PEDIDO EN AX         
                                CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105)                                 AS 'Fecha Termino Contrato',         --> FECHA DE LA PRIMERA ACEPTACIÓN DE PEDIDO DE AX          
                                CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105)                                 AS 'Vigencia del contrato',          --> DIFERENCIA PARA OBTENER LA VIGENCIA DEL CONTRATO         
                                LEFT(MM_SolicitudPedido.MotivoUrgencia, 4000)                                         AS 'Objeto del contrato',  
                                CASE  
                                    WHEN PV_TipoMoneda.IdMoneda = @Peso  
                                        THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(  
                                                                                          SUM(MM_PedidoDetalle.Subtotal),  
                                                                                          CAST(TA_Operacion.FechaRegistro AS DATE)  
                                                                                      )  
                                    WHEN PV_TipoMoneda.IdMoneda = @Dolar  
                                        THEN SUM(MM_PedidoDetalle.Subtotal)  
                                    ELSE  
                                        0  
                                END                                                                                   AS MontoUSD,  
                                CASE  
                                    WHEN PV_TipoMoneda.IdMoneda = @Dolar  
                                        THEN Petrovendor.dbo.FN_DolaresPesosTipoCambio(  
                                                                                          SUM(MM_PedidoDetalle.Subtotal),  
                                                                                          CAST(TA_Operacion.FechaRegistro AS DATE)  
                                                                                      )  
                                    WHEN PV_TipoMoneda.IdMoneda = @Peso  
                                        THEN (DBO.fn_ObtenSubtotalPedido(  
                                                                            PV_TipoMoneda.IdMoneda, MM_Pedido.IdPedido,  
                                                                            @IdContrato  
                                                                        )  
                                             )  
                                    ELSE  
                                        0  
                                END                                                                                   AS MontoMXN,  
                                Petrovendor.dbo.FN_ValorTipoCambioIterativo(CAST(TA_Operacion.FechaRegistro AS DATE)) AS TipoCambio,  
                                CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105)                                 AS FechaTipoCambio,  
                                left(MM_SolicitudPedido.MotivoUrgencia, 4000)                                         AS 'Comentarios',  
                                NombreContratista                                                                     = LEFT(UPPER(@ContratistaRazonSocialDelContrato), 4000),  
                                FechaEfectiva                                                                         = CONVERT(VARCHAR, @FechaFirma, 103) --DWONG 20190712         
                            FROM  
                                #CO_LineasPresupuestoMes                                      AS TTLineasPresupuesto  
                                JOIN  
                                    Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS MM_SolicitudPedidoDetalleLineaPresupuesto (NOLOCK)  
                                        ON TTLineasPresupuesto.IdLineaPresupuestoMes = MM_SolicitudPedidoDetalleLineaPresupuesto.IdLineaPresupuesto  
                                JOIN  
                                    Petrovendor.dbo.MM_SolicitudPedidoDetalle                 AS MM_SolicitudPedidoDetalle (NOLOCK)  
                                        ON MM_SolicitudPedidoDetalleLineaPresupuesto.IdSolicitudPedidoDetalle = MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle  
                                JOIN  
                                    Petrovendor.dbo.MM_SolicitudPedido                        AS MM_SolicitudPedido (NOLOCK)  
                                        ON MM_SolicitudPedidoDetalle.IdSolicitudPedido = MM_SolicitudPedido.IdSolicitudPedido  
                                           AND ISNULL(MM_SolicitudPedido.IdEstatusEliminado, 0) = 0  
                                JOIN  
                                    Petrovendor.dbo.MM_Pedido                                 AS MM_Pedido (NOLOCK)  
                                        ON MM_SolicitudPedido.IdSolicitudPedido = MM_Pedido.IdSolicitudPedido  
                                           AND MM_Pedido.IdContrato = @IdContrato  
                                JOIN  
                                    Petrovendor.dbo.MM_PedidoDetalle (NOLOCK)  
                                        ON MM_Pedido.IdPedido = MM_PedidoDetalle.IdPedido  
                                JOIN  
                                    Petrovendor.dbo.MM_Pedidos (NOLOCK)  
                                        ON MM_Pedido.IdPedido = MM_Pedidos.IdIdentificador  
                                           AND MM_Pedido.IdProveedorCompras = MM_Pedidos.IdProveedorCliente  
                                JOIN  
                                    Petrovendor.dbo.AX_ComparativaEmpresa (NOLOCK)  
                                        ON MM_Pedidos.IdProveedorCliente = AX_ComparativaEmpresa.IdProveedor  
                                JOIN  
                                    Petrovendor.dbo.MM_PeticionOferta (NOLOCK)  
                                        ON MM_Pedido.IdPeticionOferta = MM_PeticionOferta.IdPeticionOferta  
                                           AND MM_SolicitudPedido.IdSolicitudPedido = MM_PeticionOferta.IdSolicitudPedido  
                                JOIN  
                                    Petrovendor.dbo.MM_PeticionOfertaDetalle (NOLOCK)  
                                        ON MM_PeticionOferta.IdPeticionOferta = MM_PeticionOfertaDetalle.IdPeticionOferta  
                                           AND MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle = MM_PeticionOfertaDetalle.IdSolicitudPedidoDetalle  
                                           AND MM_PedidoDetalle.IdPeticionOfertaDetalle = MM_PeticionOfertaDetalle.IdPeticionOfertaDetalle  
                                JOIN  
                                    Petrovendor.dbo.S_Proveedor (NOLOCK)  
                                        ON MM_PeticionOferta.IdSubcontratista = S_Proveedor.IdProveedor  
                                JOIN  
                                    Petrovendor.dbo.TA_Operacion (NOLOCK)  
                                        ON TA_Operacion.IdTipoOperacion = @AprobacionDePedido  
                                           AND MM_Pedido.IdSolicitudPedido = TA_Operacion.IdDocumento  
                                           AND MM_Pedido.Version = TA_Operacion.NoVersion  
                                JOIN  
                                    Petrovendor.dbo.TA_TipoOperacion (NOLOCK)  
                                        ON TA_Operacion.IdTipoOperacion = TA_TipoOperacion.IdTipoOperacion  
                                JOIN  
                                    Petrovendor.dbo.TA_Estatus (NOLOCK)  
                                        ON TA_Operacion.IdEstatusOperacion = TA_Estatus.IdEstatus  
                                JOIN  
                                    Petrovendor.dbo.PV_TipoMoneda (NOLOCK)  
                                        ON MM_Pedido.IdMoneda = PV_TipoMoneda.IdMoneda  
                                JOIN  
                                    Petrovendor.dbo.MM_TipoPedido (NOLOCK)  
                                        ON MM_Pedidos.IdTipoPedido = MM_TipoPedido.IdTipoPedido  
                                LEFT JOIN  
                                    #AX_Layout  
                                        ON CAST(MM_Pedido.IdPedido AS NVARCHAR(100)) = CAST(#AX_Layout.NoPedidoADINCO AS NVARCHAR(100))  
                                           AND LTRIM(RTRIM(#AX_Layout.Empresa)) = @Bloque  
                                           AND ISNULL(MM_Pedido.IdEstatusEliminado, 0) = 0  
                                LEFT JOIN  
                                    Petrovendor.dbo.PV_RelacionProveedorSubcotratista (NOLOCK)  
                                        ON MM_SolicitudPedido.IdProveedor = PV_RelacionProveedorSubcotratista.IdProveedor  
                                           AND MM_Pedido.IdSubcontratista = PV_RelacionProveedorSubcotratista.IdSubcontratista  
                                LEFT JOIN  
                                    Adinco.dbo.SC_SubContrato  
                                        ON MM_Pedido.IdPedido = SC_SubContrato.IdPedido  
                                           AND SC_SubContrato.IsActivo = 1  
                            WHERE  
                                TA_Operacion.IdTipoOperacion = @AprobacionDePedido  
                                AND TA_Estatus.IdEstatus = @Aprobado  
                                AND MM_Pedido.IdContrato = @IdContrato  
                                AND ISNULL(MM_SolicitudPedido.IdEstatusEliminado, 0) = 0  
                                AND ISNULL(MM_Pedido.IdEstatusEliminado, 0) = 0  
                                AND MM_PeticionOfertaDetalle.IdPeticionOfertaDetalle IS NOT NULL -- para que no se repita que solo se ligue a los que cotizaron         
                                AND TA_Operacion.FechaRegistro  
                                BETWEEN CONVERT(DATE, @Fechainicio) AND CONVERT(DATE, @FechaFin)  
                                AND #AX_Layout.IdLayoutAX IS NULL -- esto para descartar las que estan registrados en AX_LAYOUT      
                                AND SC_SubContrato.IdSubContrato IS NULL  
                            GROUP BY  
                                PV_RelacionProveedorSubcotratista.IdRelacion,  
                                S_Proveedor.RazonSocial,  
                                S_Proveedor.RegimenCapital,  
                                MM_TipoPedido.TipoPedido,  
                                MM_SolicitudPedido.MotivoUrgencia,  
                                PV_TipoMoneda.IdMoneda,  
                                MM_Pedido.IdPedido,  
                                MM_Pedidos.IdPedido,  
                                TA_Operacion.FechaRegistro  
  
  
  
  
                SELECT  
                    NumeroContrato,                      RelacionOperadoraProveedor,  
                    Proveedor,  
                    MecanismoContratacion,  
                    [Nombre Contrato C-P],  
                    [No. Contrato],  
                    [Fecha Inicio Contrato],  
                    [Fecha Termino Contrato],  
                    [Vigencia del contrato],  
                    [Objeto del contrato],  
                    MontoUSD,  
                    MontoMXN,  
                    TipoCambio,  
                    FechaTipoCambio,  
                    Comentarios,  
                    NombreContratista,  
                    FechaEfectiva  
                FROM  
                    #Tabla -- SELET CARSO  
                ORDER BY  
                    [No. Contrato] DESC  
            END;  
  
        ---- VALIDAR SI EL PROVEEDOR ES DEA    
        ELSE IF exists  
            (  
                select  
                    1  
                from  
                    CO_contrato  
                where  
                    IdContratista in (  
                                         10013, 10060  
                                     )  
                    AND IdContrato = @IdContrato  
            ) --DEA    
                 BEGIN  
  
  
  
                     ---> OBTENER SUBTOTALES DE WDEA_PurchasingDocumentsImportados POR PEDIDOS  
                     INSERT INTO #TablaWDEA_PurchasingDocumentsImportados  
                         (  
                             IdPedidoADINCO,  
                             PURCHASING_DOCUMENT,  
                             NET_ORDER_VALUE,  
                             CURRENCY,  
                             SUM_NET_PRICE,  
                             IDMONEDA,  
                             OUTLINE_AGREEMENT,  
                             NumeroContrato,  
                             MECANISMO_CONTRATACION  
                         )  
                                 SELECT  
                                         MM_Pedido.IdPedido,  
                                         LEFT(WDEA_PurchasingDocumentsImportados.PURCHASING_DOCUMENT, 4000),
                                         WDEA_PurchasingDocumentsImportados.NET_ORDER_VALUE,  
                                         LEFT(WDEA_PurchasingDocumentsImportados.CURRENCY, 4000),  
                                         SUM(WDEA_PurchasingDocumentsImportados.NET_PRICE) AS SUM_NET_PRICE,  
                                         WDEA_PurchasingDocumentsImportados.IDMONEDA,  
                                         LEFT(WDEA_PurchasingDocumentsImportados.OUTLINE_AGREEMENT, 4000),
                                         LEFT(@NumeroContrato, 4000),
                                         LEFT(WDEA_PurchasingDocumentsImportados.MECANISMO_CONTRATACION, 4000)
                                 FROM  
                                         #CO_LineasPresupuestoMes                                  AS TTLineasPresupuesto  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS MM_SolicitudPedidoDetalleLineaPresupuesto (NOLOCK)  
                                             ON TTLineasPresupuesto.IdLineaPresupuestoMes = MM_SolicitudPedidoDetalleLineaPresupuesto.IdLineaPresupuesto  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedidoDetalle                 AS MM_SolicitudPedidoDetalle (NOLOCK)  
                                             ON MM_SolicitudPedidoDetalleLineaPresupuesto.IdSolicitudPedidoDetalle = MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedido                        AS MM_SolicitudPedido (NOLOCK)  
                                             ON MM_SolicitudPedidoDetalle.IdSolicitudPedido = MM_SolicitudPedido.IdSolicitudPedido  
                                     JOIN  
                                         Petrovendor.dbo.MM_Pedido                       AS MM_Pedido (NOLOCK)  
                                             ON MM_SolicitudPedido.IdSolicitudPedido = MM_Pedido.IdSolicitudPedido  
                                     JOIN  
                                         Petrovendor.dbo.WDEA_PurchasingDocumentsImportados (NOLOCK)  
                                             ON MM_Pedido.IdContrato = @IdContrato  
                                                AND MM_Pedido.IdPedido = WDEA_PurchasingDocumentsImportados.IdPedidoADINCO  
                                                AND ISNULL(MM_Pedido.IdEstatusEliminado, 0) = 0  
                                 WHERE  
                                         CONVERT(VARCHAR, MM_Pedido.CreadoEl, 112)  
                                 BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112)  
                                 GROUP BY  
                                         MM_Pedido.IdPedido,  
                                         WDEA_PurchasingDocumentsImportados.PURCHASING_DOCUMENT,  
                                         WDEA_PurchasingDocumentsImportados.NET_ORDER_VALUE,  
                                         WDEA_PurchasingDocumentsImportados.CURRENCY,  
                                         WDEA_PurchasingDocumentsImportados.NET_ORDER_VALUE,  
                                         WDEA_PurchasingDocumentsImportados.IDMONEDA,  
                                         WDEA_PurchasingDocumentsImportados.OUTLINE_AGREEMENT,  
                                         WDEA_PurchasingDocumentsImportados.MECANISMO_CONTRATACION  
  
  
                     --> OBTENER SUBTOTALES DE PEDIDOS DETALLE AGRUPADO POR PEDIDO   
  
                     INSERT INTO #MM_PedidoDetalle  
                         (  
                             IdPedido,  
                             SUM_Subtotal  
                         )  
                                 SELECT  
                                         MM_Pedido.IdPedido,  
                                         SUM(MM_PedidoDetalle.Subtotal)  
                                 FROM  
                                         #CO_LineasPresupuestoMes                                  AS TTLineasPresupuesto  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS MM_SolicitudPedidoDetalleLineaPresupuesto (NOLOCK)  
                                             ON TTLineasPresupuesto.IdLineaPresupuestoMes = MM_SolicitudPedidoDetalleLineaPresupuesto.IdLineaPresupuesto  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedidoDetalle                 AS MM_SolicitudPedidoDetalle (NOLOCK)  
                                             ON MM_SolicitudPedidoDetalleLineaPresupuesto.IdSolicitudPedidoDetalle = MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedido                        AS MM_SolicitudPedido (NOLOCK)  
                                             ON MM_SolicitudPedidoDetalle.IdSolicitudPedido = MM_SolicitudPedido.IdSolicitudPedido  
                                     JOIN  
                                         Petrovendor.dbo.MM_Pedido (NOLOCK)  
                                             ON MM_SolicitudPedido.IdSolicitudPedido = MM_Pedido.IdSolicitudPedido  
                                     JOIN  
                                         Petrovendor.dbo.MM_PedidoDetalle (NOLOCK)  
                                             ON MM_Pedido.IdContrato = @IdContrato  
                                                AND MM_Pedido.IdPedido = MM_PedidoDetalle.IdPedido  
                                 WHERE  
                                         CONVERT(VARCHAR, MM_Pedido.CreadoEl, 112)  
                                 BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112)  
                                 GROUP BY  
                                         MM_Pedido.IdPedido  
  
  
                     INSERT INTO #TablaDEA  
                         (  
                             NumeroContrato,  
                             RelacionOperadoraProveedor,  
                             Proveedor,  
                             MecanismoContratacion,  
                             [Nombre Contrato C-P],  
                             [No. Contrato],  
                             [Fecha Inicio Contrato],  
                             [Fecha Termino Contrato],  
                             [Vigencia del contrato],  
                             [Objeto del contrato],  
                             MontoUSD,  
                             MontoMXN,  
                             TipoCambio,  
                             FechaTipoCambio,  
                             Comentarios,  
                             NombreContratista, --   
                             FechaEfectiva      --  
                         )  
                                 SELECT  
                                         ISNULL(#TablaWDEA_PurchasingDocumentsImportados.NumeroContrato, @NumeroContrato) AS NumeroContrato,  
                                         CASE  
                                             WHEN DEA_ProveedorDescripcionSAP.IdProveedor IS NOT NULL  
                                                 THEN 'SI'  
                                             ELSE  
                                                 'NO'  
                                         END                                                                              AS RelacionOperadoraProveedor,  
                                         LEFT(S_Proveedor.RazonSocial, 4000)                                              AS Proveedor,  
                                         CASE  
                                             WHEN #TablaWDEA_PurchasingDocumentsImportados.MECANISMO_CONTRATACION = 'L'  
                                                 THEN 'Licitación' --> CTE SE PONE COMO DEFAULT YA QUE LOS PEDIDOS DE LICITACIÓN SE AGREGAN COMO MERCADEO  
                                             ELSE  
                                                 LEFT(MM_TipoPedido.TipoPedido, 200)  
                                         END                                                                              AS MecanismoContratacion,  
                                         LEFT(MM_SolicitudPedido.MotivoUrgencia, 4000)                                    AS NombreContratoCP,  
                                         LEFT(ISNULL(  
                                                   #TablaWDEA_PurchasingDocumentsImportados.PURCHASING_DOCUMENT,  
                                                   MM_Pedidos.IdPedido  
                                               ), 4000)                                                                   AS NoContratoCP,  
                                         MM_SolicitudPedido.FechaEntregaRequerida                                         AS FechaInicio,  
                                         ISNULL(  
                                                   MM_SolicitudPedido.FechaEntregaFinRequerida,  
                                                   MM_SolicitudPedido.FechaEntregaRequerida  
                                               )                                                                          AS FechaFin,  
                                         ISNULL(  
                                                   MM_SolicitudPedido.FechaEntregaFinRequerida,  
                                                   MM_SolicitudPedido.FechaEntregaRequerida  
                                               )                                                                          AS FechaVigencia,  
                                         LEFT(MM_SolicitudPedido.MotivoUrgencia, 4000)                                    AS ObjetoContrato,  
                                         CASE  
                                             WHEN #TablaWDEA_PurchasingDocumentsImportados.IdPedidoADINCO IS NOT NULL  
                                                  AND ISNULL(#TablaWDEA_PurchasingDocumentsImportados.NET_ORDER_VALUE, 0) > 0  
                                                  AND #TablaWDEA_PurchasingDocumentsImportados.CURRENCY = 'USD'  
                                                 THEN #TablaWDEA_PurchasingDocumentsImportados.NET_ORDER_VALUE  
                                             WHEN #TablaWDEA_PurchasingDocumentsImportados.IdPedidoADINCO IS NOT NULL  
                                                  AND ISNULL(#TablaWDEA_PurchasingDocumentsImportados.NET_ORDER_VALUE, 0) = 0  
                                                  AND #TablaWDEA_PurchasingDocumentsImportados.CURRENCY = 'USD'  
                                                 THEN CASE --PESO  
                                                          WHEN #TablaWDEA_PurchasingDocumentsImportados.IDMONEDA = @Peso  
                                                              THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(  
                                                                                                                #TablaWDEA_PurchasingDocumentsImportados.SUM_NET_PRICE,  
                                                                                                                MM_SolicitudPedido.FechaEntregaRequerida  
                                                                                                            )  
                                                          ELSE  
                                                              #TablaWDEA_PurchasingDocumentsImportados.SUM_NET_PRICE  
                                                      END  
                                             ELSE  
                                                 CASE  
                                                     WHEN MM_Pedido.IdMoneda = @Peso  
                                                         THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(  
                                                                                                           #MM_PedidoDetalle.SUM_Subtotal,  
                                                                                                           ISNULL(  
                                                                                                                     MM_Pedido.FechaRecepcionServicio,  
                                                                                                                     MM_Pedido.CreadoEl  
                                                                                                                 )  
                                                                                                       )  
                                                     ELSE  
                                                         #MM_PedidoDetalle.SUM_Subtotal  
                                                 END  
                                         END                                                                              AS MontoUSD,  
                                         CASE  
                                             WHEN #TablaWDEA_PurchasingDocumentsImportados.IdPedidoADINCO IS NOT NULL  
                                                  AND ISNULL(#TablaWDEA_PurchasingDocumentsImportados.NET_ORDER_VALUE, 0) > 0  
                                                  AND #TablaWDEA_PurchasingDocumentsImportados.CURRENCY = 'MXN'  
                                                 THEN #TablaWDEA_PurchasingDocumentsImportados.NET_ORDER_VALUE  
                                             WHEN #TablaWDEA_PurchasingDocumentsImportados.IdPedidoADINCO IS NOT NULL  
                                                  AND ISNULL(#TablaWDEA_PurchasingDocumentsImportados.NET_ORDER_VALUE, 0) = 0  
                                                  AND #TablaWDEA_PurchasingDocumentsImportados.CURRENCY = 'MXN'  
                                                 THEN CASE --DOLAR  
                                                          WHEN #TablaWDEA_PurchasingDocumentsImportados.IDMONEDA = @Dolar  
                                                              THEN Petrovendor.dbo.Fn_dolarespesostipocambio(  
                                                                                                                #TablaWDEA_PurchasingDocumentsImportados.SUM_NET_PRICE,  
                                                                                                                MM_SolicitudPedido.FechaEntregaRequerida  
                                                                                                            )  
                                                          ELSE  
                                                              #TablaWDEA_PurchasingDocumentsImportados.SUM_NET_PRICE  
                                                      END  
                                             ELSE  
                                                 CASE  
                                                     WHEN MM_Pedido.IdMoneda = @Dolar  
                                                         THEN Petrovendor.dbo.Fn_dolarespesostipocambio(  
                                                                                                           #MM_PedidoDetalle.SUM_Subtotal,  
                                                                                                           ISNULL(  
                                                                                                                     MM_Pedido.FechaRecepcionServicio,  
                                                                                                                     MM_Pedido.CreadoEl  
                                                                                                                 )  
                                                                                                       )  
                                                     ELSE  
                                                         #MM_PedidoDetalle.SUM_Subtotal  
                                                 END  
                                         END                                                                              AS MontoMXN,  
                                         Petrovendor.dbo.FN_ValorTipoCambio(MM_SolicitudPedido.FechaEntregaRequerida)     AS TipoCambio,  
                                         MM_SolicitudPedido.FechaEntregaRequerida                                         AS FechaTipoCambio,  
                                         LEFT(#TablaWDEA_PurchasingDocumentsImportados.OUTLINE_AGREEMENT, 4000), 
                                         LEFT(@ContratistaRazonSocialDelContrato, 4000), 
                                         CONVERT(VARCHAR, @FechaFirma, 103)                                               AS FechaEfectiva  
                                 FROM  
                                         #CO_LineasPresupuestoMes                                  AS TTLineasPresupuesto  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS MM_SolicitudPedidoDetalleLineaPresupuesto (NOLOCK)  
                                             ON TTLineasPresupuesto.IdLineaPresupuestoMes = MM_SolicitudPedidoDetalleLineaPresupuesto.IdLineaPresupuesto  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedidoDetalle                 AS MM_SolicitudPedidoDetalle (NOLOCK)  
                                             ON MM_SolicitudPedidoDetalleLineaPresupuesto.IdSolicitudPedidoDetalle = MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle  
                         JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedido                        AS MM_SolicitudPedido (NOLOCK)  
                                             ON MM_SolicitudPedidoDetalle.IdSolicitudPedido = MM_SolicitudPedido.IdSolicitudPedido  
                                                AND MM_SolicitudPedido.Activo = 1  
                                     JOIN  
                                         Petrovendor.dbo.MM_Pedido                                 AS MM_Pedido (NOLOCK)  
                                             ON MM_SolicitudPedido.IdSolicitudPedido = MM_Pedido.IdSolicitudPedido  
                                                AND ISNULL(MM_Pedido.IdEstatusEliminado, 0) = 0  
                                                AND MM_Pedido.IdContrato = @IdContrato  
                                      JOIN  
                                         #MM_PedidoDetalle  
                                             ON MM_Pedido.IdPedido = #MM_PedidoDetalle.IdPedido  
                                      JOIN  
                                         Petrovendor.dbo.S_Proveedor (NOLOCK)  
                                             ON MM_Pedido.IdSubcontratista = S_Proveedor.IdProveedor  
                                      JOIN  
                                         Petrovendor.dbo.MM_Pedidos (NOLOCK)  
                                             ON MM_Pedido.IdPedido = MM_Pedidos.IdIdentificador  
                                                AND MM_Pedido.IdProveedorCompras = MM_Pedidos.IdProveedorCliente  
                                      JOIN  
                                         Petrovendor.dbo.PV_TipoMoneda (NOLOCK)  
                                             ON MM_Pedido.IdMoneda = PV_TipoMoneda.IdMoneda  
                                      JOIN  
                                         Petrovendor.dbo.MM_TipoPedido (NOLOCK)  
                                             ON MM_Pedidos.IdTipoPedido = MM_TipoPedido.IdTipoPedido  
                                                AND MM_Pedidos.IdTipoPedido NOT IN (  
                                                                                       6  
                                                                                   )  
                                     LEFT JOIN  
                                         Petrovendor.dbo.DEA_ProveedorDescripcionSAP (NOLOCK)  
                                             ON MM_Pedido.IdSubContratista = DEA_ProveedorDescripcionSAP.IdProveedor  
                                     LEFT JOIN  
                                         #TablaWDEA_PurchasingDocumentsImportados  
                                             ON MM_Pedido.IdPedido = #TablaWDEA_PurchasingDocumentsImportados.IdPedidoADINCO  
                                 WHERE  
                                         CONVERT(VARCHAR, MM_Pedido.CreadoEl, 112)  
                                 BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112)  
                                 GROUP BY  
                                         DEA_ProveedorDescripcionSAP.IdProveedor,  
                                         S_Proveedor.RazonSocial,  
                                         MM_SolicitudPedido.MotivoUrgencia,  
                                         #TablaWDEA_PurchasingDocumentsImportados.PURCHASING_DOCUMENT,  
                                         MM_SolicitudPedido.FechaEntregaFinRequerida,  
                                         MM_SolicitudPedido.MotivoUrgencia,  
                                         #TablaWDEA_PurchasingDocumentsImportados.IdPedidoADINCO,  
                                         #TablaWDEA_PurchasingDocumentsImportados.IDMONEDA,  
                                         MM_Pedido.FechaRecepcionServicio,  
                                         MM_SolicitudPedido.FechaEntregaRequerida,  
                                         #TablaWDEA_PurchasingDocumentsImportados.OUTLINE_AGREEMENT,  
                                         MM_Pedidos.IdPedido,  
                                         MM_Pedido.IdMoneda,  
                                         MM_Pedido.CreadoEl,  
                                         MM_TipoPedido.TipoPedido,  
                                         #TablaWDEA_PurchasingDocumentsImportados.MECANISMO_CONTRATACION,  
                                         #TablaWDEA_PurchasingDocumentsImportados.NumeroContrato,  
                                         #TablaWDEA_PurchasingDocumentsImportados.CURRENCY,  
                                         #TablaWDEA_PurchasingDocumentsImportados.NET_ORDER_VALUE,  
                                         #TablaWDEA_PurchasingDocumentsImportados.SUM_NET_PRICE,  
                                         #MM_PedidoDetalle.SUM_Subtotal;  
  
                     INSERT INTO #TablaDEA  
                         (  
                             NumeroContrato,  
                             RelacionOperadoraProveedor,  
                             Proveedor,  
                             MecanismoContratacion,  
                             [Nombre Contrato C-P],  
                             [No. Contrato],  
                             [Fecha Inicio Contrato],  
                             [Fecha Termino Contrato],  
                             [Vigencia del contrato],  
                             [Objeto del contrato],  
                             MontoUSD,  
                             MontoMXN,  
                             TipoCambio,  
                             FechaTipoCambio,  
                             Comentarios,  
                             NombreContratista,  
                             FechaEfectiva  
                         )  
                                 SELECT  
                                     @NumeroContrato,  
                                     CASE  
                                         WHEN DEA_ProveedorDescripcionSAP.IdProveedor IS NOT NULL  
                                             THEN 'SI'  
                                         ELSE  
                                             'NO'  
                                     END                                                         AS RelacionOperadoraProveedor,  
                                     LEFT(PV_Subcontratista.RazonSocial, 4000)                   AS Proveedor,  
                                     'Licitación'                                                AS MecanismoContratacion,  
                                     LEFT(SC_SubContrato.Objeto, 4000)                           AS NombreContratoCP,  
                                     LEFT(SC_SubContrato.NumeroSubContrato, 4000)                AS NoContratoCP,  
                                     ISNULL(SC_SubContrato.FechaInicio, SC_SubContrato.CreadoEl) AS FechaInicio,  
                                     ISNULL(  
                                               ISNULL(SC_SubContrato.FechaFin, SC_SubContrato.FechaInicio),  
                                               SC_SubContrato.CreadoEl  
                                           )                                                     AS FechaFin,  
                                     ISNULL(  
                                               ISNULL(SC_SubContrato.FechaFin, SC_SubContrato.FechaInicio),  
                                               SC_SubContrato.CreadoEl  
                                           )                                                     AS FechaVigencia,  
                                     LEFT(SC_SubContrato.Objeto, 4000)                           AS ObjetoContrato,  
                                     CASE  
                                         WHEN SC_SubContrato.IdMoneda = @Peso  
                                             THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(  
                     SUM(SC_Materiales.Importe),  
                                                                                               ISNULL(  
                                                                                                         SC_SubContrato.FechaInicio,  
                                                                                                         SC_SubContrato.CreadoEl  
                                                                                                     )  
                                                                                           )  
                                         ELSE  
                                             SUM(SC_Materiales.Importe)  
                                     END                                                         AS MontoUSD,  
                                     CASE  
                                         WHEN SC_SubContrato.IdMoneda = @Dolar  
                                             THEN Petrovendor.dbo.Fn_dolarespesostipocambio(  
                                                                                               SUM(SC_Materiales.Importe),  
                                                                                               ISNULL(  
                                                                                                         SC_SubContrato.FechaInicio,  
                                                                                                         SC_SubContrato.CreadoEl  
                                                                                                     )  
                                                                                           )  
                                         ELSE  
                                             SUM(SC_Materiales.Importe)  
                                     END                                                         AS MontoMXN,  
                                     Petrovendor.dbo.FN_ValorTipoCambio(ISNULL(  
                                                                                  SC_SubContrato.FechaInicio,  
                                                                                  SC_SubContrato.CreadoEl  
                                                                              )  
                                                                       )                         AS TipoCambio,  
                                     ISNULL(SC_SubContrato.FechaInicio, SC_SubContrato.CreadoEl) AS FechaTipoCambio,  
                                     'ESTIMACION COMPLETA PARA OT',  
                                     LEFT(@ContratistaRazonSocialDelContrato, 4000),
                                     CONVERT(VARCHAR, @FechaFirma, 103)                          AS FechaEfectiva  
                                 FROM  
                                     Adinco.dbo.SC_Presupuesto     AS SC_Presupuesto (NOLOCK)  
                                     JOIN  
                                         Adinco.dbo.SC_SubContrato AS SC_SubContrato (NOLOCK)  
                                            ON SC_Presupuesto.IdSubContrato = SC_SubContrato.IdSubContrato  
                                            AND SC_Presupuesto.IdPresupuesto = @IdPresupuesto  
                                             AND SC_SubContrato.IdContrato = @IDCONTRATO  
                                      JOIN  
                                         Adinco.dbo.PV_Subcontratista (NOLOCK)  
                                             ON SC_SubContrato.IdSubContratista = PV_Subcontratista.IdSubcontratista  
             
                                      JOIN  
                                         Petrovendor.dbo.S_Proveedor (NOLOCK)  
                                             ON PV_Subcontratista.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = S_Proveedor.RFC  
                                     LEFT JOIN  
            Petrovendor.dbo.DEA_ProveedorDescripcionSAP (NOLOCK)  
                                             ON S_Proveedor.IdProveedor = DEA_ProveedorDescripcionSAP.IdProveedor  
                                      JOIN  
                                         Adinco.dbo.SC_Materiales (NOLOCK)  
                                             ON SC_SubContrato.IdSubContrato = SC_Materiales.IdSubContrato  
                                 WHERE  
                                     CONVERT(VARCHAR, SC_SubContrato.CreadoEl, 112)  
                                     BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112)  
                                     AND SC_SubContrato.IsActivo = 1  
                                 GROUP BY  
                                     DEA_ProveedorDescripcionSAP.IdProveedor,  
                                     PV_Subcontratista.RazonSocial,  
                                     SC_SubContrato.Objeto,  
                                     SC_SubContrato.IdPedido,  
                                     SC_SubContrato.FechaInicio,  
                                     SC_SubContrato.FechaFin,  
                                     SC_SubContrato.IdMoneda,  
                                     SC_SubContrato.FechaInicio,  
                                     SC_SubContrato.NumeroSubContrato,  
                                     SC_SubContrato.CreadoEl;  
  
  
                     SELECT  
                         NumeroContrato,  
                         RelacionOperadoraProveedor,  
                         Proveedor,  
                         MecanismoContratacion,  
                         [Nombre Contrato C-P],  
                         [No. Contrato],  
                         CONVERT(VARCHAR(10), [Fecha Inicio Contrato], 105),  
                         CONVERT(VARCHAR(10), [Fecha Termino Contrato], 105),  
                         CONVERT(VARCHAR(10), [Vigencia del contrato], 105),  
                         [Objeto del contrato],  
                         FORMAT(SUM(MontoUSD), '#,#0.000') AS MontoUSD,  
                         FORMAT(SUM(MontoMXN), '#,#0.000') AS MontoMXN,  
                         TipoCambio,  
                         CONVERT(VARCHAR(10), FechaTipoCambio, 105),  
                         Comentarios,  
                         NombreContratista,  
                         FechaEfectiva  
                     FROM  
                         #TablaDEA -- SELET DEA  
                     GROUP BY  
                         NumeroContrato,  
                         RelacionOperadoraProveedor,  
                         Proveedor,  
                         MecanismoContratacion,  
                         [Nombre Contrato C-P],  
                         [No. Contrato],  
                         [Fecha Inicio Contrato],  
                         [Fecha Termino Contrato],  
                         [Vigencia del contrato],  
                         [Objeto del contrato],  
                         TipoCambio,  
                         FechaTipoCambio,  
                         Comentarios,  
                         NombreContratista,  
                         FechaEfectiva  
                     ORDER BY  
                         [No. Contrato];  
                 END  
        --- FIN VALIDACION DEA     
        ELSE  
                 BEGIN  
                     INSERT INTO #Tabla  
                         (  
                             NumeroContrato,  
                             RelacionOperadoraProveedor,  
                             Proveedor,  
                             MecanismoContratacion,  
                             [Nombre Contrato C-P],  
                             [No. Contrato],  
                             [Fecha Inicio Contrato],  
                             [Fecha Termino Contrato],  
                             [Vigencia del contrato],  
                             [Objeto del contrato],  
                             MontoUSD,  
         MontoMXN,  
                             TipoCambio,  
                             FechaTipoCambio,  
                             Comentarios,  
                             NombreContratista,  
                             FechaEfectiva  
                         )  
                                 SELECT  
                                     @NumeroContrato,  
                                     CASE  
                                         WHEN PV_RelacionProveedorSubcotratista.IdRelacion IS NOT NULL  
                                             THEN 'SI'  
                                         ELSE  
                                             'NO'  
                                     END                                                                        AS RelacionOperadoraProveedor,  
                                     LEFT(UPPER(S_Proveedor.RazonSocial) + ' '  
                                     + ISNULL(UPPER(S_Proveedor.RegimenCapital), ''), 4000)                     AS Proveedor,  
                                     'ADJUDICACIÓN DIRECTA'                                                     AS MecanismoContratacion,  
                                     LEFT(UPPER(ISNULL(TA_Operacion.Descripcion, '')), 4000)                    AS 'Nombre Contrato C-P',  
                                     LEFT(UPPER(CONCAT(MM_Pedidos.IdPedido, ' CD')), 4000)                      AS 'No. Contrato',  
                                     CASE  
                                         WHEN CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105) IS NULL  
                                             THEN '-'  
                                         ELSE  
                                             CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105)  
                                     END                                                                        AS 'Fecha Inicio Contrato',  
                                     CASE  
                                         WHEN CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105) IS NULL  
                                             THEN '-'  
                                         ELSE  
                                             CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105)  
                                     END                                                                        AS 'Fecha Termino Contrato',  
                                     CASE  
                                         WHEN CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105) IS NULL  
                                             THEN '-'  
                                         ELSE  
                                             CONVERT(VARCHAR(10), TA_Operacion.FechaRegistro, 105)  
                                     END                                                                        AS 'Vigencia del contrato',  
                                     LEFT(UPPER(ISNULL(TA_Operacion.Descripcion, '')), 4000)                    AS 'Objeto del contrato',  
                                     CASE  
                                         WHEN FI_Factura.IdMoneda = @Peso  
                                             THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(  
                                                                                               FI_Factura.SubTotal,  
                                                                                               CAST(FI_Factura.FechaTimbrado AS DATE)  
                                                                                           )  
                                         ELSE  
                                             FI_Factura.SubTotal  
                                     END                                                                        AS MontoUSD,  
                                     CASE  
                                         WHEN FI_Factura.IdMoneda = @Dolar  
            THEN Petrovendor.dbo.FN_DolaresPesosTipoCambio(  
                                                                                               FI_Factura.SubTotal,  
                                                                                               CAST(FI_Factura.FechaTimbrado AS DATE)  
                                                                                           )  
                                         ELSE  
                                             FI_Factura.SubTotal  
                                     END                                                                        AS MontoMXN,  
                                     Petrovendor.dbo.FN_ValorTipoCambio(CAST(FI_Factura.FechaTimbrado AS DATE)) AS TipoCambio,  
                                     CONVERT(VARCHAR, FI_Factura.FechaTimbrado, 103)                            AS FechaTipoCambio,  
                                     LEFT(UPPER(ISNULL(TA_Operacion.Descripcion, '')), 4000)                    AS 'Comentarios',  
                                     LEFT(UPPER(@ContratistaRazonSocialDelContrato), 4000)                      AS NombreContratista,  
                                     CONVERT(VARCHAR, @FechaFirma, 103)                                         AS FechaEfectiva  
                                 FROM  
                                     #CO_LineasPresupuestoMes        AS TTLineasPresupuesto  
                                     JOIN  
                                         Petrovendor.dbo.CO_Registro AS CO_Registro (NOLOCK)  
                                             ON TTLineasPresupuesto.IdLineaPresupuestoMes = CO_Registro.IdLineaPresupuestoMes  
                                      JOIN  
                                         Petrovendor.dbo.FI_Factura (NOLOCK)  
                                             ON CO_Registro.IdFactura = FI_Factura.IdFactura  
                                                AND FI_Factura.IdContrato = @IdContrato  
                                      JOIN  
                                         Petrovendor.dbo.TA_Operacion (NOLOCK)  
                                             ON CO_Registro.IdFactura = TA_Operacion.IdDocumento  
                                      JOIN  
                                         Petrovendor.dbo.TA_Estatus (NOLOCK)  
                                             ON TA_Operacion.IdEstatusOperacion = TA_Estatus.IdEstatus  
                                     LEFT JOIN  
                                         Petrovendor.dbo.CC_CentroCosto (NOLOCK)  
                                             ON CO_Registro.CentroCostos = CC_CentroCosto.IdCentroCosto  
                                     LEFT JOIN  
                                         Petrovendor.dbo.DG_CuentaContable (NOLOCK)  
                                             ON CO_Registro.CuentaContable = DG_CuentaContable.Id  
                                     LEFT JOIN  
                                         Petrovendor.dbo.CO_CatalogoCuentaSH (NOLOCK)  
                                             ON CO_Registro.IdCatalogoCuentasSH = CO_CatalogoCuentaSH.IdCatalogoCuentasSH  
                                     LEFT JOIN  
                                         Petrovendor.dbo.CO_Instalacion (NOLOCK)  
                                             ON CO_Registro.IdInstalacion = CO_Instalacion.IdInstalacion  
                                      JOIN  
                                         Petrovendor.dbo.MM_Pedidos (NOLOCK)  
                                             ON FI_Factura.IdFactura = MM_Pedidos.IdIdentificador  
                                                AND MM_Pedidos.IdTipoPedido = @TipoPedidoCompraDirecta  
                                                AND TA_Operacion.IdProveedor = MM_Pedidos.IdProveedorCliente  
                                      JOIN  
                                         Petrovendor.dbo.S_Proveedor (NOLOCK)  
                ON FI_Factura.Emisor = S_Proveedor.RFC  
                                     LEFT JOIN  
                                         Petrovendor.dbo.PV_RelacionProveedorSubcotratista (NOLOCK)  
                                             ON S_Proveedor.IdProveedor = PV_RelacionProveedorSubcotratista.IdProveedor  
                                                AND S_Proveedor.IdProveedor = PV_RelacionProveedorSubcotratista.IdSubcontratista  
                                 WHERE  
                                     TA_Operacion.IdTipoOperacion = @CompraDirecta  
                                     AND TA_Estatus.IdEstatus = @Aprobado  
                                     AND ISNULL(FI_Factura.IsEliminado, 0) = 0  
                                     AND CONVERT(VARCHAR, TA_Operacion.FechaRegistro, 112)  
                                     BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112);  
  
  
                     INSERT INTO #Tabla  
                         (  
                             NumeroContrato,  
                             RelacionOperadoraProveedor,  
                             Proveedor,  
                             MecanismoContratacion,  
                             [Nombre Contrato C-P],  
                             [No. Contrato],  
                             [Fecha Inicio Contrato],  
                             [Fecha Termino Contrato],  
                             [Vigencia del contrato],  
                             [Objeto del contrato],  
                             MontoUSD,  
                             MontoMXN,  
                             TipoCambio,  
                             FechaTipoCambio,  
                             Comentarios,  
                             NombreContratista,  
                             FechaEfectiva  
                         )  
                                 SELECT  
                                     CONCAT(@NumeroContrato, '(', CO_PeriodoContrato.NombrePeriodo, ')'),  
                                     CASE  
                                         WHEN PV_RelacionProveedorSubcotratista.IdRelacion IS NOT NULL  
                                             THEN 'SI'  
                                         ELSE  
                                             'NO'  
                                     END                                             AS RelacionOperadoraProveedor,  
                                     LEFT(UPPER(S_Proveedor.RazonSocial) + ' '  
                                     + ISNULL(UPPER(S_Proveedor.RegimenCapital), ''), 4000) AS Proveedor,  
                                     CASE  
                                         WHEN MM_TipoPedido.TipoPedido = 'Mercadeo'  
                                             THEN 'TRES COTIZACIONES'  
                                         ELSE  
                                             LEFT(UPPER(MM_TipoPedido.TipoPedido), 4000)  
                                     END                                             AS MecanismoContratacion,  
                                     LEFT(UPPER(MM_SolicitudPedido.MotivoUrgencia), 4000)  AS 'Nombre Contrato C-P',  
                                     LEFT(MM_Pedidos.IdPedido, 4000)                 AS 'No. Contrato',  
                                     CONVERT(  
                                                VARCHAR(10),  
                                                isnull(  
                                                          MM_Pedido.FechaRecepcionServicio,  
                                                          MM_SolicitudPedido.FechaEntregaRequerida  
                                                      ), 105  
                                            )                                        AS 'Fecha Inicio Contrato',  
                                     CONVERT(  
                                                VARCHAR(10),  
                                                isnull(  
                      MM_Pedido.FechaRecepcionServicio,  
                                                          MM_SolicitudPedido.FechaEntregaRequerida  
                                                      ), 105  
                                            )                                        AS 'Fecha Termino Contrato',  
                                     CONVERT(  
                                                VARCHAR(10),  
                                                isnull(  
                                                          MM_Pedido.FechaRecepcionServicio,  
                                                          MM_SolicitudPedido.FechaEntregaRequerida  
                                                      ), 105  
                                            )                                        AS 'Vigencia del contrato',  
                                     UPPER(MM_SolicitudPedido.MotivoUrgencia)        AS 'Objeto del contrato',  
                                     CASE  
                                         WHEN PV_TipoMoneda.IdMoneda = @Peso  
                                             THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(  
                                                                                               SUM(MM_PedidoDetalle.Subtotal),  
                                                                                               CAST(ISNULL(  
                                                                                                              MM_SolicitudPedido.FechaEntregaRequerida,  
                                                                                                              MM_PeticionOferta.FechaFinalizado  
                                                                                                          ) AS DATE)  
                                                                                           )  
                                         ELSE  
                                             SUM(MM_PedidoDetalle.Subtotal)  
                                     END                                             AS MontoUSD,  
                                     CASE  
                                         WHEN PV_TipoMoneda.IdMoneda = @Dolar  
                                             THEN Petrovendor.dbo.FN_DolaresPesosTipoCambio(  
                                                                                               SUM(MM_PedidoDetalle.Subtotal),  
                                                                                               ISNULL(  
                                                                                                         MM_SolicitudPedido.FechaEntregaRequerida,  
                                                                                                         MM_PeticionOferta.FechaFinalizado  
                                                                                                     )  
                                                                                           )  
                                         ELSE  
                                             SUM(MM_PedidoDetalle.Subtotal)  
                                     END                                             AS MontoMXN,  
                                     Petrovendor.dbo.FN_ValorTipoCambio(CAST(ISNULL(  
                                                                                       MM_SolicitudPedido.FechaEntregaRequerida,  
                                                                                       MM_PeticionOferta.FechaFinalizado  
                                                                                   ) AS DATE)  
                                                                       )             AS TipoCambio,  
                                     CONVERT(  
                                                VARCHAR,  
          ISNULL(  
                                                          MM_SolicitudPedido.FechaEntregaRequerida,  
                                                          MM_PeticionOferta.FechaFinalizado  
                                                      ), 103  
                                            )                                        AS FechaTipoCambio,                          --DWONG 20190712       
  
                                     LEFT(UPPER(MM_SolicitudPedido.MotivoUrgencia), 4000)   AS 'Comentarios',  
                                     NombreContratista                               = LEFT(UPPER(@ContratistaRazonSocialDelContrato), 4000), --DWONG 20190712       
                                     FechaEfectiva                                   = CONVERT(VARCHAR, @FechaFirma, 103)         --DWONG 20190712       
  
                                 FROM  
                                     #CO_LineasPresupuestoMes                      AS TTLineasPresupuesto  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto (NOLOCK)  
                                             ON TTLineasPresupuesto.IdLineaPresupuestoMes = MM_SolicitudPedidoDetalleLineaPresupuesto.IdLineaPresupuesto  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedidoDetalle AS MM_SolicitudPedidoDetalle (NOLOCK)  
                                             ON MM_SolicitudPedidoDetalleLineaPresupuesto.IdSolicitudPedidoDetalle = MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle  
                                     JOIN  
                                         Petrovendor.dbo.MM_SolicitudPedido        AS MM_SolicitudPedido (NOLOCK)  
                                             ON MM_SolicitudPedidoDetalle.IdSolicitudPedido = MM_SolicitudPedido.IdSolicitudPedido  
                                     JOIN  
                                         Petrovendor.dbo.MM_Pedido                 AS MM_Pedido (NOLOCK)  
                                             ON MM_SolicitudPedido.IdSolicitudPedido = MM_Pedido.IdSolicitudPedido  
                                                AND ISNULL(MM_Pedido.IdEstatusEliminado, 0) = 0  
                                                AND MM_Pedido.IdContrato = @IdContrato  
                                     JOIN  
                                         Petrovendor.dbo.MM_PedidoDetalle (NOLOCK)  
                                             ON MM_Pedido.IdPedido = MM_PedidoDetalle.IdPedido  
                                     JOIN  
                                         Petrovendor.dbo.MM_Pedidos (NOLOCK)  
                                             ON MM_Pedido.IdPedido = MM_Pedidos.IdIdentificador  
                                                AND MM_Pedido.IdProveedorCompras = MM_Pedidos.IdProveedorCliente  
                                      JOIN  
                                         Petrovendor.dbo.MM_PeticionOferta (NOLOCK)  
                                             ON MM_Pedido.IdPeticionOferta = MM_PeticionOferta.IdPeticionOferta  
                                                AND MM_SolicitudPedido.IdSolicitudPedido = MM_PeticionOferta.IdSolicitudPedido  
                                      JOIN  
                                         Petrovendor.dbo.MM_PeticionOfertaDetalle (NOLOCK)  
                                             ON MM_PeticionOferta.IdPeticionOferta = MM_PeticionOfertaDetalle.IdPeticionOferta  
                                                AND MM_SolicitudPedidoDetalle.IdSolicitudPedidoDetalle = MM_PeticionOfertaDetalle.IdSolicitudPedidoDetalle  
                                                AND MM_PedidoDetalle.IdPeticionOfertaDetalle = MM_PeticionOfertaDetalle.IdPeticionOfertaDetalle  
                                      JOIN  
                                         Petrovendor.dbo.S_Proveedor (NOLOCK)  
                            ON MM_PeticionOferta.IdSubcontratista = S_Proveedor.IdProveedor  
                                      JOIN  
                                         Petrovendor.dbo.TA_Operacion (NOLOCK)  
                                             ON MM_Pedido.IdSolicitudPedido = TA_Operacion.IdDocumento  
                                                AND MM_Pedido.Version = TA_Operacion.NoVersion  
                                      JOIN  
                                         Petrovendor.dbo.TA_TipoOperacion (NOLOCK)  
                                             ON TA_Operacion.IdTipoOperacion = TA_TipoOperacion.IdTipoOperacion  
                                      JOIN  
                                         Petrovendor.dbo.TA_Estatus (NOLOCK)  
                                             ON TA_Operacion.IdEstatusOperacion = TA_Estatus.IdEstatus  
                                      JOIN  
                                         Petrovendor.dbo.PV_TipoMoneda (NOLOCK)  
                                             ON MM_Pedido.IdMoneda = PV_TipoMoneda.IdMoneda  
                                     LEFT JOIN  
                                         Petrovendor.dbo.PV_RelacionProveedorSubcotratista (NOLOCK)  
                                             ON MM_SolicitudPedido.IdProveedor = PV_RelacionProveedorSubcotratista.IdProveedor  
                                                AND MM_Pedido.IdSubcontratista = PV_RelacionProveedorSubcotratista.IdSubcontratista  
                                      JOIN  
                                         Petrovendor.dbo.MM_TipoPedido (NOLOCK)  
                                             /*SI ES CÁRDENAS MORA TOMAR IdTipoProceso de MM_SolicitudPedido*/  
                                             ON MM_TipoPedido.IdTipoPedido = (CASE  
                                                                                  WHEN @IdContratista IN (  
                                                                                                             10010  
                                                                                                         )  
                                                                                      then MM_SolicitudPedido.IdTipoProceso  
                                                                                  else  
                                                                                      MM_PeticionOferta.IdTipoProceso  
                                                                              END  
                                                                             )  
                                      JOIN  
                                         Adinco.dbo.CO_PeriodoContrato (NOLOCK)  
                                             ON MM_SolicitudPedido.IdPeriodo = CO_PeriodoContrato.IdPeriodo  
                                     LEFT JOIN  
                                         SC_SubContrato  
                                             ON MM_Pedido.IdPedido = SC_SubContrato.IdPedido  
                                                AND SC_SubContrato.IsActivo = 1  
                                 WHERE  
                                     TA_Operacion.IdTipoOperacion = @AprobacionDePedido  
                                     AND TA_Estatus.IdEstatus = @Aprobado  
                                     AND ISNULL(MM_SolicitudPedido.IdEstatusEliminado, 0) = 0  
                                     AND ISNULL(MM_Pedido.IdEstatusEliminado, 0) = 0  
                                     AND MM_PeticionOfertaDetalle.IdPeticionOfertaDetalle IS NOT NULL -- para que no se repita que solo se ligue a los que cotizaron       
                                     AND MM_Pedido.FechaEnvioPedido  
                                     BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112) --Evitar mostrar pedidos que ya tengan un subcontrato asignado       
                       AND SC_SubContrato.IdSubContrato IS NULL  
                                 GROUP BY  
                                     PV_RelacionProveedorSubcotratista.IdRelacion,  
                                     S_Proveedor.RazonSocial,  
                                     S_Proveedor.RegimenCapital,  
                                     MM_TipoPedido.TipoPedido,  
                                     MM_SolicitudPedido.MotivoUrgencia,  
                                     MM_SolicitudPedido.FechaEntregaRequerida,  
                                     MM_PeticionOferta.FechaFinalizado,  
                                     PV_TipoMoneda.IdMoneda,  
                                     MM_Pedido.IdPedido,  
                                     MM_Pedidos.IdPedido,  
                                     CO_PeriodoContrato.NombrePeriodo,  
                                     MM_Pedido.FechaRecepcionServicio  
  
  
                     SELECT  
                         NumeroContrato,  
                         RelacionOperadoraProveedor,  
                         Proveedor,  
                         MecanismoContratacion,  
                         [Nombre Contrato C-P],  
                         [No. Contrato],  
                         [Fecha Inicio Contrato],  
                         [Fecha Termino Contrato],  
                         [Vigencia del contrato],  
                         [Objeto del contrato],  
                         FORMAT(SUM(MontoUSD), '#,#0.000') AS MontoUSD,  
                         FORMAT(SUM(MontoMXN), '#,#0.000') AS MontoMXN,  
                         TipoCambio,  
                         FechaTipoCambio,  
                         Comentarios,  
                         NombreContratista,  
                         FechaEfectiva  
                     FROM  
                         #Tabla -- Los demas  
                     GROUP BY  
                         NumeroContrato,  
                         RelacionOperadoraProveedor,  
                         Proveedor,  
                         MecanismoContratacion,  
                         [Nombre Contrato C-P],  
                         [No. Contrato],  
                         [Fecha Inicio Contrato],  
                         [Fecha Termino Contrato],  
                         [Vigencia del contrato],  
                         [Objeto del contrato],  
                         TipoCambio,  
                         FechaTipoCambio,  
                         Comentarios,  
                         NombreContratista,  
                         FechaEfectiva  
                     ORDER BY  
                         [No. Contrato];  
  
                 END;  
    END;  
  