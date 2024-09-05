IF EXISTS (SELECT * 
           FROM INFORMATION_SCHEMA.VIEWS 
           WHERE TABLE_NAME = 'VIEW_SEL_CO_VistaFacturasPico')
BEGIN
    DROP VIEW VIEW_SEL_CO_VistaFacturasPico;
END;
GO
CREATE VIEW [dbo].[VIEW_SEL_CO_VistaFacturasPico]
AS

   
    SELECT 
        CO_Contrato.NumeroContrato,
        P.Nombre                       AS NombrePresupuesto,
        F.IdFactura,
        F.Serie,
        F.Folio,
        F.Fecha,
        F.SubTotal,
        F.Moneda,
        F.MontoConIva,
        F.TipoComprobante,
        F.MetodoPagoEstandarizado AS MetodoPago,
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
            WHEN TF.IdTransfer IS NOT NULL
                THEN T.IdTransferencia
        END                            AS IdTransferencia,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TTFCP.ReferenciaBancaria
            WHEN TF.IdTransfer IS NOT NULL
                THEN T.ReferenciaBancaria
        END                            AS ReferenciaBancaria,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TTFCP.FechaPago
            WHEN TF.IdTransfer IS NOT NULL
                THEN T.FechaPago
        END                            AS FechaPago,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TMTT.TipoMonedaCorto
            WHEN TF.IdTransfer IS NOT NULL
                THEN TMT.TipoMonedaCorto
        END                            AS MonedaPago,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN CAST(TTFCP.MontoPagado AS FLOAT)
            WHEN TF.IdTransfer IS NOT NULL
                THEN CAST(T.MontoPagado AS FLOAT)
        END                            AS MontoPagadoTransferencia,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN CAST(ISNULL(TTFCP.MontoPagado, 0) / TCDTT.TipoCambio AS FLOAT)
            WHEN TF.IdTransfer IS NOT NULL
                THEN CAST(ISNULL(T.MontoPagado, 0) / TCDT.TipoCambio AS FLOAT)
        END                            AS MontoPagadoTransferenciaUSD,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TTFCP.Concepto
            WHEN TF.IdTransfer IS NOT NULL
                THEN T.Concepto
        END                            AS ConceptoPago,
        CASE
            WHEN TF.IdTransfer IS NULL
                THEN TTFCP.NumeroPolizaContable
            WHEN TF.IdTransfer IS NOT NULL
                THEN T.NumeroPolizaContable
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
		CONVERT(date,FPETRO.CreadoEn) AS 'Fecha de carga de factura por el proveedor'
    FROM
		CO_Contratista	(NOLOCK)
	JOIN
		CO_Contrato	(NOLOCK)
		ON	CO_Contratista.IdContratista	=	CO_Contrato.IdContratista
		AND CO_Contratista.RFC	=	'PMS090112TB0'
    JOIN
		dbo.FI_Factura                   F (NOLOCK)
		ON	CO_Contrato.IdContrato	=	F.IdContrato
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
                AND CO_Contrato.IdContrato	=	T.IdContrato
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
                ON TMF.IdMoneda = F.IdMoneda
        LEFT JOIN
            dbo.PV_TipoMoneda            TMT (NOLOCK)
                ON TMT.IdMoneda = T.IdMoneda
        LEFT JOIN
            dbo.CO_TipoCambioDiario      TCDF (NOLOCK)
                ON TCDF.IdMoneda = TMF.IdMoneda
                   AND DAY(TCDF.Fecha) = DAY(F.Fecha)
                   AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
                   AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
        LEFT JOIN
            dbo.CO_TipoCambioDiario      TCDT (NOLOCK)
                ON TCDT.IdMoneda = TMT.IdMoneda
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
            dbo.FI_Factura               FCP	(NOLOCK)
                ON CP.IdFactura = FCP.IdFactura
        LEFT JOIN
            dbo.FI_TransferFactura       TFCP (NOLOCK)
                ON CP.IdFactura = TFCP.IdFactura
        LEFT JOIN
            dbo.FI_Transfer              TTFCP (NOLOCK)
                ON TFCP.IdTransfer = TTFCP.IdTransferencia
                AND	CO_Contrato.IdContrato	=	TTFCP.IdContrato
        LEFT JOIN
            dbo.PV_TipoMoneda            TMTT (NOLOCK)
                ON TMTT.IdMoneda = TTFCP.IdMoneda
        LEFT JOIN
            dbo.CO_TipoCambioDiario      TCDTT (NOLOCK)
                ON TCDTT.IdMoneda = TMTT.IdMoneda
                   AND DAY(TCDTT.Fecha) = DAY(F.Fecha)
                   AND MONTH(TCDTT.Fecha) = MONTH(F.Fecha)
                   AND YEAR(TCDTT.Fecha) = YEAR(F.Fecha)
		LEFT JOIN
			FI_FacturaAdincoPetrovendor	(NOLOCK)
			ON	F.IdFactura	=	FI_FacturaAdincoPetrovendor.IdFacturaAdinco
		LEFT JOIN
			Petrovendor.dbo.FI_Factura FPETRO (NOLOCK)
			ON	FI_FacturaAdincoPetrovendor.IdFacturaPetrovendor	=	FPETRO.IdFactura
			AND FPETRO.Activa = 1
			AND ISNULL(FPETRO.IsEliminado, 0) <> 1
    WHERE
		CO_Contratista.RFC	=	'PMS090112TB0';
