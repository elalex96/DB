-- =============================================
-- Author:		Josue Glez
-- Create date: 03-05-2017
-- Description:	Elimina una relacion factura- transferencia
-- =============================================
CREATE PROCEDURE SP_FI_ConsultaRelacionFacturasXTransferencia 
--79
	@idTransfer int
AS
BEGIN

	SET NOCOUNT ON;

   select A.IdTRansferFactura,
A.IdTRansfer, 
A.IdFactura,
      B.[Serie]
      ,B.[Folio]
      ,B.[Fecha]
      ,B.[FormaPago]
      ,B.[SubTotal]
      ,B.[Descuento]
      ,B.[TipoCambio]
      ,C.[TipoMonedaCorto]
      ,B.[MontoConIva]
      ,B.[TipoComprobante]
      ,B.[MetodoPago]
      ,B.[LugarExpedicion]
      ,B.[NumCtaPago]
      ,B.[Emisor]
      ,B.[Receptor]
      ,B.[UUID]
      ,B.[FechaTimbrado]
      ,B.[Tipo]
      ,B.[IdMoneda]
      ,B.[CreadoEn]
      ,B.[ModificadoEn]
from Fi_transferfactura A
inner join FI_factura B on A.IdFactura = B.IdFactura
inner join PV_TipoMoneda C on  C.IdMoneda = B.IdMoneda 
--inner join PV_MetodoPago D on D.idMetodoPago = B.MetodoPago 
where idTransfer = @idTransfer
   
   	
END
