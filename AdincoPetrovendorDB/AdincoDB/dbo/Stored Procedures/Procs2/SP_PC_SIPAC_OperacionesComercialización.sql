-- =============================================
-- Author:		Manuel Cruz
-- Create date: 05-06-17
-- Description:	
-- =============================================
-- 20180801	BAAC	Se modifica para redondear el precio de los hidrocarburos a 2 decimales
-- =============================================
-- Author:		Marcos Neri
-- Alter date: 2020-01-21
-- Description:	Agregar JOIN con Nueva Tabla FI_FacturasContratosVolPre
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_SIPAC_OperacionesComercialización]
-- [SP_PC_SIPAC_OperacionesComercialización] 10011,'2017-03-01'
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
                C.IDRegFiducidiario AS RI_00, 
                C.NumeroContrato AS RF01_01, 
                CONVERT(DATE, FI_F.Fecha) AS RMPCT34_00, 
                ROW_NUMBER() OVER(ORDER BY FI_F.Fecha) AS RMPCT34_01,

                --ºººººººººººººººººººººººººººººººººººººººººººººººººººº
                --Para generar archivo Sampayo
                --CONVERT(DATE, COM_OC.FechaTransaccion) AS RMPCT34_00,
                --ROW_NUMBER() OVER(ORDER BY COM_OC.FechaTransaccion) AS RMPCT34_01,
                --ºººººººººººººººººººººººººººººººººººººººººººººººººººº

                CO_TH.TipoHidrocarburo AS RMPCT34_02, 
                ROUND(COM_OC.VolumenVendido, 0) AS RMPCT34_03, 
                ROUND(COM_OC.PrecioVentaUnitario, 4) AS RMPCT34_04, 
                ROUND(COM_OC.CostoUnitarioComercializacion, 4) AS RMPCT34_05, 
                (ROUND(COM_OC.PrecioVentaUnitario, 4) - ROUND(COM_OC.CostoUnitarioComercializacion, 4)) AS RMPCT34_06, 
                FI_F.UUID AS RMLCT34_07, 
                F_VC.IdDocFacturacionSIPAC AS RMLCT34_08, 
                F_VC.ArchivoXML AS RMLCT34_09, 
                COM_OC.NumeroFolioPedimento AS RMLCT34_10, 
                CONVERT(INT, COM_OC.EPT) AS RMLCT34_11, 
                CONVERT(INT, COM_OC.OperacionBajoReglasMercado) AS RMLCT34_12, 
                COM_OC.ClasificacionDocumentoSoporte AS RMLCT34_13
         FROM CO_Contrato C(NOLOCK)
              JOIN CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
              JOIN COM_OperacionComercializacion COM_OC(NOLOCK) ON C.IdContrato = COM_OC.IdContrato
                                                                   AND COM_OC.MesReporte = @Mes
              JOIN FI_Factura FI_F(NOLOCK) ON COM_OC.IdFactura = FI_F.IdFactura
              JOIN dbo.FI_FacturasContratosVolPre F_VC(NOLOCK) ON F_VC.IdFactura = FI_F.IdFactura
                                                                  AND F_VC.Mes = COM_OC.MesReporte
                                                                  AND F_VC.IdContrato = COM_OC.IdContrato
              JOIN CO_TipoHidrocarburo CO_TH ON COM_OC.IdTipoHidrocarburo = CO_TH.IdTipoHidrocarburo
         WHERE C.IdContrato = @Contrato
               AND COM_OC.MesReporte = @Mes
               AND F_VC.NumeroProcesado = @ContNumeroProcesado;
     END;