
-- sp_PC_SIPAC_ObtenerFacturasVentas 10003,'20160501'
create PROCEDURE [dbo].[sp_PC_SIPAC_ObtenerFacturasVentas]
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 05-06-17
-- Description:	
-- =============================================
@Contrato INT,
@Mes      DATE
AS
     BEGIN
         SELECT FI_F.IdFactura,
                FI_F.XML,
                FI_F.ArchivoXML
         FROM CO_Contrato C(NOLOCK)
              JOIN CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
              JOIN COM_OperacionComercializacion COM_OC(NOLOCK) ON C.IdContrato = COM_OC.IdContrato
                                                                   AND COM_OC.MesReporte = @Mes
              JOIN FI_Factura FI_F(NOLOCK) ON COM_OC.IdFactura = FI_F.IdFactura
              JOIN CO_TipoHidrocarburo CO_TH ON COM_OC.IdTipoHidrocarburo = CO_TH.IdTipoHidrocarburo
         WHERE C.IdContrato = @Contrato
               AND COM_OC.MesReporte = @Mes
         GROUP BY FI_F.IdFactura,
                  FI_F.XML,
                  FI_F.ArchivoXML;
     END;