-- =============================================
-- Author:Reyna Olvera
-- Create date: 27-06-2018
-- Description:	
-- =============================================
-- Author:		Marcos Neri
-- Alter Date:	2020-01-21
-- Description:	Agregar JOIN con Nueva Tabla FI_FacturasContratosVolPre
-- =============================================
CREATE PROCEDURE [dbo].[SP_LI_SIPAC_ObtenerFacturasVentasXML]
-- [SP_LI_SIPAC_ObtenerFacturasVentasXML] 3,'2017-10-01'
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
         SELECT F.IdFactura, 
                COM_OC.IdContrato, 
                ROW_NUMBER() OVER(ORDER BY F.Fecha, 
                                           F.IdSubcontratista) AS SIPAC, 
                FIAX.ArchivoXML AS xml, 
                F_VC.ArchivoXML
         FROM COM_OperacionComercializacion COM_OC(NOLOCK)
              JOIN FI_Factura F(NOLOCK) ON COM_OC.IdFactura = F.IdFactura
              JOIN dbo.FI_FacturasContratosVolPre F_VC(NOLOCK) ON F_VC.IdFactura = F.IdFactura
                                                                  AND F_VC.Mes = COM_OC.MesReporte
                                                                  AND F_VC.IdContrato = COM_OC.IdContrato
              JOIN CO_Contrato C(NOLOCK) ON C.IdContrato = COM_OC.IdContrato
              JOIN CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
              JOIN CO_TipoHidrocarburo CO_TH ON COM_OC.IdTipoHidrocarburo = CO_TH.IdTipoHidrocarburo
              JOIN FI_ArchivoXml FIAX ON FIAX.IdFactura = F.IdFactura
         WHERE C.IdContrato = @Contrato
               AND COM_OC.MesReporte = @Mes
               AND F_VC.NumeroProcesado = @ContNumeroProcesado;
     END;