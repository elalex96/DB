
CREATE proc p_OT_Estimacion_Aceptacion_Fix
@pFolioEstimacion varchar(20),
@pIdContrato int,
@pError varchar(250) out
as

BEGIN TRY  

begin tran
    
select
e.IdOTSolicitud, 
e.FolioEstimacion, 
sc.Concepto, 
sc.Descripcion,
DescripcionMat = isnull(mat.DescripcionCorta,mat.DescripcionLarga),
e.IdOTEstimacion,
e.IdPedidoGeneral,
pd.IdPedido,
pd.IdPedidoDetalle,
ap.IdAceptacionPedido,
apd.IdAceptacionPedidoDetalle,
CantEst = ed.Cantidad,
CatPed = pd.Cantidad,
CantAcep = apd.Cantidad
into #tmpFix
from Adinco..OT_Estimacion e
inner join Adinco..OT_EstimacionDetalle ed on ed.IdOTEstimacion = e.IdOTEstimacion
inner join Adinco..OT_SolicitudMaterial otm on otm.IdOTSolicitudMaterial = ed.IdOTSolicitudMaterial
inner join Adinco..SC_Materiales sc on sc.IdSCMaterial = otm.IdSCMaterial
left join petrovendor..MM_Pedido ped on ped.IdPedido = e.IdPedido
left join petrovendor..MM_PedidoDetalle pd on pd.IdPedido = ped.IdPedido and pd.IdMaterial =  sc.IdMaterialContratista
left join petrovendor..MM_Material mat on mat.IdMaterial = pd.IdMaterial
left join petrovendor..MM_AceptacionPedido ap on ap.IdPedido = ped.IdPedido
left join petrovendor..MM_AceptacionPedidoDetalle apd on ap.IdPedido = ped.IdPedido and apd.IdPedidoDetalle = pd.IdPedidoDetalle
where  (ed.Cantidad <> pd.Cantidad
OR ed.Cantidad <> isnull(apd.Cantidad,0)) and
ap.IdAceptacionPedido is not null and
rtrim(e.FolioEstimacion) = rtrim(@pFolioEstimacion) and
ed.Cantidad > 0

--Actualizar estimaciones
update petrovendor..MM_AceptacionPedidoDetalle
set Cantidad = fix.CantEst
from petrovendor..MM_AceptacionPedidoDetalle a
inner join #tmpFix fix on fix.IdAceptacionPedidoDetalle = a.IdAceptacionPedidoDetalle 


insert into Petrovendor..MM_AceptacionPedidoDetalle(
IdAceptacionPedido,IdPedidoDetalle,Cantidad,Detalle,
CreadoPor,Creado,Excedente,PCN,PCN_Agregado,EditadoPor,
EditadoEl,IdEstatusEliminado,IdEliminado,ClasificacionCN,RecId
)
select tmp.IdAceptacionPedido,tmp.IdPedidoDetalle,tmp.CantEst,'',
p.CreadoPor,getdate(),0,null,null,null,
null,null,null,null,null
from #tmpFix tmp
inner join petrovendor..MM_Pedido p on p.IdPedido = tmp.IdPedido
where tmp.CantAcep is null

--ROLLBACK tran
commit tran


END TRY  
BEGIN CATCH 
	rollback tran 
    set @pError = error_message()
	select error_message()
END CATCH  

