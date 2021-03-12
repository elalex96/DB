
-- p_SC_CargaInicial 2,3,10,'','20200701','20200715',20
CREATE proc [dbo].[p_SC_CargaInicial]
@pIdContratista int,
@pIdContrato int,
@pCreadoPor int,
@pError varchar(2540) out
as
begin

	declare @i int=0,
			@idMaestro int= 0,
			@idMaterial int = 0,
			@idSCMaterial int = 0,
			@IdSubContratoPresupuesto int=0

	

	begin try

	Begin Tran

	BEGIN -- SECCION UNIDADES
	--drop table #UnidadesCarga
	create table #UnidadesCarga(Unidad nvarchar(max), IdUnidad int, Activo bit )

	Insert into #UnidadesCarga(Unidad, Activo)
	select UnidadMedida, null
	from SC_Importacion
	group by UnidadMedida

	--Revisar existen las unidades y en que estado estan
	update u
	set u.activo = mu.IsActivo, u.IdUnidad = mu.IdUnidad
	from #UnidadesCarga u
	left join Petrovendor..PV_MM_MaterialUnidad mu
	on upper(ltrim(rtrim(u.Unidad))) collate SQL_Latin1_General_CP1_CI_AS  = upper(ltrim(rtrim(mu.Unidad)))


	--Actualizar las unidades que no estan activas
	update mu
	set mu.IsActivo = 1
	from #UnidadesCarga u
	left join Petrovendor..PV_MM_MaterialUnidad mu
	on upper(ltrim(rtrim(u.Unidad))) collate SQL_Latin1_General_CP1_CI_AS  = upper(ltrim(rtrim(mu.Unidad)))

	-- Insertar las unidades que no existen
	insert into Petrovendor..PV_MM_MaterialUnidad (Unidad, IsActivo, IsEliminado)
	select Unidad, 1, 0 
	from #UnidadesCarga
	where IdUnidad is null

	-- Se actualizan los registros de las unidades no encontradas
	update u
	set u.activo = mu.IsActivo, u.IdUnidad = mu.IdUnidad
	from #UnidadesCarga u
	left join Petrovendor..PV_MM_MaterialUnidad mu
	on upper(ltrim(rtrim(u.Unidad))) collate SQL_Latin1_General_CP1_CI_AS  = upper(ltrim(rtrim(mu.Unidad)))
	where u.IdUnidad is null

END

