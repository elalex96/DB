CREATE VIEW [dbo].[VistaConsultaPresupuestosAmatitlan]
AS
     SELECT TOP (100) PERCENT P.Nombre, 
                              LPM.IdLineaPresupuestoMes, 
                              CONCAT(RIGHT('00'+CAST(MONTH(LPM.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(month, LPM.AC_PRESUP_MES), ' ', YEAR(LPM.AC_PRESUP_MES)) AS Mes_Presupuestado,
                              CASE CO.IdTipoContrato
                                  WHEN 1
                                  THEN CONVERT(NVARCHAR(MAX), TS.ID_TIPOSER)
                                  ELSE CONVERT(NVARCHAR(MAX), APCNH.id_Actividad)
                              END AS id_Actividad,
                              CASE CO.IdTipoContrato
                                  WHEN 1
                                  THEN CONVERT(NVARCHAR(MAX), TS.NombreTipoServicio)
                                  ELSE CONVERT(NVARCHAR(MAX), APCNH.DescripcionActividadPetrolera)
                              END AS DescripcionActividadPetrolera,
                              CASE CO.IdTipoContrato
                                  WHEN 1
                                  THEN CONVERT(NVARCHAR(MAX), ACIEP.ID_CATACTIV)
                                  ELSE CONVERT(NVARCHAR(MAX), SAP.[id_Sub-actividad])
                              END AS 'id_Sub-actividad',
                              CASE CO.IdTipoContrato
                                  WHEN 1
                                  THEN CONVERT(NVARCHAR(MAX), ACIEP.NombreActividad)
                                  ELSE CONVERT(NVARCHAR(MAX), SAP.SubactividadPetrolera)
                              END AS SubactividadPetrolera, 
                              TP.id_Tarea, 
                              TP.TareaPetrolera, 
                              S.NombreServicio AS Servicio, 
                              I.NombreInstalacion AS Instalacion, 
                              LPM.Monto AS [Presupuesto_USD], 
                              SUM(CASE
                                      WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                      THEN ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio
                                      ELSE 0
                                  END) AS [Registrado (USD)], 
                              LPM.Monto - SUM(CASE
                                                  WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                                  THEN ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio
                                                  ELSE 0
                                              END) AS [Saldo (USD)]
     FROM dbo.CO_LineaPresupuestoMes AS LPM
          LEFT JOIN dbo.CO_Registro R ON LPM.IdLineaPresupuestoMes = R.IdPrograma
          LEFT JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura
          LEFT JOIN dbo.CO_TipoCambioDiario TCD ON F.IdMoneda = TCD.IdMoneda
                                                   AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                                                   AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                   AND DAY(TCD.Fecha) = DAY(F.Fecha)
          LEFT JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
          LEFT JOIN dbo.CO_AnioContractual AC ON AC.IdAnioContractual = P.IdAnioContractual
          LEFT JOIN dbo.CO_Contrato CO ON CO.IdContrato = AC.IdContrato
          LEFT JOIN dbo.CO_ActividadPetroleraCNH APCNH ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
          LEFT JOIN dbo.CO_SubactividadPetrolera SAP ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
          LEFT JOIN dbo.CO_TareaPetrolera TP ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
          LEFT JOIN dbo.CO_ActividadCIEP AS ACIEP ON LPM.IdActividad = ACIEP.IdActividad
          LEFT JOIN dbo.CO_TipoServicio TS ON LPM.IdTipoServicio = TS.ID_TIPOSER
          LEFT JOIN dbo.CO_Servicio S ON LPM.IdServicio = S.IdServicio
          LEFT JOIN dbo.CO_Instalacion I ON LPM.IdInstalacion = I.IdInstalacion
     WHERE CO.IdContrato = 10007
     GROUP BY P.Nombre, 
              LPM.IdLineaPresupuestoMes, 
              LPM.AC_PRESUP_MES, 
              TS.NombreTipoServicio, 
              CO.IdTipoContrato, 
              TS.ID_TIPOSER, 
              ACIEP.ID_CATACTIV, 
              ACIEP.NombreActividad, 
              LPM.ID_PADRE, 
              S.NombreServicio, 
              I.NombreInstalacion, 
              I.IdInstalacionPemex, 
              LPM.Monto, 
              LPM.IdExcel, 
              APCNH.id_Actividad, 
              APCNH.DescripcionActividadPetrolera, 
              SAP.[id_Sub-actividad], 
              SAP.SubactividadPetrolera, 
              TP.id_Tarea, 
              TP.TareaPetrolera
     ORDER BY P.Nombre, 
              LPM.AC_PRESUP_MES;
