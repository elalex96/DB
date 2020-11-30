

CREATE VIEW [dbo].[ReporteProcesoDEA_Finanzas]
AS

SELECT distinct CA.NombreContratista, 
       C.NumeroContrato,
       CASE ISNULL(FP.IdFactura, 0)
           WHEN 0
           THEN 'Finanzas'
           ELSE 'Procura'
       END AS TipoIngreso, 
       AP.IdAceptacionPedido AS No_Aceptacion, 
       FA.IdFactura, 
       FA.Fecha AS Fecha_Emision_Factura, 
       FA.Folio, 
       SP.RazonSocial AS Razon_Social_Proveedor, 
       SP.RFC, 
       FA.UUID, 
       FA.MontoConIva, 
       FA.TipoComprobante AS Tipo_Factura, 
       T.FechaCambioEstatus AS Fecha_2da_Aprobacion,
       CASE ISNULL(FP.IdFactura, 0)
           WHEN 0
           THEN FA.CreadoEn
           ELSE FP.CreadoEn
       END AS FechaIngresoFactura,
       CASE ISNULL(FP.IdFactura, 0)
           WHEN 0
           THEN DATEDIFF(day, FA.FechaTimbrado, FA.CreadoEn)
           ELSE DATEDIFF(day, FP.FechaTimbrado, FP.CreadoEn)
       END AS TiempoIngresoFactura, 
       TRA.CreadoEn AS Fecha_Carga_Comprobante_Transferencia, 
       dbo.CalcularTipoDEA(T.FechaCambioEstatus, TRA.CreadoEn) AS Tiempo_Carga_Comprobante, 
       USCT.Nombre AS Responsable_Carga_Comprobante_Transferencia,
       CASE
           WHEN TRA.AWSPDFId IS NOT NULL
           THEN 'TRANSFERENCIA CON PDF'
           WHEN TRA.AWSPDFId IS NULL
           THEN 'SIN PDF'
       END AS Estatus_Pago_Transferencia,
       CASE
           WHEN CP.IdComplementoDePago IS NOT NULL
           THEN cp.FechaDePago
           WHEN CP.IdComplementoDePago IS NULL
           THEN tra.FechaPago
       END AS FechaDePago, 
       FCP.FechaTimbrado AS FechaEmisionComplemento, 
       FCP.CreadoEn AS Fecha_Carga_Complemento,
       CASE
           WHEN CP.IdComplementoDePago IS NOT NULL
           THEN DATEDIFF(day, cp.FechaDePago, FCP.FechaTimbrado)
           WHEN CP.IdComplementoDePago IS NULL
           THEN DATEDIFF(day, tra.FechaPago, FCP.FechaTimbrado)
       END AS TiempoPagoEmisionComplemento, 
       dbo.CalcularTipoDEA(FCP.FechaTimbrado, FCP.CreadoEn) AS Tiempo_Carga_Complemento, 
       USC.Nombre AS Responsable__Carga_Complemento,
       CASE
           WHEN CP.IdComplementoDePago IS NOT NULL
           THEN 'COMPLEMENTO CARGADO'
           WHEN CP.IdComplementoDePago IS NULL
           THEN 'SIN COMPLEMENTO'
       END AS Estatus_Complemento, 
       RA.MesPresentacion AS Mes_Reporte_SIPAC
FROM Adinco.dbo.FI_Factura AS FA	(NOLOCK)
     LEFT JOIN dbo.FI_Factura AS FP (NOLOCK)
		ON FA.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FP.UUID
                    AND FA.IdContrato IN(10038, 10044, 10045, 10046, 10144, 10145)
     LEFT JOIN dbo.MM_AceptacionFactura AS AF (NOLOCK)
		ON AF.IdFactura = FP.IdFactura
     LEFT JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
		ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
     LEFT JOIN dbo.MM_Pedido AS P (NOLOCK)
		ON P.IdPedido = AP.IdPedido
     LEFT JOIN dbo.TA_Operacion AS OP (NOLOCK)
		ON OP.IdDocumento = AF.IdAceptacionFactura
                                         AND OP.IdTipoOperacion = 10
     LEFT JOIN Adinco.dbo.PV_Subcontratista AS SP (NOLOCK)
		ON SP.RFC = FA.Emisor
     LEFT JOIN dbo.TA_Tarea AS T (NOLOCK)
		ON T.IdOperacion = OP.IdOperacion
                                    AND T.NoSecuencia = 2
									AND T.activo = 1
     LEFT JOIN dbo.S_Usuario AS US (NOLOCK)
		ON US.IdUsuario = T.IdAprobador
     LEFT JOIN Adinco.dbo.CO_Registro AS RA ON RA.IdFactura = FA.IdFactura
     LEFT JOIN Adinco.dbo.FI_TransferFactura AS TRAF ON TRAF.IdFactura = FA.IdFactura
     LEFT JOIN Adinco.dbo.FI_Transfer AS TRA ON TRA.IdTransferencia = TRAF.IdTransfer
     LEFT JOIN Adinco.dbo.FI_CPDocRelacionado AS DR ON DR.IdDocumento = FA.UUID
     LEFT JOIN Adinco.dbo.FI_ComplementoDePago AS CP ON CP.IdComplementoDePago = DR.IdComplementoDePago
     LEFT JOIN Adinco.dbo.FI_Factura AS FCP ON FCP.IdFactura = CP.IdFactura
     LEFT JOIN Adinco.dbo.AP_Usuario AS USC ON USC.UsuarioID = FCP.CreadoPor
     LEFT JOIN Adinco.dbo.AP_Usuario AS USCT ON USCT.UsuarioID = TRA.CreadoPor
     LEFT JOIN Adinco.dbo.CO_Contrato C ON FA.IdContrato = C.IdContrato
     LEFT JOIN Adinco.dbo.CO_Contratista CA ON C.IdContratista = CA.IdContratista
