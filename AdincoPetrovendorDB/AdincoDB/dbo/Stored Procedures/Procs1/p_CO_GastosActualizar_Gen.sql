CREATE PROCEDURE p_CO_GastosActualizar_Gen
@pUsuarioID int,
@pUUIDImport varchar(100),
@pIdContrato int 
as


	declare @Id int,@IdLineaP int
	DECLARE @IdCatalogoCuentasSH INT, @Poliza VARCHAR(100)= '',@CostosAtribuiblesAdministracion VARCHAR(100)='',@IdPrograma INT;

	select  Id,
		UUIDImport,
		RFCEmisor,
		UUID,
		CuentaContable,
		Poliza,
		GastoAdmon,
		Procesado,
		Error,
		ErrorDesc,
		CreadoEl,
		CreadoPor,
		IdLineaPresupuesto
	into #tmpProcesarGastos
	from CO_GastosActualizar
	where isnull(Procesado,0) = 0 and
	UUIDImport = @pUUIDImport

	select @Id = min(id)
	from #tmpProcesarGastos
	set @IdLineaP = (select IdLineaPresupuesto from #tmpProcesarGastos where Id = @Id)
	
	
	while @Id is not null
	begin
		
		
		--Validar que se tenga una cuenta capturada
		if  exists (
			select 1
			from  #tmpProcesarGastos tmp 
			where tmp.Id = @Id and
			(
				isnull(CuentaContable,'') = ''   or
				isnull(Poliza,'') = ''  
			)
		)
		begin
			
			update CO_GastosActualizar
			set Error = 1,
				Procesado = 1,
				ErrorDesc = 'La póliza y la factura son requeridas'
			from CO_GastosActualizar
			where id = @Id

			goto continue_while

		end

		--Verificar si existe la factura

		if not exists (
			select 1
			from  #tmpProcesarGastos tmp 
			inner join CO_CatalogoCuentaSH cc on rtrim(cc.Nivel3) = rtrim(tmp.CuentaContable)
			where tmp.Id = @Id 
		)
		begin
			
			update CO_GastosActualizar
			set Error = 1,
				Procesado = 1,
				ErrorDesc = 'La Cuenta S-H no existe'
			from CO_GastosActualizar
			where id = @Id

			goto continue_while


		end

		--Verificar que exista la cuenta contable
		if not exists (
			select 1
			from FI_Factura fac
			inner join #tmpProcesarGastos tmp on upper(tmp.UUID) = upper(fac.UUID)
			inner join AP_Perfil per on per.IdContrato = fac.IdContrato
			inner join AP_PerfilUsuario pu on pu.PerfilID = per.IdPerfil
			inner join AP_Usuario u on u.UsuarioID = pu.UsuarioID
			where u.UsuarioID = @pUsuarioID and
			tmp.Id = @Id
		)
		begin
			
			update CO_GastosActualizar
			set Error = 1,
				Procesado = 1,
				ErrorDesc = 'La factura no existe'
			from CO_GastosActualizar
			where id = @Id

			goto continue_while

		end

		if @IdLineaP is not null 
		begin
		--Verificar que la linea presupueso corresponda al contrato
		if not exists (
		SELECT 
					lpm.IdLineaPresupuestoMes FROM CO_LineapresupuestoMes lpm
					inner join CO_PResupuesto p on p.IdPresupuesto = lpm.IdPresupuesto
					inner join [dbo].[CO_ProgramaActividad] pa on pa.IdProgramaActividad = p.IdProgramaActividad
					inner join [dbo].[CO_PeriodoContrato] pc on pc.IdPeriodo = pa.IdPeriodoContrato
					where pc.IdContrato = @pIdContrato and
					lpm.IdLineaPresupuestoMes = @IdLineaP)
		begin
			update CO_GastosActualizar
			set Error = 1,
				Procesado = 1,
				ErrorDesc = 'La Linea Presupuesto no corresponde al contrato.'
			from CO_GastosActualizar
			where id = @Id

			goto continue_while
		end --termina end de condición linea presupuesto contrato 
		end

		begin tran

		if @IdLineaP is not null
		begin 
			SELECT TOP 1 @Poliza = tmp.Poliza,
				@CostosAtribuiblesAdministracion = tmp.GastoAdmon,
				@IdCatalogoCuentasSH = cc.IdCatalogoCuentasSH,
				@IdPrograma = tmp.IdLineaPresupuesto
			from CO_Registro reg				
			inner join #tmpProcesarGastos tmp on tmp.Id = @Id
			inner join FI_Factura fac on  rtrim(fac.UUID) = rtrim(tmp.UUID) and
											fac.idFactura = reg.IdFactura
			inner join AP_Perfil per on per.IdContrato = fac.IdContrato
			inner join AP_PerfilUsuario pu on pu.PerfilID = per.IdPerfil
			inner join AP_Usuario u on u.UsuarioID = pu.UsuarioID
			inner join CO_CatalogoCuentaSH cc on rtrim(cc.Nivel3) = rtrim(tmp.CuentaContable)
			where u.UsuarioID = @pUsuarioID 
			ORDER BY cc.IdVersion DESC

			update CO_Registro 
			set Poliza = @Poliza,
				CostosAtribuiblesAdministracion = @CostosAtribuiblesAdministracion,
				IdCatalogoCuentasSH = @IdCatalogoCuentasSH,
				IdUsuarioModPor= @pUsuarioID,
				FecMovto = getdate(),
				IdPrograma = @IdPrograma
			from CO_Registro reg				
			inner join #tmpProcesarGastos tmp on tmp.Id = @Id
			inner join FI_Factura fac on  rtrim(fac.UUID) = rtrim(tmp.UUID) and
											fac.idFactura = reg.IdFactura;
		end
		if @IdLineaP is null
		begin 
			SELECT TOP 1
				@Poliza = tmp.Poliza,
				@CostosAtribuiblesAdministracion = tmp.GastoAdmon,
				@IdCatalogoCuentasSH = cc.IdCatalogoCuentasSH
			from CO_Registro reg				
			inner join #tmpProcesarGastos tmp on tmp.Id = @Id
			inner join FI_Factura fac on  rtrim(fac.UUID) = rtrim(tmp.UUID) and
											fac.idFactura = reg.IdFactura
			inner join AP_Perfil per on per.IdContrato = fac.IdContrato
			inner join AP_PerfilUsuario pu on pu.PerfilID = per.IdPerfil
			inner join AP_Usuario u on u.UsuarioID = pu.UsuarioID
			inner join CO_CatalogoCuentaSH cc on rtrim(cc.Nivel3) = rtrim(tmp.CuentaContable)
			where u.UsuarioID = @pUsuarioID 
			ORDER BY cc.IdVersion DESC


			update CO_Registro 
			set Poliza = @Poliza,
				CostosAtribuiblesAdministracion = @CostosAtribuiblesAdministracion,
				IdCatalogoCuentasSH = @IdCatalogoCuentasSH,
				IdUsuarioModPor= @pUsuarioID,
				FecMovto = getdate()
			from CO_Registro reg				
			inner join #tmpProcesarGastos tmp on tmp.Id = @Id
			inner join FI_Factura fac on  rtrim(fac.UUID) = rtrim(tmp.UUID) and
											fac.idFactura = reg.IdFactura

		end

		if @@error <> 0
		begin
			select 'EROROR'
			rollback tran
			goto continue_while
		end
		
		update CO_GastosActualizar
		set Procesado = 1
		from CO_GastosActualizar
		where id = @Id	

		if @@error <> 0
		begin
			select 'EROROR'
			rollback tran
			goto continue_while
		end

		commit tran

		continue_while:

		
		select @Id = min(id)
		from #tmpProcesarGastos
		where id > @Id
		set @IdLineaP = (select IdLineaPresupuesto from #tmpProcesarGastos where Id = @Id)

	end

