CREATE VIEW [dbo].ConsultaCuentasContables
AS
     SELECT
			R.IdRegistro,
			C.NumeroContrato,
            ACC.NombreAreaContractual,
			P.Nombre AS Presupuesto,
			ACNH.DescripcionActividadPetrolera AS ActividadPetrolera,
			SAP.SubactividadPetrolera	AS SubActividad,
			TP.TareaPetrolera	AS TareaPetrolera,
            S.NombreServicio AS Servicio,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN ISNULL(SF.RazonSocial,'')
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN ISNULL(SPC.RazonSocial,'')
				ELSE ''
            END AS Subcontratista,
			CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN ISNULL(SF.RFC,'')
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN ISNULL(SPC.RFC,'')
				ELSE ''
            END AS RFC,
			ISNULL(CCSH.Nivel3,'') AS CuentaContable,
			ISNULL(CCSH.Descripcion,'') AS DescripcionCuentaContable,
			ISNULL(F.UUID,'') AS UUID,
			ISNULL(R.Comentarios,'') AS ComentarioGasto,
			ISNULL(R.Poliza,'')		AS NoPoliza,
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
		 END AS MontoGastoUSD,
		 ISNULL(TR.FechaPago,'') AS FechaTransferencia,
		 ISNULL(US.Nombre,'') AS CreadorGasto,
	--		agregar monto de lo registrado
		ISNULL(F.SubTotal,0) as SubtotalFactura
     FROM dbo.CO_LineaPresupuestoMes LPM WITH (NOLOCK)
	 JOIN dbo.CO_Presupuesto P WITH (NOLOCK)
		ON LPM.IdPresupuesto = P.IdPresupuesto
	JOIN dbo.CO_AnioContractual AC WITH (NOLOCK)
		ON P.IdAnioContractual	=	AC.IdAnioContractual
	JOIN dbo.CO_Contrato C WITH (NOLOCK)
		ON AC.IdContrato = C.IdContrato
    JOIN dbo.CO_Contratista CC WITH (NOLOCK)
		ON C.IdContratista	=	CC.IdContratista
    JOIN dbo.CO_AreaContractual ACC WITH (NOLOCK)
		ON C.IdAreaContractual	=	ACC.IdAreaContractual
	JOIN dbo.CO_Servicio S WITH (NOLOCK)
		ON LPM.IdServicio = S.IdServicio
	JOIN dbo.CO_ActividadPetroleraCNH ACNH WITH (NOLOCK)
		ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
    JOIN dbo.CO_SubactividadPetrolera SAP WITH (NOLOCK)
		ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
	JOIN dbo.CO_TareaPetrolera TP WITH (NOLOCK)
		ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
	JOIN dbo.CO_Registro R WITH (NOLOCK)
		ON LPM.IdLineaPresupuestoMes = R.IdPrograma
	LEFT JOIN AP_USUARIO US	WITH (NOLOCK)
		ON R.IdUsuarioCreadoPor	=	US.UsuarioID
    LEFT JOIN dbo.FI_Factura F WITH (NOLOCK)
		ON F.IdFactura = R.IdFactura
	LEFT JOIN dbo.FI_pedimentocomprobante PC WITH (NOLOCK)
	  ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
	LEFT JOIN dbo.PV_Subcontratista SF WITH (NOLOCK)
	  ON F.IdSubcontratista = SF.IdSubcontratista
    LEFT JOIN dbo.PV_Subcontratista SPC WITH (NOLOCK)
		ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
          --LEFT JOIN dbo.CO_TipoServicio TS ON LPM.IdTipoServicio = TS.IdTipoServicio
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
--     LEFT JOIN dbo.CO_RubroInterno RI ON LPM.IdRubroInterno = RI.IdRubroInterno
	LEFT JOIN CO_CatalogoCuentaSH	CCSH WITH (NOLOCK)
		ON R.IdCatalogoCuentasSH	=	CCSH.IdCatalogoCuentasSH
	LEFT JOIN dbo.FI_TransferFactura TF (NOLOCK) 
		ON F.IdFactura = TF.IdFactura
	LEFT JOIN dbo.FI_Transfer TR (NOLOCK) 
		ON TF.IdTransfer = TR.IdTransferencia
     WHERE 
		C.IdContrato IN (10014,10015,10016,10017,10018, 10019,10020,10021,10022,10023,10024, 10043, 10052)
     GROUP BY
			R.IdRegistro,
	 		C.NumeroContrato,
            ACC.NombreAreaContractual,
			P.Nombre,
			ACNH.DescripcionActividadPetrolera,
            SAP.SubactividadPetrolera,
            TP.TareaPetrolera,
            S.NombreServicio,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN ISNULL(SF.RazonSocial,'')
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN ISNULL(SPC.RazonSocial,'')
				ELSE ''
            END,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN ISNULL(SF.RFC,'')
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN ISNULL(SPC.RFC,'')
				ELSE ''
            END,
			ISNULL(CCSH.Nivel3,''),
			ISNULL(CCSH.Descripcion,''),
			ISNULL(F.UUID,''),
			ISNULL(R.Comentarios,''),
			ISNULL(R.Poliza,''),
			R.CvTipoDocFacturacion,
			ISNULL(TR.FechaPago,''),
			ISNULL(US.Nombre,''),			
			ISNULL(F.SubTotal,0)