WHERE FA.IdContrato IN(10038, 10044, 10045, 10046, 10144, 10145)
     AND FA.MetodoPago = 'PPD'
GROUP BY CA.NombreContratista, 
         C.NumeroContrato,
         CASE ISNULL(FP.IdFactura, 0)
             WHEN 0
             THEN 'Finanzas'
             ELSE 'Procura'
         END,
         CASE ISNULL(FP.IdFactura, 0)
             WHEN 0
             THEN FA.CreadoEn
             ELSE FP.CreadoEn
         END,
         CASE ISNULL(FP.IdFactura, 0)
             WHEN 0
             THEN DATEDIFF(day, FA.FechaTimbrado, FA.CreadoEn)
             ELSE DATEDIFF(day, FP.FechaTimbrado, FP.CreadoEn)
         END, 
         T.FechaCambioEstatus, 
         tra.FechaPago,
         CASE
             WHEN CP.IdComplementoDePago IS NOT NULL
             THEN cp.FechaDePago
             WHEN CP.IdComplementoDePago IS NULL
             THEN tra.FechaPago
         END,
         CASE
             WHEN CP.IdComplementoDePago IS NOT NULL
             THEN DATEDIFF(day, cp.FechaDePago, FCP.FechaTimbrado)
             WHEN CP.IdComplementoDePago IS NULL
             THEN DATEDIFF(day, tra.FechaPago, FCP.FechaTimbrado)
         END, 
         FCP.FechaTimbrado, 
         TRA.CreadoEn, 
         TRA.AWSPDFId, 
         CP.IdComplementoDePago, 
         AP.IdAceptacionPedido, 
         FA.IdFactura, 
         FA.Fecha, 
         FA.Folio, 
         SP.RazonSocial, 
         SP.RFC, 
         FA.UUID, 
         FA.MontoConIva, 
         FA.TipoComprobante, 
         T.FechaCambioEstatus, 
         TRA.CreadoEn, 
         USCT.Nombre, 
         FCP.CreadoEn, 
         USC.Nombre, 
         RA.MesPresentacion
