-- p_COSAP_Transferencia_Gen 1
create proc p_COSAP_Transferencia_Gen
@pCreadoPor int
as

	
	declare @IdMoneda int,
			@IdMetodoPago int,
			@IdTransferencia int,
			@pCurrency	varchar(5),
			@IdTransferencia_last int=0


	select 	ID = identity(int,1,1),
			IdContrato,
			SourceAccount,
			FinalAccount,
			PaymentReference,
			PaymentForm,
			PaymentDate,
			PaidAmount,
			Currency,
			Concepto,
			NumeroPolizaContable,
			PDF,
			Interest,
			NamePayee,
			SAPVendorId,
			VendorBankName,
			IdTransferencia 
	into #tmpTransfer
	from CO_SAPPaymentData
	where IdTransferencia is null
	order by PaymentDate	

	create table #tmpCuentas
	(
		Vendor varchar(50) null,
		Cuenta varchar(50),
		EsOrigen bit
	)


	declare @id int

	select @id = min(ID)
	from #tmpTransfer

	while @id is not null
	begin

		set @IdTransferencia = 0

		select @pCurrency = Currency
		from #tmpTransfer
		where id = @id

		select @IdMoneda = IdMoneda
		from PV_TipoMoneda
		where TipoMOnedaCorto = @pCurrency

		select @IdMetodoPago = IdMetodoPagoAdinco
		from  #tmpTransfer t
		inner join [CO_SAPTaxMinistry_detalle] t2 on t2.SAPPayType = t.PaymentForm and
						t2.IdContrato = t.IdCOntrato
		where t.id = @id


		/**************SI NO EXISTE CUENTA DESTINO. GENERARLA AUTOMÁTICAMENTE**********************/
		if not exists (
			select * from #tmpTransfer t
			inner join CO_SAPVendor v on v.VendorIDSAP = t.SAPVendorId
			INNER JOIN PV_Subcontratista sub on sub.RFC = v.TAXID
			inner join Petrovendor..S_Proveedor prov on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = v.TAXID COLLATE SQL_Latin1_General_CP1_CI_AS
			INNER JOIN PV_CuentaBancaria cb ON (cb.NumeroCuenta = t.FinalAccount	OR cb.CuentaClave = t.FinalAccount) and
											cb.IdProveedor = sub.IdSubcontratista
			where   t.id = @id and			
			v.IdCOntrato = t.IdContrato
		)
		begin
			insert into PV_CuentaBancaria(
				/*DatoBancarioID,*/		BancoID,		Titular,		Sucursal,		NumeroCuenta,
				CuentaClave,		NumeroTarjeta,	TipoMonedaID,	IdProveedor,	Predeterminado,
				IdTipoCuenta,		TipoCuentaTemp,	Codigo,			claveBanco,		RFC,
				IdContratista,		Activa,			CreadoPor,		CreadoEn,		Eliminada,
				Alias
			)	
			select					null,	prov.RazonSocial,			null,		t.FinalAccount,
			t.FinalAccount,			null,		@IdMoneda,				sub.IdSubcontratista,1,
			1,						null,			null,			null,			sub.RFC,
			null,					1,				@pCreadoPor,	getdate(),		0,
			null
			from #tmpTransfer t
			inner join CO_SAPVendor v on v.VendorIDSAP = t.SAPVendorId
			INNER JOIN PV_Subcontratista sub on sub.RFC = v.TAXID
			inner join Petrovendor..S_Proveedor prov on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = v.TAXID COLLATE SQL_Latin1_General_CP1_CI_AS						
			where   t.id = @id and			
			v.IdCOntrato = t.IdContrato
		end




		/******************************************************************************************/
		
		begin tran

			SELECT @IdTransferencia =  tr.IdTransferencia
			from 	#tmpTransfer t
			inner join [PV_CuentaBancaria] cOrig on (
														rtrim(cOrig.NumeroCuenta) = rtrim(t.SourceAccount) OR
														rtrim(cOrig.CuentaClave) = rtrim(t.SourceAccount)														
													)
			inner join [PV_CuentaBancaria] cDest on (
														rtrim(cDest.NumeroCuenta) = rtrim(t.FinalAccount) OR
														rtrim(cDest.CuentaClave) = rtrim(t.FinalAccount) 
													)
					
			inner join FI_Transfer tr on 
										tr.ReferenciaBancaria = t.PaymentReference and
										tr.IdCuentaOrigen = cOrig.DatoBancarioID and
										tr.IdCuentaDestino = cDest.DatoBancarioID and
										tr.MontoPagado = t.PaidAmount  and
										convert(varchar,tr.FechaPago,112) = convert(varchar,t.PaymentDate,112)  AND
										TR.ReferenciaBancaria = T.PaymentReference

			where t.id = @id 

			if(isnull(@IdTransferencia,0) = 0)
			begin

				insert into FI_Transfer(
					/*IdTransferencia,*/		IdContrato,		IdComprobantePago,		NombreExtencionArchivo,
					ReferenciaBancaria,		FechaPago,		IdCuentaOrigen,			IdCuentaDestino,
					MontoPagado,			IdMoneda,		IdClasificacionDocumento,Concepto,
					IdMetodoPago,			ProcesadoSIPAC,	NumeroPolizaContable,	Intereses,
					PDF,					CreadoPor,		CreadoEn,				ModificadoPor,
					ModificadoEn,			HashSHA256,		IdFacturaPago,			AWSPDFId)
				
				select						t.IdContrato,			t.PaymentReference,		null,
					t.PaymentReference,		t.PaymentDate,	cOrig.DatoBancarioID,	cDest.DatoBancarioID,
					t.PaidAmount,			@IdMoneda,		1,						t.Concepto	,
					@IdMetodoPago,			0,				t.NumeroPolizaContable,	0,
					null,					@pCreadoPor,	getdate()	,			null,
					null,					null,			null,					null		
						
				from #tmpTransfer t
				inner join [PV_CuentaBancaria] cOrig on (
															rtrim(cOrig.NumeroCuenta) = rtrim(t.SourceAccount) OR
															rtrim(cOrig.CuentaClave) = rtrim(t.SourceAccount)														
														)
				inner join [PV_CuentaBancaria] cDest on (
															rtrim(cDest.NumeroCuenta) = rtrim(t.FinalAccount) OR
															rtrim(cDest.CuentaClave) = rtrim(t.FinalAccount) 
														)									
				where t.id = @id 	
			
				if @@error <> 0
				begin
					rollback tran
					goto fin
				end		

			end

			

			if(@IdTransferencia_last <> @IdTransferencia)
			begin
				set @IdTransferencia_last = @IdTransferencia


				if(isnull(@IdTransferencia,0) > 0)
				begin

					update [CO_SAPPaymentData]
					set IdTransferencia = @IdTransferencia
					from CO_SAPPaymentData pd
					inner join #tmpTransfer t on t.Id = @id
					where 			
					pd.IdContrato = t.IdContrato and
					pd.SourceAccount = t.SourceAccount and
					pd.FinalAccount = t.FinalAccount and
					pd.PaymentReference = t.PaymentReference and
					pd.PaidAmount = t.PaidAmount and
					pd.PaymentDate = t.PaymentDate

				end

				if @@error <> 0
				begin
					rollback tran
					goto fin
				end
			end

			
		
	
			

			commit tran

		fin:

		select @id = min(ID)
		from #tmpTransfer
		where id > @id
		
	end

	


	

