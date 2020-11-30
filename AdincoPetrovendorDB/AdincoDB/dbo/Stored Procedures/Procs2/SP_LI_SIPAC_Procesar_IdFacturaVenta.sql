-- =============================================
-- Author: Manuel Cruz
-- Create date: 2017-04-10
-- Description: 
-- 20190319	BAAC	Se agrega el usuario
-- =============================================
-- Author:		Marcos Garcia
-- Alter Date:	2020-01-21
-- Description: Agregar Insert a Tabla
--				 FI_FacturasContratosVolPre
-- =============================================
CREATE PROCEDURE [dbo].[SP_LI_SIPAC_Procesar_IdFacturaVenta] 
-- [SP_LI_SIPAC_Procesar_IdFacturaVenta] 10011,'2017-03-01',1
-- Add the parameters for the stored procedure here
@Contrato  INT, 
@Mes       DATE, 
@IdUsuario INT  = 1
AS
     BEGIN
         SET NOCOUNT ON;
         DECLARE @ContNumeroProcesado INT;
         --======================================================
         IF OBJECT_ID('tempdb..#FI_Factura', 'U') IS NOT NULL
             DROP TABLE #FI_Factura;		
         --======================================================
         CREATE TABLE #FI_Factura
         (IdFactura  INT, 
          IdContrato INT, 
          SIPAC      INT
         );
         --======================================================
         INSERT INTO #FI_Factura
                SELECT F.IdFactura, 
                       COM_OC.IdContrato, 
                       ROW_NUMBER() OVER(ORDER BY F.Fecha, 
                                                  F.IdSubcontratista) AS SIPAC
                FROM COM_OperacionComercializacion COM_OC(NOLOCK)
                     JOIN FI_Factura F(NOLOCK) ON COM_OC.IdFactura = F.IdFactura
                     JOIN CO_Contrato C(NOLOCK) ON C.IdContrato = COM_OC.IdContrato
                     JOIN CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
                     JOIN CO_TipoHidrocarburo CO_TH ON COM_OC.IdTipoHidrocarburo = CO_TH.IdTipoHidrocarburo
                WHERE C.IdContrato = @Contrato
                      AND COM_OC.MesReporte = @Mes
                GROUP BY F.IdFactura, 
                         COM_OC.IdContrato, 
                         F.Fecha, 
                         F.IdSubcontratista;
         --======================================================
         IF EXISTS
         (
             SELECT *
             FROM dbo.FI_FacturasContratosVolPre FVP
                  JOIN #FI_Factura FIT ON FIT.IdFactura = FVP.IdFactura
             WHERE FVP.Mes = @Mes
                   AND FVP.IdContrato = @Contrato
         )
             BEGIN
                 --
                 SET @ContNumeroProcesado =
                 (
                     SELECT MAX(NumeroProcesado) + 1
                     FROM dbo.FI_FacturasContratosVolPre
                     WHERE Mes = @Mes
                           AND IdContrato = @Contrato
                 );
                 --- 
                 INSERT INTO dbo.FI_FacturasContratosVolPre
                 (IdFactura, 
                  IdContrato, 
                  Mes, 
                  IdDocFacturacionSIPAC, 
                  ArchivoXML, 
                  CreadoPor, 
                  CreadoEn, 
                  NumeroProcesado
                 )
                        SELECT FIT.IdFactura, 
                               @Contrato, 
                               @Mes, 
                               'CF-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6), 
                               'CF_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6)+'.xml', 
                               NULL, 
                               GETDATE(), 
                               @ContNumeroProcesado
                        FROM #FI_Factura FIT;
             END;
             ELSE
             BEGIN
                 INSERT INTO dbo.FI_FacturasContratosVolPre
                 (IdFactura, 
                  IdContrato, 
                  Mes, 
                  IdDocFacturacionSIPAC, 
                  ArchivoXML, 
                  CreadoPor, 
                  CreadoEn, 
                  NumeroProcesado
                 )
                 SELECT FIT.IdFactura, 
                        @Contrato, 
                        @Mes, 
                        'CF-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6), 
                        'CF_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6)+'.xml', 
                        NULL, 
                        GETDATE(), 
                        1
                 FROM #FI_Factura FIT;
             END;
                 --======================================================
                 --UPDATE dbo.FI_Factura
                 --  SET 
                 --      IdDocFacturacionSIPAC = 'CF-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6), 
                 --      ArchivoXML = 'CF_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6)+'.xml'
                 --FROM FI_Factura FI
                 --     JOIN #FI_Factura FIT ON FI.IdFactura = FIT.IdFactura;
                 --SP_LI_SIPAC_Procesar_IdFacturaVenta 10011,'2017-03-01'
     END;