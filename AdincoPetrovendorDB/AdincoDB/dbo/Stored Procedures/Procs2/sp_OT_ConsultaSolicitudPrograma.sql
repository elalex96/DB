-- sp_OT_ConsultaSolicitudPrograma 24
create Proc [dbo].[sp_OT_ConsultaSolicitudPrograma]
@pIdOTSolicitud int
As


	declare @anioIni int,
			@anioFin int

	select @anioIni = min(datepart(yy,FechaProgramaInicio)),
			@anioFin= max(datepart(yy,FechaProgramaFin))
	from OT_SolicitudMaterial (NOLOCK)
	where IdOTSolicitud= @pIdOTSolicitud


	create table #tmpMeses
	(
		mes int,
		nombreMes varchar(30),
		anio int,
		anioMes int
	)

	
	
	while @anioIni <= @anioFin
	begin


	insert into #tmpMeses
	select 1,'Enero',@anioIni,cast(@anioIni as varchar)+'01'
	union
	select 2,'Febrero',@anioIni,cast(@anioIni as varchar)+'02'
	union
	select 3,'Marzo',@anioIni,cast(@anioIni as varchar)+'03'
	union
	select 4,'Abril',@anioIni,cast(@anioIni as varchar)+'04'
	union
	select 5,'Mayo',@anioIni,cast(@anioIni as varchar)+'05'
	union
	select 6,'Junio',@anioIni,cast(@anioIni as varchar)+'06'
	union
	select 7,'Julio',@anioIni,cast(@anioIni as varchar)+'07'
	union
	select 8,'Agosto',@anioIni,cast(@anioIni as varchar)+'08'
	union
	select 9,'Septiembre',@anioIni,cast(@anioIni as varchar)+'09'
	union
	select 10,'Octubre',@anioIni,cast(@anioIni as varchar)+'10'
	union
	select 11,'Noviembre',@anioIni,cast(@anioIni as varchar)+'11'
	union
	select 12,'Dieciembre',@anioIni,cast(@anioIni as varchar)+'12'

	
	set @anioIni = @anioIni + 1
	end

	
	select 
			IDPrograma =cast(sm.IdOTSolicitudMaterial as varchar) +'-'+  cast(meses.Anio as varchar) +'-'+  cast(meses.Mes as varchar) ,
			IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial,			
			FechaProgramaInicio = sm.FechaProgramaInicio,
			FechaProgramaFin = sm.FechaProgramaFin,
			Mes = meses.Mes,
			NombreMes=meses.NombreMes,
			Anio=meses.Anio,
			CantidadMes = isnull(sp.Cantidad,0),
			Descripcion = isnull(sc.Concepto,sc.IdMaestro) +cast(sc.Descripcion as varchar(150)),
			IdOTSolicitudPrograma= isnull(sp.IdOTSolicitudPrograma,0),
			CantidadOT = sm.Cantidad		
	from OT_SolicitudMaterial sm (NOLOCK)
	inner join SC_Materiales sc (NOLOCK) on sm.IdSCMaterial = sc.IdSCMaterial  
	inner join #tmpMeses meses (NOLOCK) on 			
								meses.aniomes   >= cast(cast((datepart(yy,sm.FechaProgramaInicio)) as varchar) +  
														cast(
															
																case when datepart(mm,sm.FechaProgramaInicio) = 1 then '01'
																when datepart(mm,sm.FechaProgramaInicio) = 2 then '02'
																when datepart(mm,sm.FechaProgramaInicio) = 3 then '03'
																when datepart(mm,sm.FechaProgramaInicio) = 4 then '04'
																when datepart(mm,sm.FechaProgramaInicio) = 5 then '05'
																when datepart(mm,sm.FechaProgramaInicio) = 6 then '06'
																when datepart(mm,sm.FechaProgramaInicio) = 7 then '07'
																when datepart(mm,sm.FechaProgramaInicio) = 8 then '08'
																when datepart(mm,sm.FechaProgramaInicio) = 9 then '09'
																when datepart(mm,sm.FechaProgramaInicio) = 10 then '10'
																when datepart(mm,sm.FechaProgramaInicio) = 11 then '11'
																when datepart(mm,sm.FechaProgramaInicio) = 12 then '12'
																
																
																end
															
															as varchar) 
															
															as int) 
								and 
								meses.aniomes   <=  cast(cast((datepart(yy,sm.FechaProgramaFin)) as varchar) +  
														cast(
															
															case when datepart(mm,sm.FechaProgramaFin) = 1 then '01'
															when datepart(mm,sm.FechaProgramaFin) = 2 then '02'
															when datepart(mm,sm.FechaProgramaFin) = 3 then '03'
															when datepart(mm,sm.FechaProgramaFin) = 4 then '04'
															when datepart(mm,sm.FechaProgramaFin) = 5 then '05'
															when datepart(mm,sm.FechaProgramaFin) = 6 then '06'
															when datepart(mm,sm.FechaProgramaFin) = 7 then '07'
															when datepart(mm,sm.FechaProgramaFin) = 8 then '08'
															when datepart(mm,sm.FechaProgramaFin) = 9 then '09'
															when datepart(mm,sm.FechaProgramaFin) = 10 then '10'
															when datepart(mm,sm.FechaProgramaFin) = 11 then '11'
															when datepart(mm,sm.FechaProgramaFin) = 12 then '12'

															end
															
															as varchar) 
														
														as int)
	LEFT JOIN OT_SolicitudPrograma sp (NOLOCK) on sm.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial  and
										meses.anio = sp.anio and
										meses.mes = sp.mes 
	where IdOTSolicitud = @pIdOTSolicitud 
	group by sm.IdOTSolicitudMaterial,			
			sm.FechaProgramaInicio,
			sm.FechaProgramaFin,
			meses.nombremes,
			meses.mes,
			meses.anio,
			sp.Cantidad, sc.Descripcion,
			sp.IdOTSolicitudPrograma,sm.Cantidad,sc.Concepto,sc.IdMaestro

	order by sm.IdOTSolicitudMaterial,			
			sm.FechaProgramaInicio,
			sm.FechaProgramaFin,
			meses.anio,
			meses.mes




GO


