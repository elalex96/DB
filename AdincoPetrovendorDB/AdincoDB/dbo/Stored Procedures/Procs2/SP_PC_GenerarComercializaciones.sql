CREATE PROCEDURE [dbo].[SP_PC_GenerarComercializaciones] -- Add the parameters for the stored procedure here
@IdContrato INT,
@MesReporte DATE
--@Usuario int
AS
         BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
             SET NOCOUNT ON;
             IF @MesReporte < '20171001'
                 SELECT 'false' AS msj;
                 ELSE
                 BEGIN
    --================================================================================
    --    Distribucion Volumetrica Crudo
    --================================================================================

         --Se seleccionan de la distribucion de ingresos los registros de los puntos de venta elegido, 
	    --pertenecientes a crudo, de los campos del contrato

                     SELECT pvp.IdPtoExpedicionRecepcion,
                            di.IdMaterialPC,
                            SUM(DI.DistribucionVolumetrica) AS VolumenEKBalam,
                            CAST(0.0000 AS FLOAT) AS Porcentaje,
                            CAST(0.0000 AS FLOAT) AS VolumenDistribucion,
                            CAST(0.0000 AS FLOAT) AS VolumenFacturado,
                            CAST(0.0000 AS FLOAT) AS FactorDistribucion
                     INTO #DistCrudo
                     FROM PC_DistribucionIngresos DI
                          JOIN PC_Campo C ON C.idcampo = DI.idcampo
                          JOIN PC_ContratoCampo CC ON CC.idcampo = C.idcampo
                          JOIN PC_PuntoVentaProducto PVP ON PVP.Idcontrato = cc.idcontrato
                                                            AND pvp.IdPtoExpedicionRecepcion = di.IdPtoExpedicionRecepcion
                                                            AND pvp.IdMaterialPC = di.IdMaterialPC
                     WHERE pvp.aplica = 1 --El punto de venta esta selccionado
                           AND CC.idcontrato = @IdContrato --Los campos ligados al contrato
                           AND di.IdMaterialPC IN(10000, 10001, 10002, 10003, 10004, 10005, 10006, 10007, 10008, 10009, 10010, 10016, 10019, 10020) -- Lista de productos que son crudo
                          AND DATEFROMPARTS(SUBSTRING(di.MesReporte, 7, 4), SUBSTRING(di.MesReporte, 4, 2), 1) = @MesReporte
                          AND pvp.Mes = @MesReporte
                     GROUP BY pvp.IdPtoExpedicionRecepcion,
                              di.IdMaterialPC;
                     SELECT *
                     FROM #DistCrudo;
	    --Sumatoria del volumen de crudo de los puntos de venta seleccionados en el paso anterior
                     DECLARE @sumacrudo AS FLOAT;
                     SELECT @sumacrudo = SUM(VolumenEKBalam)
                     FROM #DistCrudo;
                     SELECT @sumacrudo AS VolumenTotalCrudoDI;  ---comentar para web
         
	    --Porcentaje Proporcional de cada volumen entre el total del contrato
                     UPDATE #DistCrudo
                       SET
                           Porcentaje = CONVERT(FLOAT, (VolumenEKBalam / (@sumacrudo)));

	    --Calculo del volumen de crudo a vender basado en reparticion preliminar
                     DECLARE @distribuciontotalp AS DECIMAL(12, 4);
