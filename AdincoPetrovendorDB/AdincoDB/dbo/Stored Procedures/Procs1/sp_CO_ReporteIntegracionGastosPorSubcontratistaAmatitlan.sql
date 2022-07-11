USE adinco
GO
DROP PROCEDURE IF EXISTS sp_CO_ReporteIntegracionGastosPorSubcontratistaAmatitlan
GO
CREATE PROCEDURE [dbo].[sp_CO_ReporteIntegracionGastosPorSubcontratistaAmatitlan] -- 2021,10,10188      
    @Anio INT = 0,  
    @Mes INT = 0,  
    @IdPresupuesto INT = 0 AS BEGIN   
 -- =============================================      
    -- Author:   Miguel      
    -- Create date: Domingo 1 Diciembre 2016 19:49 p.m.      
    -- Description: Reporte de Integración de Gastos a Nivel Actividad      
    -- =============================================    
    -- Author:   Reyna 20211208 Issue 1663 
    -- Se borra la linea de AND RRF.MesPresentacion = R.MesPresentacion  del JOIN FI_RelacionRefacturas Ya que no se mostraban las LUMS y se agrego nuevamente los JOINS 
    -- para los comprobantes en el extranjero se muestran como LUMS
    -- =============================================    
	-- Author:   Luis David
    -- Date: 08/07/2022
    -- Descripcion: Se agregan las columnas que se solicitan en el issue Petrovendor #1903
    -- =============================================    
SET  
    LANGUAGE spanish;  
