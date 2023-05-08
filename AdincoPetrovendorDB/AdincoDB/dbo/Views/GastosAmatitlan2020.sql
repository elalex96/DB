
CREATE VIEW [dbo].[GastosAmatitlan2020]
AS
SELECT R.IdRegistro,
       S.NombreServicio AS Servicio,
       I.NombreInstalacion AS InstalacionPresupuestada,
       LPM.AC_FEC_INI AS FechaInicio,
       LPM.AC_FEC_FIN AS FechaFin,
       CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN 'CF'
            WHEN R.CvTipoDocFacturacion = 2 THEN 'PI'
            WHEN R.CvTipoDocFacturacion = 3 THEN 'PE' END AS TipoDocumento,
       CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN LTRIM(RTRIM(isnull(F.Serie, '') + ' ' + isnull(F.Folio, '')))
            WHEN R.CvTipoDocFacturacion = 2 THEN PC.NumeroPedimento
            WHEN R.CvTipoDocFacturacion = 3 THEN PC.FolioComprobante END AS Numero,
       CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN F.Fecha
            WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN PC.FechaPago END AS FechaDocumento,
       CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN
                SUM(CASE
                         WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN
                    (CASE
                          WHEN (F.TipoComprobante) LIKE '%egreso%'
                            OR F.TipoComprobante LIKE 'E%' THEN
                              ROUND(
                                  ISNULL((ABS(ISNULL(R.MontoRegistro, 0)) * -1), 0)
                                  / ISNULL(RM.TipoCambio, TCDF.TipoCambio),
                                  2)
                          ELSE ROUND(ISNULL(R.MontoRegistro, 0) / ISNULL(RM.TipoCambio, TCDF.TipoCambio), 2) END)
                         ELSE 0 END)
            WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                SUM(CASE
                         WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN
                             ROUND(ISNULL(R.MontoRegistro, 0) / ISNULL(RM.TipoCambio, TCDPC.TipoCambio), 2)
                         ELSE 0 END) END AS MontoUSD,
       SUM(CAST((CASE
                      WHEN R.CvTipoDocFacturacion = 1 THEN
           (CASE
                 WHEN (F.TipoComprobante) LIKE '%egreso%'
                   OR F.TipoComprobante LIKE 'E%' THEN
                     ISNULL(
                         (ABS(ISNULL(
                                  ABS(ISNULL(RM.MontoGasto, R.MontoRegistro)) + ABS(ISNULL(RM.MontoEquivalente, 0)), 0))
                          * -1),
                         0)
                 ELSE ISNULL(ISNULL(RM.MontoGasto, R.MontoRegistro) + ISNULL(RM.MontoEquivalente, 0), 0) END)
                      ELSE ISNULL(ISNULL(RM.MontoGasto, R.MontoRegistro) + ISNULL(RM.MontoEquivalente, 0), 0) END)
                / (CASE
                        WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(RM.TipoCambio, TCDF.TipoCambio)
                        WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN ISNULL(RM.TipoCambio, TCDPC.TipoCambio)
                        ELSE 0 END) AS DECIMAL(15, 2))) AS MontoUSDConMarkup,
       CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN SF.RazonSocial
            WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN SPC.RazonSocial END AS Subcontratista,
       IR.NombreInstalacion AS InstalacionRegistro,
       R.InicioEjecucion,
       R.FinEjecucion,
       U.Nombre AS CreadoPor,
       CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN
       (CASE
             WHEN (F.TipoComprobante) LIKE '%egreso%'
               OR F.TipoComprobante LIKE 'E%' THEN ISNULL((ABS(ISNULL(R.MontoRegistro, 0)) * -1), 0)
             ELSE R.MontoRegistro END)
            ELSE R.MontoRegistro END AS MontoRegistro,
       CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN TMF.TipoMonedaCorto
            WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN TMPC.TipoMonedaCorto END AS Moneda,
       R.MesPresentacion,
       CASE
            WHEN P.ciep = 1 THEN TS.NombreTipoServicio
            ELSE ACNH.DescripcionActividadPetrolera END AS TipoDeServicio,
       CASE
            WHEN P.ciep = 1 THEN ACIEP.NombreActividad
            ELSE SAP.SubactividadPetrolera END AS Actividad,
       CASE
            WHEN P.ciep = 1 THEN RI.NombreRubro
            ELSE TP.TareaPetrolera END AS SubActividad,
       ER.NombreEstado AS EstadoValidacion,
       A.NombreArea AS Area,
       R.Comentarios,
       CA.ClasificacionAnexo4 AS Anexo4,
       CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN F.IdFactura
            WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN PC.IdPedimentoComprobante END AS Identificador,
       LPM.IdLineaPresupuestoMes AS LineaPresupuesto,
       P.Nombre AS Presupuesto,
       CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(RM.TipoCambio, TCDF.TipoCambio)
            WHEN R.CvTipoDocFacturacion in ( 2, 3 ) THEN ISNULL(RM.TipoCambio, TCDPC.TipoCambio) END AS TipoCambio, ------TipoCambio CF, PI, PE
       ISNULL(F.UUID, '') AS [UUID FACTURA PROVEEDOR PRIMARIO],
       RM.Porcentaje, --21/10/2021 DR
       ISNULL(CO_EstadoRegistro_V2.NombreEstado, 'Revisión') AS [Estatus Certificado],
       CASE
            WHEN RM.MesEstadoPemex IS NULL THEN ''
            WHEN CAST(MONTH(RM.MesEstadoPemex) AS INT) < 10 THEN
                CAST(YEAR(RM.MesEstadoPemex) AS VARCHAR(10)) + ' - 0' + CAST(MONTH(RM.MesEstadoPemex) AS VARCHAR(10))
            ELSE CAST(YEAR(RM.MesEstadoPemex) AS VARCHAR(10)) + ' - ' + CAST(MONTH(RM.MesEstadoPemex) AS VARCHAR(10))END AS [CGE Aprobado Pemex],
       SUM(CASE
                WHEN ISNULL(RM.ImporteEstimadoParcial, 0) <> 0 THEN
				CASE
				WHEN ISNULL(CO_EstadoRegistro_V2.NombreEstado, 'Revisión') LIKE '%Aprobado%'
				THEN
                    CAST(ISNULL(RM.ImporteEstimadoParcial, 0)
                         / (CASE
                                 WHEN R.CvTipoDocFacturacion = 1 THEN
                                     ISNULL(RM.TipoCambio, TCDF.TipoCambio)
                                 WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                                     ISNULL(RM.TipoCambio, TCDPC.TipoCambio)
                                 ELSE 0 END) AS DECIMAL(15, 2))
				ELSE 0 END
				ELSE 
				CASE 
				WHEN ISNULL(CO_EstadoRegistro_V2.NombreEstado, 'Revisión') LIKE '%Aprobado%'
				THEN
                    CAST(
							(CASE
                               WHEN R.CvTipoDocFacturacion = 1 THEN
								   (CASE
										 WHEN (F.TipoComprobante) LIKE '%egreso%'
										   OR F.TipoComprobante LIKE 'E%' THEN
											 ISNULL(
												 (ABS(ISNULL(
														  ABS(ISNULL(RM.MontoGasto, R.MontoRegistro)) + ABS(ISNULL(RM.MontoEquivalente, 0)), 0))
												  * -1),
												 0)
										 ELSE ISNULL(ISNULL(RM.MontoGasto, R.MontoRegistro) + ISNULL(RM.MontoEquivalente, 0), 0) END)
													   ELSE ISNULL(ISNULL(RM.MontoGasto, R.MontoRegistro) + ISNULL(RM.MontoEquivalente, 0), 0) END)
												 / (CASE
														 WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(RM.TipoCambio, TCDF.TipoCambio)
														 WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN ISNULL(RM.TipoCambio, TCDPC.TipoCambio)
														 ELSE 0 END) 
								 
								AS DECIMAL(15, 2))
								
						ELSE 0
						END
				END)
				AS ImporteEstimadoParcialUSD
  FROM dbo.CO_LineaPresupuestoMes AS LPM WITH (NOLOCK)
  LEFT OUTER JOIN dbo.CO_Servicio AS S WITH (NOLOCK)
    ON LPM.IdServicio                  = S.IdServicio
  LEFT OUTER JOIN dbo.CO_Instalacion AS I WITH (NOLOCK)
    ON LPM.IdInstalacion               = I.IdInstalacion
  LEFT OUTER JOIN dbo.CO_Registro AS R WITH (NOLOCK)
    ON R.IdPrograma                    = LPM.IdLineaPresupuestoMes
  LEFT OUTER JOIN dbo.FI_Factura AS F WITH (NOLOCK)
    ON F.IdFactura                     = R.IdFactura
  LEFT OUTER JOIN dbo.FI_PedimentoComprobante AS PC WITH (NOLOCK)
    ON PC.IdPedimentoComprobante       = R.IdPedimentoComprobante
  LEFT OUTER JOIN dbo.PV_Subcontratista AS SF WITH (NOLOCK)
    ON F.IdSubcontratista              = SF.IdSubcontratista
  LEFT OUTER JOIN dbo.PV_Subcontratista AS SPC WITH (NOLOCK)
    ON SPC.IdSubcontratista            = PC.IdSubcontratistaExportador
  LEFT OUTER JOIN dbo.CO_Instalacion AS IR WITH (NOLOCK)
    ON R.IdInstalacion                 = IR.IdInstalacion
  LEFT OUTER JOIN dbo.AP_Usuario AS U WITH (NOLOCK)
    ON R.IdUsuarioCreadoPor            = U.UsuarioID
  LEFT OUTER JOIN dbo.CO_TipoServicio AS TS WITH (NOLOCK)
    ON LPM.IdTipoServicio              = TS.IdTipoServicio
  LEFT OUTER JOIN dbo.CO_ActividadCIEP AS ACIEP WITH (NOLOCK)
    ON LPM.IdActividad                 = ACIEP.IdActividad
  LEFT OUTER JOIN dbo.CO_SubactividadCIEP AS SCIEP WITH (NOLOCK)
    ON LPM.IdSubactividad              = SCIEP.IdSubactividad
  LEFT OUTER JOIN dbo.CO_EstadoRegistro AS ER WITH (NOLOCK)
    ON R.IdEstado                      = ER.IdEstadoRegistro
  LEFT OUTER JOIN dbo.CO_Area AS A WITH (NOLOCK)
    ON A.IdArea                        = LPM.IdArea
  LEFT OUTER JOIN dbo.PV_TipoMoneda AS TMF WITH (NOLOCK)
    ON TMF.IdMoneda                    = F.IdMoneda
  LEFT OUTER JOIN dbo.CO_TipoCambioMensual AS TCDF WITH (NOLOCK)
    ON TCDF.IdMoneda                   = TMF.IdMoneda
   AND TCDF.Anio                       = YEAR(F.Fecha)
   AND TCDF.IdMes                      = MONTH(F.Fecha)
  LEFT OUTER JOIN dbo.PV_TipoMoneda AS TMPC WITH (NOLOCK)
    ON TMPC.IdMoneda                   = PC.IdMoneda
  LEFT OUTER JOIN dbo.CO_TipoCambioMensual AS TCDPC WITH (NOLOCK)
    ON TCDPC.IdMoneda                  = TMPC.IdMoneda
   AND TCDPC.Anio                      = YEAR(PC.FechaPago)
   AND TCDPC.IdMes                     = MONTH(PC.FechaPago)
  LEFT OUTER JOIN dbo.CO_ClasificacionAnexo4 AS CA WITH (NOLOCK)
    ON LPM.IdAnexo4                    = CA.IdAnexo4
  LEFT OUTER JOIN dbo.CO_Presupuesto AS P WITH (NOLOCK)
    ON LPM.IdPresupuesto               = P.IdPresupuesto
  LEFT OUTER JOIN dbo.CO_ActividadPetroleraCNH AS ACNH WITH (NOLOCK)
    ON LPM.IdActividadPetrolera        = ACNH.IdActividadPetrolera
  LEFT OUTER JOIN dbo.CO_SubactividadPetrolera AS SAP WITH (NOLOCK)
    ON LPM.IdSubactividadPetrolera     = SAP.IdSubactividadPetrolera
  LEFT OUTER JOIN dbo.CO_RubroInterno AS RI WITH (NOLOCK)
    ON LPM.IdRubroInterno              = RI.IdRubroInterno
  LEFT OUTER JOIN dbo.CO_TareaPetrolera AS TP WITH (NOLOCK)
    ON LPM.IdTareaPetrolera            = TP.IdTareaPetrolera
  LEFT JOIN CO_RegistroMarkup RM		(NOLOCK)
    ON R.IdRegistro                    = RM.GastoId --21/10/2021 DR
  LEFT JOIN CO_EstadoRegistro_V2		(NOLOCK)
    ON CO_EstadoRegistro_V2.IdContrato = 10007
   AND RM.IdEstadoPemex                = CO_EstadoRegistro_V2.IdClvEstado
 WHERE (P.IdPresupuesto IN ( 10048, 10037, 10065, 10075, 10159, 10188, 10038, 10000, 10169, 10089, 10217, 10240, 10239 ))
   AND (R.IdRegistro IS NOT NULL)
 GROUP BY PC.NumeroPedimento,
          S.NombreServicio,
          I.NombreInstalacion,
          LPM.AC_FEC_INI,
          LPM.AC_FEC_FIN,
          F.Fecha,
          LTRIM(RTRIM(ISNULL(F.Serie, '') + ' ' + ISNULL(F.Folio, ''))),
          SF.RazonSocial,
          IR.NombreInstalacion,
          R.InicioEjecucion,
          R.FinEjecucion,
          F.Fecha,
          U.Nombre,
          --R.MontoRegistro,
          CASE
               WHEN R.CvTipoDocFacturacion = 1 THEN
          (CASE
                WHEN (F.TipoComprobante) LIKE '%egreso%'
                  OR F.TipoComprobante LIKE 'E%' THEN ISNULL((ABS(ISNULL(R.MontoRegistro, 0)) * -1), 0)
                ELSE R.MontoRegistro END)
               ELSE R.MontoRegistro END,
          TMF.TipoMonedaCorto,
          R.MesPresentacion,
          CASE
               WHEN P.ciep = 1 THEN TS.NombreTipoServicio
               ELSE ACNH.DescripcionActividadPetrolera END,
          CASE
               WHEN P.ciep = 1 THEN ACIEP.NombreActividad
               ELSE SAP.SubactividadPetrolera END,
          CASE
               WHEN P.ciep = 1 THEN RI.NombreRubro
               ELSE TP.TareaPetrolera END,
          R.IdRegistro,
          ER.NombreEstado,
          A.NombreArea,
          R.Comentarios,
          CA.ClasificacionAnexo4,
          F.IdFactura,
          PC.IdPedimentoComprobante,
          IR.CUIP,
          IR.WelIID,
          LPM.IdLineaPresupuestoMes,
          IR.IdInstalacion,
          P.Nombre,
          R.CvTipoDocFacturacion,
          PC.FechaPago,
          PC.IdMoneda,
          R.IdRegistro,
          PC.FolioComprobante,
          SPC.RazonSocial,
          TMPC.TipoMonedaCorto,
          CASE
               WHEN R.CvTipoDocFacturacion = 1 THEN ISNULL(RM.TipoCambio, TCDF.TipoCambio)
               WHEN R.CvTipoDocFacturacion in ( 2, 3 ) THEN ISNULL(RM.TipoCambio, TCDPC.TipoCambio) END,
          ISNULL(F.UUID, ''),
          RM.Porcentaje,
          ISNULL(CO_EstadoRegistro_V2.NombreEstado, 'Revisión'),
          CASE
               WHEN RM.MesEstadoPemex IS NULL THEN ''
               WHEN CAST(MONTH(RM.MesEstadoPemex) AS INT) < 10 THEN
                   CAST(YEAR(RM.MesEstadoPemex) AS VARCHAR(10)) + ' - 0'
                   + CAST(MONTH(RM.MesEstadoPemex) AS VARCHAR(10))
               ELSE
                   CAST(YEAR(RM.MesEstadoPemex) AS VARCHAR(10)) + ' - ' + CAST(MONTH(RM.MesEstadoPemex) AS VARCHAR(10))
	END

