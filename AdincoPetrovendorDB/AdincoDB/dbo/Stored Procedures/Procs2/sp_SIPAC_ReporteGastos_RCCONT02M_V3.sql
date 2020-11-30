CREATE PROCEDURE [dbo].[sp_SIPAC_ReporteGastos_RCCONT02M_V3] 
-- Add the parameters for the stored procedure here
@Contrato      INT,
@Mes           DATETIME,
@IdPresupuesto INT
AS
     BEGIN
         -- =============================================
         -- Author:		Miguel Gomez
         -- Create date:	2017-03-18
         -- Description:	Reporte de CGI - Registro de costos. Plantilla
         --				RC_CONT_02_M
         -- =============================================
         SET NOCOUNT ON;
         
	    DECLARE @CONTRATISTA INT;
         SELECT @CONTRATISTA = Ca.IdContratista
         FROM CO_Contrato Co
              JOIN CO_Contratista Ca ON Co.IdContratista = Ca.IdContratista
         WHERE Co.IdContrato = @Contrato;
         
	    EXEC sp_SIPAC_Procesar_IdPreciosTransfer
              @Contrato,
              @Mes,
              @IdPresupuesto;
         EXEC sp_SIPAC_Procesar_IdFactura
              @Contrato,
              @Mes,
              @IdPresupuesto;
         
	    SELECT --DISTINCT
         --F.IdFactura,
         --F.IdSubcontratista,
         LTRIM(RTRIM(CA.IDSIPAC)) AS [RF_00],
         LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00],
         CONVERT (CHAR(10), (DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1)),103) AS [RC02_00],
         F.IdDocFacturacionSIPAC AS [RC02_01],
         F.ArchivoXML AS [RC02_02],
         CASE
             WHEN ISNULL(RE.IdRelacionada, 2) <> 2
             THEN 1
             ELSE 2
         END AS [RC02_03],
         F.UUID AS [RC02_04],
         F.FechaTimbrado AS [RC02_05],
         F.Emisor AS [RC02_06],
         S.RazonSocial AS [RC02_07],
         ISNULL(S.NombreVialidad, '') AS [RC02_08],
         ISNULL(S.NumExterior, '') AS [RC02_09],
         ISNULL(S.NumInterior, '') AS [RC02_10],
         ISNULL(S.CodigoPostal, '') AS [RC02_11],
         ISNULL(S.Colonia, '') AS [RC02_12],
         ISNULL(S.Municipio, '') AS [RC02_13],
         ISNULL(S.Entidad, '') AS [RC02_14],
         FC.Cantidad AS [RC02_15],
         LTRIM(RTRIM(FC.Unidad)) AS [RC02_16],
         LTRIM(RTRIM(FC.Descripcion)) AS [RC02_17],
         CAST (ROUND (FC.ValorUnitario,2) AS DECIMAL (15,2)) AS [RC02_18],
         CAST (ROUND (F.SubTotal,2) AS DECIMAL (15,2)) AS [RC02_19],
         TM.TipoMonedaCorto AS [RC02_20],
         TCD.TipoCambio AS [RC02_21],
         F.ClaveFormaPago AS [RC02_22],
         CASE
             WHEN ISNULL(R.MontoRegistro, 0) <> 0
             THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio),2)AS DECIMAL(15,2))
             ELSE 0
         END AS [RC02_23],
         CASE TR.IdMetodoPago when 6 then 1 else 0  end AS [RC02_24],
         CASE TR.IdMetodoPago when 4 then 1 else 0  end AS [RC02_25],
         CASE TR.IdMetodoPago when 1 then 1 else 0  end AS [RC02_26],
         CASE TR.IdMetodoPago when 2 then 1 else 0  end AS [RC02_27],
         CASE TR.IdMetodoPago when 3 then 1 else 0  end AS [RC02_28],
         CASE TR.IdMetodoPago when 5 then 1 else 0  end AS [RC02_29],
         EPT.IdDocFacturacionSIPAC AS [RC02_30],
         EPT.IdClasificacionDocumento AS [RC02_31]
         FROM CO_Contrato C
              LEFT JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
              LEFT JOIN CO_AnioContractual AC ON C.IdContrato = AC.IdContrato
              LEFT JOIN CO_Presupuesto P ON AC.IdAnioContractual = P.IdAnioContractual
                                            AND P.IdPresupuesto = @IdPresupuesto
              LEFT JOIN CO_LineaPresupuestoMes LPM ON P.IdPresupuesto = LPM.IdPresupuesto
              LEFT JOIN CO_Registro R ON LPM.IdLineaPresupuestoMes = R.IdPrograma
              LEFT JOIN FI_Factura F ON R.IdFactura = F.IdFactura
              LEFT JOIN FI_CFDIConcepto FC ON F.IdFactura = FC.IdFactura
              LEFT JOIN FI_transferfactura TF ON F.IdFactura = TF.IdFactura
              LEFT JOIN FI_transfer TR ON TF.idtransfer = TR.idtransferencia
              LEFT JOIN PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
              LEFT JOIN PV_TipoMoneda TM ON F.IdMoneda = TM.IdMoneda
              LEFT JOIN CO_TipoCambioDiario TCD ON TCD.IdMoneda = TM.IdMoneda
										  AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                    AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                    AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
              LEFT JOIN FI_EstudioPreciosTransfer EPT ON F.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
              LEFT JOIN CO_RelacionEmpresas RE ON RE.idcontratista = CA.idproveedor
                                                  AND F.idsubcontratista = RE.IdRelacionada
		    --LEFT JOIN FI_Documento D ON F.IdFactura = D.IdFactura
         WHERE C.IdContratista = @Contratista
               AND DATEFROMPARTS(YEAR(TR.FechaPago), MONTH(TR.FechaPago), 1) = @Mes
               AND R.IdEstado = 10004
			AND ISNULL(CONVERT(INT,F.ProcesadoSIPAC),0) = 0
         GROUP BY 
	    --F.IdFactura,
         --F.IdSubcontratista,
         CA.IDSIPAC,
         C.IDRegFiducidiario,
         R.MesPresentacion,
         F.IdDocFacturacionSIPAC,
         F.ArchivoXML,
         CASE
             WHEN S.Relacionada = 1
             THEN 1
             ELSE 2
         END,
         F.UUID,
         F.FechaTimbrado,
         F.Emisor,
         S.RazonSocial,
         S.NombreVialidad,
         S.NumExterior,
         S.NumInterior,
         S.CodigoPostal,
         S.Colonia,
         S.Municipio,
         S.Entidad,
         FC.Cantidad,
         FC.Unidad,
         FC.Descripcion,
         FC.ValorUnitario,
         F.SubTotal,
         TM.TipoMonedaCorto,
         TCD.TipoCambio,
	    TR.IdMetodoPago,
         F.ClaveFormaPago,
         CASE
             WHEN ISNULL(R.MontoRegistro, 0) <> 0
             THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio),2)AS DECIMAL(15,2))
             ELSE 0
         END,
         CASE TR.IdMetodoPago when 6 then 1 else 0  end,
         CASE TR.IdMetodoPago when 4 then 1 else 0  end,
         CASE TR.IdMetodoPago when 1 then 1 else 0  end,
         CASE TR.IdMetodoPago when 2 then 1 else 0  end,
         CASE TR.IdMetodoPago when 3 then 1 else 0  end,
         CASE TR.IdMetodoPago when 5 then 1 else 0  end,
         EPT.IdClasificacionDocumento,
         EPT.IdDocFacturacionSIPAC,
         RE.IdRelacionada;
         --EXEC sp_SIPAC_ReporteGastos_RCCONT02M_V3 10003,'2017-04-01',10023
     END;

