CREATE VIEW [dbo].[ReporteFacturasIHSA]
AS
     SELECT DISTINCT TOP (100) PERCENT C.NumeroContrato, 
                                       ACC.NombreAreaContractual, 
                                       ISNULL(P.Nombre, 'Sin ligar a un gasto') AS Presupuesto, 
                                       ACNH.id_Actividad AS ActPetrolera, 
                                       ACNH.DescripcionActividadPetrolera AS DescActPetrolera, 
                                       SAP.[id_Sub-actividad] AS SubActPetrolera, 
                                       SAP.SubactividadPetrolera AS DescSubActPetrolera, 
                                       TP.id_Tarea AS TareaPetrolera, 
                                       TP.TareaPetrolera AS DescTareaPetrolera, 
                                       S.NombreServicio AS [Servicio/SubTarea], 
                                       F.IdFactura,
                                       CASE
                                           WHEN PC.IdPedimentoComprobante IS NULL
                                           THEN 'CF'
                                           WHEN F.IdFactura IS NULL
                                           THEN 'PI'
                                           WHEN F.IdFactura IS NULL
                                           THEN 'PE'
                                       END AS TipoDocumento,
                                       CASE
                                           WHEN PC.IdPedimentoComprobante IS NULL
                                           THEN LTRIM(RTRIM(F.Serie+' '+F.Folio))
                                           WHEN F.IdFactura IS NULL
                                           THEN PC.NumeroPedimento
                                           WHEN F.IdFactura IS NULL
                                           THEN PC.FolioComprobante
                                       END AS Numero, 
                                       ISNULL(F.SubTotal, '') AS [SubtotalFactura], 
                                       ISNULL(F.MontoConIva, '') AS [MontoFacturaConIVA], 
                                       ISNULL(F.Moneda, '') AS [MonedaFactura], 
                                       ISNULL(F.UUID, '') AS [UUID],
                                       CASE
                                           WHEN F.MetodoPago LIKE '%exhibi%'
                                                OR F.MetodoPago LIKE '%PUE%'
                                                OR F.FormaPago LIKE '%exhibi%'
                                                OR F.FormaPago LIKE '%PUE%'
                                           THEN 'PUE'
                                           WHEN F.MetodoPago LIKE '%parcia%'
                                                OR F.MetodoPago LIKE '%dife%'
                                                OR F.MetodoPago LIKE '%PPD%'
                                                OR F.FormaPago LIKE '%parcia%'
                                                OR F.FormaPago LIKE '%dife%'
                                                OR F.FormaPago LIKE '%PPD%'
                                           THEN 'PPD'
                                       END AS MetodoPago,
                                       CASE
                                           WHEN F.MetodoPago NOT LIKE '%exhibi%'
                                                OR F.MetodoPago NOT LIKE '%PUE%'
                                           THEN F.FormaPago
                                           WHEN F.FormaPago NOT LIKE '%exhibi%'
                                                OR F.FormaPago NOT LIKE '%PUE%'
                                           THEN F.MetodoPago
                                       END AS FormaPago,
                                       CASE
                                           WHEN PC.IdPedimentoComprobante IS NULL
                                           THEN F.Fecha
                                           WHEN F.IdFactura IS NULL
                                           THEN PC.FechaPago
                                       END AS FechaDocumento,
                                       CASE
                                           WHEN PC.IdPedimentoComprobante IS NULL
                                           THEN SF.RFC
                                           WHEN F.IdFactura IS NULL
                                           THEN SPC.RFC
                                       END AS RFC,
                                       CASE
                                           WHEN PC.IdPedimentoComprobante IS NULL
                                           THEN SF.RazonSocial
                                           WHEN F.IdFactura IS NULL
                                           THEN SPC.RazonSocial
                                       END AS Proveedor, 
                                       R.MesPresentacion AS 'Mes presentación gasto', 
                                       R.Comentarios, 
                                       GR.Descripcion AS [RubroCN], 
                                       R.PCN AS [PCN],
                                       CASE
                                           WHEN DADA.IdDocAdinco IS NOT NULL
                                           THEN 'Si tiene carta pdf'
                                           ELSE 'NO TIENE CARTA PDF'
                                       END AS CartaContenidoNacionalPDF,
                                       CASE
                                           WHEN R.IdCBSISH IS NULL
                                           THEN 'SIN CLASIFICAR'
                                           ELSE CONCAT(MA.Codigo, ' - ', MA.Nombre)
                                       END AS 'Catalogo Bienes/Servicios Sector Hidrocarburos',
                                       CASE
                                           WHEN D.IdDocumento IS NOT NULL
                                           THEN 'pdf cargado'
                                           ELSE 'PDF NO CARGADO'
                                       END AS FacturaPDF, 
                                       'columna pendiente por definir' AS 'Factura Reportada SIPAC'
     FROM dbo.FI_Factura F(NOLOCK)
          LEFT JOIN dbo.CO_Registro R(NOLOCK) ON F.IdFactura = R.IdFactura
          LEFT JOIN dbo.CO_LineaPresupuestoMes LPM(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
          LEFT JOIN dbo.CO_Presupuesto P(NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto
          LEFT JOIN dbo.CO_ActividadPetroleraCNH ACNH(NOLOCK) ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
          LEFT JOIN dbo.CO_TareaPetrolera TP(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
          LEFT JOIN dbo.CO_SubactividadPetrolera SAP(NOLOCK) ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
          LEFT JOIN dbo.CO_Servicio S(NOLOCK) ON LPM.IdServicio = S.IdServicio
          LEFT JOIN dbo.CO_Instalacion I(NOLOCK) ON LPM.IdInstalacion = I.IdInstalacion
          LEFT JOIN dbo.CO_Contrato C(NOLOCK) ON F.IdContrato = C.IdContrato
          LEFT JOIN dbo.CO_Contratista CC(NOLOCK) ON CC.IdContratista = C.IdContratista
          LEFT JOIN dbo.CO_AreaContractual ACC(NOLOCK) ON ACC.IdAreaContractual = C.IdAreaContractual
          LEFT JOIN dbo.CO_Instalacion IR(NOLOCK) ON R.IdInstalacion = IR.IdInstalacion
          LEFT JOIN dbo.CO_GastosRubro GR(NOLOCK) ON R.IdGastoRubro = GR.IdGastoRubro
          LEFT JOIN dbo.FI_PedimentoComprobante PC(NOLOCK) ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
          LEFT JOIN dbo.PV_Subcontratista SF(NOLOCK) ON F.IdSubcontratista = SF.IdSubcontratista
          LEFT JOIN dbo.PV_Subcontratista SPC(NOLOCK) ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
          LEFT JOIN dbo.PV_TipoMoneda TMF(NOLOCK) ON TMF.IdMoneda = F.IdMoneda
          LEFT JOIN dbo.CO_TipoCambioDiario TCDF(NOLOCK) ON TCDF.IdMoneda = TMF.IdMoneda
                                                            AND DAY(TCDF.Fecha) = DAY(F.Fecha)
                                                            AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
                                                            AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
          LEFT JOIN dbo.PV_TipoMoneda TMPC(NOLOCK) ON TMPC.IdMoneda = PC.IdMoneda
          LEFT JOIN dbo.CO_TipoCambioDiario TCDPC(NOLOCK) ON TCDPC.IdMoneda = TMPC.IdMoneda
                                                             AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago)
                                                             AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago)
                                                             AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago)
          LEFT JOIN dbo.AWS_DocAwsDocAdinco DADA(NOLOCK) ON F.IdFactura = DADA.IdDocAdinco
          LEFT JOIN dbo.MM_BS_Actividad MA(NOLOCK) ON R.IdCBSISH = MA.IdActividad
          LEFT JOIN dbo.FI_Documento D ON F.IdFactura = D.IdFactura
     WHERE F.IdContrato IN(10031, 10034, 10035)
     ORDER BY ACC.NombreAreaContractual, 
              C.NumeroContrato, 
              R.MesPresentacion;