SELECT
    UPPER(  
        CONCAT(  
            DATENAME(MONTH, R.MesPresentacion),  
            ' ',  
            YEAR(R.MesPresentacion)  
        )  
    ) AS FechaReporte,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(F.Serie, '') + ' ' + ISNULL(F.Folio, '')  
        WHEN R.CvTipoDocFacturacion IN(2, 3) THEN PC.FolioComprobante  
        ELSE ''
    END AS NumeroFactura,      
    CASE WHEN R.MontoRegistro < 0 then 
	R.Comentarios else NULL end as 'Comentarios',  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN F.Fecha  
        WHEN R.CvTipoDocFacturacion IN(2, 3) THEN PC.FechaPago  
        ELSE ''
    END AS FechaFactura,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN RTRIM(P.RazonSocial)  
        WHEN R.CvTipoDocFacturacion IN(2, 3) THEN RTRIM(PPC.RazonSocial)  
        ELSE ''
    END AS Proveedor,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN TCM.TipoCambio  
        WHEN R.CvTipoDocFacturacion IN(2, 3) THEN TCMPC.TipoCambio  
        ELSE 0
    END AS TipoCambio,  
    TS.NombreTipoServicio,  
    S.NombreServicio AS NombreServicioConcepto,  
    RTRIM(A.NombreActividad) AS Actividad,  
    R.MesPresentacion AS Periodo,  
    CASE  
        P.Relacionada  
        WHEN 1 THEN 'Relacionadas'
        ELSE 'Prestadora de Servicios'
    END AS Segmento,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN F.IdFactura  
        WHEN R.CvTipoDocFacturacion IN(2, 3) THEN PC.IdPedimentoComprobante  
        ELSE 0
    END AS IdFactura,     
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(FRRF.Serie, '') + ' ' + ISNULL(FRRF.Folio, '')  
         WHEN R.CvTipoDocFacturacion IN(2, 3)    
        THEN ISNULL(RPRF.Serie,'')+' '+ ISNULL(RPRF.Folio,'')   
        ELSE ''
    END AS FacturaLum,    
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(PRF.RazonSocial, '')     
        WHEN R.CvTipoDocFacturacion IN(2, 3)    
        THEN ISNULL(RPRSub.RazonSocial,'') 
        ELSE ''
    END AS RSRefac,   
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(CONVERT(varchar, FRRF.Fecha, 103), '') 
        WHEN R.CvTipoDocFacturacion IN(2, 3)    
        THEN ISNULL(CONVERT(varchar, RPRF.Fecha,103),'')
        ELSE ''
    END AS FechaFacLum,  
    I.NombreInstalacion AS Instalacion,  
    --instalacion del gasto      
    R.InicioEjecucion AS FechaI,  
    R.FinEjecucion AS FechaF,  
    PPS.IdPedido AS OrdenSC,  
    '' AS Partida,
    CASE  
        WHEN FRRF.IdMoneda = 2 THEN dbo.ObtieneValorUnitario(FRRF.IdFactura)  
		WHEN FP.IdMoneda = 2 THEN Petrovendor.dbo.ObtieneValorUnitario(FP.IdFactura)
        ELSE NULL
    END AS PUUSD,  
    CASE  
        WHEN FRRF.IdMoneda = 1 THEN dbo.ObtieneValorUnitario(FRRF.IdFactura)  
		WHEN FP.IdMoneda = 1 THEN Petrovendor.dbo.ObtieneValorUnitario(FP.IdFactura)  
        ELSE NULL
    END AS PUMXN,  
    convert(varchar(50), CAST(cast(cast(SUM(CASE  
            WHEN R.CvTipoDocFacturacion = 1 THEN F.SubTotal  
            ELSE PCD.PrecioUnitario  
        END) as decimal(10, 2)) as varchar(255)) as money), -1) AS ImporteFA,     
     convert(varchar(50), CAST(cast(cast(ISNULL(ISNULL(R.MontoRegistro,RM.MontoGasto) + ISNULL(rm.MontoEquivalente,0),0) as decimal(10, 2)) as varchar(255)) as money), -1) AS ImporteFaCMarckup, 
    CASE  
        WHEN F.IdMoneda = 1 THEN 'MXN'
        ELSE 'USD'
    END AS Moneda,  
    convert(varchar(50), CAST(cast(cast(SUM(CASE WHEN R.CvTipoDocFacturacion = 1 AND ISNULL(ISNULL(R.MontoRegistro,RM.MontoGasto), 0) <> 0 
				THEN ISNULL(ISNULL(R.MontoRegistro,RM.MontoGasto), 0) / ISNULL (RM.TipoCambio, TCM.TipoCambio)
            WHEN R.CvTipoDocFacturacion IN(2, 3) AND ISNULL(ISNULL(R.MontoRegistro,RM.MontoGasto), 0) <> 0 
				THEN ISNULL(ISNULL(R.MontoRegistro,RM.MontoGasto), 0) / ISNULL (RM.TipoCambio, TCMPC.TipoCambio)
            ELSE 0
        END  
    ) as decimal(10, 2)) as varchar(255)) as money), -1) AS ImprteUSDMxnUsd,   
    ISNULL(rm.MontoEquivalente, 0) AS MarkUp,  
    convert(varchar(50), CAST(cast(cast(ISNULL(ISNULL(R.MontoRegistro,RM.MontoGasto) + ISNULL(rm.MontoEquivalente,0), 0) / (  
        CASE  
            WHEN R.CvTipoDocFacturacion = 1 THEN TCM.TipoCambio  
            WHEN R.CvTipoDocFacturacion IN(2, 3) THEN TCMPC.TipoCambio  
            ELSE 0
        END  
    ) as decimal(10, 2)) as varchar(255)) as money), -1) AS ImporteEstimadoUSD,        
    R.MesCertificadoCIEP,  
    Rub.NombreRubro AS SubActividad,  
    '' AS AplicacionEspecifica,  
    PRE.Nombre AS Presupuesto,  
    CASE  
        WHEN TS.NombreTipoServicio LIKE '%desarrollo%'
        OR TS.NombreTipoServicio LIKE '%explora%' THEN 'CAPEX'
        WHEN TS.NombreTipoServicio LIKE '%produc%' THEN 'OPEX'
        ELSE 'OVERHEAD'
    END AS CAPEXOPEX,  
    'Facturado relacionada' AS Estatus,  
     R.IdRegistro,
	 MM.DescripcionLarga as 'DescripcionPartidaServicio',
	 U.Unidad,
	 APD.Cantidad
