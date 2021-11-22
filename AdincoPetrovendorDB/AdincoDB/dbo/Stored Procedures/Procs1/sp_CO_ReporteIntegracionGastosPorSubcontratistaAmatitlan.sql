USE adinco
IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = 'sp_CO_ReporteIntegracionGastosPorSubcontratistaAmatitlan')
    DROP PROCEDURE sp_CO_ReporteIntegracionGastosPorSubcontratistaAmatitlan
GO
create PROCEDURE [dbo].[sp_CO_ReporteIntegracionGastosPorSubcontratistaAmatitlan]-- 2021,10,10188    
@Anio          INT = 0,     
@Mes           INT = 0,     
@IdPresupuesto INT = 0    
AS    
     BEGIN    
         -- =============================================    
         -- Author:   Miguel    
         -- Create date: Domingo 1 Diciembre 2016 19:49 p.m.    
         -- Description: Reporte de Integración de Gastos a Nivel Actividad    
         -- =============================================    
         SET LANGUAGE spanish;    
         SELECT UPPER(CONCAT(DATENAME(MONTH, R.MesPresentacion), ' ', YEAR(R.MesPresentacion))) AS FechaReporte,    
                CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN ISNULL(F.Serie,'')+' '+ ISNULL(F.Folio,'')    
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN PC.FolioComprobante    
                    ELSE ''    
                END AS NumeroFactura,    
                --'' AS Receptor,     
                R.Comentarios,    
                CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN F.Fecha    
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN PC.FechaPago    
                    ELSE ''    
                END AS FechaFactura,    
                CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN RTRIM(P.RazonSocial)    
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN RTRIM(PPC.RazonSocial)    
                    ELSE ''    
                END AS Proveedor,    
                CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN TCM.TipoCambio    
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN TCMPC.TipoCambio    
                    ELSE 0    
                END AS TipoCambio,     
                TS.NombreTipoServicio,     
                S.NombreServicio AS NombreServicioConcepto,     
                RTRIM(A.NombreActividad) AS Actividad,     
                R.MesPresentacion AS Periodo,    
                CASE P.Relacionada    
                    WHEN 1    
                    THEN 'Relacionadas'    
                    ELSE 'Prestadora de Servicios'    
                END AS Segmento,    
                CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN F.IdFactura    
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN PC.IdPedimentoComprobante    
                    ELSE 0    
                END AS IdFactura,    
                --FRRF.IdFactura AS IdLum,   
				CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN  ISNULL(FRRF.Serie,'')+' '+ ISNULL(FRRF.Folio,'')   --**[RO] SE MODIFICA DEBIDO A REQUERIMIENTO DEL ISSUE 1155     
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN ISNULL(RPRF.Serie,'')+' '+ ISNULL(RPRF.Folio,'')   
                    ELSE ''    
                END AS FacturaLum, 
               	CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN  ISNULL(PRF.RazonSocial,'')    --**[RO] SE MODIFICA DEBIDO A REQUERIMIENTO DEL ISSUE 1155     
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN ISNULL(RPRSub.RazonSocial,'') 
                    ELSE ''    
                END AS RSRefac, 
				CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN  ISNULL(CONVERT(varchar, FRRF.Fecha,103),'')    --**[RO] SE MODIFICA DEBIDO A REQUERIMIENTO DEL ISSUE 1155     
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN ISNULL(CONVERT(varchar, RPRF.Fecha,103),'')
                    ELSE ''    
                END AS FechaFacLum, 
				
                I.NombreInstalacion AS Instalacion, --instalacion del gasto    
                R.InicioEjecucion AS FechaI,     
                R.FinEjecucion AS FechaF,     
                '' AS OrdenSC,     
                '' AS Partida,     
                --CFRRF.Unidad AS Unidad,     
                CASE    
                    WHEN FRRF.IdMoneda = 2    
                    THEN dbo.ObtieneValorUnitario(FRRF.IdFactura)    
                    ELSE NULL    
                END AS PUUSD,    
                CASE    
                    WHEN FRRF.IdMoneda = 1    
                    THEN dbo.ObtieneValorUnitario(FRRF.IdFactura)    
                    ELSE NULL    
                END AS PUMXN,     
                SUM(CASE    
                        WHEN R.CvTipoDocFacturacion = 1    
                        THEN F.SubTotal    
                        ELSE PCD.PrecioUnitario    
                    END)  AS ImporteFA,  --**[RO] SE COMENTA DEBIDO A REQUERIMIENTO DEL ISSUE 1155    
     --R.MontoRegistro AS ImporteFA,     
    --R.MontoRegistro AS ImporteFaCMarckup --**[RO] SE COMENTA DEBIDO A REQUERIMIENTO DEL ISSUE 1155    
     ISNULL(RM.MontoGasto+ rm.MontoEquivalente, 0) AS ImporteFaCMarckup,    
                CASE    
                    WHEN F.IdMoneda = 1    
                    THEN 'MXN'    
                    ELSE 'USD'    
                END AS Moneda,     
                SUM(CASE    
                        WHEN R.CvTipoDocFacturacion = 1    
             AND ISNULL(F.SubTotal, 0) <> 0    
                        THEN ISNULL(F.SubTotal, 0) / TCM.TipoCambio    
                        WHEN R.CvTipoDocFacturacion IN(2, 3)    
                             AND ISNULL(PCD.PrecioUnitario, 0) <> 0    
                        THEN ISNULL(PCD.PrecioUnitario, 0) / TCMPC.TipoCambio    
                        ELSE 0    
                    END) AS ImprteUSDMxnUsd,     
                --SUM(CASE    
                --        WHEN R.CvTipoDocFacturacion = 1    
                --             AND ISNULL(R.MontoRegistro, 0) <> 0    
                --        THEN(ROUND(ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio, 2) * .07)    
                --        WHEN R.CvTipoDocFacturacion IN(2, 3)    
                --             AND ISNULL(R.MontoRegistro, 0) <> 0    
                --        THEN(ROUND(ISNULL(R.MontoRegistro, 0) / TCMPC.TipoCambio, 2) * .07)    
                --        ELSE 0    
                --    END) AS MarkUp,   --**[RO] SE COMENTA DEBIDO A REQUERIMIENTO DEL ISSUE 1155    
    ISNULL(rm.MontoEquivalente, 0) AS MarkUp,     
  ISNULL(RM.MontoGasto+ rm.MontoEquivalente, 0) /  
   (CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN TCM.TipoCambio    
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN TCMPC.TipoCambio    
                    ELSE 0    
                END)  
     AS ImporteEstimadoUSD,   
                --ROUND(SUM(CASE    
                --              WHEN R.CvTipoDocFacturacion = 1    
                --                   AND ISNULL(R.MontoRegistro, 0) <> 0    
                --              THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio    
                --              WHEN R.CvTipoDocFacturacion IN(2, 3)    
                --                   AND ISNULL(R.MontoRegistro, 0) <> 0    
                --              THEN ISNULL(R.MontoRegistro, 0) / TCMPC.TipoCambio    
                --              ELSE 0    
                --          END), 2) AS ImporteEstimadoUSD,     
                R.MesCertificadoCIEP,     
                Rub.NombreRubro AS SubActividad,     
                '' AS AplicacionEspecifica,     
                PRE.Nombre AS Presupuesto,    
                CASE    
                    WHEN TS.NombreTipoServicio LIKE '%desarrollo%'    
                         OR TS.NombreTipoServicio LIKE '%explora%'    
                    THEN 'CAPEX'    
                    WHEN TS.NombreTipoServicio LIKE '%produc%'    
                    THEN 'OPEX'    
                    ELSE 'OVERHEAD'    
                END AS CAPEXOPEX,     
                'Facturado relacionada' AS Estatus,     
                R.IdRegistro  
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
                                          --  AND RRF.MesPresentacion = R.MesPresentacion --**RO se comenta     
              --LEFT JOIN dbo.FI_Factura AS F ON F.IdFactura = RRF.idFacturaHijo    
              LEFT JOIN dbo.PV_Subcontratista AS P ON F.IdSubcontratista = P.IdSubcontratista    
              LEFT JOIN dbo.FI_Factura FRRF ON RRF.idFacturaPadre = FRRF.IdFactura    
              --AND RRF.MesPresentacion = R.MesPresentacion    
              --AND MONTH(R.MesPresentacion) = MONTH(FRRF.Fecha)    
              --AND YEAR(R.MesPresentacion) = YEAR(FRRF.Fecha)    
              --LEFT JOIN dbo.FI_CFDIConcepto CFRRF ON FRRF.IdFactura = CFRRF.IdFactura    
            LEFT JOIN dbo.PV_Subcontratista AS PRF ON FRRF.IdSubcontratista = PRF.IdSubcontratista    
              --(SELECT PRF.IdSubcontratista,PRF.RazonSocial FROM dbo.PV_Subcontratista AS PRF JOIN dbo.FI_Factura FRRF  ON FRRF.IdSubcontratista = PRF.IdSubcontratista WHERE FRRF.IdFactura IS NOT NULL) AS SubCon ON FRRF.IdSubcontratista = SubCon.IdSubcontratista    
              LEFT JOIN dbo.CO_TipoCambioMensual AS TCM ON TCM.IdMoneda = F.IdMoneda    
                                                           AND TCM.IdMes = MONTH(F.Fecha)    
                                                           AND TCM.Anio = YEAR(F.Fecha)    
              LEFT JOIN dbo.FI_PedimentoComprobante AS PC ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante    
              LEFT JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante    
              LEFT JOIN dbo.CO_TipoCambioMensual AS TCMPC ON TCMPC.IdMoneda = PC.IdMoneda    
                                                             AND TCMPC.IdMes = MONTH(PC.FechaPago)    
                                                             AND TCMPC.Anio = YEAR(PC.FechaPago)    
              LEFT JOIN dbo.PV_Subcontratista AS PPC ON PC.IdSubcontratistaExportador = PPC.IdSubcontratista    
			  LEFT JOIN CO_RegistroMarkup RM ON RM.GastoId= R.IdRegistro  
			  LEFT JOIN FI_RelacionPedimento	AS	RRP	ON R.IdPedimentoComprobante = RRP.IdPedimentoHijo 
			  LEFT JOIN dbo.FI_Factura RPRF ON RRP.idFacturaPadre = RPRF.IdFactura  
			  LEFT JOIN dbo.PV_Subcontratista AS RPRSub ON RPRF.IdSubcontratista = RPRSub.IdSubcontratista    
         WHERE(YEAR(R.MesPresentacion) = @Anio    
               AND MONTH(R.MesPresentacion) = @Mes)    
              AND C.IdPresupuesto = @IdPresupuesto    
         --AND R.IdRegistro IN(13750)--, 13751, 13752, 13753, 13754, 13755, 13756, 13757, 13758, 13759, 13760, 13761, 13762, 13763, 13764, 13765, 13766, 13767, 13768, 13769, 13770, 13771, 13772, 13773, 13774)    
         --AND RRF.MesPresentacion = R.MesPresentacion    
         GROUP BY UPPER(CONCAT(DATENAME(MONTH, R.MesPresentacion), ' ', YEAR(R.MesPresentacion))),    
                  CASE    
                      WHEN R.CvTipoDocFacturacion = 1    
                      THEN ISNULL(F.Serie,'')+' '+ ISNULL(F.Folio,'')    
                      WHEN R.CvTipoDocFacturacion IN(2, 3)    
                      THEN PC.FolioComprobante    
                      ELSE ''    
                  END,    
                  --'' AS Receptor,     
                  R.Comentarios,    
                  CASE    
                      WHEN R.CvTipoDocFacturacion = 1    
                      THEN F.Fecha    
                      WHEN R.CvTipoDocFacturacion IN(2, 3)    
                      THEN PC.FechaPago    
                      ELSE ''    
                  END,    
                  CASE    
                      WHEN R.CvTipoDocFacturacion = 1    
                      THEN RTRIM(P.RazonSocial)    
                      WHEN R.CvTipoDocFacturacion IN(2, 3)    
                      THEN RTRIM(PPC.RazonSocial)    
                      ELSE ''    
                  END,    
			  ISNULL(RM.MontoGasto+ rm.MontoEquivalente, 0),  
			  ISNULL( rm.MontoEquivalente, 0),  
				/*SUM(CASE    
               WHEN R.CvTipoDocFacturacion = 1    
                    AND F.IdMoneda = 2    
               THEN F.SubTotal    
               WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    AND PC.IdMoneda = 2    
               THEN PCD.PrecioUnitario    
               ELSE 0    
           END) AS USD,     
       SUM(CASE    
        WHEN R.CvTipoDocFacturacion = 1    
                    AND F.IdMoneda = 1    
               THEN F.SubTotal    
               WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    AND PC.IdMoneda = 1    
               THEN PCD.PrecioUnitario    
               ELSE 0    
           END) AS MXN, */    
                  --ISNULL(R.MontoRegistro, 0) AS 'MARK UP', --monto del registro ya incluye el markup    
          /*SUM(CASE    
               WHEN R.CvTipoDocFacturacion = 1    
                    AND ISNULL(R.MontoRegistro, 0) <> 0    
               THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio    
               WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    AND ISNULL(R.MontoRegistro, 0) <> 0    
               THEN ISNULL(R.MontoRegistro, 0) / TCMPC.TipoCambio    
               ELSE 0    
           END) AS TotalUSD,*/    