BEGIN -- SECCION MATERIALES
	--drop table #MaterialesCarga
	create table #MaterialesCarga(DescripcionPartida nvarchar(max), IdMaterial int, Unidad nvarchar(max), IdUnidad int, IdDetalle int, IdProveedor int, IdMaestro int, MaestroActivo bit)

	--Se obtienen las partidas con su unidad las que esten nulas seran partidas que se insertaran ya que no existe
	-- dada de alta con su unidad
	insert into #MaterialesCarga(DescripcionPartida, Unidad, IdUnidad, IdDetalle, IdProveedor)
	select upper(ltrim(rtrim(m.DescripcionCorta))), i.UnidadMedida, u.IdUnidad, i.IdSCDetalle, p.IdProveedor
	from SC_Importacion i
	inner join petrovendor..s_proveedor p 
		on upper(rtrim(ltrim(p.RFC))) collate SQL_Latin1_General_CP1_CI_AS = upper(rtrim(ltrim(i.RFCProveedor)))
	left join petrovendor..mm_material m 
		on upper(ltrim(rtrim(i.DescripcionPartida))) collate SQL_Latin1_General_CP1_CI_AS = upper(rtrim(ltrim(m.DescripcionCorta)))
		and m.IdProveedor = p.IdProveedor
	left join Petrovendor..PV_MM_MaterialUnidad u 
		on u.IdUnidad = m.IdUnidad
		and upper(ltrim(rtrim(i.UnidadMedida))) collate SQL_Latin1_General_CP1_CI_AS = upper(rtrim(ltrim(u.Unidad)))
		and u.IsActivo = 1
		group by m.DescripcionCorta, i.UnidadMedida, u.IdUnidad, i.IdSCDetalle, p.IdProveedor

		--se setea el valor del idMaterial, se realiza mediante update ya que anteriormente se agregaban entnces puede
		-- existir muchos valores repetidos en mm_material
		update carga
		set carga.IdMaterial = m.IdMaterial
		from SC_Importacion i
		inner join petrovendor..s_proveedor p 
			on upper(rtrim(ltrim(p.RFC))) collate SQL_Latin1_General_CP1_CI_AS = upper(rtrim(ltrim(i.RFCProveedor)))
		left join petrovendor..mm_material m 
			on upper(ltrim(rtrim(i.DescripcionPartida))) collate SQL_Latin1_General_CP1_CI_AS = upper(rtrim(ltrim(m.DescripcionCorta)))
			and m.IdProveedor = p.IdProveedor
		inner join Petrovendor..PV_MM_MaterialUnidad u 
			on u.IdUnidad = m.IdUnidad
			and upper(ltrim(rtrim(i.UnidadMedida))) collate SQL_Latin1_General_CP1_CI_AS = upper(rtrim(ltrim(u.Unidad)))
			and u.IsActivo = 1
		inner join #MaterialesCarga carga 
			on carga.IdDetalle = i.IdSCDetalle

		--se setean los valores del campo intermedio para insertar en mm_material los materiales que no 
		--tienen dada de alta la unidad
		update m
		set m.IdUnidad = u.IdUnidad
		from #MaterialesCarga m
		inner join Petrovendor..PV_MM_MaterialUnidad u
		 on upper(ltrim(rtrim(m.Unidad))) collate SQL_Latin1_General_CP1_CI_AS = upper(rtrim(ltrim(u.Unidad)))
		 where m.IdUnidad is null

		-- solo se insertan las que no tienen dada de alta su respectiva unidad
		insert into petrovendor..mm_material(IdProveedor, DescripcionCorta, DescripcionLarga, Modelo, FechaAlta, Activo, IdTipoCatalogoMaestro, IsPublico, IdUnidad)
		select IdProveedor, upper(ltrim(rtrim(DescripcionPartida))), upper(ltrim(rtrim(DescripcionPartida))), 'NA', getdate(), 1, 2, 1, IdUnidad
		from #MaterialesCarga 
		where IdMaterial is null

		--Se vuelve a actualizar para tener los valores del idmaterial actualizados
		update carga
		set carga.IdMaterial = m.IdMaterial
		from SC_Importacion i
		inner join petrovendor..s_proveedor p 
			on upper(rtrim(ltrim(p.RFC))) collate SQL_Latin1_General_CP1_CI_AS = upper(rtrim(ltrim(i.RFCProveedor)))
		left join petrovendor..mm_material m 
			on upper(ltrim(rtrim(i.DescripcionPartida))) collate SQL_Latin1_General_CP1_CI_AS = upper(rtrim(ltrim(m.DescripcionCorta)))
			and m.IdProveedor = p.IdProveedor
		inner join Petrovendor..PV_MM_MaterialUnidad u 
			on u.IdUnidad = m.IdUnidad
			and upper(ltrim(rtrim(i.UnidadMedida))) collate SQL_Latin1_General_CP1_CI_AS = upper(rtrim(ltrim(u.Unidad)))
			and u.IsActivo = 1
		inner join #MaterialesCarga carga 
			on carga.IdDetalle = i.IdSCDetalle

		--Se termina seccion materiales
END