FROM
    dbo.CO_Registro AS R  
    JOIN dbo.CO_LineaPresupuestoMes AS C ON R.IdPrograma = C.IdLineaPresupuestoMes  
    JOIN dbo.CO_Presupuesto PRE ON C.IdPresupuesto = PRE.IdPresupuesto  
    JOIN dbo.CO_Servicio AS S ON C.IdServicio = S.IdServicio  
    JOIN dbo.CO_TipoServicio AS TS ON C.IdTipoServicio = TS.IdTipoServicio  
    JOIN dbo.CO_Rubro Rub ON C.IdRubro = Rub.IdRubro  
    JOIN dbo.CO_Instalacion AS I ON R.IdInstalacion = I.IdInstalacion  
    JOIN dbo.CO_ActividadCIEP AS A ON C.IdActividad = A.IdActividad  
    LEFT JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura  
    LEFT JOIN dbo.FI_RelacionRefacturas AS RRF ON R.IdFactura = RRF.idFacturaHijo  
    LEFT JOIN dbo.PV_Subcontratista AS P ON F.IdSubcontratista = P.IdSubcontratista  
    LEFT JOIN dbo.FI_Factura FRRF ON RRF.idFacturaPadre = FRRF.IdFactura  
    LEFT JOIN dbo.PV_Subcontratista AS PRF ON FRRF.IdSubcontratista = PRF.IdSubcontratista 
    LEFT JOIN dbo.CO_TipoCambioMensual AS TCM ON F.IdMoneda = TCM.IdMoneda  
    AND MONTH(F.Fecha) = TCM.IdMes
    AND YEAR(F.Fecha) = TCM.Anio
    LEFT JOIN dbo.FI_PedimentoComprobante AS PC ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
    LEFT JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante  
    LEFT JOIN dbo.CO_TipoCambioMensual AS TCMPC ON PC.IdMoneda = TCMPC.IdMoneda  
    AND MONTH(PC.FechaPago) = TCMPC.IdMes
    AND YEAR(PC.FechaPago) = TCMPC.Anio
    LEFT JOIN dbo.PV_Subcontratista AS PPC ON PC.IdSubcontratistaExportador = PPC.IdSubcontratista  
    LEFT JOIN CO_RegistroMarkup RM ON R.IdRegistro = RM.GastoId
    LEFT JOIN FI_RelacionPedimento  AS  RRP ON R.IdPedimentoComprobante = RRP.IdPedimentoHijo 
    LEFT JOIN dbo.FI_Factura RPRF ON RRP.idFacturaPadre = RPRF.IdFactura  
    LEFT JOIN dbo.PV_Subcontratista AS RPRSub ON RPRF.IdSubcontratista = RPRSub.IdSubcontratista    
	LEFT JOIN Petrovendor..CO_RelacionRegistroAdinco AS RCO on R.IdRegistro = RCO.IdRegistroAdinco
	LEFT JOIN Petrovendor..CO_Registro as PR on RCO.IdRegistroPetrovendor = PR.IdRegistro
	left JOIN Petrovendor..MM_AceptacionPedidoDetalle as APD on PR.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
	left JOIN Petrovendor..MM_AceptacionPedido AS AP ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
	left JOIN petrovendor..mm_pedido as PP on AP.IdPedido = PP.IdPedido
	left JOIN petrovendor..mm_pedidos as PPS on PP.IdPedido = PPS.IdIdentificador
	left JOIN petrovendor..MM_SolicitudPedidoDetalle as SPD on PP.IdSolicitudPedido = SPD.IdSolicitudPedido
	left JOIN petrovendor..MM_Material as MM on SPD.IdMaterial = MM.IdMaterial
	LEFT JOIN petrovendor..PV_MM_MaterialUnidad as U on SPD.IdUnidad = U.IdUnidad
	LEFT JOIN petrovendor..FI_Factura as FP on PR.IdFactura = FP.IdFactura
WHERE
(  
        YEAR(R.MesPresentacion) = @Anio  
        AND MONTH(R.MesPresentacion) = @Mes  
    )  
    AND C.IdPresupuesto = @IdPresupuesto       
