CREATE PROCEDURE [dbo].[sp_SIPAC_ReporteGastos_RCCONT02M]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN

         -- =============================================
         -- Author: Manuel Cruz
         -- Create date:  2017-05-12
         -- Description:   Reporte de CGI - Registro de costos. Plantilla RC_CONT_02_M
         -- =============================================

         SET NOCOUNT ON;
         EXEC sp_SIPAC_Procesar_IdPreciosTransfer_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;
         EXEC sp_SIPAC_Procesar_IdFactura_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;
         --
         SELECT
         --DISTINCT
         --F.IdFactura,
         --F.IdSubcontratista,
         LTRIM(RTRIM(con.IDSIPAC)) AS [RF_00], 
         LTRIM(RTRIM(c.IDRegFiducidiario)) AS [RI_00], 
         CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1)), 103) AS [RC02_00], 
         f.IdDocFacturacionSIPAC AS [RC02_01], 
         REPLACE(f.ArchivoXML, '-', '_') AS [RC02_02],
         CASE
             WHEN ISNULL(RE.IdRelacionada, 2) <> 2
             THEN 1
             ELSE 2
         END AS [RC02_03], 
         f.UUID AS [RC02_04], 
         CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(f.FechaTimbrado), MONTH(f.FechaTimbrado), DAY(f.FechaTimbrado))), 103) AS [RC02_05], 
         LTRIM(RTRIM(f.Emisor)) AS [RC02_06], 
         LTRIM(RTRIM(S.RazonSocial)) AS [RC02_07], 
         SUBSTRING(ISNULL(S.NombreVialidad, ''), 0, 30) AS [RC02_08], 
         REPLACE(LTRIM(RTRIM(ISNULL(S.NumExterior, ''))), ' ', '-') AS [RC02_09], 
         LTRIM(RTRIM((SUBSTRING(ISNULL(S.NumInterior, ''), 0, 30)))) AS [RC02_10], 
         LTRIM(RTRIM(ISNULL(S.CodigoPostal, ''))) AS [RC02_11], 
         LTRIM(RTRIM(ISNULL(SUBSTRING(S.Colonia, 0, 30), ''))) AS [RC02_12], 
         LTRIM(RTRIM(ISNULL(S.Municipio, ''))) AS [RC02_13], 
         LTRIM(RTRIM(ISNULL(S.Entidad, ''))) AS [RC02_14], 
         1 AS [RC02_15], --FC.Cantidad AS [RC02_15],
         'SERV-' AS [RC02_16], --LTRIM(RTRIM(FC.Unidad)) AS [RC02_16],
         'SERVICIO' AS [RC02_17], --LTRIM(RTRIM(FC.Descripcion)) AS [RC02_17],
         1 AS [RC02_18], --CAST (ROUND (FC.ValorUnitario,2) AS DECIMAL (15,2)) AS [RC02_18],
         CAST(ROUND(f.SubTotal, 2) AS DECIMAL(15, 2)) AS [RC02_19], 
         TM.TipoMonedaCorto AS [RC02_20], 
         TCD.TipoCambio AS [RC02_21], 
         f.ClaveFormaPago AS [RC02_22], 
         SUM(CASE
                 WHEN ISNULL(r.MontoRegistro, 0) <> 0
                 THEN CAST(ROUND((ISNULL(r.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                 ELSE 0
             END) AS [RC02_23],
         CASE tr.IdMetodoPago
             WHEN 6
             THEN 1
             ELSE 0
         END AS [RC02_24],
         CASE tr.IdMetodoPago
             WHEN 4
             THEN 1
             ELSE 0
         END AS [RC02_25],
         CASE tr.IdMetodoPago
             WHEN 1
             THEN 1
             ELSE 0
         END AS [RC02_26],
         CASE tr.IdMetodoPago
             WHEN 2
             THEN 1
             ELSE 0
         END AS [RC02_27],
         CASE tr.IdMetodoPago
             WHEN 3
             THEN 1
             ELSE 0
         END AS [RC02_28],
         CASE tr.IdMetodoPago
             WHEN 5
             THEN 1
             ELSE 0
         END AS [RC02_29], 
         ISNULL(EPT.IdDocFacturacionSIPAC, 'NA') AS [RC02_30], 
         2 AS [RC02_31]           --EPT.IdClasificacionDocumento AS [RC02_31],     
         FROM FI_Transfer tr WITH(NOLOCK)
              LEFT JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer
              LEFT JOIN FI_Factura f WITH(NOLOCK) ON tf.IdFactura = f.IdFactura
              --LEFT JOIN FI_CFDIConcepto FC ON F.IdFactura = FC.IdFactura
              LEFT JOIN CO_Registro r WITH(NOLOCK) ON r.IdFactura = f.IdFactura
              LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
              LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
              LEFT JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
              LEFT JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato
              LEFT JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
              LEFT JOIN PV_Subcontratista S WITH(NOLOCK) ON f.IdSubcontratista = S.IdSubcontratista
              LEFT JOIN PV_TipoMoneda TM WITH(NOLOCK) ON f.IdMoneda = TM.IdMoneda
              LEFT JOIN CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                AND DAY(TCD.Fecha) = DAY(f.Fecha)
                                                                AND MONTH(TCD.Fecha) = MONTH(f.Fecha)
                                                                AND YEAR(TCD.Fecha) = YEAR(f.Fecha)
              LEFT JOIN FI_EstudioPreciosTransfer EPT WITH(NOLOCK) ON f.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
              LEFT JOIN CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.idcontratista = con.IdContratista
                                                               AND f.IdSubcontratista = RE.IdRelacionada
         WHERE c.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
               AND r.IdEstado = 10004
               AND ISNULL(CONVERT(INT, f.ProcesadoSIPAC), 0) = 0
               AND p.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN lpm.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END
               --AND p.idpresupuesto = @IdPresupuesto

               AND r.CvTipoDocFacturacion = 1
         GROUP BY
         --F.IdFactura,
         --F.IdSubcontratista,
         con.IDSIPAC, 
         c.IDRegFiducidiario, 
         r.MesPresentacion, 
         f.IdDocFacturacionSIPAC, 
         f.ArchivoXML,
         CASE
             WHEN S.Relacionada = 1
             THEN 1
             ELSE 2
         END, 
         f.UUID, 
         f.FechaTimbrado, 
         f.Emisor, 
         S.RazonSocial, 
         S.NombreVialidad, 
         S.NumExterior, 
         S.NumInterior, 
         S.CodigoPostal, 
         S.Colonia, 
         S.Municipio, 
         S.Entidad,
         --FC.Cantidad,
         --FC.Unidad,
         --FC.Descripcion,
         --FC.ValorUnitario,
         f.SubTotal, 
         TM.TipoMonedaCorto, 
         TCD.TipoCambio, 
         tr.IdMetodoPago, 
         f.ClaveFormaPago,
         CASE tr.IdMetodoPago
             WHEN 6
             THEN 1
             ELSE 0
         END,
         CASE tr.IdMetodoPago
             WHEN 4
             THEN 1
             ELSE 0
         END,
         CASE tr.IdMetodoPago
             WHEN 1
             THEN 1
             ELSE 0
         END,
         CASE tr.IdMetodoPago
             WHEN 2
             THEN 1
             ELSE 0
         END,
         CASE tr.IdMetodoPago
             WHEN 3
             THEN 1
             ELSE 0
         END,
         CASE tr.IdMetodoPago
             WHEN 5
             THEN 1
             ELSE 0
         END, 
         EPT.IdClasificacionDocumento, 
         EPT.IdDocFacturacionSIPAC, 
         RE.IdRelacionada;

         --EXEC sp_SIPAC_ReporteGastos_RCCONT02M 10003,'2016-06-01',10006

     END;
