CREATE VIEW [dbo].[ConsultaGastosTonalli]
AS
     SELECT R.IdRegistro,
            S.NombreServicio AS Servicio,
            I.NombreInstalacion AS InstalacionPresupuestada,
            LPM.AC_FEC_INI AS FechaInicio,
            LPM.AC_FEC_FIN AS FechaFin,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN 'CF'
                WHEN R.CvTipoDocFacturacion = 2
                THEN 'PI'
                WHEN R.CvTipoDocFacturacion = 3
                THEN 'PE'
            END AS TipoDocumento,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN LTRIM(RTRIM(F.Serie+' '+F.Folio))
                WHEN R.CvTipoDocFacturacion = 2
                THEN PC.NumeroPedimento
                WHEN R.CvTipoDocFacturacion = 3
                THEN PC.FolioComprobante
            END AS Numero,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN F.Fecha
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN PC.FechaPago
            END AS FechaDocumento,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN SUM(CASE
                             WHEN ISNULL(R.MontoRegistro, 0) <> 0
                             THEN ISNULL(R.MontoRegistro, 0) / TCDF.TipoCambio
                             ELSE 0
                         END)
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN SUM(CASE
                             WHEN ISNULL(R.MontoRegistro, 0) <> 0
                             THEN ISNULL(R.MontoRegistro, 0) / TCDPC.TipoCambio
                             ELSE 0
                         END)
            END AS MontoUSD,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN SF.RazonSocial
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN SPC.RazonSocial
            END AS Subcontratista,
            IR.NombreInstalacion AS InstalacionRegistro,
            R.InicioEjecucion,
            R.FinEjecucion,
            U.Nombre AS CreadoPor,
            R.MontoRegistro,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN TMF.TipoMonedaCorto
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN TMPC.TipoMonedaCorto
            END AS Moneda,
            R.MesPresentacion AS MesPresentacion,
            CASE
                WHEN P.ciep = 1
                THEN TS.NombreTipoServicio
                ELSE ACNH.DescripcionActividadPetrolera
            END AS TipoDeServicio,
            CASE
                WHEN P.ciep = 1
                THEN ACIEP.NombreActividad
                ELSE SAP.SubactividadPetrolera
            END AS Actividad,
            CASE
                WHEN P.ciep = 1
                THEN RI.NombreRubro
                ELSE TP.TareaPetrolera
            END AS SubActividad,
            ER.NombreEstado AS EstadoValidacion,
            A.NombreArea AS Area,
            R.Comentarios,
            CA.ClasificacionAnexo4 AS Anexo4,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN F.IdFactura
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN PC.IdPedimentoComprobante
            END AS Identificador,
            LPM.IdLineaPresupuestoMes AS LineaPresupuesto,
            P.Nombre AS Presupuesto
     FROM 
		dbo.CO_AnioContractual ac (NOLOCK)
		JOIN  dbo.CO_Presupuesto P ON ac.IdAnioContractual = p.IdAnioContractual
		JOIN 
			dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
			on		LPM.IdPresupuesto = P.IdPresupuesto
          LEFT JOIN dbo.CO_Servicio S (NOLOCK)
			ON LPM.IdServicio = S.IdServicio
          LEFT JOIN dbo.CO_Instalacion I (NOLOCK)
			ON LPM.IdInstalacion = I.IdInstalacion
          LEFT JOIN dbo.CO_Registro R (NOLOCK)
			ON R.IdPrograma = LPM.IdLineaPresupuestoMes
          LEFT JOIN dbo.FI_Factura F (NOLOCK)
			ON F.IdFactura = R.IdFactura
          LEFT JOIN dbo.FI_pedimentocomprobante PC (NOLOCK)
			ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
          LEFT JOIN dbo.PV_Subcontratista SF (NOLOCK)
			ON F.IdSubcontratista = SF.IdSubcontratista
          LEFT JOIN dbo.PV_Subcontratista SPC (NOLOCK)
			ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
          LEFT JOIN dbo.CO_Instalacion IR (NOLOCK)
			ON R.IdInstalacion = IR.IdInstalacion
          LEFT JOIN dbo.AP_Usuario U (NOLOCK)
			ON R.IdUsuarioCreadoPor = U.UsuarioID
          LEFT JOIN dbo.CO_TipoServicio TS (NOLOCK)
			ON LPM.IdTipoServicio = TS.IdTipoServicio
          LEFT JOIN dbo.CO_ActividadCIEP ACIEP (NOLOCK)
			ON LPM.IdActividad = ACIEP.IdActividad
          LEFT JOIN dbo.CO_SubactividadCIEP SCIEP (NOLOCK)
			ON LPM.IdSubactividad = SCIEP.IdSubactividad
          LEFT JOIN dbo.CO_EstadoRegistro ER (NOLOCK)
			ON R.IdEstado = ER.IdEstadoRegistro
          LEFT JOIN dbo.CO_Area A (NOLOCK)
			ON A.IdArea = LPM.IdArea
          LEFT JOIN dbo.PV_TipoMoneda TMF (NOLOCK)
			ON TMF.IdMoneda = F.IdMoneda
          LEFT JOIN dbo.CO_TipoCambioDiario TCDF (NOLOCK)
			ON TCDF.IdMoneda = TMF.IdMoneda
                AND DAY(TCDF.Fecha) = DAY(F.Fecha)
                AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
                AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
          LEFT JOIN dbo.PV_TipoMoneda TMPC (NOLOCK)
			ON TMPC.IdMoneda = PC.IdMoneda
          LEFT JOIN dbo.CO_TipoCambioDiario TCDPC (NOLOCK)
			ON TCDPC.IdMoneda = TMPC.IdMoneda
                AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago)
                AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago)
                AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago)
          LEFT JOIN dbo.CO_ClasificacionAnexo4 CA (NOLOCK)
			ON LPM.IdAnexo4 = CA.IdAnexo4
          --LEFT JOIN dbo.CO_Presupuesto P ON LPM.IdPresupuesto = P.IdPresupuesto
          LEFT JOIN dbo.CO_ActividadPetroleraCNH ACNH (NOLOCK)
			ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
          LEFT JOIN dbo.CO_SubactividadPetrolera SAP (NOLOCK)
			ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
          LEFT JOIN dbo.CO_RubroInterno RI (NOLOCK)
			ON LPM.IdRubroInterno = RI.IdRubroInterno
          LEFT JOIN dbo.CO_TareaPetrolera TP (NOLOCK)
			ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
     WHERE --R.IdPrograma = 9
     --P.Nombre LIKE '%tecolutla%')
     --AND ((R.IdEstado = 10004
     --      AND P.IdPresupuesto = 10000)
     --     OR (R.IdEstado IN(10000, 10001, 10002, 10003, 10004, 10005, 10006)
     --AND P.IdPresupuesto <> 10000))
	 ac.IdContrato = 10005
          AND (R.IdRegistro IS NOT NULL)
     GROUP BY PC.NumeroPedimento,
              S.NombreServicio,
              I.NombreInstalacion,
              LPM.AC_FEC_INI,
              LPM.AC_FEC_FIN,
              F.Fecha,
              LTRIM(RTRIM(F.Serie+' '+F.Folio)),
              SF.RazonSocial,
              IR.NombreInstalacion,
              R.InicioEjecucion,
              R.FinEjecucion,
              F.Fecha,
              U.Nombre,
              R.MontoRegistro,
              TMF.TipoMonedaCorto,
              R.MesPresentacion,
              CASE
                  WHEN P.ciep = 1
                  THEN TS.NombreTipoServicio
                  ELSE ACNH.DescripcionActividadPetrolera
              END,
              CASE
                  WHEN P.ciep = 1
                  THEN ACIEP.NombreActividad
                  ELSE SAP.SubactividadPetrolera
              END,
              CASE
                  WHEN P.ciep = 1
                  THEN RI.NombreRubro
                  ELSE TP.TareaPetrolera
              END,
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
              TMPC.TipoMonedaCorto;