begin --SECCION CATALOGO MAESTRO
	UPDATE carga
	set carga.IdMaestro = maestro.IdMaestro, carga.MaestroActivo = maestro.IsActivo
	from #MaterialesCarga carga
	inner join petrovendor..MM_Material m
		on m.idMaterial = carga.IdMaterial
	inner join petrovendor..MM_Maestro maestro 
		on maestro.IdMaestro = m.IdMaestro
	inner join Petrovendor..PV_MM_MaterialUnidad u 
			on u.IdUnidad = maestro.IdUnidadPreterminada
			and u.IsActivo = 1	


	declare @idsubcontrato int

	update SC_Importacion
	set RFCContratista = rtrim(ltrim(RFCContratista)),
		RFCProveedor= rtrim(ltrim(RFCProveedor)),
		IdMaterial = carga.IdMaterial
	from SC_Importacion imp
	inner join #MaterialesCarga carga
		on carga.IdDetalle = imp.IdSCDetalle

	update m
	set m.IsActivo = 1
	from petrovendor..mm_Maestro m
	inner join #MaterialesCarga carga 
		on carga.IdMaestro = m.IdMaestro
	where isnull(carga.MaestroActivo, 0) = 0


				insert into Petrovendor..MM_Maestro(
				IdTipoCatalogoMaestro,	IdSubFamilia,	TextoCorto,		TextoLargo,		IdMoneda,
				IdTipoMaterial,	Prc,					IsActivo,		IsEliminado,	CreadoPor,		CreadoEn,
				ModificadoPor,	ModificadoEn,			IdUnidadPreterminada,IdUnidad_1,IdUnidad_2,		IdUnidad_3)
				select distinct				1,						null,			DescripcionPartida,	DescripcionPartida,	2,
				null,			null,					1,				0,				null,			null,
				null,			null,					isnull(IdUnidad,10011/*SERVICIO*/),			null,		null,			null					
				from #MaterialesCarga
				where IdMaestro is null

				UPDATE carga
				set carga.IdMaestro = maestro.IdMaestro, carga.MaestroActivo = maestro.IsActivo
				from #MaterialesCarga carga
				inner join petrovendor..MM_Material m
					on m.idMaterial = carga.IdMaterial
				inner join petrovendor..MM_Maestro maestro 
					on upper(ltrim(rtrim(maestro.TextoCorto))) = upper(ltrim(rtrim(m.DescripcionCorta)))
				inner join Petrovendor..PV_MM_MaterialUnidad u 
						on u.IdUnidad = maestro.IdUnidadPreterminada
						and u.IsActivo = 1
				where carga.IdMaestro is null

					 
				update m
				set m.IdMaestro = carga.IdMaestro
				from petrovendor..MM_Material m
				inner join #MaterialesCarga carga
					on carga.IdProveedor = m.IdProveedor
					and carga.IdMaterial = m.IdMaterial
				where m.IdMaestro is null

