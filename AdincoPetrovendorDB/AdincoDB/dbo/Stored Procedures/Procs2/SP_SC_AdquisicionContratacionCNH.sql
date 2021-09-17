USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_SC_AdquisicionContratacionCNH]    Script Date: 17/09/2021 10:20:28 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_SC_AdquisicionContratacionCNH] 
@IdContrato INT, 
@Fechainicio DATE, 
@FechaFin DATE 
AS 
BEGIN 
   
    --- VALIDAR SI EL CONTRATO ES DE CARSO, EJECUTAR SP DE SP_SC_AdquisicionContratacionCNH_Carso         
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
        MontoUSD NVARCHAR(MAX),   
        MontoMXN NVARCHAR(MAX),   
        TipoCambio NVARCHAR(MAX),   
        FechaTipoCambio NVARCHAR(MAX),   
        Comentarios NVARCHAR(MAX),   
        NombreContratista NVARCHAR(MAX),   
        FechaEfectiva NVARCHAR(10)   
    );   
   
   
    DECLARE @SolpedConMateriales TABLE (IdSolicitudPedido INT);   
   
    ---AGREGAR LOS CONTRATOS QUE ESTAN INCLUIDOS EN EL REPORTE DE CARSO --         
    --##EDITAR ID'S DE CONTRATOS##         
    IF ISNULL(@IdContrato, 0) IN ( 10047, 10048 )   
    BEGIN   
	 
        INSERT INTO @SolpedConMateriales (IdSolicitudPedido)   
        SELECT sp.IdSolicitudPedido   
        FROM Petrovendor.dbo.MM_SolicitudPedido sp   
            INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd   
                ON sp.IdSolicitudPedido = spd.IdSolicitudPedido   
            INNER JOIN Petrovendor.dbo.MM_Material m   
                ON spd.IdMaterial = m.IdMaterial   
        WHERE sp.IdContrato = @IdContrato   
              AND ISNULL(sp.IdEstatusEliminado, 0) = 0   
        GROUP BY sp.IdSolicitudPedido;   
   
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
                       FORMAT(   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       fiFact.SubTotal, CAST(fiFact.FechaTimbrado AS DATE)),   
                       '#,#0.000')   
                   ELSE   
                       FORMAT(fiFact.SubTotal, '#,#0.000')   
     END AS MontoUSD,   
               CASE   
                   WHEN fiFact.IdMoneda = 2 THEN   
                       FORMAT(   
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       fiFact.SubTotal, CAST(fiFact.FechaTimbrado AS DATE)),   
                       '#,#0.000')   
                   ELSE   
                       FORMAT(fiFact.SubTotal, '#,#0.000')   
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
                       FORMAT(   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       SUM(PD.Subtotal),   
                       CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) AS DATE)),   
                       '#,#0.000')   
                   WHEN Mon.IdMoneda = 2   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       FORMAT(SUM(PD.Subtotal), '#,#0.000')   
                   ELSE   
                       FORMAT(0, '#,#0.000')   
               END AS MontoUSD,   
               CASE   
                   WHEN Mon.IdMoneda = 2   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       FORMAT(   
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       SUM(PD.Subtotal),   
                       CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) AS DATE)),   
                       '#,#0.000')   
                   WHEN Mon.IdMoneda = 1   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       FORMAT(SUM(PD.Subtotal), '#,#0.000')   
                   ELSE   
                       FORMAT(0, '#,#0.000')   
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
         LEFT JOIN Petrovendor.dbo.AX_Layout AXP   
                ON CAST(AXP.NoPedidoADINCO AS NVARCHAR(MAX)) = CAST(P.IdPedido AS NVARCHAR(MAX))   
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
                ON TP.IdTipoPedido = PO.IdTipoProceso   
            INNER JOIN @SolpedConMateriales filtro   
                ON filtro.IdSolicitudPedido = solPed.IdSolicitudPedido   
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
                       FORMAT(   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       SUM(PD.Subtotal),   
                       CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) AS DATE)),   
                       '#,#0.000')   
                   WHEN Mon.IdMoneda = 2   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       FORMAT(SUM(PD.Subtotal), '#,#0.000')   
                   ELSE   
                       FORMAT(0, '#,#0.000')   
               END AS MontoUSD,   
               CASE   
                   WHEN Mon.IdMoneda = 2   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       FORMAT(   
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       SUM(PD.Subtotal),   
                       CAST(dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) AS DATE)),   
                       '#,#0.000')   
                   WHEN Mon.IdMoneda = 1   
                        AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL THEN   
                       FORMAT(SUM(PD.Subtotal), '#,#0.000')   
                   ELSE   
                       FORMAT(0, '#,#0.000')   
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
            LEFT JOIN Petrovendor.dbo.AX_Layout AXP   
                ON CAST(AXP.NoPedidoADINCO AS NVARCHAR(MAX)) = CAST(P.IdPedido AS NVARCHAR(MAX))   
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
                ON TP.IdTipoPedido = PO.IdTipoProceso   
            INNER JOIN @SolpedConMateriales filtro   
                ON filtro.IdSolicitudPedido = solPed.IdSolicitudPedido   
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
               --AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL        
               THEN   
                       FORMAT(   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       SUM(PD.Subtotal), CAST(O.FechaRegistro AS DATE)),   
                       '#,#0.000')   
                   WHEN Mon.IdMoneda = 2   
        --AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL        
               THEN   
                       FORMAT(SUM(PD.Subtotal), '#,#0.000')   
                   ELSE   
                       FORMAT(0, '#,#0.000')   
               END AS MontoUSD,   
               CASE   
                   WHEN Mon.IdMoneda = 2   
               --AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL        
               THEN   
                       FORMAT(   
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       SUM(PD.Subtotal), CAST(O.FechaRegistro AS DATE)),   
                       '#,#0.000')   
                   WHEN Mon.IdMoneda = 1   
               --AND dbo.fn_SC_AdquisicionFechaNormalizadaCarso(AXP.FechaRegistroCompra) IS NOT NULL        
               THEN   
                       FORMAT(SUM(PD.Subtotal), '#,#0.000')   
                   ELSE   
                       FORMAT(0, '#,#0.000')   
               END AS MontoMXN,   
               Petrovendor.dbo.FN_ValorTipoCambioIterativo(CAST(O.FechaRegistro AS DATE)) AS TipoCambio,   
               CONVERT(VARCHAR(10), O.FechaRegistro, 105) AS FechaTipoCambio,   
               solPed.MotivoUrgencia AS 'Comentarios',   
               NombreContratista = UPPER(ctista.RazonSocial),   
               FechaEfectiva = CONVERT(VARCHAR, c.FechaFirma, 103)                     --DWONG 20190712       
        FROM Petrovendor.dbo.MM_Pedido p   
            LEFT JOIN Petrovendor.dbo.AX_Layout AXP   
                ON CAST(AXP.NoPedidoADINCO AS NVARCHAR(MAX)) = CAST(p.IdPedido AS NVARCHAR(MAX))   
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
                ON TP.IdTipoPedido = PO.IdTipoProceso   
            INNER JOIN @SolpedConMateriales filtro   
                ON filtro.IdSolicitudPedido = solPed.IdSolicitudPedido   
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
   
    --SELECT dbo.fn_SC_AdquisicionFechaNormalizadaCarso(FechaCreacionOCAX)       
    --FROM #AX_Layout       
    END;   
   
    ---- VALIDA SI EL PROVEEDOR ES DEA   
    ELSE IF exists(select 1 from CO_contrato where IdContratista in (10013,10060) AND IdContrato = @IdContrato) --DEA  
    BEGIN   
 
 
  --      INSERT INTO @SolpedConMateriales (IdSolicitudPedido)   
  --      SELECT sp.IdSolicitudPedido   
  --      FROM Petrovendor.dbo.MM_SolicitudPedido sp   
  --          INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd   
  --              ON sp.IdSolicitudPedido = spd.IdSolicitudPedido   
  --          INNER JOIN Petrovendor.dbo.MM_Material m   
  --              ON spd.IdMaterial = m.IdMaterial   
  --      WHERE sp.IdContrato = @IdContrato   
  --AND ISNULL(sp.IdEstatusEliminado, 0) = 0   
  --      GROUP BY sp.IdSolicitudPedido;   
   
   
   
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
            NombreContratista,  -- 
            FechaEfectiva   --
        )
		SELECT
			CON.NumeroContrato,
			CASE 
				WHEN PROSAP.IdProveedor IS NOT NULL THEN 'SI'
				ELSE 'NO'
			END AS RelacionOperadoraProveedor,
			PRO.RazonSocial AS Proveedor,
			TP.TipoPedido AS MecanismoContratacion,
			SP.MotivoUrgencia AS NombreContratoCP,
			CASE	
				WHEN RPRPO.PO IS NOT NULL THEN SUBSTRING(SUBSTRING(RPRPO.PO,CHARINDEX('45', RPRPO.PO) + 2, LEN(RPRPO.PO)-CHARINDEX('@', RPRPO.PO)),0,9)--00558104-ASCOP
				ELSE ISNULL(PDI.PURCHASING_DOCUMENT,PS.IdPedido)
			END AS NoContratoCP,
			SP.FechaEntregaRequerida AS FechaInicio,
			ISNULL(SP.FechaEntregaFinRequerida, SP.FechaEntregaRequerida) AS FechaFin,
			ISNULL(SP.FechaEntregaFinRequerida, SP.FechaEntregaRequerida) AS FechaVigencia,
			SP.MotivoUrgencia AS ObjetoContrato,
			CASE
				WHEN PDI.IdPedidoADINCO IS NOT NULL THEN
														CASE		--PESO
															WHEN PDI.IDMONEDA = 1 THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(PDI.NET_PRICE,SP.FechaEntregaRequerida)
															ELSE PDI.NET_PRICE -- DOLAR
														END
				ELSE 
					CASE 
						WHEN P.IdMoneda = 1 THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(SUM(PD.Subtotal),ISNULL(P.FechaRecepcionServicio,P.CreadoEl))
						ELSE SUM(PD.Subtotal)
				END
			END AS MontoUSD,
			CASE
				WHEN PDI.IdPedidoADINCO IS NOT NULL THEN
														CASE		--DOLAR
															WHEN PDI.IDMONEDA = 2 THEN Petrovendor.dbo.Fn_dolarespesostipocambio(PDI.NET_PRICE,SP.FechaEntregaRequerida)
															ELSE PDI.NET_PRICE -- PESO MXN
														END
				ELSE 
					CASE 
						WHEN P.IdMoneda = 2 THEN Petrovendor.dbo.Fn_dolarespesostipocambio(SUM(PD.Subtotal),ISNULL(P.FechaRecepcionServicio,P.CreadoEl))
						ELSE SUM(PD.Subtotal)
				END
			END AS MontoMXN,
			Petrovendor.dbo.FN_ValorTipoCambio(SP.FechaEntregaRequerida) AS TipoCambio,
			SP.FechaEntregaRequerida AS FechaTipoCambio,
			PDI.OUTLINE_AGREEMENT,
			CT.RazonSocial,
			CONVERT(VARCHAR, CON.FechaFirma, 103) AS FechaEfectiva 
		FROM Adinco.dbo.CO_Contrato AS CON (NOLOCK)
			JOIN Petrovendor.dbo.MM_Pedido AS P (NOLOCK)
				ON P.IdContrato = @IDCONTRATO AND P.IdContrato = CON.IdContrato
			JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD (NOLOCK) 
				ON P.IdPedido = PD.IdPedido
			JOIN Petrovendor.dbo.MM_SolicitudPedido AS SP (NOLOCK) 
				ON P.IdSolicitudPedido = SP.IdSolicitudPedido AND SP.Activo = 1
			LEFT JOIN Petrovendor.dbo.DEA_ProveedorDescripcionSAP AS PROSAP (NOLOCK)
				ON P.IdSubContratista = PROSAP.IdProveedor
			JOIN Petrovendor.dbo.S_Proveedor AS PRO  (NOLOCK)
				ON P.IdSubcontratista = PRO.IdProveedor
			LEFT JOIN Petrovendor.dbo.DEA_Relacion_PR_PO AS RPRPO (NOLOCK) 
				ON P.IdPedido = RPRPO.IdPedido
			LEFT JOIN Petrovendor.dbo.WDEA_PurchasingDocumentsImportados AS PDI (NOLOCK) 
				ON P.IdPedido = PDI.IdPedidoADINCO
			JOIN Petrovendor.dbo.MM_Pedidos AS PS (NOLOCK)
				ON P.IdPedido = PS.IdIdentificador AND PS.IdProveedorCliente = P.IdProveedorCompras
			JOIN Petrovendor.dbo.PV_TipoMoneda AS M (NOLOCK)
				ON P.IdMoneda = M.IdMoneda
			JOIN Petrovendor.dbo.MM_PeticionOferta AS PO (NOLOCK)
				ON P.IdPeticionOferta = PO.IdPeticionOferta
			JOIN Petrovendor.dbo.MM_TipoPedido AS TP (NOLOCK)
				ON PO.IdTipoProceso = TP.IdTipoPedido
			JOIN Adinco.dbo.CO_Contratista AS CT (NOLOCK)
				ON CON.IdContratista = CT.IdContratista
		WHERE CONVERT(VARCHAR, P.CreadoEl, 112)   
              BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112)
			GROUP BY CON.NumeroContrato,
				PROSAP.IdProveedor,
				PRO.RazonSocial,
				SP.MotivoUrgencia,
				RPRPO.PO,
				PDI.PURCHASING_DOCUMENT,
				SP.FechaEntregaFinRequerida,
				SP.MotivoUrgencia,
				PDI.IdPedidoADINCO,
				PDI.IDMONEDA,
				PDI.NET_PRICE,
				P.FechaRecepcionServicio,
				SP.FechaEntregaRequerida,
				PDI.OUTLINE_AGREEMENT,
				PS.IdPedido,
				P.IdMoneda,
				P.CreadoEl,
				TP.TipoPedido,
				CT.RazonSocial,
				CON.FechaFirma;   
  --      SELECT C.NumeroContrato,   
  --             CASE   
  --                 WHEN RE.IdRelacion IS NOT NULL THEN   
  --                     'SI'   
  --                 ELSE   
  --                     'NO'   
  --             END AS RelacionOperadoraProveedor,   
  --             UPPER(P.RazonSocial) + ' ' + ISNULL(UPPER(P.RegimenCapital), '') AS Proveedor,   
  --             CASE WHEN SC.NumeroSubcontrato IS NOT NULL    
  --   THEN 'LICITACIÓN'    
  --   ELSE 'ADJUDICACIÓN DIRECTA'    
  --  END AS MecanismoContratacion,   
  --  ISNULL(SC.NumeroSubcontrato,PG.IdPedido) AS  'Nombre Contrato C-P' ,   
  --              UPPER(CONCAT(PG.IdPedido, ' CD')) AS 'No. Contrato',   
                  
  --  CASE   
  --     WHEN OT.FechaInicio IS NOT NULL THEN CONVERT(VARCHAR(10), OT.FechaInicio, 105)   
  --     WHEN CONVERT(VARCHAR(10), TAO.FechaRegistro, 105) IS NULL THEN   
  --                     '-'   
  --     ELSE   
  --          CONVERT(VARCHAR(10), TAO.FechaRegistro, 105)   
  --  END AS 'Fecha Inicio Contrato',   
  --  CASE   
		--WHEN OT.FechaFin IS NOT NULL THEN CONVERT(VARCHAR(10), OT.FechaFin, 105)   
  --      WHEN CONVERT(VARCHAR(10), TAO.FechaRegistro, 105) IS NULL THEN   
  --                     '-'   
  --      ELSE   
  --          CONVERT(VARCHAR(10), TAO.FechaRegistro, 105)   
  --  END AS 'Fecha Termino Contrato',   
  --   CASE   
		--WHEN OT.FechaFin IS NOT NULL THEN CONVERT(VARCHAR(10), OT.FechaFin, 105)   
  --      WHEN CONVERT(VARCHAR(10), TAO.FechaRegistro, 105) IS NULL THEN   
  --                     '-'   
  --      ELSE   
  --          CONVERT(VARCHAR(10), TAO.FechaRegistro, 105)   
  --  END AS 'Vigencia del contrato',   
  --    CASE    
  --   WHEN SC.NumeroSubcontrato IS NOT NULL THEN OT.Objeto   
  --   ELSE   UPPER(SUBSTRING(ISNULL(TAO.Descripcion, ''), 0, 40))    
  --  END AS 'Objeto del contrato',   
  --             CASE   
  --                 WHEN fiFact.IdMoneda = 1 THEN   
  --                     FORMAT(   
  --                     Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
  --                     fiFact.SubTotal, CAST(fiFact.FechaTimbrado AS DATE)),   
  --                     '#,#0.000')   
  --                 ELSE   
  --                     FORMAT(fiFact.SubTotal, '#,#0.000')   
  --             END AS MontoUSD,   
  --             CASE   
  --                 WHEN fiFact.IdMoneda = 2 THEN   
  --                     FORMAT(   
  --                     Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
  --                     fiFact.SubTotal, CAST(fiFact.FechaTimbrado AS DATE)),   
  --                     '#,#0.000')   
  --                 ELSE   
  --                     FORMAT(fiFact.SubTotal, '#,#0.000')   
  --             END AS MontoMXN,   
   
  --            --SE CAMBIA LA FECHA DEL TIPO DE CAMBIO POR fiFact.FechaTimbrado, ESTO DE ACUERDO AL MANUAL EL CUAL INDICA 
		--	  /* 
		--	  FECHA AL TIPO DE CAMBIO: FECHA AL TIPO DE CAMBIO EN QUE SE LLEVÓ A CABO LA TRANSACCIÓN 
		--	  */   
  --             Petrovendor.dbo.FN_ValorTipoCambio(cast(fiFact.FechaTimbrado as DATE)) AS TipoCambio,    
		--	 --SE CAMBIA LA FECHA DEL TIPO DE CAMBIO POR fiFact.FechaTimbrado, ESTO DE ACUERDO AL MANUAL EL CUAL INDICA 
		--	  /* 
		--	  FECHA AL TIPO DE CAMBIO: FECHA AL TIPO DE CAMBIO EN QUE SE LLEVÓ A CABO LA TRANSACCIÓN 
		--	  */ 
		--	  CONVERT(VARCHAR,fiFact.FechaTimbrado, 103)    FechaTipoCambio,   
  --             UPPER(SUBSTRING(ISNULL(TAO.Descripcion, ''), 0, 40)) AS 'Comentarios',   
  --             UPPER(ctista.RazonSocial) AS NombreContratista,   
  --             CONVERT(VARCHAR, c.FechaFirma, 103) AS FechaEfectiva   
  --      FROM Petrovendor.dbo.CO_Registro AS coRegistro   
  --          LEFT JOIN Petrovendor.dbo.FI_Factura AS fiFact   
  --              ON coRegistro.IdFactura = fiFact.IdFactura   
  --          LEFT JOIN Petrovendor.dbo.TA_Operacion AS TAO   
  --              ON TAO.IdDocumento = coRegistro.IdFactura   
  --          LEFT JOIN Petrovendor.dbo.TA_Estatus AS TE   
  --              ON TE.IdEstatus = TAO.IdEstatusOperacion   
  --          LEFT JOIN Petrovendor.dbo.CC_CentroCosto centroCosto   
  --              ON centroCosto.IdCentroCosto = coRegistro.CentroCostos   
  --          LEFT JOIN Petrovendor.dbo.DG_CuentaContable cuentaContable   
  --              ON cuentaContable.Id = coRegistro.CuentaContable   
  --          LEFT JOIN Petrovendor.dbo.CO_CatalogoCuentaSH cuentaSh   
  --              ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH   
  --          LEFT JOIN Petrovendor.dbo.CO_Instalacion instalacion   
  --              ON instalacion.IdInstalacion = coRegistro.IdInstalacion   
  --          LEFT JOIN Petrovendor.dbo.MM_Pedidos PG   
  --              ON PG.IdIdentificador = fiFact.IdFactura   
  --                 AND PG.IdTipoPedido = 1   
  --                 AND TAO.IdProveedor = PG.IdProveedorCliente   
  --          LEFT JOIN Petrovendor.dbo.S_Proveedor AS P   
  --       ON P.RFC = fiFact.Emisor   
  --          LEFT JOIN Adinco.dbo.CO_Contrato AS C   
  --              ON fiFact.IdContrato = C.IdContrato   
  --          LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC   
  --              ON C.IdAreaContractual = AC.IdAreaContractual   
  --          LEFT JOIN Petrovendor.dbo.PV_RelacionProveedorSubcotratista AS RE   
  --              ON RE.IdProveedor = P.IdProveedor   
  --                 AND RE.IdSubcontratista = P.IdProveedor   
  -- LEFT JOIN Adinco.dbo.CO_Contratista ctista   
  --              ON ctista.IdContratista = C.IdContratista   
  -- LEFT JOIN Adinco..OT_Estimacion EST on EST.IdPedido = PG.IdIdentificador and isnull(EST.Cancelada,0) = 0   
  -- LEFT JOIN Adinco..OT_Solicitud OT ON OT.IdOTSolicitud = EST.IdOTSolicitud   
  -- LEFT JOIN Adinco..SC_Subcontrato SC ON SC.IdSubcontrato = OT.IdSubcontrato   
  --      WHERE TAO.IdTipoOperacion = 14   
  --            AND TE.IdEstatus = 2   
  --            AND ISNULL(fiFact.IsEliminado, 0) = 0   
  --            AND C.IdContrato = @IdContrato   
  --            AND CONVERT(VARCHAR, TAO.FechaRegistro, 112)   
  --            BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112);   
   
   
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
			SC.FechaInicio AS FechaInicio,
			SC.FechaFin AS FechaFin,
			SC.FechaFin AS FechaVigencia,
			SC.Objeto AS ObjetoContrato,
			CASE
				WHEN SC.IdMoneda = 1 THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(SUM(SCM.Importe),ISNULL(SC.FechaInicio,SC.CreadoEl))
				ELSE SUM(SCM.Importe) -- PESO MXN					
			END AS MontoUSD,
			CASE
				WHEN SC.IdMoneda = 2 THEN Petrovendor.dbo.Fn_dolarespesostipocambio(SUM(SCM.Importe),ISNULL(SC.FechaInicio,SC.CreadoEl))
				ELSE SUM(SCM.Importe) -- PESO MXN					
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
		LEFT JOIN Adinco.dbo.OT_Solicitud AS OTS (NOLOCK)
			ON SC.IdSubContrato = OTS.IdSubContrato
		LEFT JOIN Adinco.dbo.OT_SolicitudMaterial AS OTSM (NOLOCK)
			ON OTS.IdOTSolicitud = OTSM.IdOTSolicitud
		LEFT JOIN Adinco.dbo.SC_Materiales AS SCM (NOLOCK)
			ON OTSM.IdSCMaterial = SCM.IdSCMaterial
		JOIN Adinco.dbo.CO_Contratista AS CT (NOLOCK)
				ON CON.IdContratista = CT.IdContratista
		WHERE  CONVERT(VARCHAR, SC.CreadoEl, 112)   
              BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112)
		GROUP BY CON.NumeroContrato,
				PROSAP.IdProveedor,
				SUB.RazonSocial,
				SC.Objeto,
				SC.IdPedido,
				SC.FechaInicio,
				SC.FechaFin,
				SC.IdMoneda,
				SC.FechaInicio,
				SC.NumeroSubContrato,
				--SCM.Importe,
				SC.CreadoEl,
				CT.RazonSocial,
				CON.FechaFirma;

   --     SELECT CONCAT(c.NumeroContrato, '(', periodo.NombrePeriodo, ')'),   
   --            CASE   
   --                WHEN RE.IdRelacion IS NOT NULL THEN   
   --                    'SI'   
   --                ELSE   
   --                    'NO'   
   --            END AS RelacionOperadoraProveedor,   
   --            UPPER(PV.RazonSocial) + ' ' + ISNULL(UPPER(PV.RegimenCapital), '') AS Proveedor,   
   --   CASE WHEN SC.NumeroSubcontrato IS NOT NULL OR solPed.MotivoUrgencia like '%ESTIMACIÓN COMPLETA PARA OT%' THEN 'LICITACIÓN'   
   --  ELSE   
   --   CASE        
   --    WHEN TP.TipoPedido = 'Mercadeo' THEN   
   --        'TRES COTIZACIONES'   
   --    ELSE   
   --        UPPER(TP.TipoPedido)   
   --     END    
   -- END AS MecanismoContratacion,       
                  
   --             ISNULL(isnull(SC.NumeroSubcontrato,DEA_RPO.PO),cast(p.IdPedido as varchar))  AS 'Nombre Contrato C-P',   
   -- DEA_RPO.PO AS 'No. Contrato',   
   -- isnull(CASE   
			-- WHEN OT.FechaInicio IS NOT NULL THEN CONVERT(VARCHAR(10), OT.FechaInicio, 105)    
       
			--ELSE CONVERT(VARCHAR(10), P.FechaRecepcionServicio, 105)    
			--END, CONVERT(VARCHAR(10), min(O.FechaRegistro), 105) ) AS 'Fecha Inicio Contrato',   
   -- isnull(CASE    
   --  WHEN OT.FechaFin IS NOT NULL THEN CONVERT(VARCHAR(10), OT.FechaFin, 105)   
   --  ELSE CONVERT(VARCHAR(10), P.FechaRecepcionServicio, 105)    
   -- END, CONVERT(VARCHAR(10), max(O.FechaRegistro), 105)) AS 'Fecha Termino Contrato',   
   --  isnull(CASE    
   --  WHEN OT.FechaFin IS NOT NULL THEN CONVERT(VARCHAR(10), OT.FechaFin, 105)   
   --  ELSE CONVERT(VARCHAR(10), P.FechaRecepcionServicio, 105)    
   -- END, CONVERT(VARCHAR(10), max(O.FechaRegistro), 105)) AS 'Vigencia del contrato',   
   --   CASE WHEN SC.NumeroSubcontrato IS NOT NULL THEN OT.Objeto   
   --  ELSE UPPER(SUBSTRING(solPed.MotivoUrgencia, 0, 40))   
   -- END AS 'Objeto del contrato',   
   --            CASE   
   --                WHEN Mon.IdMoneda = 1 THEN   
   --                    FORMAT(   
   --                    Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
   --                    SUM(PD.Subtotal), CAST(PO.FechaFinalizado AS DATE)),   
   --                    '#,#0.000')   
   --                ELSE   
   --                    FORMAT(SUM(PD.Subtotal), '#,#0.000')   
   --            END AS MontoUSD,   
   --            CASE   
   --          WHEN Mon.IdMoneda = 2 THEN   
   --                    FORMAT(   
   --                    Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
   --                    SUM(PD.Subtotal), CAST(PO.FechaFinalizado AS DATE)),   
   --                    '#,#0.000')   
   --                ELSE   
   --                    FORMAT(SUM(PD.Subtotal), '#,#0.000')   
   --            END AS MontoMXN,   
   --            Petrovendor.dbo.FN_ValorTipoCambio( CAST(PO.FechaFinalizado AS DATE)) AS TipoCambio,   
			--	CAST(PO.FechaFinalizado AS DATE)			    
			--   AS FechaTipoCambio, --DWONG 20190712     
   
   --            UPPER(SUBSTRING(solPed.MotivoUrgencia, 0, 40)) AS 'Comentarios',   
   --            NombreContratista = UPPER(ctista.RazonSocial),                                                      --DWONG 20190712     
   
   --            FechaEfectiva = CONVERT(VARCHAR, c.FechaFirma, 103)                                                 --DWONG 20190712     
   
   --     FROM Petrovendor.dbo.MM_Pedido AS P   
   --         LEFT JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD   
   --             ON PD.IdPedido = P.IdPedido   
   --         LEFT JOIN Petrovendor.dbo.MM_Pedidos PSS   
   --             ON P.IdPedido = PSS.IdIdentificador   
   --                AND PSS.IdProveedorCliente = P.IdProveedorCompras   
   --         LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido solPed   
   --             ON solPed.IdSolicitudPedido = P.IdSolicitudPedido   
   --         LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle SPD   
   --             ON solPed.IdSolicitudPedido = SPD.IdSolicitudPedido   
   --         LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL   
   --             ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle   
   --         LEFT JOIN Petrovendor.dbo.MM_PeticionOferta AS PO   
   --             ON PO.IdPeticionOferta = P.IdPeticionOferta   
   --                AND PO.IdSolicitudPedido = solPed.IdSolicitudPedido   
   --         LEFT JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle POD   
   --             ON POD.IdPeticionOferta = PO.IdPeticionOferta   
   --                AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle   
   --                AND POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle   
   --         LEFT JOIN Petrovendor.dbo.S_Proveedor AS PV   
   --             ON PV.IdProveedor = PO.IdSubcontratista   
   --         LEFT JOIN Petrovendor.dbo.TA_Operacion AS O   
   --             ON O.IdDocumento = P.IdSolicitudPedido   
   --                AND P.Version = O.NoVersion   
   --         LEFT JOIN Petrovendor.dbo.TA_TipoOperacion AS TTO   
   --             ON TTO.IdTipoOperacion = O.IdTipoOperacion   
   --         LEFT JOIN Petrovendor.dbo.TA_Estatus AS E   
   --             ON E.IdEstatus = O.IdEstatusOperacion   
   --         LEFT JOIN Adinco.dbo.CO_Contrato c   
   --             ON c.IdContrato = P.IdContrato   
   --         INNER JOIN Adinco.dbo.CO_Contratista ctista   
   --             ON ctista.IdContratista = c.IdContratista   
   --         INNER JOIN Petrovendor.dbo.PV_TipoMoneda AS Mon   
   --             ON P.IdMoneda = Mon.IdMoneda   
   --         LEFT JOIN Petrovendor.dbo.PV_RelacionProveedorSubcotratista AS RE   
   --             ON RE.IdProveedor = solPed.IdProveedor   
   --                AND RE.IdSubcontratista = P.IdSubcontratista   
   --         LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP   
   --             ON TP.IdTipoPedido = PO.IdTipoProceso   
   --         INNER JOIN @SolpedConMateriales filtro   
   --             ON filtro.IdSolicitudPedido = solPed.IdSolicitudPedido   
   --         INNER JOIN Petrovendor.dbo.DEA_Relacion_PR_PO DEA_RPO -- se agrego la relación PO    
   --             ON DEA_RPO.IdPedido = P.IdPedido   
   --         LEFT JOIN Adinco.dbo.CO_PeriodoContrato periodo   
   --             ON periodo.IdPeriodo = solPed.IdPeriodo   
   --LEFT JOIN Adinco..OT_Estimacion EST on EST.IdPedido = P.IdPedido and isnull(EST.Cancelada,0) = 0   
   --LEFT JOIN Adinco..OT_Solicitud OT ON OT.IdOTSolicitud = EST.IdOTSolicitud    
   --LEFT JOIN Adinco..SC_Subcontrato SC ON SC.IdSubcontrato = OT.IdSubcontrato   
   --     WHERE O.IdTipoOperacion = 9   
   --           AND E.IdEstatus = 2   
   --           AND c.IdContrato = @IdContrato   
   --           AND ISNULL(solPed.IdEstatusEliminado, 0 ) = 0   
   --           AND ISNULL(P.IdEstatusEliminado, 0) = 0   
   --           AND POD.IdPeticionOfertaDetalle IS NOT NULL -- para que no se repita que solo se ligue a los que cotizaron     
   
   --           AND P.FechaEnvioPedido   
   --           BETWEEN CONVERT(VARCHAR, @Fechainicio, 112) AND CONVERT(VARCHAR, @FechaFin, 112) --Evitar mostrar pedidos que ya tengan un subcontrato asignado     
   
   --           AND NOT EXISTS   
   --     (   SELECT 1   
   --         FROM SC_SubContrato sc   
   --         WHERE sc.IdPedido = P.IdPedido   
   --               AND sc.IsActivo = 1)   
   --     GROUP BY RE.IdRelacion,   
   --              PV.RazonSocial,   
   --              PV.RegimenCapital,   
   --              TP.TipoPedido,   
   --              solPed.MotivoUrgencia,   
   --              c.NumeroContrato,   
   --              solPed.FechaEntregaFinRequerida,   
   --              solPed.FechaEntregaRequerida,   
   --              PO.FechaFinalizado,   
   --              c.DescripcionContrato,   
   --              Mon.IdMoneda,   
   --              solPed.IdSolicitudPedido,   
   --              P.IdPedido,   
   --              PSS.IdPedido,   
   --              ctista.RazonSocial,   
   --              c.FechaFirma,   
   --              DEA_RPO.PO,   
   --              periodo.NombrePeriodo,   
   --              P.FechaRecepcionServicio,   
   --  SC.NumeroSubcontrato,   
   --  OT.FechaInicio,   
   --  OT.FechaFin,   
   --  OT.Objeto   
   --     ORDER BY PSS.IdPedido ASC;   
   
   
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
        ORDER BY [No. Contrato];   
    END   
    --- FIN VALIDACION DEA   
    ELSE   
    BEGIN   
 
		 
        INSERT INTO @SolpedConMateriales (IdSolicitudPedido)   
        SELECT sp.IdSolicitudPedido   
        FROM Petrovendor.dbo.MM_SolicitudPedido sp   
            INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd   
     ON sp.IdSolicitudPedido = spd.IdSolicitudPedido   
            INNER JOIN Petrovendor.dbo.MM_Material m   
                ON spd.IdMaterial = m.IdMaterial   
        WHERE sp.IdContrato = @IdContrato   
  AND ISNULL(sp.IdEstatusEliminado, 0) = 0   
        GROUP BY sp.IdSolicitudPedido;   
   
   
   
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
                       FORMAT(   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       fiFact.SubTotal, CAST(fiFact.FechaTimbrado AS DATE)),   
                       '#,#0.000')   
                   ELSE   
                       FORMAT(fiFact.SubTotal, '#,#0.000')   
               END AS MontoUSD,   
               CASE   
                   WHEN fiFact.IdMoneda = 2 THEN   
                       FORMAT(   
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       fiFact.SubTotal, CAST(fiFact.FechaTimbrado AS DATE)),   
                       '#,#0.000')   
                   ELSE   
                       FORMAT(fiFact.SubTotal, '#,#0.000')   
               END AS MontoMXN,   
   
               -- Petrovendor.dbo.FN_ValorTipoCambio(CAST(fiFact.FechaTimbrado AS DATE)) AS TipoCambio,     
   
               Petrovendor.dbo.FN_ValorTipoCambio(CAST(fiFact.FechaTimbrado AS DATE)) AS TipoCambio,   
   
   
               --CONVERT(VARCHAR, fiFact.FechaTimbrado, 103) AS FechaTipoCambio,     
   
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
                       FORMAT(   
                       Petrovendor.dbo.FN_PesosDolaresTipoCambio(   
                       SUM(PD.Subtotal), CAST(ISNULL(solPed.FechaEntregaRequerida, PO.FechaFinalizado) AS DATE)),   
                       '#,#0.000')   
                   ELSE   
                       FORMAT(SUM(PD.Subtotal), '#,#0.000')   
               END AS MontoUSD,   
               CASE   
                   WHEN Mon.IdMoneda = 2 THEN   
                       FORMAT(   
                       Petrovendor.dbo.FN_DolaresPesosTipoCambio(   
                       SUM(PD.Subtotal), ISNULL(solPed.FechaEntregaRequerida, PO.FechaFinalizado)),   
                       '#,#0.000')   
                   ELSE   
                       FORMAT(SUM(PD.Subtotal), '#,#0.000')   
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
            INNER JOIN @SolpedConMateriales filtro   
                ON filtro.IdSolicitudPedido = solPed.IdSolicitudPedido   
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
               MontoUSD,   
               MontoMXN,   
 TipoCambio,   
               FechaTipoCambio,   
               Comentarios,   
               NombreContratista,   
               FechaEfectiva   
        FROM @Tabla   
        ORDER BY [No. Contrato];   
   
    END;   
END; 
