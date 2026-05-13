-- =============================================  
-- Author:  David De La Cruz  
-- Create date: 0811/2019  
-- Description: Permite agregar LA OPERACION para hacer relacion con un flujo de tareas  
-- =============================================  
create PROCEDURE [dbo].[p_NC_TA_ConsultarNotaCreditoProveedor]  
    -- Add the parameters for the stored procedure here  
 @IdProveedor INT,  
    @IdUsuario INT,  
    @IdAceptacionPedido INT  
AS  
BEGIN  
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
    SET NOCOUNT ON;  
  
  select 
  '' as Descripcion,
  E.Name as Estatus,
  MANC.CreadoEl,
  UC.Nombre AS CargadoPor,
  F.IdFactura,
  F.SubTotal,
  F.MontoConIva,
  MANC.IdAceptacionNotaCredito,
  0 as IdOperacion,
  FechaAprobacion as 'FechaCambioEstatus',
  MANC.Comentario as ComentarioAprobador,
  F.Moneda,  
           F.UUID,  
           MANC.CFDIRelacionados  

   from MPY_MM_AceptacionNotaCredito as MANC
   join TA_Estatus as E on E.IdEstatus = MANC.IdEstatus
   join S_Usuario as UC on UC.IdUsuario = MANC.CreadoPor
   join FI_Factura as F on F.IdFactura = MANC.IdFacturaNotaCredito
   where MANC.IdAceptacionPedido = @IdAceptacionPedido
 
  
END;  
  