end

	declare @pedidoC varchar(50)

	select @pedidoC = min(NumeroPedido)
	from SC_Importacion
	where IdSubcontrato is null

	while @pedidoC is not null
	begin

		select  @idsubcontrato =  isnull(max(IdSubContrato), 0) + 1
		from SC_Subcontrato

		
		insert into SC_Subcontrato(
			IdSubContrato,		IdSubContratista,		IdContratista,		NumeroSubContrato,		CreadoPor,
			CreadoEl,			ModificadoPor,			ModificadoEl,		IsActivo,				IsEliminado,
			Objeto,				IdPedido,				PrefijoOT,			IdContrato,				IdMoneda,
			IdTipoPedido			
		)
		select @idsubcontrato,prov.IdSubcontratista,con.IdContratista,cast(tmp.NumeroPedido as varchar),@pCreadoPor,
		getdate(),				null,					null,				1,						0,
		tmp.Descripcion,						null,					
		'OT-'+ case when len(tmp.NumeroPedido) <= 5 then tmp.NumeroPedido else substring( tmp.NumeroPedido,len( tmp.NumeroPedido)-4,len( tmp.NumeroPedido)) end,
		max(c.IdContrato),m.IdMoneda,tmp.IdTipoPedido
		from SC_Importacion tmp
		inner join PV_Subcontratista prov on prov.RFC = tmp.RFCProveedor
		inner join CO_Contratista con on con.IdContratista = @pIdContratista
		inner join CO_Contrato c on c.IdContrato = @pIdContrato	
		left join Petrovendor..PV_TipoMoneda m on upper(m.TipoMonedaCorto) COLLATE SQL_Latin1_General_CP1_CI_AS = upper(tmp.Moneda) COLLATE SQL_Latin1_General_CP1_CI_AS
		where not exists (
			select 1
			from SC_Subcontrato
			where NumeroSubContrato =cast(tmp.NumeroPedido as varchar) and
			IdContratista = con.IdContratista and
			IsActivo = 1 and
			isnull(IsEliminado,0) = 0
		)
		and tmp.NumeroPedido = @pedidoC
		group by tmp.NumeroPedido,prov.IdSubcontratista,con.IdContratista,tmp.IdSCCarga,tmp.RFCProveedor,m.IdMoneda	,tmp.IdTipoPedido,tmp.Descripcion

		select @idSCMaterial = isnull(max(IdSCMaterial),0)
		from [SC_Materiales]

		insert into [dbo].[SC_Materiales](	IdSCMaterial,	IdSubContrato,	Concepto,	IdMaestro,	IdUnidad,
		Cantidad,	PrecioUnitario,	Importe,					Descripcion,	DescripcionCorta,
		CreadoPor,	CreadoEl,		ModificadoPor,				ModificadoEl,			IdServicio)
		select ROW_NUMBER() OVER(ORDER BY IdSCDetalle ASC) + @idSCMaterial, @idsubcontrato, i.Partida, i.IdMaterial, ISNULL(mat.IdUnidad,10011),
		i.cantidad,	i.PrecioUnitario, isnull(Cantidad,0) * isnull(i.PrecioUnitario,0),cast(mat.DescripcionLarga as varchar(510)),cast(mat.DescripcionCorta as varchar(250)),
		@pCreadoPor,			getdate(),		null,						null,					null
		from SC_Importacion I
		inner join Petrovendor..MM_Material mat on mat.IdMaterial = i.IdMaterial
		inner join SC_Subcontrato sc on sc.IdSubcontrato = @idsubcontrato
		where I.NumeroPedido = @pedidoC and isnull(@idsubcontrato,0) > 0
		and not exists (
			select 1
			from [SC_Materiales] st1
			where st1.IdSubContrato = @idsubcontrato and
			st1.Concepto = i.Partida
		)


		select @IdSubContratoPresupuesto = isnull(max(IdSubContratoPresupuesto),0)
		from SC_Presupuesto

		insert into SC_Presupuesto(IdSubContratoPresupuesto,IdSubContrato,IdPresupuesto,CreadoPor,
		CreadoEl)
		select  ROW_NUMBER() OVER(ORDER BY sc.IdSubContrato ASC) + @IdSubContratoPresupuesto ,
		sc.IdSubContrato,pre.IdPresupuesto,1,getdate()
		from SC_Subcontrato sc
		inner join CO_Contrato con on con.IdContrato = @pIdContrato
		inner join CO_PeriodoContrato pc on pc.IdContrato = con.IdContrato
		inner join CO_ProgramaActividad pa on pa.IdPeriodoContrato = pc.IdPeriodo
		inner join CO_Presupuesto pre on pre.IdProgramaActividad = pa.IdProgramaActividad
		where sc.IdSubcontrato = @idsubcontrato
		and not exists (
			select 1
			from SC_Presupuesto s1
			where s1.IdPresupuesto = pre.IdPresupuesto and
			s1.IdSubContrato = sc.IdSubContrato
		)
		group by sc.IdSubContrato,sc.IdSubContrato,pre.IdPresupuesto

		exec [dbo].[p_SC_Materiales_Gen] @idsubcontrato,''

		update SC_Importacion
		set IdSubcontrato = @idsubcontrato
		where IdSubcontrato is null
		and NumeroPedido = @pedidoC

		select @pedidoC =  min(NumeroPedido)
		from SC_Importacion
		where IdSubcontrato is null and
		NumeroPedido > @pedidoC

	end

	commit tran

	END TRY  
	BEGIN CATCH
	
		rollback tran  
		set @pError = error_message()
	END CATCH  
end

	
	

	

	














