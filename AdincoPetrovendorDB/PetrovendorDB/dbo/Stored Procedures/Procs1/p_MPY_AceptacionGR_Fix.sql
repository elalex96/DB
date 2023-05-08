create proc p_MPY_AceptacionGR_Fix
@IdProformaGR int
as

declare @IdAceptacionPedido int

select @IdAceptacionPedido = max(IdAceptacionPedido )
from Petrovendor..[MPY_MM_AceptacionPedido] ap
inner join Adinco..CO_SAPGR gr on gr.PO_SAPNumber COLLATE Modern_Spanish_CI_AS = ap.IdPedido COLLATE Modern_Spanish_CI_AS 									
inner join Adinco..CO_SAPPRESES  p on p.IdPRESES = @IdProformaGR and
						p.SAPPONumber COLLATE Modern_Spanish_CI_AS= ap.IdPedido COLLATE Modern_Spanish_CI_AS and
						p.IdEstatus = 2 
where isnull(ap.ReferenceNumber,'') = '' OR ap.ReferenceNumber = '0'


update Petrovendor..[MPY_MM_AceptacionPedido]
set ReferenceNumber = pre.SAPSESNumber
from Petrovendor..[MPY_MM_AceptacionPedido] a
inner join Adinco..CO_SAPPRESES pre on pre.IdPreses = @IdProformaGR  
where a.IdAceptacionPedido = @IdAceptacionPedido

update Petrovendor..[MPY_MM_AceptacionPedidoDetalle]
set cantidad = 1,
	PrecioUnitario = MontoTotalPrefactura
from Petrovendor..[MPY_MM_AceptacionPedidoDetalle] a
inner join Adinco..CO_SAPPRESES pre on pre.IdPreses = @IdProformaGR  
where a.IdAceptacionPedido = @IdAceptacionPedido





