CREATE VIEW [dbo].[ReportePresupuestoGasto_IHSA]
AS
     SELECT TOP (100) PERCENT C.NumeroContrato, 
                              AREA.NombreAreaContractual, 
                              P.Nombre AS Presupuesto, 
                              LPM.IdLineaPresupuestoMes, 
                              CONCAT(RIGHT('00'+CAST(MONTH(LPM.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, LPM.AC_PRESUP_MES), ' ', YEAR(LPM.AC_PRESUP_MES)) AS Mes_Presupuestado, 
                              APCNH.id_Actividad AS ActPetrolera, 
                              APCNH.DescripcionActividadPetrolera AS DescActPetrolera, 
                              SP.[id_Sub-actividad] AS SubActPetrolera, 
                              SP.SubactividadPetrolera AS DescSubActPetrolera, 
                              TP.id_Tarea AS TareaPetrolera, 
                              TP.TareaPetrolera AS DescTareaPetrolera, 
                              S.NombreServicio AS [Servicio/SubTarea], 
                              I.NombreInstalacion AS InstalacionPresupuestada, 
                              LPM.Monto AS [Presupuesto (USD)], 
                              ROUND(SUM(CASE
                                            WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                            THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio
                                            ELSE 0
                                        END), 4) AS [Registrado (USD)], 
                              ROUND(LPM.Monto - SUM(CASE
                                                        WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                                        THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio
                                                        ELSE 0
                                                    END), 4) AS [Saldo (USD)]
     FROM dbo.CO_LineaPresupuestoMes(NOLOCK) LPM
          JOIN dbo.CO_Presupuesto(NOLOCK) P ON P.idpresupuesto = LPM.IdPresupuesto
          JOIN dbo.CO_ActividadPetroleraCNH(NOLOCK) APCNH ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
          JOIN dbo.CO_TareaPetrolera(NOLOCK) TP ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
          JOIN dbo.CO_SubactividadPetrolera(NOLOCK) SP ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
          JOIN dbo.CO_Servicio(NOLOCK) S ON LPM.IdServicio = S.IdServicio
          JOIN dbo.CO_Instalacion(NOLOCK) I ON LPM.IdInstalacion = I.IdInstalacion
          JOIN dbo.CO_AnioContractual AC(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
          JOIN dbo.CO_Contrato C(NOLOCK) ON AC.IdContrato = C.IdContrato
          JOIN dbo.CO_AreaContractual AREA(NOLOCK) ON C.IdAreaContractual = AREA.IdAreaContractual
          LEFT JOIN dbo.CO_Registro(NOLOCK) R ON LPM.IdLineaPresupuestoMes = R.IdPrograma
          LEFT JOIN dbo.CO_Instalacion(NOLOCK) IR ON R.IdInstalacion = IR.IdInstalacion
          LEFT JOIN dbo.FI_Factura(NOLOCK) F ON F.IdFactura = R.IdFactura
          LEFT JOIN dbo.CO_TipoCambioMensual(NOLOCK) TCM ON TCM.IdMoneda = F.IdMoneda
                                                            AND TCM.IdMes = MONTH(R.MesPresentacion)
                                                            AND TCM.Anio = YEAR(R.MesPresentacion)
     WHERE C.IdContrato IN(10031, 10034, 10035)
     GROUP BY C.NumeroContrato, 
              CONCAT(RIGHT('00'+CAST(MONTH(LPM.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, LPM.AC_PRESUP_MES), ' ', YEAR(LPM.AC_PRESUP_MES)), 
              AREA.NombreAreaContractual, 
              P.Nombre, 
              LPM.IdLineaPresupuestoMes, 
              APCNH.id_Actividad, 
              APCNH.DescripcionActividadPetrolera, 
              SP.[id_Sub-actividad], 
              SP.SubactividadPetrolera, 
              TP.id_Tarea, 
              TP.TareaPetrolera, 
              S.NombreServicio, 
              I.NombreInstalacion, 
              LPM.Monto
     ORDER BY AREA.NombreAreaContractual, 
              Presupuesto;
