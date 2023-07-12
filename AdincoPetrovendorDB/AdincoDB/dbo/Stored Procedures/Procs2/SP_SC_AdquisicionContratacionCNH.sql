IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_SC_AdquisicionContratacionCNH'
)
    DROP PROCEDURE SP_SC_AdquisicionContratacionCNH;
GO

CREATE PROCEDURE [dbo].[SP_SC_AdquisicionContratacionCNH] 
@IdContrato INT, 
@Fechainicio DATE, 
@FechaFin DATE 
AS 
BEGIN 
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Create date: 29/21/2021
-- Description:	consume la función para obtener el subtotal para issue 1489(Petrovendor)
-- =============================================
-- 20211203	BAAC	Se agrega tabla temporal para agrupar los datos de la tabla AX_Layout
--					porque existen muchos registros repetidos y afecta la sumatorio de montos
-- 20220118	BAAC	Se corrigen format en monto USD y MXN por error en DEA
-- 20221014 DAC     Se toma en consideración MECANISMO_CONTRATACION para reporte DEA cuando sea L --> Poner default Licitación
-- 20230119 JAGE    Se corrige la consulta de las relaciones de WDEA
-- 20230131 DAC     Se calcula subtotales en temporales para evitar duplicados DEA
-- =============================================
SET NOCOUNT ON
   -- SE CREA TABLA PARA QUE NO SE REPITAN LOS DATOS EN LOS MONTOS POR HABER DUPLICADOS EN ESTA TABLA: AX_Layout
   CREATE TABLE #AX_Layout
   (
	IdLayoutAX	INT,
	Empresa	varchar (250),
	NoOrden	varchar (250),
	FechaRegistroCompra	VARCHAR(250),
	NoPedidoADINCO	VARCHAR (250),
	Estatus	VARCHAR(250),
	FechaEntrega	VARCHAR(250)
   )
   	 
    --- VALIDAR SI EL CONTRATO ES DE CARSO, EJECUTAR SP DE SP_SC_AdquisicionContratacionCNH_Carso         
    DECLARE @TablaDEA TABLE   
    (   
        NumeroContrato NVARCHAR(MAX),   
        RelacionOperadoraProveedor NVARCHAR(100),   
        Proveedor NVARCHAR(MAX),   
        MecanismoContratacion NVARCHAR(200),   
        [Nombre Contrato C-P] NVARCHAR(MAX),   
        [No. Contrato] NVARCHAR(MAX),   
        [Fecha Inicio Contrato] DATETIME,   
        [Fecha Termino Contrato] DATETIME,   
        [Vigencia del contrato] DATETIME,   
        [Objeto del contrato] NVARCHAR(MAX),   
        MontoUSD FLOAT,   
        MontoMXN FLOAT,   
        TipoCambio FLOAT,   
        FechaTipoCambio DATETIME,   
        Comentarios NVARCHAR(MAX),   
        NombreContratista NVARCHAR(MAX),   
        FechaEfectiva NVARCHAR(10)   
    );  
	
	DECLARE @Tabla TABLE   
    (   
        NumeroContrato NVARCHAR(MAX),   
        RelacionOperadoraProveedor NVARCHAR(100),   
        Proveedor NVARCHAR(MAX),   
        MecanismoContratacion NVARCHAR(200),   
        [Nombre Contrato C-P] NVARCHAR(MAX),   
        [No. Contrato] NVARCHAR(MAX),   
        [Fecha Inicio Contrato] NVARCHAR(MAX),   
        [Fecha Termino Contrato] NVARCHAR(MAX),   
        [Vigencia del contrato] NVARCHAR(MAX),   
        [Objeto del contrato] NVARCHAR(MAX),   
        MontoUSD FLOAT,   
        MontoMXN FLOAT,   
        TipoCambio NVARCHAR(MAX),
        FechaTipoCambio NVARCHAR(MAX),   
        Comentarios NVARCHAR(MAX),   
        NombreContratista NVARCHAR(MAX),   
        FechaEfectiva NVARCHAR(10)   
    ); 

	 DECLARE @TablaWDEA_PurchasingDocumentsImportados TABLE   
    (   
		IdPedidoADINCO INT,
        PURCHASING_DOCUMENT VARCHAR(MAX),  
		CURRENCY VARCHAR(MAX),  
        NET_ORDER_VALUE FLOAT,   
		SUM_NET_PRICE FLOAT,		
		IDMONEDA INT,   
		OUTLINE_AGREEMENT VARCHAR(MAX), 
		NumeroContrato VARCHAR(MAX),
		MECANISMO_CONTRATACION  VARCHAR(MAX)
	);

	DECLARE @MM_PedidoDetalle TABLE   
	(   
			IdPedido INT,    
			SUM_Subtotal FLOAT		
	);

	DECLARE @Bloque	VARCHAR(50)
    ---AGREGAR LOS CONTRATOS QUE ESTAN INCLUIDOS EN EL REPORTE DE CARSO --         
    --##EDITAR ID'S DE CONTRATOS##         
    IF ISNULL(@IdContrato, 0) IN ( 10047, 10048 )   
    BEGIN

		SELECT
			@Bloque	= CASE WHEN @IdContrato = 10047 THEN 'OP12' ELSE 'OP13' END

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
        INSERT INTO @Tabla   
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
        SELECT C.NumeroContrato,   
               CASE   
                   WHEN RE.IdRelacion IS NOT NULL THEN   
                       'SI'   
                   ELSE   
                       'NO'   
               END AS RelacionOperadoraProveedor,   
               UPPER(P.RazonSocial) + ' ' + ISNULL(UPPER(P.RegimenCapital), '') AS Proveedor,   
               'ADJUDICACIÓN DIRECTA' AS MecanismoContratacion,   
               UPPER(ISNULL(TAO.Descripcion, '')) AS 'Nombre Contrato C-P',   
               UPPER(CONCAT(PG.IdPedido, ' CD')) AS 'No. Contrato',   
               CASE   
                   WHEN CONVERT(VARCHAR(10), TAO.FechaRegistro, 105) IS NULL THEN   
                       '-'   
                   ELSE   
                       CONVERT(VARCHAR(10), TAO.FechaRegistro, 105)   
               END AS 'Fecha Inicio Contrato',   
               CASE   
                   WHEN CONVERT(VARCHAR(10), TAO.FechaRegistro, 105) IS NULL THEN   
						'-'   
                   ELSE   
                       CONVERT(VARCHAR(10), TAO.FechaRegistro, 105)   
               END AS 'Fecha Termino Contrato',                  
               CASE   
                   WHEN CONVERT(VARCHAR(10), TAO.FechaRegistro, 105) IS NULL THEN   
                       '-'   
                   ELSE   
                       CONVERT(VARCHAR(10), TAO.FechaRegistro, 105)   
               END AS 'Vigencia del contrato',   
               UPPER(ISNULL(TAO.Descripcion, '')) AS 'Objeto del contrato',   
               CASE   
                   WHEN fiFact.IdMoneda = 1 THEN   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       fiFact.SubTotal, CAST(fiFact.FechaTimbrado AS DATE))  
                   ELSE   
					   fiFact.SubTotal
				END AS MontoUSD,   
               CASE   
                   WHEN fiFact.IdMoneda = 2 THEN     
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       fiFact.SubTotal, CAST(fiFact.FechaTimbrado AS DATE)) 
                   ELSE   
					   fiFact.SubTotal 
               END AS MontoMXN,   
               Petrovendor.dbo.FN_ValorTipoCambioIterativo(CAST(TAO.FechaRegistro AS DATE)) AS TipoCambio,   
               CONVERT(VARCHAR, TAO.FechaRegistro, 105) AS FechaTipoCambio,   
               UPPER(ISNULL(TAO.Descripcion, '')) AS 'Comentarios',   
               UPPER(ctista.RazonSocial) AS NombreContratista,   
               '' AS FechaEfectiva   
        FROM Petrovendor.dbo.CO_Registro AS coRegistro   
            LEFT JOIN Petrovendor.dbo.FI_Factura AS fiFact   
                ON coRegistro.IdFactura = fiFact.IdFactura   
            LEFT JOIN Petrovendor.dbo.TA_Operacion AS TAO   
                ON TAO.IdDocumento = coRegistro.IdFactura   
            LEFT JOIN Petrovendor.dbo.TA_Estatus AS TE   
                ON TE.IdEstatus = TAO.IdEstatusOperacion   
            LEFT JOIN Petrovendor.dbo.CC_CentroCosto centroCosto   
                ON centroCosto.IdCentroCosto = coRegistro.CentroCostos   
            LEFT JOIN Petrovendor.dbo.DG_CuentaContable cuentaContable   
                ON cuentaContable.Id = coRegistro.CuentaContable   
            LEFT JOIN Petrovendor.dbo.CO_CatalogoCuentaSH cuentaSh   
                ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH   
            LEFT JOIN Petrovendor.dbo.CO_Instalacion instalacion   
                ON instalacion.IdInstalacion = coRegistro.IdInstalacion   
            LEFT JOIN Petrovendor.dbo.MM_Pedidos PG   
                ON PG.IdIdentificador = fiFact.IdFactura   
                   AND PG.IdTipoPedido = 1   
                   AND TAO.IdProveedor = PG.IdProveedorCliente   
            LEFT JOIN Petrovendor.dbo.S_Proveedor AS P   
                ON P.RFC = fiFact.Emisor   
            LEFT JOIN Adinco.dbo.CO_Contrato AS C   
                ON fiFact.IdContrato = C.IdContrato   
            LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC   
                ON C.IdAreaContractual = AC.IdAreaContractual   
            LEFT JOIN Petrovendor.dbo.PV_RelacionProveedorSubcotratista AS RE   
                ON RE.IdProveedor = P.IdProveedor   
                   AND RE.IdSubcontratista = P.IdProveedor   
            INNER JOIN Adinco.dbo.CO_Contratista ctista   
                ON ctista.IdContratista = C.IdContratista   
        WHERE TAO.IdTipoOperacion = 14   
              AND TE.IdEstatus = 2   
              AND ISNULL(fiFact.IsEliminado, 0) = 0   
              AND C.IdContrato = @IdContrato   
              AND CONVERT(VARCHAR, TAO.FechaRegistro, 112)   
              BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112);   
   
        --#MODIFICACIÓN PARA PEDIDOS -MERCADEO - ADJ DIRECTA DE OPERADORA CARSO        
        INSERT INTO @Tabla   
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
        SELECT c.NumeroContrato,   
               CASE   
                   WHEN RE.IdRelacion IS NOT NULL THEN   
                       'SI'   
                   ELSE   
                       'NO'   
               END AS RelacionOperadoraProveedor,   
               UPPER(PV.RazonSocial) + ' ' + ISNULL(UPPER(PV.RegimenCapital), '') AS Proveedor,   
               CASE   
                   WHEN TP.TipoPedido = 'Mercadeo' THEN   
                       'TRES COTIZACIONES'   
                   ELSE   
                       UPPER(TP.TipoPedido)   
               END AS MecanismoContratacion,   
               dbo.fn_SC_AdquisicionMaterialesCarso(P.IdPedido) AS 'Nombre Contrato C-P', ---> OBTENER EL NOMBRE DE LOS MATERIALES DE LA COMPARATIVA  QUE ESTAN EN EL PEDIDO ACTUAL       
               AXP.NoOrden AS 'No. Contrato',                                             --> NUMERO DE PEDIDO DE AX        
               REPLACE(AXP.FechaRegistroCompra, '/', '-') AS 'Fecha Inicio Contrato',     --> FECHA DE CREACIÓN DEL PEDIDO EN AX       
               REPLACE(AXP.FechaEntrega, '/', '-') AS 'Fecha Termino Contrato',           --> FECHA DE LA PRIMERA ACEPTACIÓN DE PEDIDO DE AX        
               REPLACE(AXP.FechaEntrega, '/', '-') AS 'Vigencia del contrato',                                            --> DIFERENCIA PARA OBTENER LA VIGENCIA DEL CONTRATO       
               dbo.fn_SC_AdquisicionMaterialesCarso(P.IdPedido) AS 'Objeto del contrato', ---> OBTENER EL NOMBRE DE LOS MATERIALES DE LA COMPARATIVA  QUE ESTAN EN EL PEDIDO ACTUAL       
               CASE   
                   WHEN Mon.IdMoneda = 1   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN  
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       SUM(PD.Subtotal),   
                       CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) AS DATE)) 
                   WHEN Mon.IdMoneda = 2   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
					   SUM(PD.Subtotal)
                   ELSE  
					   0 
               END AS MontoUSD,   
               CASE   
                   WHEN Mon.IdMoneda = 2   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       SUM(PD.Subtotal),   
                       CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) AS DATE))  
                   WHEN Mon.IdMoneda = 1 AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL 
					THEN (DBO.fn_ObtenSubtotalPedido(Mon.IdMoneda,P.IdPedido,@IdContrato))       
                   ELSE   
					   0  
               END AS MontoMXN,   
               CASE   
                   WHEN dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       Petrovendor.dbo.FN_ValorTipoCambioIterativo(   
                       CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) AS DATE))   
                   ELSE   
                       ''   
               END AS TipoCambio,   
               REPLACE(AXP.FechaRegistroCompra, '/', '-') AS FechaTipoCambio,             --DWONG 20190712       
               dbo.fn_SC_AdquisicionMaterialesCarso(P.IdPedido) AS 'Comentarios', NombreContratista = UPPER(ctista.RazonSocial),   
               FechaEfectiva = CONVERT(VARCHAR, c.FechaFirma, 103)                        --DWONG 20190712       
        FROM Petrovendor.dbo.MM_Pedido AS P 
			LEFT JOIN #AX_Layout AXP
                ON CAST(AXP.NoPedidoADINCO AS NVARCHAR(MAX)) = CAST(P.IdPedido AS NVARCHAR(MAX))   
				AND LTRIM(RTRIM(AXP.Empresa))	=	@Bloque
            LEFT JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD   
                ON PD.IdPedido = P.IdPedido   
				AND ISNULL(P.IdEstatusEliminado,0) = 0
            LEFT JOIN Petrovendor.dbo.MM_Pedidos PSS   
                ON P.IdPedido = PSS.IdIdentificador   
                   AND PSS.IdProveedorCliente = P.IdProveedorCompras   
            INNER JOIN Petrovendor.dbo.AX_ComparativaEmpresa emp   
                ON emp.IdProveedor = PSS.IdProveedorCliente   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido solPed   
                ON solPed.IdSolicitudPedido = P.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle SPD   
                ON solPed.IdSolicitudPedido = SPD.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL   
                ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle   
            LEFT JOIN Petrovendor.dbo.MM_PeticionOferta AS PO   
                ON PO.IdPeticionOferta = P.IdPeticionOferta   
                   AND PO.IdSolicitudPedido = solPed.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle POD   
                ON POD.IdPeticionOferta = PO.IdPeticionOferta   
                   AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle   
                   AND POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle   
            LEFT JOIN Petrovendor.dbo.S_Proveedor AS PV   
                ON PV.IdProveedor = PO.IdSubcontratista   
            LEFT JOIN Petrovendor.dbo.TA_Operacion AS O   
                ON O.IdDocumento = P.IdSolicitudPedido   
                   AND P.Version = O.NoVersion   
            LEFT JOIN Petrovendor.dbo.TA_TipoOperacion AS TTO   
                ON TTO.IdTipoOperacion = O.IdTipoOperacion   
            LEFT JOIN Petrovendor.dbo.TA_Estatus AS E   
                ON E.IdEstatus = O.IdEstatusOperacion   
            LEFT JOIN Adinco.dbo.CO_Contrato c   
                ON c.IdContrato = P.IdContrato   
            INNER JOIN Adinco.dbo.CO_Contratista ctista   
                ON ctista.IdContratista = c.IdContratista   
            INNER JOIN Petrovendor.dbo.PV_TipoMoneda AS Mon   
                ON P.IdMoneda = Mon.IdMoneda   
            LEFT JOIN Petrovendor.dbo.PV_RelacionProveedorSubcotratista AS RE   
                ON RE.IdProveedor = solPed.IdProveedor   
                   AND RE.IdSubcontratista = P.IdSubcontratista   
            LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP    
				ON PSS.IdTipoPedido	=	TP.IdTipoPedido
        WHERE O.IdTipoOperacion = 9   
              AND E.IdEstatus = 2   
              AND c.IdContrato = @IdContrato   
              AND ISNULL(solPed.IdEstatusEliminado, 0) = 0   
              AND ISNULL(P.IdEstatusEliminado, 0) = 0   
              AND POD.IdPeticionOfertaDetalle IS NOT NULL -- para que no se repita que solo se ligue a los que cotizaron       
              AND CONVERT(DATE, dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra))   
              BETWEEN CONVERT(DATE, @Fechainicio) AND CONVERT(DATE, @FechaFin)   
              AND NOT EXISTS   
        (   SELECT 1   
            FROM SC_SubContrato sc   
            WHERE sc.IdPedido = P.IdPedido   
                  AND sc.IsActivo = 1)   
              AND UPPER(LTRIM(RTRIM(AXP.Estatus))) <> UPPER('cancelado')   
        GROUP BY RE.IdRelacion,   
                 PV.RazonSocial,   
                 PV.RegimenCapital,   
                 TP.TipoPedido,   
                 solPed.MotivoUrgencia,   
                 c.NumeroContrato,   
                 solPed.FechaEntregaFinRequerida,   
                 solPed.FechaEntregaRequerida,   
                 PO.FechaFinalizado,   
                 c.DescripcionContrato,   
                 Mon.IdMoneda,   
                 solPed.IdSolicitudPedido,   
                 P.IdPedido,   
                 PSS.IdPedido,   
                 ctista.RazonSocial,   
                 c.FechaFirma,   
                 AXP.FechaRegistroCompra,   
                 AXP.NoOrden,   
                 AXP.FechaEntrega   
        ORDER BY PSS.IdPedido ASC;   
   
        --Aqui se agregan los pedidos que estan en orden abierta       
        INSERT INTO @Tabla   
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
        SELECT c.NumeroContrato,   
               CASE   
                   WHEN RE.IdRelacion IS NOT NULL THEN   
                       'SI'   
                   ELSE   
                       'NO'   
               END AS RelacionOperadoraProveedor,   
               UPPER(PV.RazonSocial) + ' ' + ISNULL(UPPER(PV.RegimenCapital), '') AS Proveedor,   
               CASE   
                   WHEN TP.TipoPedido = 'Mercadeo' THEN   
                       'TRES COTIZACIONES'   
                   ELSE   
                       UPPER(TP.TipoPedido)   
               END AS MecanismoContratacion,   
               dbo.fn_SC_AdquisicionMaterialesCarso(P.IdPedido) AS 'Nombre Contrato C-P', ---> OBTENER EL NOMBRE DE LOS MATERIALES DE LA COMPARATIVA  QUE ESTAN EN EL PEDIDO ACTUAL       
               AXP.NoOrden AS 'No. Contrato',                                             --> NUMERO DE PEDIDO DE AX        
               REPLACE(AXP.FechaRegistroCompra, '/', '-') AS 'Fecha Inicio Contrato',     --> FECHA DE CREACIÓN DEL PEDIDO EN AX       
               REPLACE(AXP.FechaEntrega, '/', '-') AS 'Fecha Termino Contrato',           --> FECHA DE LA PRIMERA ACEPTACIÓN DE PEDIDO DE AX        
               REPLACE(AXP.FechaEntrega, '/', '-') AS 'Vigencia del contrato',                                            --> DIFERENCIA PARA OBTENER LA VIGENCIA DEL CONTRATO       
               dbo.fn_SC_AdquisicionMaterialesCarso(P.IdPedido) AS 'Objeto del contrato', ---> OBTENER EL NOMBRE DE LOS MATERIALES DE LA COMPARATIVA  QUE ESTAN EN EL PEDIDO ACTUAL       
               CASE   
                   WHEN Mon.IdMoneda = 1   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       SUM(PD.Subtotal),   
                       CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) AS DATE))
                   WHEN Mon.IdMoneda = 2   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
					   SUM(PD.Subtotal)
                   ELSE   
					   0
               END AS MontoUSD,   
               CASE   
                   WHEN Mon.IdMoneda = 2   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN    
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       SUM(PD.Subtotal),   
                       CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) AS DATE))  
                   WHEN Mon.IdMoneda = 1   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       (DBO.fn_ObtenSubtotalPedido(Mon.IdMoneda,P.IdPedido,@IdContrato))
                   ELSE 0
               END AS MontoMXN,   
               CASE   
                   WHEN dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       Petrovendor.dbo.FN_ValorTipoCambioIterativo(   
                       CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) AS DATE))   
                   ELSE   
                       ''   
               END AS TipoCambio,   
               REPLACE(AXP.FechaRegistroCompra, '/', '-') AS FechaTipoCambio,             --DWONG 20190712       
               dbo.fn_SC_AdquisicionMaterialesCarso(P.IdPedido) AS 'Comentarios',   
               NombreContratista = UPPER(ctista.RazonSocial),   
               FechaEfectiva = CONVERT(VARCHAR, c.FechaFirma, 103)                        --DWONG 20190712       
        FROM Petrovendor.dbo.MM_Pedido AS P   
			LEFT JOIN #AX_Layout	AXP
                ON CAST(AXP.NoPedidoADINCO AS NVARCHAR(MAX)) = CAST(P.IdPedido AS NVARCHAR(MAX))   
				AND LTRIM(RTRIM(AXP.Empresa))	=	@Bloque
				AND ISNULL(P.IdEstatusEliminado,0) = 0
            LEFT JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD   
                ON PD.IdPedido = P.IdPedido   
            LEFT JOIN Petrovendor.dbo.MM_Pedidos PSS   
                ON P.IdPedido = PSS.IdIdentificador   
                   AND PSS.IdProveedorCliente = P.IdProveedorCompras   
            INNER JOIN Petrovendor.dbo.AX_ComparativaEmpresa emp   
                ON emp.IdProveedor = PSS.IdProveedorCliente   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido solPed   
                ON solPed.IdSolicitudPedido = P.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle SPD   
                ON solPed.IdSolicitudPedido = SPD.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL   
                ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle   
            LEFT JOIN Petrovendor.dbo.MM_PeticionOferta AS PO   
                ON PO.IdPeticionOferta = P.IdPeticionOferta   
                   AND PO.IdSolicitudPedido = solPed.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle POD   
                ON POD.IdPeticionOferta = PO.IdPeticionOferta   
                   AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle   
                   AND POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle   
            LEFT JOIN Petrovendor.dbo.S_Proveedor AS PV   
                ON PV.IdProveedor = PO.IdSubcontratista   
            LEFT JOIN Petrovendor.dbo.TA_Operacion AS O   
                ON O.IdDocumento = P.IdSolicitudPedido   
                   AND P.Version = O.NoVersion   
            LEFT JOIN Petrovendor.dbo.TA_TipoOperacion AS TTO   
                ON TTO.IdTipoOperacion = O.IdTipoOperacion   
            LEFT JOIN Petrovendor.dbo.TA_Estatus AS E   
                ON E.IdEstatus = O.IdEstatusOperacion   
            LEFT JOIN Adinco.dbo.CO_Contrato c   
                ON c.IdContrato = P.IdContrato   
            INNER JOIN Adinco.dbo.CO_Contratista ctista   
                ON ctista.IdContratista = c.IdContratista   
            INNER JOIN Petrovendor.dbo.PV_TipoMoneda AS Mon   
                ON P.IdMoneda = Mon.IdMoneda   
            LEFT JOIN Petrovendor.dbo.PV_RelacionProveedorSubcotratista AS RE   
                ON RE.IdProveedor = solPed.IdProveedor   
                   AND RE.IdSubcontratista = P.IdSubcontratista   
            LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP   
				ON	PSS.IdTipoPedido	=	TP.IdTipoPedido
        WHERE O.IdTipoOperacion = 9   
              AND E.IdEstatus = 1   
              AND c.IdContrato = @IdContrato   
              AND ISNULL(solPed.IdEstatusEliminado, 0) = 0   
              AND ISNULL(P.IdEstatusEliminado, 0) = 0   
              AND POD.IdPeticionOfertaDetalle IS NOT NULL -- para que no se repita que solo se ligue a los que cotizaron       
              AND CONVERT(DATE, dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra))   
              BETWEEN CONVERT(DATE, @Fechainicio) AND CONVERT(DATE, @FechaFin)   
              AND NOT EXISTS   
        (   SELECT 1   
            FROM SC_SubContrato sc   
            WHERE sc.IdPedido = P.IdPedido   
                  AND sc.IsActivo = 1)   
              AND UPPER(LTRIM(RTRIM(AXP.Estatus))) = UPPER('Orden abierta')   
        GROUP BY RE.IdRelacion,   
                 PV.RazonSocial,   
                 PV.RegimenCapital,   
                 TP.TipoPedido,   
                 solPed.MotivoUrgencia,   
                 c.NumeroContrato,   
                 solPed.FechaEntregaFinRequerida,   
                 solPed.FechaEntregaRequerida,   
                 PO.FechaFinalizado,   
                 c.DescripcionContrato,   
                 Mon.IdMoneda,   
                 solPed.IdSolicitudPedido,   
                 P.IdPedido,   
                 PSS.IdPedido,   
                 ctista.RazonSocial,   
                 c.FechaFirma,   
                 AXP.FechaRegistroCompra,   
                 AXP.NoOrden,   
                 AXP.FechaEntrega   
        ORDER BY PSS.IdPedido ASC;   
   
   
        -- AQUI SE AGREGAN LOS PEDIDOS QUE NO ESTAN EN EL LAYOUT DE AX_LAYOUT       
        INSERT INTO @Tabla   
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
        SELECT c.NumeroContrato,   
               CASE   
                   WHEN RE.IdRelacion IS NOT NULL THEN   
                       'SI'   
					ELSE   
                       'NO'   
               END AS RelacionOperadoraProveedor,   
               UPPER(PV.RazonSocial) + ' ' + ISNULL(UPPER(PV.RegimenCapital), '') AS Proveedor,   
               CASE   
                   WHEN TP.TipoPedido = 'Mercadeo' THEN   
                       'TRES COTIZACIONES'   
                   ELSE   
                       UPPER(TP.TipoPedido)   
               END AS MecanismoContratacion,   
               solPed.MotivoUrgencia AS 'Nombre Contrato C-P',   
               UPPER(PSS.IdPedido) AS 'No. Contrato',                                  --> NUMERO DE PEDIDO DE AX        
               CONVERT(VARCHAR(10), O.FechaRegistro, 105) AS 'Fecha Inicio Contrato',  --> FECHA DE CREACIÓN DEL PEDIDO EN AX       
               CONVERT(VARCHAR(10), O.FechaRegistro, 105) AS 'Fecha Termino Contrato', --> FECHA DE LA PRIMERA ACEPTACIÓN DE PEDIDO DE AX        
               CONVERT(VARCHAR(10), O.FechaRegistro, 105) AS 'Vigencia del contrato',                                         --> DIFERENCIA PARA OBTENER LA VIGENCIA DEL CONTRATO       
               solPed.MotivoUrgencia AS 'Objeto del contrato',   
               CASE   
                   WHEN Mon.IdMoneda = 1          
               THEN   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       SUM(PD.Subtotal), CAST(O.FechaRegistro AS DATE))
                   WHEN Mon.IdMoneda = 2        
               THEN   
					   SUM(PD.Subtotal) 
                   ELSE   
					   0
               END AS MontoUSD,   
               CASE   
                   WHEN Mon.IdMoneda = 2         
               THEN   
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       SUM(PD.Subtotal), CAST(O.FechaRegistro AS DATE))
                   WHEN Mon.IdMoneda = 1          
               THEN   
                    (DBO.fn_ObtenSubtotalPedido(Mon.IdMoneda,P.IdPedido,@IdContrato))
                   ELSE 0
               END AS MontoMXN,   
               Petrovendor.dbo.FN_ValorTipoCambioIterativo(CAST(O.FechaRegistro AS DATE)) AS TipoCambio,   
               CONVERT(VARCHAR(10), O.FechaRegistro, 105) AS FechaTipoCambio,   
               solPed.MotivoUrgencia AS 'Comentarios',   
               NombreContratista = UPPER(ctista.RazonSocial),   
               FechaEfectiva = CONVERT(VARCHAR, c.FechaFirma, 103)                     --DWONG 20190712       
        FROM Petrovendor.dbo.MM_Pedido p   
			LEFT JOIN #AX_Layout	AXP
                ON CAST(AXP.NoPedidoADINCO AS NVARCHAR(MAX)) = CAST(p.IdPedido AS NVARCHAR(MAX))   
				AND LTRIM(RTRIM(AXP.Empresa))	=	@Bloque
				AND ISNULL(P.IdEstatusEliminado,0) = 0
            LEFT JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD   
                ON PD.IdPedido = p.IdPedido   
            LEFT JOIN Petrovendor.dbo.MM_Pedidos PSS   
                ON p.IdPedido = PSS.IdIdentificador   
                   AND PSS.IdProveedorCliente = p.IdProveedorCompras   
            INNER JOIN Petrovendor.dbo.AX_ComparativaEmpresa emp   
                ON emp.IdProveedor = PSS.IdProveedorCliente   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido solPed   
                ON solPed.IdSolicitudPedido = p.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle SPD   
                ON solPed.IdSolicitudPedido = SPD.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL   
                ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle   
            LEFT JOIN Petrovendor.dbo.MM_PeticionOferta AS PO   
                ON PO.IdPeticionOferta = p.IdPeticionOferta   
                   AND PO.IdSolicitudPedido = solPed.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle POD   
                ON POD.IdPeticionOferta = PO.IdPeticionOferta   
                   AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle   
         AND POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle   
            LEFT JOIN Petrovendor.dbo.S_Proveedor AS PV   
                ON PV.IdProveedor = PO.IdSubcontratista   
            LEFT JOIN Petrovendor.dbo.TA_Operacion AS O   
                ON O.IdDocumento = p.IdSolicitudPedido   
                   AND p.Version = O.NoVersion   
            LEFT JOIN Petrovendor.dbo.TA_TipoOperacion AS TTO   
                ON TTO.IdTipoOperacion = O.IdTipoOperacion   
            LEFT JOIN Petrovendor.dbo.TA_Estatus AS E   
                ON E.IdEstatus = O.IdEstatusOperacion   
            LEFT JOIN Adinco.dbo.CO_Contrato c   
                ON c.IdContrato = p.IdContrato   
            INNER JOIN Adinco.dbo.CO_Contratista ctista   
                ON ctista.IdContratista = c.IdContratista   
            INNER JOIN Petrovendor.dbo.PV_TipoMoneda AS Mon   
                ON p.IdMoneda = Mon.IdMoneda   
            LEFT JOIN Petrovendor.dbo.PV_RelacionProveedorSubcotratista AS RE   
                ON RE.IdProveedor = solPed.IdProveedor   
                   AND RE.IdSubcontratista = p.IdSubcontratista   
      LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP   
                --ON TP.IdTipoPedido = PO.IdTipoProceso
				ON	PSS.IdTipoPedido	=	TP.IdTipoPedido
        WHERE O.IdTipoOperacion = 9   
              AND E.IdEstatus = 2   
              AND c.IdContrato = @IdContrato   
              AND ISNULL(solPed.IdEstatusEliminado, 0) = 0   
              AND ISNULL(p.IdEstatusEliminado, 0) = 0   
              AND POD.IdPeticionOfertaDetalle IS NOT NULL -- para que no se repita que solo se ligue a los que cotizaron       
              AND O.FechaRegistro   
              BETWEEN CONVERT(DATE, @Fechainicio) AND CONVERT(DATE, @FechaFin)   
              AND AXP.IdLayoutAX IS NULL -- esto para descartar las que estan registrados en AX_LAYOUT       
              AND NOT EXISTS   
        (   SELECT 1   
            FROM SC_SubContrato sc   
            WHERE sc.IdPedido = p.IdPedido   
                  AND sc.IsActivo = 1)   
        GROUP BY RE.IdRelacion,   
                 PV.RazonSocial,   
                 PV.RegimenCapital,   
                 TP.TipoPedido,   
                 solPed.MotivoUrgencia,   
                 c.NumeroContrato,   
                 solPed.FechaEntregaFinRequerida,   
                 solPed.FechaEntregaRequerida,   
                 PO.FechaFinalizado,   
                 c.DescripcionContrato,   
                 Mon.IdMoneda,   
                 solPed.IdSolicitudPedido,   
                 p.IdPedido,   
                 PSS.IdPedido,   
                 ctista.RazonSocial,   
                 c.FechaFirma,   
                 O.FechaRegistro   
        ORDER BY PSS.IdPedido ASC   
   
   
   
   
        SELECT NumeroContrato,   
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
        FROM @Tabla   
        ORDER BY [No. Contrato] DESC         
    END;   
   
    ---- VALIDAR SI EL PROVEEDOR ES DEA  
    ELSE IF exists(select 1 from CO_contrato where IdContratista in (10013,10060) AND IdContrato = @IdContrato) --DEA 	
    BEGIN      
		
		--->	OBTENER SUBTOTALES DE WDEA_PurchasingDocumentsImportados POR PEDIDOS
		INSERT INTO @TablaWDEA_PurchasingDocumentsImportados(
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
		P.IdPedido,
		PDI.PURCHASING_DOCUMENT,			
		PDI.NET_ORDER_VALUE,
		PDI.CURRENCY,
		SUM(PDI.NET_PRICE) AS SUM_NET_PRICE,
		PDI.IDMONEDA,			
		PDI.OUTLINE_AGREEMENT,
		CONDEA.NumeroContrato,
		PDI.MECANISMO_CONTRATACION
		FROM Petrovendor.dbo.MM_Pedido AS P (NOLOCK)			
			JOIN Petrovendor.dbo.WDEA_PurchasingDocumentsImportados AS PDI (NOLOCK) 
				ON P.IdPedido = PDI.IdPedidoADINCO
				AND ISNULL(P.IdEstatusEliminado,0) = 0
				AND P.IdContrato = @IdContrato	
			JOIN Adinco.dbo.CO_Contrato AS CONDEA (NOLOCK)
				ON  P.IdContrato = CONDEA.IdContrato
		WHERE CONVERT(VARCHAR, P.CreadoEl, 112)   
              BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112) 
		GROUP BY
		P.IdPedido,
		PDI.PURCHASING_DOCUMENT,				
		PDI.NET_ORDER_VALUE,
		PDI.CURRENCY,
		PDI.NET_ORDER_VALUE,
		PDI.IDMONEDA,				
		PDI.OUTLINE_AGREEMENT,
		CONDEA.NumeroContrato,
		PDI.MECANISMO_CONTRATACION

		--> OBTENER SUBTOTALES DE PEDIDOS DETALLE AGRUPADO POR PEDIDO 
		INSERT INTO @MM_PedidoDetalle(IdPedido, SUM_Subtotal)
		SELECT 
		P.IdPedido,
		SUM(PD.Subtotal)
		FROM Petrovendor.dbo.MM_Pedido AS P (NOLOCK)
		JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD (NOLOCK) 
			ON P.IdPedido = PD.IdPedido
			AND P.IdContrato = @IdContrato
		WHERE CONVERT(VARCHAR, P.CreadoEl, 112)   
		BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112)	
		GROUP BY 
		P.IdPedido


        INSERT INTO @TablaDEA   
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
            NombreContratista,  -- 
            FechaEfectiva   --
        )
		SELECT
			ISNULL(PDI.NumeroContrato,CON.NumeroContrato) AS NumeroContrato,
			CASE 
				WHEN PROSAP.IdProveedor IS NOT NULL THEN 'SI'
				ELSE 'NO'
			END AS RelacionOperadoraProveedor,
			PRO.RazonSocial AS Proveedor,
			CASE WHEN PDI.MECANISMO_CONTRATACION ='L' THEN 
				'Licitación' --> CTE SE PONE COMO DEFAULT YA QUE LOS PEDIDOS DE LICITACIÓN SE AGREGAN COMO MERCADEO
			ELSE 
				TP.TipoPedido 
			END AS MecanismoContratacion,			
			SP.MotivoUrgencia AS NombreContratoCP,
			ISNULL(PDI.PURCHASING_DOCUMENT,PS.IdPedido) AS NoContratoCP,
			SP.FechaEntregaRequerida AS FechaInicio,
			ISNULL(SP.FechaEntregaFinRequerida, SP.FechaEntregaRequerida) AS FechaFin,
			ISNULL(SP.FechaEntregaFinRequerida, SP.FechaEntregaRequerida) AS FechaVigencia,
			SP.MotivoUrgencia AS ObjetoContrato,
			CASE
				WHEN PDI.IdPedidoADINCO IS NOT NULL AND ISNULL(PDI.NET_ORDER_VALUE,0) > 0 AND PDI.CURRENCY = 'USD' THEN PDI.NET_ORDER_VALUE
				WHEN PDI.IdPedidoADINCO IS NOT NULL AND ISNULL(PDI.NET_ORDER_VALUE,0) = 0 AND PDI.CURRENCY = 'USD' THEN
						CASE		--PESO
							WHEN PDI.IDMONEDA = 1 THEN 
							Petrovendor.dbo.FN_PesosDolaresTipoCambio(PDI.SUM_NET_PRICE,SP.FechaEntregaRequerida)
							ELSE 
							PDI.SUM_NET_PRICE
						END
				ELSE 
					CASE 
						WHEN P.IdMoneda = 1 THEN 
						Petrovendor.dbo.FN_PesosDolaresTipoCambio(PD.SUM_Subtotal,ISNULL(P.FechaRecepcionServicio,P.CreadoEl))
						ELSE 
						PD.SUM_Subtotal
				END
			END AS MontoUSD,
			CASE
				WHEN PDI.IdPedidoADINCO IS NOT NULL AND ISNULL(PDI.NET_ORDER_VALUE,0) > 0 AND PDI.CURRENCY = 'MXN' THEN PDI.NET_ORDER_VALUE
				WHEN PDI.IdPedidoADINCO IS NOT NULL AND ISNULL(PDI.NET_ORDER_VALUE,0) = 0 AND PDI.CURRENCY = 'MXN' THEN
														CASE		--DOLAR
															WHEN PDI.IDMONEDA = 2 THEN 
															Petrovendor.dbo.Fn_dolarespesostipocambio(PDI.SUM_NET_PRICE,SP.FechaEntregaRequerida)
															ELSE 
															PDI.SUM_NET_PRICE
														END
				ELSE 
					CASE 
						WHEN 
						P.IdMoneda = 2 THEN 
						Petrovendor.dbo.Fn_dolarespesostipocambio(PD.SUM_Subtotal,ISNULL(P.FechaRecepcionServicio,P.CreadoEl))
						ELSE PD.SUM_Subtotal
				END
			END AS MontoMXN,
			Petrovendor.dbo.FN_ValorTipoCambio(SP.FechaEntregaRequerida) AS TipoCambio,
			SP.FechaEntregaRequerida AS FechaTipoCambio,
			PDI.OUTLINE_AGREEMENT,
			CT.RazonSocial,
			CONVERT(VARCHAR, CON.FechaFirma, 103) AS FechaEfectiva 
		FROM Petrovendor.dbo.MM_Pedido AS P (NOLOCK)
			JOIN Adinco.dbo.CO_Contrato AS CON (NOLOCK)
				ON P.IdContrato = CON.IdContrato
				AND ISNULL(P.IdEstatusEliminado,0) = 0
				AND P.IdContrato = @IdContrato
			JOIN @MM_PedidoDetalle AS PD 
				ON P.IdPedido = PD.IdPedido
			JOIN Petrovendor.dbo.MM_SolicitudPedido AS SP (NOLOCK) 
				ON P.IdSolicitudPedido = SP.IdSolicitudPedido 
				AND SP.Activo = 1			
			JOIN Petrovendor.dbo.S_Proveedor AS PRO  (NOLOCK)
				ON P.IdSubcontratista = PRO.IdProveedor			
			JOIN Petrovendor.dbo.MM_Pedidos AS PS (NOLOCK)
				ON P.IdPedido = PS.IdIdentificador 
				AND PS.IdProveedorCliente = P.IdProveedorCompras
			JOIN Petrovendor.dbo.PV_TipoMoneda AS M (NOLOCK)
				ON P.IdMoneda = M.IdMoneda			
			JOIN Petrovendor.dbo.MM_TipoPedido AS TP (NOLOCK)
				ON PS.IdTipoPedido = TP.IdTipoPedido			
				AND PS.IdTipoPedido NOT IN (6)			
			JOIN Adinco.dbo.CO_Contratista AS CT (NOLOCK)
				ON CON.IdContratista = CT.IdContratista
			LEFT JOIN Petrovendor.dbo.DEA_ProveedorDescripcionSAP AS PROSAP (NOLOCK)
				ON P.IdSubContratista = PROSAP.IdProveedor
			LEFT JOIN @TablaWDEA_PurchasingDocumentsImportados AS PDI 
				ON P.IdPedido = PDI.IdPedidoADINCO			
		WHERE CONVERT(VARCHAR, P.CreadoEl, 112)   
              BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112)
			GROUP BY CON.NumeroContrato,
				PROSAP.IdProveedor,
				PRO.RazonSocial,
				SP.MotivoUrgencia,
				PDI.PURCHASING_DOCUMENT,
				SP.FechaEntregaFinRequerida,
				SP.MotivoUrgencia,
				PDI.IdPedidoADINCO,
				PDI.IDMONEDA,
				P.FechaRecepcionServicio,
				SP.FechaEntregaRequerida,
				PDI.OUTLINE_AGREEMENT,
				PS.IdPedido,
				P.IdMoneda,
				P.CreadoEl,
				TP.TipoPedido,
				CT.RazonSocial,
				CON.FechaFirma,
				P.IdPedido,
				PDI.MECANISMO_CONTRATACION,
				PDI.NumeroContrato,
				PDI.CURRENCY,
				PDI.NET_ORDER_VALUE,
				PDI.NumeroContrato,
				PDI.SUM_NET_PRICE,
				PD.SUM_Subtotal;
   
   
        INSERT INTO @TablaDEA   
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
			CON.NumeroContrato,
			CASE 
				WHEN PROSAP.IdProveedor IS NOT NULL THEN 'SI'
				ELSE 'NO'
			END AS RelacionOperadoraProveedor,
			SUB.RazonSocial AS Proveedor,
			'Licitación' AS MecanismoContratacion,
			SC.Objeto AS NombreContratoCP,
			SC.NumeroSubContrato AS NoContratoCP,
			ISNULL(SC.FechaInicio,SC.CreadoEl) AS FechaInicio,
			ISNULL(ISNULL(SC.FechaFin,SC.FechaInicio),SC.CreadoEl) AS FechaFin,
			ISNULL(ISNULL(SC.FechaFin,SC.FechaInicio),SC.CreadoEl) AS FechaVigencia,
			SC.Objeto AS ObjetoContrato,
			CASE
				WHEN SC.IdMoneda = 1 THEN
				Petrovendor.dbo.FN_PesosDolaresTipoCambio(SUM(SCM.Importe),ISNULL(SC.FechaInicio,SC.CreadoEl))
				ELSE 
				SUM(SCM.Importe)				
			END AS MontoUSD,
			CASE
				WHEN SC.IdMoneda = 2 THEN 
				Petrovendor.dbo.Fn_dolarespesostipocambio(SUM(SCM.Importe),ISNULL(SC.FechaInicio,SC.CreadoEl))
				ELSE 
				SUM(SCM.Importe)				
			END AS MontoMXN,
			Petrovendor.dbo.FN_ValorTipoCambio(ISNULL(SC.FechaInicio,SC.CreadoEl)) AS TipoCambio,
			ISNULL(SC.FechaInicio,SC.CreadoEl) AS FechaTipoCambio,
			'ESTIMACION COMPLETA PARA OT',
			CT.RazonSocial,
			CONVERT(VARCHAR, CON.FechaFirma, 103) AS FechaEfectiva 
		FROM Adinco.dbo.SC_SubContrato AS SC (NOLOCK)
		JOIN Adinco.dbo.CO_Contrato AS CON (NOLOCK)
			ON SC.IdContrato = CON.IdContrato AND SC.IdContrato = @IDCONTRATO
		LEFT JOIN Adinco.dbo.PV_Subcontratista AS SUB (NOLOCK)
			ON SC.IdSubContratista = SUB.IdSubcontratista
		LEFT JOIN Petrovendor.dbo.S_Proveedor AS PROP (NOLOCK)
			ON SUB.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = PROP.RFC
		LEFT JOIN Petrovendor.dbo.DEA_ProveedorDescripcionSAP AS PROSAP (NOLOCK)
			ON PROP.IdProveedor = PROSAP.IdProveedor	
		LEFT JOIN Adinco.dbo.SC_Materiales AS SCM (NOLOCK)
			ON SC.IdSubContrato = SCM.IdSubContrato
		JOIN Adinco.dbo.CO_Contratista AS CT (NOLOCK)
				ON CON.IdContratista = CT.IdContratista
		WHERE  CONVERT(VARCHAR, SC.CreadoEl, 112)   
              BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112)
			and SC.IsActivo= 1			
		GROUP BY  CON.NumeroContrato,
				PROSAP.IdProveedor,
				SUB.RazonSocial,
				SC.Objeto,
				SC.IdPedido,
				SC.FechaInicio,
				SC.FechaFin,
				SC.IdMoneda,
				SC.FechaInicio,
				SC.NumeroSubContrato,
				SC.CreadoEl,
				CT.RazonSocial,
				CON.FechaFirma;
   
   
        SELECT NumeroContrato,   
               RelacionOperadoraProveedor,   
               Proveedor,   
               MecanismoContratacion,   
               [Nombre Contrato C-P],   
               [No. Contrato], 
			   CONVERT(VARCHAR(10),[Fecha Inicio Contrato], 105),
			   CONVERT(VARCHAR(10),[Fecha Termino Contrato], 105),
			   CONVERT(VARCHAR(10),[Vigencia del contrato], 105),
               [Objeto del contrato],   
               FORMAT(SUM(MontoUSD), '#,#0.000') AS MontoUSD,   
               FORMAT(SUM(MontoMXN), '#,#0.000') AS MontoMXN,   
               TipoCambio,   
               CONVERT(VARCHAR(10), FechaTipoCambio, 105),   
               Comentarios,   
               NombreContratista,   
               FechaEfectiva
        FROM @TablaDEA   
		GROUP BY NumeroContrato,   
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
        ORDER BY [No. Contrato];   
    END   
    --- FIN VALIDACION DEA   
    ELSE   
    BEGIN   
        INSERT INTO @Tabla   
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
        SELECT C.NumeroContrato,   
               CASE   
			   WHEN RE.IdRelacion IS NOT NULL THEN   
                       'SI'   
                   ELSE   
                       'NO'   
               END AS RelacionOperadoraProveedor,   
               UPPER(P.RazonSocial) + ' ' + ISNULL(UPPER(P.RegimenCapital), '') AS Proveedor,   
               'ADJUDICACIÓN DIRECTA' AS MecanismoContratacion,   
               UPPER(ISNULL(TAO.Descripcion, '')) AS 'Nombre Contrato C-P',   
               UPPER(CONCAT(PG.IdPedido, ' CD')) AS 'No. Contrato',   
				CASE   
                   WHEN CONVERT(VARCHAR(10), TAO.FechaRegistro, 105) IS NULL THEN   
                       '-'   
                   ELSE   
                       CONVERT(VARCHAR(10), TAO.FechaRegistro, 105)   
               END AS 'Fecha Inicio Contrato',   
               CASE   
                   WHEN CONVERT(VARCHAR(10), TAO.FechaRegistro, 105) IS NULL THEN   
                       '-'   
                   ELSE   
                       CONVERT(VARCHAR(10), TAO.FechaRegistro, 105)   
               END AS 'Fecha Termino Contrato',   
                CASE   
                   WHEN CONVERT(VARCHAR(10), TAO.FechaRegistro, 105) IS NULL THEN   
                       '-'   
                   ELSE   
                       CONVERT(VARCHAR(10), TAO.FechaRegistro, 105)   
               END AS 'Vigencia del contrato',   
               UPPER(ISNULL(TAO.Descripcion, '')) AS 'Objeto del contrato',   
               CASE   
                   WHEN fiFact.IdMoneda = 1 THEN   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       fiFact.SubTotal, CAST(fiFact.FechaTimbrado AS DATE)) 
                   ELSE   
					   fiFact.SubTotal  
               END AS MontoUSD,   
               CASE   
                   WHEN fiFact.IdMoneda = 2 THEN   
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       fiFact.SubTotal, CAST(fiFact.FechaTimbrado AS DATE))
                   ELSE   
					   fiFact.SubTotal
               END AS MontoMXN,
               Petrovendor.dbo.FN_ValorTipoCambio(CAST(fiFact.FechaTimbrado AS DATE)) AS TipoCambio, 
               CONVERT(VARCHAR, fiFact.FechaTimbrado, 103) AS FechaTipoCambio,   
               UPPER(ISNULL(TAO.Descripcion, '')) AS 'Comentarios',   
               UPPER(ctista.RazonSocial) AS NombreContratista,   
               CONVERT(VARCHAR, c.FechaFirma, 103) AS FechaEfectiva   
        FROM Petrovendor.dbo.CO_Registro AS coRegistro   
            LEFT JOIN Petrovendor.dbo.FI_Factura AS fiFact   
                ON coRegistro.IdFactura = fiFact.IdFactura   
            LEFT JOIN Petrovendor.dbo.TA_Operacion AS TAO   
                ON TAO.IdDocumento = coRegistro.IdFactura   
            LEFT JOIN Petrovendor.dbo.TA_Estatus AS TE   
                ON TE.IdEstatus = TAO.IdEstatusOperacion   
            LEFT JOIN Petrovendor.dbo.CC_CentroCosto centroCosto   
                ON centroCosto.IdCentroCosto = coRegistro.CentroCostos   
            LEFT JOIN Petrovendor.dbo.DG_CuentaContable cuentaContable   
                ON cuentaContable.Id = coRegistro.CuentaContable   
            LEFT JOIN Petrovendor.dbo.CO_CatalogoCuentaSH cuentaSh   
                ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH   
            LEFT JOIN Petrovendor.dbo.CO_Instalacion instalacion   
                ON instalacion.IdInstalacion = coRegistro.IdInstalacion   
            LEFT JOIN Petrovendor.dbo.MM_Pedidos PG   
                ON PG.IdIdentificador = fiFact.IdFactura   
                   AND PG.IdTipoPedido = 1   
                   AND TAO.IdProveedor = PG.IdProveedorCliente   
            LEFT JOIN Petrovendor.dbo.S_Proveedor AS P   
                ON P.RFC = fiFact.Emisor   
            LEFT JOIN Adinco.dbo.CO_Contrato AS C   
                ON fiFact.IdContrato = C.IdContrato   
            LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC   
                ON C.IdAreaContractual = AC.IdAreaContractual   
            LEFT JOIN Petrovendor.dbo.PV_RelacionProveedorSubcotratista AS RE   
                ON RE.IdProveedor = P.IdProveedor   
                   AND RE.IdSubcontratista = P.IdProveedor   
            INNER JOIN Adinco.dbo.CO_Contratista ctista   
                ON ctista.IdContratista = C.IdContratista   
        WHERE TAO.IdTipoOperacion = 14   
              AND TE.IdEstatus = 2   
              AND ISNULL(fiFact.IsEliminado, 0) = 0   
              AND C.IdContrato = @IdContrato   
              AND CONVERT(VARCHAR, TAO.FechaRegistro, 112)   
              BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112);   
   
   
        INSERT INTO @Tabla   
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
        SELECT CONCAT(c.NumeroContrato, '(', periodo.NombrePeriodo, ')'),   
               CASE   
                   WHEN RE.IdRelacion IS NOT NULL THEN   
						'SI'   
                   ELSE   
                       'NO'   
               END AS RelacionOperadoraProveedor,   
               UPPER(PV.RazonSocial) + ' ' + ISNULL(UPPER(PV.RegimenCapital), '') AS Proveedor,   
               CASE   
                   WHEN TP.TipoPedido = 'Mercadeo' THEN   
                       'TRES COTIZACIONES'   
                ELSE   
                       UPPER(TP.TipoPedido)   
               END AS MecanismoContratacion,   
               UPPER(solPed.MotivoUrgencia) AS 'Nombre Contrato C-P',   
               PSS.IdPedido AS 'No. Contrato',   
               CONVERT(VARCHAR(10),isnull(P.FechaRecepcionServicio,solPed.FechaEntregaRequerida), 105) AS 'Fecha Inicio Contrato',   
               CONVERT(VARCHAR(10), isnull(P.FechaRecepcionServicio,solPed.FechaEntregaRequerida), 105) AS 'Fecha Termino Contrato',   
               CONVERT(VARCHAR(10),isnull(P.FechaRecepcionServicio,solPed.FechaEntregaRequerida), 105) AS 'Vigencia del contrato',   
               UPPER(solPed.MotivoUrgencia) AS 'Objeto del contrato',   
               CASE   
                   WHEN Mon.IdMoneda = 1 THEN   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       SUM(PD.Subtotal), CAST(ISNULL(solPed.FechaEntregaRequerida, PO.FechaFinalizado) AS DATE)) 
                   ELSE   
					   SUM(PD.Subtotal) 
               END AS MontoUSD,   
               CASE   
                   WHEN Mon.IdMoneda = 2 THEN  
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       SUM(PD.Subtotal), ISNULL(solPed.FechaEntregaRequerida, PO.FechaFinalizado))  
                   ELSE   
					   SUM(PD.Subtotal) 
               END AS MontoMXN,   
               Petrovendor.dbo.FN_ValorTipoCambio(   
               CAST(ISNULL(solPed.FechaEntregaRequerida, PO.FechaFinalizado) AS DATE)) AS TipoCambio,   
               CONVERT(VARCHAR, ISNULL(solPed.FechaEntregaRequerida, PO.FechaFinalizado), 103) AS FechaTipoCambio, --DWONG 20190712     
   
               UPPER(solPed.MotivoUrgencia) AS 'Comentarios',   
               NombreContratista = UPPER(ctista.RazonSocial),                                                      --DWONG 20190712     
   
               FechaEfectiva = CONVERT(VARCHAR, c.FechaFirma, 103)                                                 --DWONG 20190712     
   
        FROM Petrovendor.dbo.MM_Pedido AS P   
            LEFT JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD   
                ON PD.IdPedido = P.IdPedido   
				AND ISNULL(P.IdEstatusEliminado,0) = 0
            LEFT JOIN Petrovendor.dbo.MM_Pedidos PSS   
                ON P.IdPedido = PSS.IdIdentificador   
                   AND PSS.IdProveedorCliente = P.IdProveedorCompras   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido solPed   
                ON solPed.IdSolicitudPedido = P.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle SPD   
                ON solPed.IdSolicitudPedido = SPD.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL   
                ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle   
            LEFT JOIN Petrovendor.dbo.MM_PeticionOferta AS PO   
                ON PO.IdPeticionOferta = P.IdPeticionOferta   
                   AND PO.IdSolicitudPedido = solPed.IdSolicitudPedido   
            LEFT JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle POD   
                ON POD.IdPeticionOferta = PO.IdPeticionOferta   
                   AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle   
                   AND POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle   
            LEFT JOIN Petrovendor.dbo.S_Proveedor AS PV   
                ON PV.IdProveedor = PO.IdSubcontratista   
            LEFT JOIN Petrovendor.dbo.TA_Operacion AS O   
                ON O.IdDocumento = P.IdSolicitudPedido   
                   AND P.Version = O.NoVersion   
            LEFT JOIN Petrovendor.dbo.TA_TipoOperacion AS TTO   
                ON TTO.IdTipoOperacion = O.IdTipoOperacion   
            LEFT JOIN Petrovendor.dbo.TA_Estatus AS E   
                ON E.IdEstatus = O.IdEstatusOperacion   
			LEFT JOIN Adinco.dbo.CO_Contrato c   
                ON c.IdContrato = P.IdContrato   
            INNER JOIN Adinco.dbo.CO_Contratista ctista   
                ON ctista.IdContratista = c.IdContratista   
            INNER JOIN Petrovendor.dbo.PV_TipoMoneda AS Mon   
                ON P.IdMoneda = Mon.IdMoneda   
            LEFT JOIN Petrovendor.dbo.PV_RelacionProveedorSubcotratista AS RE   
                ON RE.IdProveedor = solPed.IdProveedor   
                   AND RE.IdSubcontratista = P.IdSubcontratista   
            LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP   
				/*SI ES CÁRDENAS MORA TOMAR IdTipoProceso de MM_SolicitudPedido*/ 
                ON TP.IdTipoPedido = (CASE WHEN C.IdContratista IN (10010 ) then solPed.IdTipoProceso else  PO.IdTipoProceso END ) 
			LEFT JOIN Adinco.dbo.CO_PeriodoContrato periodo   
                ON periodo.IdPeriodo = solPed.IdPeriodo   
        WHERE O.IdTipoOperacion = 9   
              AND E.IdEstatus = 2   
              AND c.IdContrato = @IdContrato   
              AND ISNULL(solPed.IdEstatusEliminado, 0) = 0   
              AND ISNULL(P.IdEstatusEliminado, 0 ) = 0   
              AND POD.IdPeticionOfertaDetalle IS NOT NULL -- para que no se repita que solo se ligue a los que cotizaron     
   
              AND P.FechaEnvioPedido   
              BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112) --Evitar mostrar pedidos que ya tengan un subcontrato asignado     
   
              AND NOT EXISTS   
        (   SELECT 1   
            FROM SC_SubContrato sc   
            WHERE sc.IdPedido = P.IdPedido   
                  AND sc.IsActivo = 1)   
        GROUP BY RE.IdRelacion,   
                 PV.RazonSocial,   
                 PV.RegimenCapital,   
                 TP.TipoPedido,   
                 solPed.MotivoUrgencia,   
                 c.NumeroContrato,   
                 solPed.FechaEntregaFinRequerida,   
                 solPed.FechaEntregaRequerida,   
                 PO.FechaFinalizado,   
                 c.DescripcionContrato,   
                 Mon.IdMoneda,   
                 solPed.IdSolicitudPedido,   
                 P.IdPedido,   
                 PSS.IdPedido,   
                 ctista.RazonSocial,   
                 c.FechaFirma,   
                 periodo.NombrePeriodo,   
                 P.FechaRecepcionServicio   
        ORDER BY PSS.IdPedido ASC;   
   
   
        SELECT NumeroContrato,   
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
        FROM @Tabla   
		GROUP BY NumeroContrato,   
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
        ORDER BY [No. Contrato];   
   
    END;   
END;
