CREATE PROCEDURE [dbo].[SP_PC_GenerarComercializacionesGas] -- Add the parameters for the stored procedure here
@IdContrato INT,
@MesReporte DATE
AS
     BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
         SET NOCOUNT ON; 
    

    ----================================================================================
    ----    Distribucion Volumetrica Gas
    ----================================================================================
    -- DROP TABLE #DistGas;
    --         SELECT Denominación AS PuntoVenta,
    --                [Texto breve de material] AS Producto,
    --                SUM(DI.[Distribución Volumétrica]) AS VolumenEKBalam,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS Porcentaje,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenDistribucionC1,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenDistribucionC2,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenDistribucionC3,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenDistribucionC4,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenFacturado,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS FactorDistribucionC1,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS FactorDistribucionC2,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS FactorDistribucionC3,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS FactorDistribucionC4
    --         INTO #DistGas
    --         FROM PC_DistribucionIngresos DI
    --         WHERE Des#Cmpo# IN('Ek', 'Balam')
    --         AND [Texto breve de material] NOT LIKE '%istmo%'
    --         AND [Texto breve de material] LIKE '%gas%'
    --         GROUP BY Denominación,
    --                  [Texto breve de material];
    --         DECLARE @sumagas AS FLOAT;
    --         SELECT @sumagas = SUM(VolumenEKBalam)
    --         FROM #DistGas;
    --         SELECT @sumagas AS VolumenTotalGasDI;
    --         UPDATE #DistGas
    --           SET
    --               Porcentaje = VolumenEKBalam / (@sumagas);
    --         DECLARE @distribuciontotalC1 AS DECIMAL;
    --         DECLARE @distribuciontotalC2 AS DECIMAL;
    --         DECLARE @distribuciontotalC3 AS DECIMAL;
    --         DECLARE @distribuciontotalC4 AS DECIMAL;
    --         SELECT @distribuciontotalC1 = C1,
    --                @distribuciontotalC2 = C2,
    --                @distribuciontotalC3 = C3,
    --                @distribuciontotalC4 = C4
    --         FROM PC_Volumenes;
    --         SELECT @distribuciontotalC1 AS VolumenDistribucionFMPC1,
    --                @distribuciontotalC2 AS VolumenDistribucionFMPC2,
    --                @distribuciontotalC3 AS VolumenDistribucionFMPC3,
    --                @distribuciontotalC4 AS VolumenDistribucionFMPC4;
    --         UPDATE #DistGas
    --           SET
    --               VolumenDistribucionC1 = @distribuciontotalC1 * Porcentaje,
    --               VolumenDistribucionC2 = @distribuciontotalC2 * Porcentaje,
    --               VolumenDistribucionC3 = @distribuciontotalC3 * Porcentaje,
    --               VolumenDistribucionC4 = @distribuciontotalC4 * Porcentaje;
    --         DROP TABLE #FacturasGas;
    --         SELECT DISTINCT
    --                CFDI.IdFactura,
    --                EPV.Denominación,
    --                DI.[Texto breve de material] AS Producto,
    --                C.cantidad,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS Factor
    --         INTO #FacturasGas
    --         FROM PC_DistribucionIngresos DI
    --              JOIN PC_ReporteComercializacion RC ON DI.[Texto breve de material] = RC.Denominación
    --              JOIN PC_EquivalenciaPuntoVenta EPV ON EPV.Denominación = DI.Denominación
    --                                                    AND EPV.[Nombre 1] = RC.[Nombre 1]
    --              LEFT JOIN PC_Facturas F ON CONCAT('00', RC.Factura) = F.FACTURA
    --              JOIN FI_Factura CFDI ON F.UUID = CFDI.UUID
    --              JOIN FI_CFDIConcepto C ON C.IdFactura = CFDI.IdFactura
    --         WHERE Des#Cmpo# IN('Ek', 'Balam')
    --              AND RC.[Cantidad facturada] > 0
    --              AND RC.[Importe] > 0
    --              AND C.Descripcion LIKE '%Gas%'
    --              AND MONTH(CFDI.fecha) = 9
    --              AND YEAR(CFDI.fecha) = 2017
    --         GROUP BY CFDI.IdFactura,
    --                  EPV.Denominación,
    --                  DI.[Texto breve de material],
    --                  C.cantidad
    --         ORDER BY EPV.Denominación;

         SELECT pvp.IdPtoExpedicionRecepcion,
                di.IdMaterialPC,
                SUM(DI.DistribucionVolumetrica) AS VolumenEKBalam,
                CAST(0.0000000000000000000000000 AS FLOAT) AS Porcentaje,
                CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenDistribucionC1,
                CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenDistribucionC2,
                CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenDistribucionC3,
                CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenDistribucionC4,
                CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenFacturado,
                CAST(0.0000000000000000000000000 AS FLOAT) AS FactorDistribucionC1,
                CAST(0.0000000000000000000000000 AS FLOAT) AS FactorDistribucionC2,
                CAST(0.0000000000000000000000000 AS FLOAT) AS FactorDistribucionC3,
                CAST(0.0000000000000000000000000 AS FLOAT) AS FactorDistribucionC4
         INTO #DistGas
         FROM PC_DistribucionIngresos DI
              JOIN PC_Campo C ON C.idcampo = DI.idcampo
              JOIN PC_ContratoCampo CC ON CC.idcampo = C.idcampo
              JOIN PC_PuntoVentaProducto PVP ON PVP.Idcontrato = cc.idcontrato
                                                AND pvp.IdPtoExpedicionRecepcion = di.IdPtoExpedicionRecepcion
                                                AND pvp.IdMaterialPC = di.IdMaterialPC
         WHERE pvp.aplica = 1 --AND [Texto breve de material] NOT LIKE '%istmo%'
               AND CC.idcontrato = @IdContrato --Des#Cmpo# IN('Ek', 'Balam')
			--AND cast( DI.MesReporte AS date)=  @MesReporte
               AND di.IdMaterialPC IN(10013, 10014, 10015, 10017)--AND [Texto breve de material] LIKE '%crudo%'
         GROUP BY pvp.IdPtoExpedicionRecepcion,
                  di.IdMaterialPC;
			

			--   select * from PC_Material  where TextoBreve like  '%gas%' 

         DECLARE @sumagas AS FLOAT;
         SELECT @sumagas = 2525.108818;
    --         FROM #DistGas;
    --         SELECT @sumagas AS VolumenTotalGasDI;



         UPDATE #DistGas
           SET
               Porcentaje = VolumenEKBalam / (@sumagas);
         DECLARE @distribuciontotalC1 AS DECIMAL;
         DECLARE @distribuciontotalC2 AS DECIMAL;
         DECLARE @distribuciontotalC3 AS DECIMAL;
         DECLARE @distribuciontotalC4 AS DECIMAL;
         SELECT @distribuciontotalC1 = 1819.494184;
         SELECT @distribuciontotalC2 = 350.9607921;
         SELECT @distribuciontotalC3 = 215.7417322;
         SELECT @distribuciontotalC4 = 138.9121099;
            -- FROM PC_Volumenes;

         SELECT @distribuciontotalC1 AS VolumenDistribucionFMPC1,
                @distribuciontotalC2 AS VolumenDistribucionFMPC2,
                @distribuciontotalC3 AS VolumenDistribucionFMPC3,
                @distribuciontotalC4 AS VolumenDistribucionFMPC4;
         UPDATE #DistGas
           SET
               VolumenDistribucionC1 = @distribuciontotalC1 * Porcentaje,
               VolumenDistribucionC2 = @distribuciontotalC2 * Porcentaje,
               VolumenDistribucionC3 = @distribuciontotalC3 * Porcentaje,
               VolumenDistribucionC4 = @distribuciontotalC4 * Porcentaje;
    --         DROP TABLE #FacturasGas;
    --         SELECT DISTINCT
    --                CFDI.IdFactura,
    --                EPV.Denominación,
    --                DI.[Texto breve de material] AS Producto,
    --                C.cantidad,
    --                CAST(0.0000000000000000000000000 AS FLOAT) AS Factor
    --         INTO #FacturasGas
    --         FROM PC_DistribucionIngresos DI
    --              JOIN PC_ReporteComercializacion RC ON DI.[Texto breve de material] = RC.Denominación
    --              JOIN PC_EquivalenciaPuntoVenta EPV ON EPV.Denominación = DI.Denominación
    --                                                    AND EPV.[Nombre 1] = RC.[Nombre 1]
    --              LEFT JOIN PC_Facturas F ON CONCAT('00', RC.Factura) = F.FACTURA
    --              JOIN FI_Factura CFDI ON F.UUID = CFDI.UUID
    --              JOIN FI_CFDIConcepto C ON C.IdFactura = CFDI.IdFactura
    --         WHERE Des#Cmpo# IN('Ek', 'Balam')
    --              AND RC.[Cantidad facturada] > 0
    --              AND RC.[Importe] > 0
    --              AND C.Descripcion LIKE '%Gas%'
    --              AND MONTH(CFDI.fecha) = 9
    --              AND YEAR(CFDI.fecha) = 2017
    --         GROUP BY CFDI.IdFactura,
    --                  EPV.Denominación,
    --                  DI.[Texto breve de material],
    --                  C.cantidad
    --         ORDER BY EPV.Denominación;

         DELETE FROM pc_facturasgas;
         INSERT INTO pc_facturasgas
                SELECT DISTINCT
                       CFDI.IdFactura,
                       EPV.IdPtoExpedicionRecepcion AS IdPtoExpedicionRecepcion,
                       DI.IdMaterialPC AS IdMaterialPC,
                       C.cantidad,
                       CAST(0.0000000000000000000000000 AS FLOAT) AS Factor
                FROM PC_DistribucionIngresos DI
                     JOIN PC_Material M ON m.IdMaterialPC = di.IdMaterialPC
                     JOIN PC_Comercializacion RC ON m.TextoBreve = RC.Denominación
                     JOIN PC_EquivalenciaPuntoVenta EPV ON EPV.IdPtoExpedicionRecepcion = DI.IdPtoExpedicionRecepcion
                                                           AND EPV.[Nombre 1] = RC.[Nombre 1]
                     LEFT JOIN #PC_Facturas F ON CONCAT('00', RC.Factura) = F.FACTURA
                     JOIN FI_Factura CFDI ON F.UUID = CFDI.UUID
                     JOIN FI_CFDIConcepto C ON C.IdFactura = CFDI.IdFactura
                     JOIN PC_Campo CA ON CA.idcampo = DI.idcampo
                     JOIN PC_ContratoCampo CC ON CC.idcampo = CA.idcampo
                     JOIN PC_PuntoVentaProducto PVP ON PVP.Idcontrato = cc.idcontrato
                                                       AND pvp.IdPtoExpedicionRecepcion = di.IdPtoExpedicionRecepcion
                                                       AND pvp.IdMaterialPC = di.IdMaterialPC
                WHERE RC.[Cantidad facturada] > 0
                      AND RC.[Importe] > 0
                      AND pvp.aplica = 1
				  AND pvp.IdPtoExpedicionRecepcion = 10023

                      AND CC.idcontrato = @IdContrato
                      AND di.IdMaterialPC IN(10013, 10014, 10015, 10017)
                     AND MONTH(CFDI.fecha) = MONTH(@MesReporte)
                     AND YEAR(CFDI.fecha) = YEAR(@MesReporte)
                GROUP BY CFDI.IdFactura,
                         EPV.IdPtoExpedicionRecepcion,
                         DI.IdMaterialPC,
                         C.cantidad;
         SELECT *
         FROM pc_facturasgas;
       --  DROP TABLE #VolumenFacturado;

	    CREATE TABLE #VolumenFacturadoGas
         (IdPtoExpedicionRecepcion INT,
          IdMaterialPC             INT,
          VolumenFacturado         FLOAT
         );
         INSERT INTO #VolumenFacturadogas
	                  SELECT IdPtoExpedicionRecepcion,
                       IdMaterialPC,
                       SUM(cantidad) AS VolumenFacturado
                FROM pc_facturasgas
                GROUP BY IdPtoExpedicionRecepcion,
                         IdMaterialPC;
          
             UPDATE DC
               SET
                   VolumenFacturado = VF.VolumenFacturado * 0.94781712,
                   FactorDistribucionC1 = DC.VolumenDistribucionC1 / (VF.VolumenFacturado * 0.94781712),
                   FactorDistribucionC2 = DC.VolumenDistribucionC2 / (VF.VolumenFacturado * 0.94781712),
                   FactorDistribucionC3 = DC.VolumenDistribucionC3 / (VF.VolumenFacturado * 0.94781712),
                   FactorDistribucionC4 = DC.VolumenDistribucionC4 / (VF.VolumenFacturado * 0.94781712)
             FROM #DistGas DC
                  JOIN #VolumenFacturadoGas VF ON DC.IdPtoExpedicionRecepcion = VF.IdPtoExpedicionRecepcion
                                               AND DC.IdMaterialPC = VF.IdMaterialPC;
             SELECT *
             FROM #DistGas;
    -- INSERT INTO COM_OPERACIONCOMERCIALIZACION
    --C1
  --  INSERT INTO COM_OPERACIONCOMERCIALIZACION
             SELECT 10010, --IdContrato
                    @MesReporte, --MesReporte
                    F.Fecha, --FechaTransaccion    
                    10002, --     IdTipoHidrocarburo     10002: Metano      10003: Etano       10004: Propano  10005: Butano
                    C.Cantidad * E.Factor * DC.FactorDistribucionC1, --VolumenVendido  
                    ((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor), --PrecioVentaUnitario
                    1.2, --CostoUnitarioComercializacion
                    (((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)) - 1.12, --PrecioPuntoMedicion
                    F.IdFactura,
                    '000000000000000', --NumeroFolioPedimento
                    1, --EPT
                    1, --OperacionBajoReglasMercado
                    2, --ClasificacionDocumentoSoporte
                    1, --CreadoPor
                    GETDATE(), --CreadoEl
                    1, --ModificadoPor
                    GETDATE(), --ModificadoEl
                    1   ---Activo
             FROM pc_facturasgas FG
                  JOIN #DistGas DC ON FG.IdPtoExpedicionRecepcion = DC.IdPtoExpedicionRecepcion
                                      AND FG.IdMaterialPC = DC.IdMaterialPC
                  JOIN FI_FACTURA F(NOLOCK) ON F.idfactura = FG.idfactura
                  JOIN FI_CFDIConcepto C(NOLOCK) ON F.IDFACTURA = C.IDFACTURA
                  JOIN COM_Equivalencias E ON C.Unidad = E.Unidad
                  JOIN CO_TipoCambioDiario T ON F.IdMoneda = T.IdMoneda
                                                AND CONVERT(DATE, F.Fecha) = T.Fecha;
    --C2
  --  INSERT INTO COM_OPERACIONCOMERCIALIZACION
             SELECT 10010, --IdContrato
                   @MesReporte, --MesReporte
                    F.Fecha, --FechaTransaccion    
                    10003, --     IdTipoHidrocarburo     10002: Metano      10003: Etano       10004: Propano  10005: Butano
                    C.Cantidad * E.Factor * DC.FactorDistribucionC2, --VolumenVendido  
                    ((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor), --PrecioVentaUnitario
                    1.12, --CostoUnitarioComercializacion
                    (((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)) - 1.12, --PrecioPuntoMedicion
                    F.IdFactura,
                    '000000000000000', --NumeroFolioPedimento
                    1, --EPT
                    1, --OperacionBajoReglasMercado
                    2, --ClasificacionDocumentoSoporte
                    1, --CreadoPor
                    GETDATE(), --CreadoEl
                    1, --ModificadoPor
                    GETDATE(), --ModificadoEl
                    1   ---Activo
             FROM pc_facturasgas FG
                  JOIN #DistGas DC ON FG.IdPtoExpedicionRecepcion = DC.IdPtoExpedicionRecepcion
                                      AND FG.IdMaterialPC = DC.IdMaterialPC
                  JOIN FI_FACTURA F(NOLOCK) ON F.idfactura = FG.idfactura
                  JOIN FI_CFDIConcepto C(NOLOCK) ON F.IDFACTURA = C.IDFACTURA
                  JOIN COM_Equivalencias E ON C.Unidad = E.Unidad
                  JOIN CO_TipoCambioDiario T ON F.IdMoneda = T.IdMoneda
                                                AND CONVERT(DATE, F.Fecha) = T.Fecha;
    --C3
  --  INSERT INTO COM_OPERACIONCOMERCIALIZACION
             SELECT 10010, --IdContrato
                   @MesReporte, --MesReporte
                    F.Fecha, --FechaTransaccion    
                    10004, --     IdTipoHidrocarburo     10002: Metano      10003: Etano       10004: Propano  10005: Butano
                    C.Cantidad * E.Factor * DC.FactorDistribucionC3, --VolumenVendido  
                    ((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor), --PrecioVentaUnitario
                    1.12, --CostoUnitarioComercializacion
                    (((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)) - 1.12, --PrecioPuntoMedicion
                    F.IdFactura,
                    '000000000000000', --NumeroFolioPedimento
                    1, --EPT
                    1, --OperacionBajoReglasMercado
                    2, --ClasificacionDocumentoSoporte
                    1, --CreadoPor
                    GETDATE(), --CreadoEl
                    1, --ModificadoPor
                    GETDATE(), --ModificadoEl
                    1   ---Activo
             FROM pc_facturasgas FG
                  JOIN #DistGas DC ON FG.IdPtoExpedicionRecepcion = DC.IdPtoExpedicionRecepcion
                                      AND FG.IdMaterialPC = DC.IdMaterialPC
                  JOIN FI_FACTURA F(NOLOCK) ON F.idfactura = FG.idfactura
                  JOIN FI_CFDIConcepto C(NOLOCK) ON F.IDFACTURA = C.IDFACTURA
                  JOIN COM_Equivalencias E ON C.Unidad = E.Unidad
                  JOIN CO_TipoCambioDiario T ON F.IdMoneda = T.IdMoneda
                                                AND CONVERT(DATE, F.Fecha) = T.Fecha;
    --C4
   -- INSERT INTO COM_OPERACIONCOMERCIALIZACION
             SELECT 10010, --IdContrato
                    @MesReporte, --MesReporte
                    F.Fecha, --FechaTransaccion    
                    10005, --     IdTipoHidrocarburo     10002: Metano      10003: Etano       10004: Propano  10005: Butano
                    C.Cantidad * E.Factor * DC.FactorDistribucionC4, --VolumenVendido  
                    ((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor), --PrecioVentaUnitario
                    1.12, --CostoUnitarioComercializacion
                    (((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)) - 1.12, --PrecioPuntoMedicion
                    F.IdFactura,
                    '000000000000000', --NumeroFolioPedimento
                    1, --EPT
                    1, --OperacionBajoReglasMercado
                    2, --ClasificacionDocumentoSoporte
                    1, --CreadoPor
                    GETDATE(), --CreadoEl
                    1, --ModificadoPor
                    GETDATE(), --ModificadoEl
                    1   ---Activo
             FROM pc_facturasgas FG
                  JOIN #DistGas DC ON FG.IdPtoExpedicionRecepcion = DC.IdPtoExpedicionRecepcion
                                      AND FG.IdMaterialPC = DC.IdMaterialPC
                  JOIN FI_FACTURA F(NOLOCK) ON F.idfactura = FG.idfactura
                  JOIN FI_CFDIConcepto C(NOLOCK) ON F.IDFACTURA = C.IDFACTURA
                  JOIN COM_Equivalencias E ON C.Unidad = E.Unidad
                  JOIN CO_TipoCambioDiario T ON F.IdMoneda = T.IdMoneda
                                                AND CONVERT(DATE, F.Fecha) = T.Fecha;

         DELETE FROM COM_OperacionComercializacion
         WHERE VolumenVendido < .5
          --     AND IdTipoHidrocarburo = 10000
               AND MesReporte = @MesReporte;

         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;