GROUP BY
    UPPER(  
        CONCAT(  
            DATENAME(MONTH, R.MesPresentacion),  
            ' ',  
            YEAR(R.MesPresentacion)  
        )  
    ),  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(F.Serie, '') + ' ' + ISNULL(F.Folio, '')  
        WHEN R.CvTipoDocFacturacion IN(2, 3) THEN PC.FolioComprobante  
        ELSE ''
    END,  
    R.Comentarios,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN F.Fecha  
        WHEN R.CvTipoDocFacturacion IN(2, 3) THEN PC.FechaPago  
        ELSE ''
    END,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN RTRIM(P.RazonSocial)  
        WHEN R.CvTipoDocFacturacion IN(2, 3) THEN RTRIM(PPC.RazonSocial)  
        ELSE ''
    END,  
		ISNULL(ISNULL(R.MontoRegistro,RM.MontoGasto) + ISNULL(rm.MontoEquivalente,0),0),
		ISNULL(rm.MontoEquivalente, 0),  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN TCM.TipoCambio  
        WHEN R.CvTipoDocFacturacion IN(2, 3) THEN TCMPC.TipoCambio  
        ELSE 0
    END,  
    TS.NombreTipoServicio,  
    S.NombreServicio,  
    RTRIM(A.NombreActividad),  
    R.MesPresentacion,    
    CASE  
        P.Relacionada  
        WHEN 1 THEN 'Relacionadas'
        ELSE 'Prestadora de Servicios'
    END,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN F.IdFactura  
        WHEN R.CvTipoDocFacturacion IN(2, 3) THEN PC.IdPedimentoComprobante  
        ELSE 0
    END,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(FRRF.Serie, '') + ' ' + ISNULL(FRRF.Folio, '')
        WHEN R.CvTipoDocFacturacion IN(2, 3)    
        THEN ISNULL(RPRF.Serie,'')+' '+ ISNULL(RPRF.Folio,'')   
        ELSE ''
    END,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(PRF.RazonSocial, '') 
        WHEN R.CvTipoDocFacturacion IN(2, 3)    
        THEN ISNULL(RPRSub.RazonSocial,'') 
        ELSE ''
    END,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(CONVERT(varchar, FRRF.Fecha, 103), '')
         WHEN R.CvTipoDocFacturacion IN(2, 3)    
        THEN ISNULL(CONVERT(varchar, RPRF.Fecha,103),'')
        ELSE ''
    END,  
    I.NombreInstalacion,       
    R.InicioEjecucion,  
    R.FinEjecucion,  
    CASE  
        WHEN FRRF.IdMoneda = 2 THEN dbo.ObtieneValorUnitario(FRRF.IdFactura) 
		WHEN FP.IdMoneda = 2 THEN Petrovendor.dbo.ObtieneValorUnitario(FP.IdFactura)
        ELSE NULL
    END,  
    CASE  
        WHEN FRRF.IdMoneda = 1 THEN dbo.ObtieneValorUnitario(FRRF.IdFactura)  
		WHEN FP.IdMoneda = 1 THEN Petrovendor.dbo.ObtieneValorUnitario(FP.IdFactura)  
        ELSE NULL
    END,  
    CASE  
        WHEN R.CvTipoDocFacturacion = 1 THEN F.SubTotal  
        ELSE PCD.PrecioUnitario  
    END,  
    R.MontoRegistro,  
    CASE  
        WHEN F.IdMoneda = 1 THEN 'MXN'
        ELSE 'USD'
    END,  
    R.MesCertificadoCIEP,  
    Rub.NombreRubro,  
    PRE.Nombre,  
    CASE  
        WHEN TS.NombreTipoServicio LIKE '%desarrollo%'
        OR TS.NombreTipoServicio LIKE '%explora%' THEN 'CAPEX'
        WHEN TS.NombreTipoServicio LIKE '%produc%' THEN 'OPEX'
        ELSE 'OVERHEAD'
    END,  
    R.IdRegistro  ,
     RRF.MesPresentacion,
	 PPS.IdPedido,
	 MM.DescripcionLarga,
	 U.Unidad,
	 APD.Cantidad
ORDER BY
    R.IdRegistro,
    IdFactura,  
    TS.NombreTipoServicio,  
    Actividad,  
    Proveedor;
	END;
