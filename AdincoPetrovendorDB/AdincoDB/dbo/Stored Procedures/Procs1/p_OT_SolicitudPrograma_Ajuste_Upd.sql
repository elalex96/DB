-- p_OT_SolicitudPrograma_Ajuste_Upd 47
CREATE proc p_OT_SolicitudPrograma_Ajuste_Upd
@pIdOTSolicitud int
as
begin

BEGIN TRY

	begin tran

	/********PROCESO PARA GENERAR PROGRAMA DE MANERA AUTOMÁTICA*******************/

	create table #tmp(
					IdDiagrama varchar(50),
					IdOTSolicitudMaterial int,
					FechaProgramaInicio DateTime,
					FechaProgramaFin DateTime,
					Mes int,
					NombreMes varchar(20),
					Anio int,
					CantidadMes float,
					Descripcion varchar(1000),
					IdOTSolicitudPrograma int,
					CantidadOT float
				)

		--select CONERROR= count(distinct ot.IdOTSolicitud)
		--from OT_Solicitud ot
		--inner join Ot_SolicitudMaterial otm on otm.IdOTSolicitud = OT.IdOTSolicitud
		--AND @id IN (0,ot.IdOTSolicitud)
		--where ot.IdOTEstatus in (5,6) and otm.Cantidad > 0
		--and not exists (
		--	select 1
		--	from [dbo].[OT_SolicitudPrograma] s1
		--	where s1.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
		--)

		
		select  ot.IdOTSolicitud
		into #tmpOT
		from OT_Solicitud ot
		inner join Ot_SolicitudMaterial otm on otm.IdOTSolicitud = OT.IdOTSolicitud
		where IdOTEstatus in (1,11,5,6)
		AND @pIdOTSolicitud IN (ot.IdOTSolicitud)  and otm.Cantidad > 0
		--and not exists (
		--	select 1
		--	from [dbo].[OT_SolicitudPrograma] s1
		--	where s1.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
		--)
		group by ot.IdOTSolicitud
		
	
	

		declare @idOT int=0,
			@IdOTSolicitudPrograma int = 0

		

		select @idOT = min(IdOTSolicitud)
		from #tmpOT

		while @idOT > 0
		begin			

				delete [OT_SolicitudPrograma]
				from [OT_SolicitudPrograma] p
				inner join OT_SolicitudMaterial sm on sm.IdOTSolicitudMaterial = p.IdOTSolicitudMaterial
				where sm.IdOTSolicitud = @pIdOTSolicitud

				insert into #tmp(IdDiagrama,IdOTSolicitudMaterial,FechaProgramaInicio,FechaProgramaFin,
				Mes,NombreMes,Anio,CantidadMes,Descripcion,IdOTSolicitudPrograma,CantidadOT)
				exec Adinco..sp_OT_ConsultaSolicitudPrograma @idOT

				--select OT=@idOT,* from #tmp

				select @IdOTSolicitudPrograma = isnull(max(IdOTSolicitudPrograma),0) + 1
				from [OT_SolicitudPrograma]

				insert into [OT_SolicitudPrograma](
					IdOTSolicitudPrograma,	IdOTSolicitudMaterial,		Anio,		Mes,
					Cantidad,				CreadoPor,					CreadoEl,	ModificadoPor,
					ModificadoEl,			IdEstatus)
				select @IdOTSolicitudPrograma + ROW_NUMBER() OVER(ORDER BY IdOTSolicitudMaterial ASC),IdOTSolicitudMaterial,	Anio,	Mes,
					CantidadOT / (select count(distinct Mes) from #tmp where IdOTSolicitudMaterial = t1.IdOTSolicitudMaterial ),10505,getdate(),null,
					null,					null
				from #tmp t1
				where not exists (
					select 1
					from OT_SolicitudPrograma s1
					where s1.IdOTSolicitudMaterial = t1.IdOTSolicitudMaterial and
					s1.Anio = t1.Anio and
					s1.Mes = t1.Mes
				)
				group by 	IdOTSolicitudMaterial,	CantidadOT,	Anio,	Mes
				

				select @idOT = min(IdOTSolicitud)
				from #tmpOT
				where IdOTSolicitud > @idOT

		end
		


	/*****PROCESO PÁRA AJUSTAR DECIMALES**************/

select sp.IdOTSolicitudPrograma,
		sp.IdOTSolicitudMaterial,
		sp.Anio,
		sp.Mes,
		CantidadProg = sp.Cantidad,
		tmp.Cantidad,
		Diff = tmp.diff
into #tmpUpdProg
from [OT_SolicitudPrograma] sp
inner join OT_SolicitudMaterial otm on otm.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial
inner join OT_Solicitud ot on ot.IdOTSolicitud = otm.IdOTSolicitud
inner join (
	select sm.IdOTSolicitud, sm.IdOTSolicitudMaterial,sm.Cantidad,CantProg= sum(sp.Cantidad),diff = sm.Cantidad -sum(sp.Cantidad) 
	from OT_SolicitudMaterial sm
	inner join [dbo].[OT_SolicitudPrograma] sp on sp.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial
	group by sm.IdOTSolicitud, sm.IdOTSolicitudMaterial,sm.Cantidad
	having sm.Cantidad <> sum(sp.Cantidad)
	) tmp ON tmp.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial
where ot.IdOTSolicitud = @pIdOTSolicitud



select IdOTSolicitudPrograma = max(IdOTSolicitudPrograma),
		IdOTSolicitudMaterial,
		CantUpd = Diff
into #tmpUpdProg2
from #tmpUpdProg
group by IdOTSolicitudMaterial,Diff

update [OT_SolicitudPrograma]
set Cantidad = sp.Cantidad  + (upd.CantUpd)
from [OT_SolicitudPrograma] sp
inner join #tmpUpdProg2 upd on upd.IdOTSolicitudPrograma = sp.IdOTSolicitudPrograma


drop table #tmpUpdProg
drop table #tmpUpdProg2

	commit tran

end try
BEGIN CATCH
	rollback tran
	select error_message()

END CATCH

end




