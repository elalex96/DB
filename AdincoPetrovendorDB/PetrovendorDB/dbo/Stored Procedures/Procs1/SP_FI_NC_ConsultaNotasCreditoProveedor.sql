-- Author:		Luis David De La Cruz
-- Create date: 12/11/2019
-- Description:	Se agrega las notas de crédito para Murphy
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/09/2019
-- Description:	Lista de Notas de Credito
-- =============================================
create PROCEDURE [dbo].[SP_FI_NC_ConsultaNotasCreditoProveedor]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		select
	 AP.IdAceptacionPedido
	 , '' as Descripcion
	 , E.Nombre AS Estatus
	 ,NC.CreadoEl
	 ,UC.Nombre AS CargadoPor
	 ,F.IdFactura
	 ,F.SubTotal
	 ,F.MontoConIva
	 ,NC.IdAceptacionNotaCredito
	 ,0 as IdOperacion
	 ,Null AS FechaCambioEstatus
	 , '' AS ComentarioAprobador
	 ,F.Moneda
	 ,F.UUID
	 ,NC.CFDIRelacionados
	 ,CASE  
			WHEN E.IdEstatus = 2 THEN 'label label-success'  
			WHEN E.IdEstatus = 1 THEN 'label label-primary'  
			WHEN E.IdEstatus = 3 THEN 'label label-danger'  
			WHEN E.IdEstatus IS NULL THEN 'label label-default'  
		   END AS span,
		Murphy = 1
	
from 
	MPY_MM_AceptacionNotaCredito as NC
	join MPY_MM_AceptacionPedido AP on AP.IdAceptacionPedido = NC.IdAceptacionPedido
	join TA_Estatus as E on E.IdEstatus = NC.IdEstatus
	join S_Usuario as UC on NC.CreadoPor = UC.IdUsuario
	join FI_Factura as F on F.IdFactura = NC.IdFacturaNotaCredito
	join adinco..CO_SAPVendor as t2 on t2.VendorIDSAP collate Modern_Spanish_CI_AS= AP.IdSubContratista collate Modern_Spanish_CI_AS
	join S_Proveedor as p on t2.TaxID collate Modern_Spanish_CI_AS= P.RFC collate Modern_Spanish_CI_AS
	where p.IdProveedor = @IdProveedor
	union
	SELECT 
		   AP.IdAceptacionPedido,
		   O.Descripcion,
           E.Nombre AS Estatus,
           NC.CreadoEl,
           UC.Nombre AS CargadoPor,
           F.IdFactura,
           F.SubTotal,
           F.MontoConIva,
           NC.IdAceptacionNotaCredito,
           O.IdOperacion,
           O.FechaModificacion AS FechaCambioEstatus,
           '' AS ComentarioAprobador,
           F.Moneda,
           F.UUID,
           NC.CFDIRelacionados,
		   CASE  
			WHEN E.IdEstatus = 2 THEN 'label label-success'  
			WHEN E.IdEstatus = 1 THEN 'label label-primary'  
			WHEN E.IdEstatus = 3 THEN 'label label-danger'  
			WHEN E.IdEstatus IS NULL THEN 'label label-default'  
		   END AS span,
		   Murphy = 0
    FROM dbo.MM_AceptacionNotaCredito NC
        LEFT JOIN dbo.MM_AceptacionPedido AP
            ON AP.IdAceptacionPedido = NC.IdAceptacionPedido
        LEFT JOIN dbo.MM_Pedido P
            ON P.IdPedido = AP.IdPedido
        LEFT JOIN dbo.TA_Operacion O
            ON O.IdDocumento = NC.IdAceptacionNotaCredito
               AND O.IdTipoOperacion = 17 --> APROBACIÓN NOTA DE CREDITO
        LEFT JOIN dbo.TA_Estatus E
            ON E.IdEstatus = O.IdEstatusOperacion
        LEFT JOIN dbo.FI_Factura F
            ON F.IdFactura = NC.IdFacturaNotaCredito
        LEFT JOIN dbo.S_Usuario UC
            ON UC.IdUsuario = NC.CreadoPor
    WHERE P.IdSubcontratista = @IdProveedor
          AND ISNULL(NC.IdEstatusEliminada, 0) = 0
    GROUP BY CASE
             WHEN E.IdEstatus = 2 THEN
             'label label-success'
             WHEN E.IdEstatus = 1 THEN
             'label label-primary'
             WHEN E.IdEstatus = 3 THEN
             'label label-danger'
             WHEN E.IdEstatus IS NULL THEN
             'label label-default'
             END,
             AP.IdAceptacionPedido,
             O.Descripcion,
             E.Nombre,
             NC.CreadoEl,
             UC.Nombre,
             F.IdFactura,
             F.SubTotal,
             F.MontoConIva,
             NC.IdAceptacionNotaCredito,
             O.IdOperacion,
             O.FechaModificacion,
             F.Moneda,
             F.UUID,
             NC.CFDIRelacionados
	ORDER BY NC.CreadoEl DESC


END