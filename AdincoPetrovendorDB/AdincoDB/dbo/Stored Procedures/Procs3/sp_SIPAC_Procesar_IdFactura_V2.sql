CREATE PROCEDURE [dbo].[sp_SIPAC_Procesar_IdFactura_V2]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN

         -- =============================================
         -- Author: Manuel Cruz
         -- Create date: 2017-04-10
         -- Description:  
         -- =============================================
         -- Modificado:		  Marcos Garcia
         -- Fecha Modificado: 2020-01-23
         -- Description:	  *Agregar Validacion de @IdPresupuesto = 0
         --					  *Agregar WITH (NOLOCK) en las tablas 
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.

         SET NOCOUNT ON;

         -- Insert statements for procedure here

         CREATE TABLE #FI_Factura
         ([IdFactura]  [INT], 
          [IdContrato] [INT], 
          [SIPAC]      [INT]
         );
         INSERT INTO #FI_Factura
                SELECT f.IdFactura, 
                       f.IdContrato, 
                       ROW_NUMBER() OVER(ORDER BY f.Fecha, 
                                                  f.IdSubcontratista) AS SIPAC
                FROM dbo.FI_Transfer tr WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura tf WITH(NOLOCK) ON tf.IdTransfer = tr.IdTransferencia
                     JOIN dbo.FI_Factura f WITH(NOLOCK) ON tf.IdFactura = f.IdFactura
                     --JOIN FI_CFDIConcepto FC ON F.IdFactura = FC.IdFactura
                     JOIN dbo.CO_Registro r WITH(NOLOCK) ON r.IdFactura = f.IdFactura
                     JOIN dbo.CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
                     JOIN dbo.CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
                     JOIN dbo.Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
                     JOIN dbo.co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato
                     JOIN dbo.co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
                     JOIN dbo.PV_Subcontratista S WITH(NOLOCK) ON f.IdSubcontratista = S.IdSubcontratista
                     JOIN dbo.PV_TipoMoneda tm WITH(NOLOCK) ON tr.IdMoneda = tm.IdMoneda
                     JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = tm.IdMoneda
                                                                      AND DAY(TCD.Fecha) = DAY(tr.FechaPago)
                                                                      AND MONTH(TCD.Fecha) = MONTH(tr.FechaPago)
                                                                      AND YEAR(TCD.Fecha) = YEAR(tr.FechaPago)

                --LEFT JOIN FI_EstudioPreciosTransfer EPT ON F.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
                --LEFT JOIN CO_RelacionEmpresas RE ON RE.idcontratista = CON.idproveedor
                --AND F.idsubcontratista = RE.IdRelacionada
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

                GROUP BY f.IdFactura, 
                         f.IdContrato, 
                         f.Fecha, 
                         f.IdSubcontratista;
         --select * from #FI_Factura
         UPDATE dbo.FI_Factura
           SET 
               IdDocFacturacionSIPAC = 'CF-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6), 
               ArchivoXML = 'CF_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6)+'.xml'
         --IdDocFacturacionSIPAC = CONCAT('CF', '-', LEFT('0'+CAST(MONTH(@Mes) AS VARCHAR(2)), 2)+CAST(YEAR(@Mes) AS CHAR(4)), '-', RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6)),
         --ArchivoXML = CONCAT('CF', '_', LEFT('0'+CAST(MONTH(@Mes) AS VARCHAR(2)), 2)+CAST(YEAR(@Mes) AS CHAR(4)), '_', RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6), '.xml')
         FROM FI_Factura FI
              JOIN #FI_Factura FIT ON FI.IdFactura = FIT.IdFactura
         WHERE FI.IdFactura = FIT.IdFactura;

         --EXEC sp_SIPAC_Procesar_IdFactura_V2 3,'2017-03-01',3

     END;