--             DELETE FROM dbo.PC_Volumenes
--             WHERE IdContrato = @IdContrato
--                   AND Mes = @MesReporte;
--             INSERT INTO dbo.PC_Volumenes
--(IdContrato,
-- Mes,
-- Petroleo,
-- Condensado,
-- C1,
-- C2,
-- C3,
-- C4
--)
--                    SELECT @IdContrato, -- IdContrato - int
--                           @MesReporte, -- Mes - date
--                           CASE
--                               WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo < 0
--                               THEN ROUND((VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo, 0)
--                               ELSE ROUND((((VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100)))), 0)
--                           END AS Crudo, -- RMPCT32_28        -- Petroleo - int
--                           CASE
--                               WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado < 0
--                               THEN ROUND((((VMPPG.VolumenCondensadoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado)), 0)
--                               ELSE ROUND(((VMPPG.VolumenCondensadoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
--                           END AS Condensado, -- RMPCT32_33         -- Condensado - int
	     
		
            
--                           CASE
--                               WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 < 0
--                               THEN ROUND(((VMPPG.MetanoC1 * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1), 0)
--                               ELSE ROUND(((VMPPG.MetanoC1 * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
--                           END AS C1, --RMPCT32_29,
              

--                           CASE
--                               WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 < 0
--                               THEN ROUND(((VMPPG.EtanoC2 * (FMP53.NuevaDistribucionProvisionalContratista / 100) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2)), 0)
--                               ELSE ROUND(((VMPPG.EtanoC2 * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
--                           END AS C2, --RMPCT32_30,
            
--                           CASE
--                               WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 < 0
--                               THEN ROUND((((VMPPG.PropanoC3 * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3)), 0)
--                               ELSE ROUND(((VMPPG.PropanoC3 * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
--                           END AS C3, -- RMPCT32_31,
         
--                           CASE
--                               WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 < 0
--                               THEN ROUND((((VMPPG.ButanoC4 * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4)), 0)
--                               ELSE ROUND(((VMPPG.ButanoC4 * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
--                           END AS C4 -- RMPCT32_32,
             
            
--                    FROM PR_VolumenMensualProduccionPetroleo VMPPG
--                         LEFT JOIN CO_Contrato C ON VMPPG.IdContrato = C.IdContrato
--                         LEFT JOIN CO_Contratista Ca ON C.IdContratista = Ca.IdContratista
--                         LEFT JOIN SIPAC_RM_FMP_53_M FMP53 ON FMP53.IdContrato = @IdContrato
--                                                              AND DATEADD(month, 1, DATEFROMPARTS(FMP53.anioreporte, FMP53.mesreporte, 1)) = @MesReporte
--                    WHERE VMPPG.IdContrato = @IdContrato
--                          AND VMPPG.MesReporte = @MesReporte;


	   --Se toma el volumen de petroleo a distribuir antes calculado
                     SELECT @distribuciontotalp = Petroleo
                     FROM PC_Volumenes
                     WHERE IdContrato = @IdContrato
                           AND Mes = @MesReporte;
                     SELECT @distribuciontotalp AS VolumenDistribucionFMP;   ---para ver el volumen que se va a distribuir
             
	   --Se actualiza el volumen por cada punto de venta - producto
                     UPDATE #DistCrudo
                       SET
                           VolumenDistribucion = @distribuciontotalp * Porcentaje;

	   --Se seleccionan las facturas de PMI y PTI que pertenecen al mes reporte
                     SELECT RF.*
                     INTO #PC_Facturas
                     FROM dbo.PC_PMI_V2 RF
                          JOIN dbo.FI_Factura F ON F.UUID = RF.UUID
                     WHERE DATEFROMPARTS(YEAR(F.FechaTimbrado), MONTH(F.FechaTimbrado), 1) = @MesReporte
                     UNION
                     SELECT RF.*
                     FROM dbo.PC_PTI_V2 RF
                          JOIN dbo.FI_Factura F ON F.UUID = RF.UUID
                     WHERE DATEFROMPARTS(YEAR(F.FechaTimbrado), MONTH(F.FechaTimbrado), 1) = @MesReporte
                     SELECT *
                     FROM #PC_Facturas

	   --Se borra la tabla donde se procesan
                     DELETE FROM pc_facturascrudo;
        
	   --Se insertan solo aquellas facturas que cumplen con el criterio
                     INSERT INTO pc_facturascrudo
                     SELECT DISTINCT
                            CFDI.IdFactura,
                            EPV.IdPtoExpedicionRecepcion AS IdPtoExpedicionRecepcion,
                            DI.IdMaterialPC AS IdMaterialPC,
                            C.cantidad,
                            CAST(0.0000 AS FLOAT) AS Factor
                     FROM PC_DistribucionIngresos DI
                          JOIN PC_Material M ON m.IdMaterialPC = di.IdMaterialPC
                          JOIN dbo.PC_Comercializacion_V2 RC ON m.TextoBreve = RC.Denominación
                          JOIN PC_EquivalenciaPuntoVenta EPV ON EPV.IdPtoExpedicionRecepcion = DI.IdPtoExpedicionRecepcion
                                                                AND EPV.[Nombre 1] = RC.[Nombre1]
                          JOIN #PC_Facturas F ON CONCAT('00', RC.Factura) = F.FACTURA
                          JOIN FI_Factura CFDI ON F.UUID = CFDI.UUID
                          JOIN FI_CFDIConcepto C ON C.IdFactura = CFDI.IdFactura
                          JOIN PC_Campo CA ON CA.idcampo = DI.idcampo
                          JOIN PC_ContratoCampo CC ON CC.idcampo = CA.idcampo
                          JOIN PC_PuntoVentaProducto PVP ON PVP.Idcontrato = cc.idcontrato
                                                            AND pvp.IdPtoExpedicionRecepcion = di.IdPtoExpedicionRecepcion
                                                            AND pvp.IdMaterialPC = di.IdMaterialPC
                     WHERE RC.[Cantidadfacturada] > 0	 --La factura debe tener un volumen a facturar
                           AND RC.[Importe] > 0		 --El importe no puede ser cero o negativo (nota de credito)
                           AND pvp.aplica = 1			 --La factura de acuerdo a comercializacion pertenece a un punto de venta seleccionado
                           AND CC.idcontrato = @IdContrato
                           AND di.IdMaterialPC IN(10000, 10001, 10002, 10003, 10004, 10005, 10006, 10007, 10008, 10009, 10010, 10016, 10019, 10020)  --El producto facturado es algun petroeleo
                          AND MONTH(CFDI.fecha) = MONTH(@MesReporte)
                          AND YEAR(CFDI.fecha) = YEAR(@MesReporte)
                     GROUP BY CFDI.IdFactura,
                              EPV.IdPtoExpedicionRecepcion,
                              DI.IdMaterialPC,
                              C.cantidad;
                     SELECT *
                     FROM pc_facturascrudo;
                     CREATE TABLE #VolumenFacturado
(IdPtoExpedicionRecepcion INT,
 IdMaterialPC             INT,
 VolumenFacturado         FLOAT
);

	   --Basado en las facturas antes seleccionadas se calcula el volumen facturado por cada punto de venta
                     INSERT INTO #VolumenFacturado
                     SELECT IdPtoExpedicionRecepcion,
                            IdMaterialPC,
                            SUM(cantidad) AS VolumenFacturado
                     FROM pc_facturascrudo
                     GROUP BY IdPtoExpedicionRecepcion,
                              IdMaterialPC;

	   --Se actualiza la tabla de distribucion con los volmenes calculados en el paso anterior
                     UPDATE DC
                       SET
                           VolumenFacturado = VF.VolumenFacturado,
                           FactorDistribucion = DC.VolumenDistribucion / VF.VolumenFacturado
                     FROM #DistCrudo DC
                          JOIN #VolumenFacturado VF ON DC.IdPtoExpedicionRecepcion = VF.IdPtoExpedicionRecepcion
                                                       AND DC.IdMaterialPC = VF.IdMaterialPC;-- FECHA FACTURA PARA PEMEX 

	   --Se borran las comercializaciones anteriores por si ya habia alguna generada con anterioridad de petroleo del mes y del contrato
                     DELETE FROM COM_OperacionComercializacion
                     WHERE idcontrato = @idcontrato
                           AND mesreporte = @MesReporte
                           AND idtipohidrocarburo = 10000;
                     SELECT *
                     FROM #DistCrudo;  ---comentar para web
                     INSERT INTO dbo.COM_OperacionComercializacion

				
                     SELECT @IdContrato, 
    --IdContrato
                            @MesReporte, 
    --MesReporte   cast (@MesReporte as date ),
                            F.Fecha, 
    --FechaTransaccion
                            10000, 
    --     IdTipoHidrocarburo     PETROLEO: 10000     CONDENSADO: 10001
                            C.Cantidad * E.Factor * DC.FactorDistribucion, 
    --VolumenVendido  PETROLEO: 0.02517440463032650        CONDENSADO: 0.00211554376127699
                            ((CONVERT(DECIMAL(12, 4), C.ValorUnitario) / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor), 
    --PrecioVentaUnitario
                            2.19, 
    --CostoUnitarioComercializacion
                            (((CONVERT(DECIMAL(12, 4), C.ValorUnitario) / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)) - 2.19, 
    --PrecioPuntoMedicion
                            F.IdFactura,
                            '000000000000000', 
    --NumeroFolioPedimento
                            1, 
    --EPT
                            1, 
    --OperacionBajoReglasMercado
                            2, 
    --ClasificacionDocumentoSoporte
                            1, 
    --CreadoPor
                            GETDATE(), 
    --CreadoEl
                            1, 
    --ModificadoPor
                            GETDATE(), 
    --ModificadoEl
                            1, ---Activo
					   0,
					   0
                     FROM pc_facturascrudo FC
                          JOIN #DistCrudo DC ON FC.IdPtoExpedicionRecepcion = DC.IdPtoExpedicionRecepcion
                                                AND FC.IdMaterialPC = DC.IdMaterialPC
                          JOIN FI_FACTURA F(NOLOCK) ON F.idfactura = FC.idfactura
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
         END;
