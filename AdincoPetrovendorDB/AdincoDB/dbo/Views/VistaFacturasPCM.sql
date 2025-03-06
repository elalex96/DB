IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'VistaFacturasPCM'
    )
    DROP VIEW VistaFacturasPCM
GO
CREATE VIEW  VistaFacturasPCM
AS


    SELECT DISTINCT
        CON.NumeroContrato,
        P.Nombre AS NombrePresupuesto,
        F.IdFactura,
        F.Serie,
        F.Folio,
        F.Fecha,
        F.SubTotal,
        F.Moneda,
        F.MontoConIva,
        F.TipoComprobante,
        ISNULL(F.MetodoPagoEstandarizado, 'PPD')  AS MetodoPago,
        CASE
            WHEN F.MetodoPago LIKE '%exhibi%'
                 OR F.MetodoPago LIKE '%PUE%'
                 OR F.MetodoPago LIKE '%parcia%'
                 OR F.MetodoPago LIKE '%dife%'
                 OR F.MetodoPago LIKE '%PPD%'
                THEN F.FormaPago
            WHEN F.FormaPago LIKE '%exhibi%'
                 OR F.FormaPago LIKE '%PUE%'
                 OR F.FormaPago LIKE '%parcia%'
                 OR F.FormaPago LIKE '%dife%'
                 OR F.FormaPago LIKE '%PPD%'
                THEN F.MetodoPago
        END                            AS FormaPago,
        F.LugarExpedicion,
        F.Emisor,
        SE.RazonSocial                 AS RAEmisor,
        F.Receptor,
        SR.RazonSocial                 AS RAReceptor,
        F.UUID,
        F.FechaTimbrado,
        F.UsoCFDI,
        F.CreadoEn,
        YEAR(F.CreadoEn)               AS AñoCarga,
        MONTH(F.CreadoEn)              AS MesCarga,
        DAY(F.CreadoEn)                AS DíaCarga,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TTFCP.IdTransferencia
            ELSE
                 T.IdTransferencia
        END                            AS IdTransferencia,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TTFCP.ReferenciaBancaria
          ELSE
                 T.ReferenciaBancaria
        END                            AS ReferenciaBancaria,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TTFCP.FechaPago
        ELSE 
                 T.FechaPago
        END                            AS FechaPago,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TMTT.TipoMonedaCorto
            ELSE
                 TMT.TipoMonedaCorto
        END                            AS MonedaPago,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN CAST(TTFCP.MontoPagado AS FLOAT)
            ELSE
                 CAST(T.MontoPagado AS FLOAT)
        END                            AS MontoPagadoTransferencia,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN CAST(ISNULL(TTFCP.MontoPagado, 0) / TCDTT.TipoCambio AS FLOAT)
           ELSE
                 CAST(ISNULL(T.MontoPagado, 0) / TCDT.TipoCambio AS FLOAT)
        END                            AS MontoPagadoTransferenciaUSD,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TTFCP.Concepto
         ELSE
                 T.Concepto
        END                            AS ConceptoPago,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TTFCP.NumeroPolizaContable
         ELSE
                 T.NumeroPolizaContable
        END                            AS NumeroPolizaContable,
        R.InicioEjecucion,
        R.FinEjecucion,
        R.MesPresentacion,
        CAST(R.MontoRegistro AS FLOAT) AS MontoRegistroOriginal,
        CASE
            WHEN R.CvTipoDocFacturacion = 1
                THEN (CASE
                          WHEN ISNULL(R.MontoRegistro, 0) <> 0
                              THEN CAST(ISNULL(R.MontoRegistro, 0) / TCDF.TipoCambio AS FLOAT)
                          ELSE
                              0
                      END
                     )
        END                            AS MontoRegistroUSD,
        R.Comentarios                  AS ComentarioRegistro,
        I.NombreInstalacion            AS NombreInstalacionRegistro,
        GR.Descripcion                 AS ClasificaciónRubro,
        ACNH.id_Actividad,
        ACNH.DescripcionActividadPetrolera,
        SP.[id_Sub-actividad],
        SP.SubactividadPetrolera,
        TA.id_Tarea,
        TA.TareaPetrolera,
        S.NombreServicio               AS SubTarea,
        CASE
            WHEN SIPACPUE.IdRccont21 IS NOT NULL
                 AND R.IdRegistro IS NOT NULL
                THEN SIPACPUE.Periodo
            WHEN SIPACPUE.IdRccont21 IS NULL
                 AND R.IdRegistro IS NOT NULL
                THEN SIPACPPD.Periodo
        END                            AS MesSIPAC,
        CASE
            WHEN SIPACPUE.IdRccont21 IS NOT NULL
                 AND R.IdRegistro IS NOT NULL
                THEN SIPACPUE.TareaRC2112
            WHEN SIPACPUE.IdRccont21 IS NULL
                 AND R.IdRegistro IS NOT NULL
                THEN SIPACPPD.TareaRC2112
        END                            AS TareaSIPAC,
		R.Poliza	AS 'PólizaGasto',
		CO_CatalogoCuentaSH.Nivel3                                              AS 'CuentaContableS.H',  
        CO_CatalogoCuentaSH.Descripcion                                         AS 'DescripciónCuentaContableS.H', 
		  CASE 
			WHEN R.CapexOpexEdicion IS NOT NULL
				THEN CASE 
						WHEN R.CapexOpexEdicion = 0
							THEN 'CAPEX'--2
						ELSE 'OPEX'--1
						END
			ELSE CASE 
					WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
						AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
						THEN 'OPEX'--1
					WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
						AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
						THEN 'OPEX'--1
					WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
						AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
						THEN 'CAPEX'--2
					WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
						AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
						THEN 'OPEX'--1
					END
								END   AS 'TipoGasto'
    FROM
		dbo.CO_Contrato              CON (NOLOCK)
	JOIN
        dbo.FI_Factura                   F (NOLOCK)
			 ON CON.IdContrato	=	10036
			 AND F.IdContrato = CON.IdContrato
			 AND F.IdContrato = 10036
        JOIN
            dbo.PV_Subcontratista        SE (NOLOCK)
                ON F.IdSubcontratista = SE.IdSubcontratista
        JOIN
            dbo.PV_Subcontratista        SR (NOLOCK)
                ON F.Receptor = SR.RFC  
        LEFT JOIN
            dbo.FI_TransferFactura       TF (NOLOCK)
                ON F.IdFactura = TF.IdFactura
        LEFT JOIN
            dbo.FI_Transfer              T (NOLOCK)
                ON TF.IdTransfer = T.IdTransferencia
                   and T.IdContrato = 10036
        LEFT JOIN
            dbo.CO_Registro              R (NOLOCK)
                ON F.IdFactura = R.IdFactura
        LEFT JOIN
            dbo.CO_LineaPresupuestoMes   L (NOLOCK)
                ON R.IdPrograma = L.IdLineaPresupuestoMes
        LEFT JOIN
            dbo.CO_GastosRubro           GR (NOLOCK)
                ON R.IdGastoRubro = GR.IdGastoRubro
        LEFT JOIN
            dbo.CO_ActividadPetroleraCNH ACNH (NOLOCK)
                ON L.IdActividadPetrolera = ACNH.IdActividadPetrolera
        LEFT JOIN
            dbo.CO_SubactividadPetrolera SP (NOLOCK)
                ON L.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
        LEFT JOIN
            dbo.CO_TareaPetrolera        TA (NOLOCK)
                ON L.IdTareaPetrolera = TA.IdTareaPetrolera
        LEFT JOIN
            dbo.CO_Servicio              S (NOLOCK)
                ON L.IdServicio = S.IdServicio
        LEFT JOIN
            dbo.CO_Instalacion           I (NOLOCK)
                ON R.IdInstalacion = I.IdInstalacion
        LEFT JOIN
            dbo.CO_Presupuesto           P (NOLOCK)
                ON L.IdPresupuesto = P.IdPresupuesto
        LEFT JOIN
            dbo.PV_TipoMoneda            TMF (NOLOCK)
                ON F.IdMoneda	=	 TMF.IdMoneda
        LEFT JOIN
            dbo.PV_TipoMoneda            TMT (NOLOCK)
                ON  T.IdMoneda	=	TMT.IdMoneda
        LEFT JOIN
            dbo.CO_TipoCambioDiario      TCDF (NOLOCK)
                ON TMF.IdMoneda	=	TCDF.IdMoneda
                   AND DAY(TCDF.Fecha) = DAY(F.Fecha)
                   AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
                   AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
        LEFT JOIN
            dbo.CO_TipoCambioDiario      TCDT (NOLOCK)
                ON TMT.IdMoneda	=	TCDT.IdMoneda
                   AND DAY(TCDT.Fecha) = DAY(F.Fecha)
                   AND MONTH(TCDT.Fecha) = MONTH(F.Fecha)
                   AND YEAR(TCDT.Fecha) = YEAR(F.Fecha)
        LEFT JOIN
            dbo.FI_CPDocRelacionado      FCPDR (NOLOCK)
                ON F.UUID = FCPDR.IdDocumento
        LEFT JOIN
            dbo.FI_ComplementoDePago     CP (NOLOCK)
                ON CP.IdComplementoDePago = FCPDR.IdComplementoDePago
        LEFT JOIN
            dbo.FI_Factura               FCP
                ON CP.IdFactura = FCP.IdFactura
				  AND FCP.IdContrato = 10036
        LEFT JOIN
            dbo.FI_TransferFactura       TFCP (NOLOCK)
                ON CP.IdFactura = TFCP.IdFactura
        LEFT JOIN
            dbo.FI_Transfer              TTFCP (NOLOCK)
                ON TFCP.IdTransfer = TTFCP.IdTransferencia
                   and TTFCP.IdContrato = 10036
        LEFT JOIN
            dbo.PV_TipoMoneda            TMTT (NOLOCK)
                ON  TTFCP.IdMoneda	=	TMTT.IdMoneda
        LEFT JOIN
            dbo.CO_TipoCambioDiario      TCDTT (NOLOCK)
                ON TMTT.IdMoneda	=	TCDTT.IdMoneda
                   AND DAY(TCDTT.Fecha) = DAY(F.Fecha)
                   AND MONTH(TCDTT.Fecha) = MONTH(F.Fecha)
                   AND YEAR(TCDTT.Fecha) = YEAR(F.Fecha)
        LEFT JOIN
            dbo.SIPAC_RCCONT21M          SIPACPUE	(NOLOCK)
                ON F.UUID = SIPACPUE.IdentificadorCFDIRC2105
                   AND TA.id_Tarea = SIPACPUE.TareaRC2112
        LEFT JOIN
            dbo.SIPAC_RCCONT21M          SIPACPPD	(NOLOCK)
                ON FCP.UUID = SIPACPPD.IdentificadorCFDIRC2105
                   AND TA.id_Tarea = SIPACPPD.TareaRC2112
		LEFT JOIN  
              dbo.CO_CatalogoCuentaSH			(NOLOCK)  
                ON R.IdCatalogoCuentasSH	=	CO_CatalogoCuentaSH.IdCatalogoCuentasSH
    WHERE
        F.IdContrato IN (
                            10036
                        )


