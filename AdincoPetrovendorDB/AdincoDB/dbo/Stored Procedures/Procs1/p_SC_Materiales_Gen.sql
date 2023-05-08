
-- [p_SC_Materiales_Gen] 2
CREATE proc [dbo].[p_SC_Materiales_Gen]
@pIdSubcontrato int,
@pError bit=0 out
as


	
	declare @IdSCMaterial_i int,
		@IdMaterialProv int,
		@IdMaterialCon int,
		@idMaestro int,
		@idMaterial int

	select @IdSCMaterial_i = min(IdSCMaterial)			
	from SC_Materiales m
	where m.IdSubcontrato = @pIdSubcontrato and
	(
		isnull(m.IdMaestro,0)= 0 OR
		isnull(m.IdMaterialContratista,0) =0
	)

	BEGIN TRY  

		BEGIN TRAN
     
		while @IdSCMaterial_i is not null
		begin

			set @idMaestro = 0
			set @idMaterial = 0

			select @IdMaterialProv =m.IdMaestro,
					@IdMaterialCon = m.IdMaterialContratista
			from SC_Materiales m
			where m.IdSCMaterial = @IdSCMaterial_i


			--Generar Material para el Proveedor
			if(isnull(@IdMaterialProv,0) =0)
			begin
			
				insert into Petrovendor..MM_Maestro(
					/*IdMaestro,*/		IdTipoCatalogoMaestro,	IdSubFamilia,	TextoCorto,		TextoLargo,		IdMoneda,
					IdTipoMaterial,	Prc,					IsActivo,		IsEliminado,	CreadoPor,		CreadoEn,
					ModificadoPor,	ModificadoEn,			IdUnidadPreterminada,IdUnidad_1,IdUnidad_2,		IdUnidad_3)
				select				1,						null,			DescripcionCorta,	Descripcion,	isnull(sc.IdMoneda,2/*USD*/),
					null,			null,					1,				0,				null,			null,
					null,			null,					isnull(IdUnidad,10011/*SERVICIO*/),			null,		null,			null	
				from SC_Materiales mat
				inner join SC_Subcontrato sc on sc.IdSubcontrato = mat.IdSubcontrato
				where IdSCMaterial = @IdSCMaterial_i


				set @idMaestro = SCOPE_IDENTITY() 
		
				insert into petrovendor..MM_Material(
						IdProveedor,	IdUnidad,					DescripcionCorta,		DescripcionLarga,		Consumible,
						Inventariable,	TiempoEntregaEstimadoDias,	Marca,					IsPublico,				Imagen,
						FechaAlta,		Activo,						IsEliminado,			IdMaestro,				IsClasificionMaestro,
						IdTipoProveedor,IdTipoCatalogoMaestro
				)
				select prov.IdProveedor,	mm.IdUnidadPreterminada,mm.TextoLargo,		mm.TextoLargo,			0,
					1,					0,							null,					1,						null,
					getdate(),		1,								0,						mm.IdMaestro,			1,
					2,					mm.IdTipoCatalogoMaestro
				from Petrovendor..MM_Maestro mm
				inner join SC_Subcontrato t1 on t1.IdSubcontrato = @pIdSubcontrato
				inner join PV_Subcontratista ctista on ctista.IdSubcontratista = t1.IdSubContratista
				inner join petrovendor..S_Proveedor prov on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = ctista.RFC COLLATE SQL_Latin1_General_CP1_CI_AS and prov.Activo = 1
				where mm.IdMaestro = @idMaestro

				set @idMaterial = SCOPE_IDENTITY() 

				update SC_Materiales
				set IdMaestro = @idMaterial
				WHERE IdSCMaterial = @IdSCMaterial_i


			end

			--Generar Material para la Operadora
			if(isnull(@IdMaterialCon,0) = 0)
			begin
			
				insert into Petrovendor..MM_Maestro(
					/*IdMaestro,*/		IdTipoCatalogoMaestro,	IdSubFamilia,	TextoCorto,		TextoLargo,		IdMoneda,
					IdTipoMaterial,	Prc,					IsActivo,		IsEliminado,	CreadoPor,		CreadoEn,
					ModificadoPor,	ModificadoEn,			IdUnidadPreterminada,IdUnidad_1,IdUnidad_2,		IdUnidad_3)
				select				1,						null,			DescripcionCorta,	Descripcion,	isnull(sc.IdMoneda,2/*USD*/),
					null,			null,					1,				0,				null,			null,
					null,			null,					isnull(IdUnidad,10011/*SERVICIO*/),			null,		null,			null	
				from SC_Materiales mat
				inner join SC_Subcontrato sc on sc.IdSubcontrato = mat.IdSubcontrato
				where IdSCMaterial = @IdSCMaterial_i


				set @idMaestro = SCOPE_IDENTITY() 
		
				insert into petrovendor..MM_Material(
						IdProveedor,	IdUnidad,					DescripcionCorta,		DescripcionLarga,		Consumible,
						Inventariable,	TiempoEntregaEstimadoDias,	Marca,					IsPublico,				Imagen,
						FechaAlta,		Activo,						IsEliminado,			IdMaestro,				IsClasificionMaestro,
						IdTipoProveedor,IdTipoCatalogoMaestro
				)
				select prov.IdProveedor,	mm.IdUnidadPreterminada,mm.TextoLargo,		mm.TextoLargo,			0,
					1,					0,							null,					1,						null,
					getdate(),		1,								0,						mm.IdMaestro,			1,
					2,					mm.IdTipoCatalogoMaestro
				from Petrovendor..MM_Maestro mm
				inner join SC_Subcontrato t1 on t1.IdSubcontrato = @pIdSubcontrato
				inner join CO_Contratista ctista on ctista.Idcontratista = t1.IdContratista
				inner join petrovendor..S_Proveedor prov on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = ctista.RFC COLLATE SQL_Latin1_General_CP1_CI_AS and prov.Activo = 1
				where mm.IdMaestro = @idMaestro

				set @idMaterial = SCOPE_IDENTITY() 

				update SC_Materiales
				set IdMaterialContratista = @idMaterial
				WHERE IdSCMaterial = @IdSCMaterial_i


			end

			select @IdSCMaterial_i = min(IdSCMaterial)			
			from SC_Materiales m
			where m.IdSubcontrato = @pIdSubcontrato and
			(
				isnull(m.IdMaestro,0)= 0 OR
				isnull(m.IdMaterialContratista,0) =0
			)
			and IdSCMaterial > @IdSCMaterial_i


		end

		COMMIT TRAN
	END TRY  
	BEGIN CATCH  
		ROLLBACK TRAN
		set @pError = 1
		
	END CATCH  



