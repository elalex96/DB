CREATE PROCEDURE [dbo].[sp_SIPAC_ReporteGastos_RCCONT01M]  
-- Add the parameters for the stored procedure here  
@Contrato      INT,   
@Mes           DATE,   
@IdPresupuesto INT  
AS  
     BEGIN  
         -- =============================================  
         -- Author: Miguel Gomez  
         -- Create date: 2017-03-18  
         -- Description: Reporte de CGI - Registro de costos. Plantilla RC_CONT_01_M  
         -- =============================================  
         -- Modificado: Marcos Garcia  
         -- Fecha Modificado: 2020-01-23  
         -- Description:   *Agregar Validacion de @IdPresupuesto = 0  
         --                *Agregar WITH (NOLOCK) en las tablas   
         -- =============================================  
         SET NOCOUNT ON;  
  
         /**/  
  
         EXEC sp_SIPAC_Procesar_IdComprobanteExtranjero_V2   
              @Contrato,   
              @Mes,   
              @IdPresupuesto;  
         EXEC sp_SIPAC_Procesar_IdPedimentoImportacion_V2   
              @Contrato,   
              @Mes,   
              @IdPresupuesto;  
         EXEC sp_SIPAC_Procesar_IdFactura_V2   
              @Contrato,   
              @Mes,   
              @IdPresupuesto;  
  
         /**/  
  
         SELECT [RF_00],   
                [RI_00],   
                [RC01_00],   
                [RC01_01],   
                ROW_NUMBER() OVER(ORDER BY [RC01_04] ASC) AS [RC01_02],   
                [RC01_03],   
                [RC01_04],   
                [RC01_05],   
                [RC01_06],   
                [RC01_07],   
                [RC01_08],   
                [RC01_09],   
                [RC01_10],   
                [RC01_11],   
                [RC01_12],   
                [RC01_13],   
                [RC01_14],   
                [RC01_15]  
         FROM  
         (  
             SELECT  
             --F.IdFactura,  
             LTRIM(RTRIM(con.IDSIPAC)) AS [RF_00],   
             LTRIM(RTRIM(c.IDRegFiducidiario)) AS [RI_00],   
             CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1)), 103) AS [RC01_00],   
             f.IdDocFacturacionSIPAC AS [RC01_01],   
             NULL AS [RC01_02], -- ROW_NUMBER() OVER(ORDER BY SP.[id_Sub-actividad] ASC)  
             LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC01_03],   
             LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC01_04],   
             LTRIM(RTRIM(TP.id_Tarea)) AS [RC01_05],   
             LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))) AS [RC01_06],   
             LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))) AS [RC01_07],   
             LTRIM(RTRIM(I.NombreInstalacion)) AS [RC01_08],   
             CC.Nivel3 AS [RC01_09],   
             CC.Descripcion AS [RC01_10],   
             r.Poliza AS [RC01_11],   
             r.Comentarios AS [RC01_12],  
             CASE  
                 WHEN ISNULL(r.MontoRegistro, 0) <> 0  
                 THEN CAST(ROUND((ISNULL(r.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))  
                 ELSE 0  
             END AS [RC01_13],  
             case when r.CapexOpexEdicion is not null then 
			   case when r.CapexOpexEdicion = 1 then 1 
				else 2 end 
			else 
				case when CC.Operacion = 1 then 1 else 2 end end AS [RC01_14],   
             p.IdPresupuestoCNH AS [RC01_15]  
             FROM FI_Transfer tr WITH(NOLOCK)  
                  LEFT JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer  
                  LEFT JOIN FI_Factura f WITH(NOLOCK) ON tf.IdFactura = f.IdFactura  
                  LEFT JOIN CO_Registro r WITH(NOLOCK) ON r.IdFactura = f.IdFactura  
                  LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes  
                  LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto  
                  LEFT JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual  
                  LEFT JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato  
                  LEFT JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista  
                  LEFT JOIN CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON lpm.IdActividadPetrolera = APCNH.IdActividadPetrolera  
                  LEFT JOIN CO_SubactividadPetrolera SP WITH(NOLOCK) ON lpm.IdSubactividadPetrolera = SP.IdSubactividadPetrolera  
                  LEFT JOIN CO_TareaPetrolera TP WITH(NOLOCK) ON lpm.IdTareaPetrolera = TP.IdTareaPetrolera  
                  LEFT JOIN CO_Instalacion I WITH(NOLOCK) ON r.IdInstalacion = I.IdInstalacion  
                  LEFT JOIN PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo  
                  LEFT JOIN CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento  
                  LEFT JOIN CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = r.IdCatalogoCuentasSH  
                  LEFT JOIN PV_TipoMoneda TM WITH(NOLOCK) ON f.IdMoneda = TM.IdMoneda  
                  LEFT JOIN CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda  
                                                                    AND DAY(TCD.Fecha) = DAY(f.Fecha)  
                                                                    AND MONTH(TCD.Fecha) = MONTH(f.Fecha)  
                                                                    AND YEAR(TCD.Fecha) = YEAR(f.Fecha)  
             WHERE c.IdContrato = @Contrato  
                   AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes  
                   AND r.IdEstado = 10004  
                   AND r.CvTipoDocFacturacion = 1  
                   AND ISNULL(CONVERT(INT, f.ProcesadoSIPAC), 0) = 0  
                   AND p.IdPresupuesto = CASE  
                                             WHEN @IdPresupuesto = 0  
                                             THEN lpm.IdPresupuesto  
                                             ELSE @IdPresupuesto  
                                         END  
             --AND p.idpresupuesto = @IdPresupuesto  
             --AND CC.IdVersion = 10001  
  
             GROUP BY LTRIM(RTRIM(con.IDSIPAC)),   
                      LTRIM(RTRIM(c.IDRegFiducidiario)),   
                      CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1)), 103),   
                      f.IdDocFacturacionSIPAC,   
                      LTRIM(RTRIM(APCNH.id_Actividad)),   
                      SP.[id_Sub-actividad],   
                      LTRIM(RTRIM(TP.id_Tarea)),   
                      LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))),   
                      LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))),   
                      LTRIM(RTRIM(I.NombreInstalacion)),   
                      CC.Nivel3,   
                      CC.Descripcion,   
                      r.Poliza,   
                      r.Comentarios,  
                      CASE  
                          WHEN ISNULL(r.MontoRegistro, 0) <> 0  
                          THEN CAST(ROUND((ISNULL(r.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))  
                          ELSE 0  
                      END,  
                      case when r.CapexOpexEdicion is not null then 
			   case when r.CapexOpexEdicion = 1 then 1 
				else 2 end 
			else 
				case when CC.Operacion = 1 then 1 else 2 end end,   
                      p.IdPresupuestoCNH  
             --  
             UNION  
             --  
             SELECT  
             --PC.IdPedimentoComprobante,  
             LTRIM(RTRIM(con.IDSIPAC)) AS [RF_00],   
             LTRIM(RTRIM(c.IDRegFiducidiario)) AS [RI_00],   
             CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1)), 103) AS [RC01_00],   
             PC.IdDocFacturacionSIPAC AS [RC01_01],   
             NULL AS [RC01_02], -- ROW_NUMBER() OVER(ORDER BY SP.[id_Sub-actividad] ASC)  
             LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC01_03],   
             LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC01_04],   
             LTRIM(RTRIM(TP.id_Tarea)) AS [RC01_05],   
             LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))) AS [RC01_06],   
             LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))) AS [RC01_07],   
             LTRIM(RTRIM(I.NombreInstalacion)) AS [RC01_08],   
             CC.Nivel3 AS [RC01_09],   
             CC.Descripcion AS [RC01_10],   
             tr.NumeroPolizaContable AS [RC01_11],   
             tr.Concepto AS [RC01_12],  
             CASE  
                 WHEN ISNULL(r.MontoRegistro, 0) <> 0  
                 THEN CAST(ROUND((ISNULL(r.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))  
                 ELSE 0  
             END AS [RC01_13],  
             case when r.CapexOpexEdicion is not null then 
			   case when r.CapexOpexEdicion = 1 then 1 
				else 2 end 
			else 
				case when CC.Operacion = 1 then 1 else 2 end end AS [RC01_14],   
             p.IdPresupuestoCNH AS [RC01_15]  
             FROM FI_Transfer tr WITH(NOLOCK)  
                  LEFT JOIN FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = tr.IdTransferencia  
                  LEFT JOIN FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante  
                  LEFT JOIN CO_Registro r WITH(NOLOCK) ON r.IdPedimentoComprobante = PC.IdPedimentoComprobante  
                  LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes  
                  LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto  
                  LEFT JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual  
                  LEFT JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato  
                  LEFT JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista  
                  LEFT JOIN CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON lpm.IdActividadPetrolera = APCNH.IdActividadPetrolera  
                  LEFT JOIN CO_SubactividadPetrolera SP WITH(NOLOCK) ON lpm.IdSubactividadPetrolera = SP.IdSubactividadPetrolera  
                  LEFT JOIN CO_TareaPetrolera TP WITH(NOLOCK) ON lpm.IdTareaPetrolera = TP.IdTareaPetrolera  
                  LEFT JOIN CO_Instalacion I WITH(NOLOCK) ON r.IdInstalacion = I.IdInstalacion  
                  LEFT JOIN PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo  
                  LEFT JOIN CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento  
                  LEFT JOIN CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = r.IdCatalogoCuentasSH  
                  LEFT JOIN PV_TipoMoneda TM WITH(NOLOCK) ON PC.IdMoneda = TM.IdMoneda  
                  LEFT JOIN CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda  
                                                                    AND DAY(TCD.Fecha) = DAY(PC.FechaPago)  
                                                                    AND MONTH(TCD.Fecha) = MONTH(PC.FechaPago)  
                                                                    AND YEAR(TCD.Fecha) = YEAR(PC.FechaPago)  
             WHERE c.IdContrato = @Contrato  
                   AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes  
                   AND r.IdEstado = 10004  
                   AND r.CvTipoDocFacturacion IN(2, 3)  
                  AND ISNULL(PC.ProcesadoSIPAC, 0) = 0  
                  AND p.IdPresupuesto = CASE  
                                            WHEN @IdPresupuesto = 0  
                                            THEN lpm.IdPresupuesto  
                                            ELSE @IdPresupuesto  
                                        END  
             --AND p.idpresupuesto = @IdPresupuesto  
             --AND CC.IdVersion = 10001  
  
             GROUP BY PC.IdPedimentoComprobante,   
                      con.IDSIPAC,   
                      c.IDRegFiducidiario,   
                      r.MesPresentacion,   
                      APCNH.id_Actividad,   
                      SP.[id_Sub-actividad],   
                      TP.id_Tarea,   
                      CPO.NombreCampo,   
                      Y.NombreYacimiento,   
                      I.NombreInstalacion,  
                      CASE  
                          WHEN ISNULL(r.MontoRegistro, 0) <> 0  
                          THEN CAST(ROUND((ISNULL(r.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))  
                          ELSE 0  
                      END,  
                      case when r.CapexOpexEdicion is not null then 
			   case when r.CapexOpexEdicion = 1 then 1 
				else 2 end 
			else 
				case when CC.Operacion = 1 then 1 else 2 end end,   
                      PC.IdDocFacturacionSIPAC,   
                      CC.Nivel3,   
                      CC.Descripcion,   
                      tr.NumeroPolizaContable,   
                      tr.Concepto,   
                      p.IdPresupuestoCNH  
         ) C;  
         --select * from sys.objects where name like '%cuenta%' and type = 'f'  
         --EXEC sp_SIPAC_ReporteGastos_RCCONT01M 10003,'2016-07-01',10006 --10002,'2017-04-01',10022  
         --EXEC sp_SIPAC_ReporteGastos_RCCONT01M 10005, '2016-12-01', 10036  
  
     END;