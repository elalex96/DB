
-- p_FI_TransferImportacion_Validacion 10037
create proc p_FI_TransferImportacion_Validacion
@pIdContrato int
as

	declare @idTransferImport int

	create table #tmpResult
	(
		idTransferImport int,
		Error varchar(500)
	)

	select *
	into #tmpImportacion
	from [FI_TransferImportacion]
	where IdContrato = @pIdContrato and
	isnull(Sincronizar,0) = 1


	select @idTransferImport = min(IdTransferenciaImportacion)
	from #tmpImportacion

	while @idTransferImport is not null
	begin

		declare @moneda varchar(10)
		--Validar Moneda
		select @moneda = MOnedaPago
			from [FI_TransferImportacion] ti											
			where IdTransferenciaImportacion = @idTransferImport

		if isnull(@moneda,'') = ''
		begin
			insert into #tmpResult
			select @idTransferImport, 'Es necesario especificar una moneda de pago'
		end
		
		--Validar que exista la factura

		if not exists (
			select 1
			from [FI_TransferImportacion] ti
			inner join FI_Factura f on f.IdContrato = ti.IdContrato and
								rtrim(f.UUID) = rtrim(ti.UUIDFactura)
			where IdTransferenciaImportacion = @idTransferImport
		)
		begin 

			insert into #tmpResult
			select @idTransferImport,'No existe la factura ' + UUIDFactura
			from  [FI_TransferImportacion] ti
			where IdTransferenciaImportacion = @idTransferImport

		end


		--Validar que existan las cuentas contables
		if not exists (
			select 1
			from [FI_TransferImportacion] ti
			inner join [PV_CuentaBancaria] c on c.NumeroCuenta = ti.CuentaOrigen			
			where IdTransferenciaImportacion = @idTransferImport
		)
		
		Begin

			insert into #tmpResult
			select @idTransferImport,'No existe la cuenta Origen:'+ CuentaOrigen 
			from  [FI_TransferImportacion] ti
			where IdTransferenciaImportacion = @idTransferImport
			
			
		End
		if not exists (
			select 1
			from [FI_TransferImportacion] ti
			inner join [PV_CuentaBancaria] c on c.NumeroCuenta = ti.CuentaDestino			
			where IdTransferenciaImportacion = @idTransferImport
		)		
		Begin

			insert into #tmpResult
			select @idTransferImport,'No existe la cuenta Destino:'+ CuentaDestino 
			from  [FI_TransferImportacion] ti
			where IdTransferenciaImportacion = @idTransferImport
			
			
		End


		select @idTransferImport = min(IdTransferenciaImportacion)
			from #tmpImportacion
			where IdTransferenciaImportacion > @idTransferImport



	end

	select * from #tmpResult