/*CASE    
           WHEN R.CvTipoDocFacturacion = 1    
           THEN CONVERT(DECIMAL(15, 2), R.MontoRegistro * 0.16)    
           WHEN R.CvTipoDocFacturacion IN(2, 3)    
           THEN 0    
           ELSE 0    
       END AS IVA,*/    
                  --total markup * 0.16    
          /*SUM(CASE    
               WHEN R.CvTipoDocFacturacion = 1    
               THEN CONVERT(DECIMAL(15, 2), R.MontoRegistro) + CONVERT(DECIMAL(15, 2), R.MontoRegistro * 0.16)    
               WHEN R.CvTipoDocFacturacion IN(2, 3)    
               THEN CONVERT(DECIMAL(15, 2), R.MontoRegistro)    
               ELSE 0    
           END) AS Total,*/    
                  --markup + iva    
                  CASE    
                      WHEN R.CvTipoDocFacturacion = 1    
                      THEN TCM.TipoCambio    
                      WHEN R.CvTipoDocFacturacion IN(2, 3)    
                      THEN TCMPC.TipoCambio    
                      ELSE 0    
                  END,     
                  TS.NombreTipoServicio,     
                  S.NombreServicio,     
                  RTRIM(A.NombreActividad),     
                  R.MesPresentacion,    
			/*SUM(CASE    
               WHEN R.CvTipoDocFacturacion = 1    
                    AND ISNULL(R.MontoRegistro, 0) <> 0    
               THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio    
               WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    AND ISNULL(R.MontoRegistro, 0) <> 0    
               THEN ISNULL(R.MontoRegistro, 0) / TCMPC.TipoCambio    
               ELSE 0    
           END) AS Importe,*/    
                  CASE P.Relacionada    
                      WHEN 1    
                      THEN 'Relacionadas'    
                      ELSE 'Prestadora de Servicios'    
                  END,    
                  CASE    
                      WHEN R.CvTipoDocFacturacion = 1    
                      THEN F.IdFactura    
                      WHEN R.CvTipoDocFacturacion IN(2, 3)    
                      THEN PC.IdPedimentoComprobante    
                      ELSE 0    
                  END,    
				  	CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN  ISNULL(FRRF.Serie,'')+' '+ ISNULL(FRRF.Folio,'')   --**[RO] SE MODIFICA DEBIDO A REQUERIMIENTO DEL ISSUE 1155     
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN ISNULL(RPRF.Serie,'')+' '+ ISNULL(RPRF.Folio,'')   
                    ELSE ''    
                END , 
               	CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN  ISNULL(PRF.RazonSocial,'')    --**[RO] SE MODIFICA DEBIDO A REQUERIMIENTO DEL ISSUE 1155     
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN ISNULL(RPRSub.RazonSocial,'') 
                    ELSE ''    
                END, 
				CASE    
                    WHEN R.CvTipoDocFacturacion = 1    
                    THEN  ISNULL(CONVERT(varchar, FRRF.Fecha,103),'')    --**[RO] SE MODIFICA DEBIDO A REQUERIMIENTO DEL ISSUE 1155     
                    WHEN R.CvTipoDocFacturacion IN(2, 3)    
                    THEN ISNULL(CONVERT(varchar, RPRF.Fecha,103),'')
                    ELSE ''    
                END,  
                  I.NombreInstalacion, --instalacion del gasto    
                  --CFRRF.Descripcion AS DescripcionPartida,    
                  R.InicioEjecucion,     
                  R.FinEjecucion,     
                  --CFRRF.Unidad,    
                  CASE    
                      WHEN FRRF.IdMoneda = 2    
                      THEN dbo.ObtieneValorUnitario(FRRF.IdFactura)    
                      ELSE NULL    
                  END,    
                  CASE    
                      WHEN FRRF.IdMoneda = 1    
                      THEN dbo.ObtieneValorUnitario(FRRF.IdFactura)    
                      ELSE NULL    
                  END,    
                  CASE    
                      WHEN R.CvTipoDocFacturacion = 1    
                      THEN F.SubTotal    
                      ELSE PCD.PrecioUnitario    
                  END,     
                  R.MontoRegistro,    
                  CASE    
                      WHEN F.IdMoneda = 1    
                      THEN 'MXN'    
                      ELSE 'USD'    
                  END,    
			/*CASE    
             WHEN R.CvTipoDocFacturacion = 1    
                  AND ISNULL(F.SubTotal, 0) <> 0    
             THEN ISNULL(F.SubTotal, 0) / TCM.TipoCambio    
             WHEN R.CvTipoDocFacturacion IN(2, 3)    
                  AND ISNULL(PCD.PrecioUnitario, 0) <> 0    
             THEN ISNULL(PCD.PrecioUnitario, 0) / TCMPC.TipoCambio    
             ELSE 0    
         END,*/    
			/*CASE    
             WHEN R.CvTipoDocFacturacion = 1    
                  AND ISNULL(R.MontoRegistro, 0) <> 0    
             THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio    
             WHEN R.CvTipoDocFacturacion IN(2, 3)    
                  AND ISNULL(R.MontoRegistro, 0) <> 0    
             THEN ISNULL(R.MontoRegistro, 0) / TCMPC.TipoCambio    
             ELSE 0    
         END, */    
                  R.MesCertificadoCIEP,     
                  Rub.NombreRubro,     
                  PRE.Nombre,    
                  CASE    
                      WHEN TS.NombreTipoServicio LIKE '%desarrollo%'    
                           OR TS.NombreTipoServicio LIKE '%explora%'    
                      THEN 'CAPEX'    
                      WHEN TS.NombreTipoServicio LIKE '%produc%'    
                      THEN 'OPEX'    
                      ELSE 'OVERHEAD'    
                  END,     
                  R.IdRegistro  
         --RRF.idFacturaPadre    
  ORDER BY IdFactura,     
                  TS.NombreTipoServicio,     
                  Actividad,     
                  Proveedor;    
     END;