UNION
     SELECT distinct CA.NombreContratista, 
            C.NumeroContrato,
            CASE ISNULL(FP.IdFactura, 0)
                WHEN 0
                THEN 'Finanzas'
                ELSE 'Procura'
            END AS TipoIngreso, 
            AP.IdAceptacionPedido AS No_Aceptacion, 
            FA.IdFactura, 
            FA.Fecha AS Fecha_Emision_Factura, 
            FA.Folio, 
            SP.RazonSocial AS Razon_Social_Proveedor, 
            SP.RFC, 
            FA.UUID, 
            FA.MontoConIva, 
            FA.TipoComprobante AS Tipo_Factura, 
            T.FechaCambioEstatus AS Fecha_2da_Aprobacion, 
			  CASE ISNULL(FP.IdFactura, 0)
                WHEN 0
                THEN FA.CreadoEn
                ELSE FP.CreadoEn
            END AS FechaIngresoFactura,
            CASE ISNULL(FP.IdFactura, 0)
                WHEN 0
                THEN DATEDIFF(day, FA.FechaTimbrado, FA.CreadoEn)
                ELSE DATEDIFF(day, FP.FechaTimbrado, FP.CreadoEn)
            END AS TiempoIngresoFactura, 
            TRA.CreadoEn AS Fecha_Carga_Comprobante_Transferencia, 
            dbo.CalcularTipoDEA(T.FechaCambioEstatus, TRA.CreadoEn) AS Tiempo_Carga_Comprobante, 
            USTRA.Nombre AS Responsable_Carga_Comprobante_Transferencia,
            CASE
                WHEN TRA.AWSPDFId IS NOT NULL
                THEN 'TRANSFERENCIA CON PDF'
                WHEN TRA.AWSPDFId IS NULL
                THEN 'SIN PDF'
            END AS Estatus_Pago_Transferencia, 
			tra.FechaPago as FechaDePago,
			null as FechaEmisionComplemento,
            --TRA.CreadoEn AS Fecha_Carga_Complemento,
			NULL	AS Fecha_Carga_Complemento,
			--CASE
			--   WHEN CP.IdComplementoDePago IS NOT NULL
			--   THEN DATEDIFF(day, cp.FechaDePago, FCP.FechaTimbrado)
			--   WHEN CP.IdComplementoDePago IS NULL
			--   THEN DATEDIFF(day, tra.FechaPago, FCP.FechaTimbrado)
			--END AS TiempoPagoEmisionComplemento,
			NULL	AS TiempoPagoEmisionComplemento,
            '0.00' AS Tiempo_Carga_Complemento, 
            'N/A' AS Responsable__Carga_Complemento,
            'NO APLICA COMPLEMENTO'
             AS Estatus_Complemento, 
            RA.MesPresentacion AS Mes_Reporte_SIPAC
     FROM Adinco.dbo.FI_Factura AS FA
          LEFT JOIN dbo.FI_Factura AS FP ON FA.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FP.UUID
          LEFT JOIN dbo.MM_AceptacionFactura AS AF ON AF.IdFactura = FP.IdFactura
          LEFT JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
          LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
          LEFT JOIN dbo.TA_Operacion AS OP ON OP.IdDocumento = AF.IdAceptacionFactura
                                              AND OP.IdTipoOperacion = 10
          LEFT JOIN Adinco.dbo.PV_Subcontratista AS SP ON SP.RFC = FA.Emisor
          LEFT JOIN dbo.TA_Tarea AS T ON T.IdOperacion = OP.IdOperacion
                                         AND T.NoSecuencia = 2
										 AND T.activo = 1
          LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = T.IdAprobador
          LEFT JOIN Adinco.dbo.CO_Registro AS RA ON RA.IdFactura = FA.IdFactura
          LEFT JOIN Adinco.dbo.FI_TransferFactura AS TRAF ON TRAF.IdFactura = FA.IdFactura
          LEFT JOIN Adinco.dbo.FI_Transfer AS TRA ON TRA.IdTransferencia = TRAF.IdTransfer
          LEFT JOIN Adinco.dbo.AP_Usuario AS USTRA ON USTRA.UsuarioID = TRA.CreadoPor
          LEFT JOIN Adinco.dbo.CO_Contrato C ON FA.IdContrato = C.IdContrato
          LEFT JOIN Adinco.dbo.CO_Contratista CA ON C.IdContratista = CA.IdContratista
     WHERE FA.IdContrato IN(10038, 10044, 10045, 10046, 10144, 10145)
          AND FA.MetodoPago = 'PUE'
     GROUP BY CA.NombreContratista, 
              C.NumeroContrato,
			    CASE ISNULL(FP.IdFactura, 0)
                  WHEN 0
                  THEN 'Finanzas'
                  ELSE 'Procura'
              END,
              CASE ISNULL(FP.IdFactura, 0)
                  WHEN 0
                  THEN FA.CreadoEn
                  ELSE FP.CreadoEn
              END,
              CASE ISNULL(FP.IdFactura, 0)
                  WHEN 0
                  THEN DATEDIFF(day, FA.FechaTimbrado, FA.CreadoEn)
                  ELSE DATEDIFF(day, FP.FechaTimbrado, FP.CreadoEn)
              END, 
              CASE ISNULL(FP.IdFactura, 0)
                  WHEN 0
                  THEN 'Finanzas'
                  ELSE 'Procura'
              END, 
              TRA.AWSPDFId, 
              FA.MetodoPago, 
			  tra.FechaPago,
              TRA.IdTransferencia, 
              AP.IdAceptacionPedido, 
              FA.IdFactura, 
              FA.Fecha, 
              FA.Folio, 
              SP.RazonSocial, 
              SP.RFC, 
              FA.UUID, 
              FA.MontoConIva, 
              FA.TipoComprobante, 
              T.FechaCambioEstatus, 
              TRA.CreadoEn, 
              USTRA.Nombre, 
              TRA.CreadoEn, 
              RA.MesPresentacion;
