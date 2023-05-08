-- =============================================
-- Author:		Manuel Cruz
-- Create date: 19-06-17
-- Description:	
-- =============================================
-- 20180801	BAAC	Se modifica para redondear el precio de los hidrocarburos a 2 decimales
-- 20190319	BAAC	Se agrega el usuario
-- =============================================
-- Author:		Marcos Neri
-- Alter Date:	2020-01-21
-- Description:	Agregar JOIN con Nueva Tabla FI_FacturasContratosVolPre
-- =============================================
CREATE PROCEDURE [dbo].[SP_LI_SIPAC_OperacionesComercializacion] 
-- [SP_LI_SIPAC_OperacionesComercializacion] 10011,'2017-03-01'
-- Add the parameters for the stored procedure here
@Contrato  INT, 
@Mes       DATE, 
@IdUsuario INT  = 1
AS
     BEGIN
         SET NOCOUNT ON;
         DECLARE @ContNumeroProcesado INT;
         --======================================================
         SET @ContNumeroProcesado =
         (
             SELECT MAX(NumeroProcesado)
             FROM dbo.FI_FacturasContratosVolPre
             WHERE Mes = @Mes
                   AND IdContrato = @Contrato
         );
         --====================================================== 
         SELECT CC.IDSIPAC AS RF_00, 
                C.IdRegFiducidiario AS RI_00, 
                C.NumeroContrato AS RF01_01, 
                COM_OC.FechaTransaccion AS RMLCT27_00, 
                ROW_NUMBER() OVER(ORDER BY FI_F.Fecha) AS RMLCT27_01, 
                CO_TH.TipoHidrocarburo AS RMLCT27_02, 
                ROUND(COM_OC.VolumenVendido, 0) AS RMLCT27_03, 
                ROUND(COM_OC.PrecioVentaUnitario, 4) AS RMLCT27_04, 
                ROUND(COM_OC.CostoUnitarioComercializacion, 4) AS RMLCT27_05, 
                (ROUND(COM_OC.PrecioVentaUnitario, 4) - ROUND(COM_OC.CostoUnitarioComercializacion, 4)) AS RMLCT27_06, 
                FI_F.UUID AS RMLCT27_07, 
                F_VC.IdDocFacturacionSIPAC AS RMLCT27_08, 
                F_VC.ArchivoXML AS RMLCT27_09, 
                COM_OC.NumeroFolioPedimento AS RMLCT27_10, 
                CONVERT(INT, COM_OC.EPT) AS RMLCT27_11, 
                CONVERT(INT, COM_OC.OperacionBajoReglasMercado) AS RMLCT27_12, 
                2 AS RMLCT27_13
         FROM dbo.COM_OperacionComercializacion COM_OC(NOLOCK)
              JOIN dbo.FI_Factura FI_F(NOLOCK) ON COM_OC.IdFactura = FI_F.IdFactura
              JOIN dbo.FI_FacturasContratosVolPre F_VC(NOLOCK) ON F_VC.IdFactura = FI_F.IdFactura
                                                                  AND F_VC.Mes = COM_OC.MesReporte
                                                                  AND F_VC.IdContrato = COM_OC.IdContrato
              JOIN dbo.CO_Contrato C(NOLOCK) ON C.IdContrato = COM_OC.IdContrato
              JOIN dbo.CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
              JOIN dbo.CO_TipoHidrocarburo CO_TH ON COM_OC.IdTipoHidrocarburo = CO_TH.IdTipoHidrocarburo
         WHERE C.IdContrato = @Contrato
               AND COM_OC.MesReporte = @Mes
               AND F_VC.NumeroProcesado = @ContNumeroProcesado;
     END;