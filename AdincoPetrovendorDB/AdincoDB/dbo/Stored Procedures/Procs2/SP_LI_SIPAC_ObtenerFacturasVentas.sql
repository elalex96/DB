-- SP_LI_SIPAC_ObtenerFacturasVentas 10001,'20181201'
CREATE PROCEDURE [dbo].[SP_LI_SIPAC_ObtenerFacturasVentas]
-- Add the parameters for the stored procedure here
@Contrato INT, 
@Mes      DATE
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT F.IdFactura, 
                COM_OC.IdContrato, 
                ROW_NUMBER() OVER(ORDER BY F.Fecha, 
                                           F.IdSubcontratista) AS SIPAC, 
                F.XML, 
                F.ArchivoXML
         FROM COM_OperacionComercializacion COM_OC(NOLOCK)
              JOIN FI_Factura F(NOLOCK) ON COM_OC.IdFactura = F.IdFactura
              JOIN CO_Contrato C(NOLOCK) ON C.IdContrato = COM_OC.IdContrato --AND COM_OC.MesReporte = @Mes
              JOIN CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
              JOIN CO_TipoHidrocarburo CO_TH ON COM_OC.IdTipoHidrocarburo = CO_TH.IdTipoHidrocarburo
         WHERE C.IdContrato = @Contrato
               AND COM_OC.MesReporte = @Mes
         GROUP BY F.IdFactura, 
                  COM_OC.IdContrato, 
                  F.Fecha, 
                  F.IdSubcontratista, 
                  F.XML, 
                  f.ArchivoXML;
     END;