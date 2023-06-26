CREATE Proc [dbo].[p_CO_InsUpdSAPPaymentData]
@pIdContrato	int,
@pSourceAccount	varchar(20),
@pFinalAccount	varchar(20),
@pPaymentReference	varchar(10),
@pPaymentForm	varchar(2),
@pPaymentDate	varchar(10),
@pPaidAmount	float,
@pCurrency	varchar(5),
@pConcepto	varchar(50),
@pNumeroPolizaContable	varchar(20),
@pPDF	varchar(250),
@pInterest	float,
@pNamePayee varchar(50),
@pSAPVendorId varchar(50),
@pVendorBankName varchar(50),
@pCreadoPor int,
@pInvoiceNumber varchar(20)='',
@pError varchar(500) out

as


		declare @IdMoneda int,
			@IdMetodoPago int,
			@IdTransferencia int,
			@titularCuenta varchar(500)

		select @IdMoneda = IdMoneda
		from PV_TipoMoneda (NOLOCK)
		where TipoMOnedaCorto = @pCurrency

		select @IdMetodoPago = IdMetodoPagoAdinco
		from [CO_SAPTaxMinistry_detalle] (NOLOCK)
		where SAPPayType = @pPaymentForm and
		IdContrato = @pIdContrato


		BEGIN TRY 

		
		begin tran

		/**************SI NO EXISTE CUENTA DESTINO. GENERARLA AUTOMÁTICAMENTE**********************/
		if not exists (
			select 1 from CO_SAPVendor v (NOLOCK)
			INNER JOIN PV_Subcontratista sub (NOLOCK) on sub.RFC = v.TAXID
			inner join Petrovendor..S_Proveedor prov  (NOLOCK) on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = v.TAXID COLLATE SQL_Latin1_General_CP1_CI_AS
			INNER JOIN PV_CuentaBancaria cb (NOLOCK) ON (cb.NumeroCuenta = @pFinalAccount	OR cb.CuentaClave = @pFinalAccount) and
											cb.IdProveedor = sub.IdSubcontratista
			where  v.VendorIDSAP =@pSAPVendorId and
			v.IdCOntrato = @pIdContrato
		)
		begin
			insert into PV_CuentaBancaria(
				/*DatoBancarioID,*/		BancoID,		Titular,		Sucursal,		NumeroCuenta,
				CuentaClave,		NumeroTarjeta,	TipoMonedaID,	IdProveedor,	Predeterminado,
				IdTipoCuenta,		TipoCuentaTemp,	Codigo,			claveBanco,		RFC,
				IdContratista,		Activa,			CreadoPor,		CreadoEn,		Eliminada,
				IdCuenta,			Alias
			)
			select					null,	prov.RazonSocial,			null,		@pFinalAccount,
			@pFinalAccount,			null,		m.IdMoneda,				sub.IdSubcontratista,1,
			1,						null,			null,			null,			sub.RFC,
			null,					1,				@pCreadoPor,	getdate(),		0,
			null,					null
			from CO_SAPVendor v (NOLOCK)
			INNER JOIN PV_Subcontratista sub (NOLOCK) on sub.RFC = v.TAXID
			inner join Petrovendor..S_Proveedor prov (NOLOCK) on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = v.TAXID COLLATE SQL_Latin1_General_CP1_CI_AS	
			inner join PV_TipoMoneda m (NOLOCK) on m.TipoMonedaCorto = 	@pCurrency	
			where  v.VendorIDSAP =@pSAPVendorId and
			v.IdCOntrato = @pIdContrato
		end


		/******************************************************************************************/

	

		if not exists (
			select 1
			from [CO_SAPPaymentData] (NOLOCK)
			where IdContrato = @pIdContrato and
			rtrim(SourceAccount) = rtrim(@pSourceAccount) and
			rtrim(FinalAccount) = rtrim(@pFinalAccount) and
			rtrim(PaymentReference) = rtrim(@pPaymentReference) and
			cast(PaidAmount as decimal(10,2)) = cast(@pPaidAmount as decimal(10,2))  and
			rtrim(PaymentDate) = rtrim(@pPaymentDate) and
			rtrim(isnull(InvoiceNumber,'')) = rtrim(@pInvoiceNumber)

		)
		begin
			insert into CO_SAPPaymentData(
				IdContrato,		SourceAccount,	FinalAccount,	PaymentReference,
				PaymentForm,	PaymentDate,	PaidAmount,		Currency,
				Concepto,		NumeroPolizaContable,PDF,		Interest,
				NamePayee,		SAPVendorId,	VendorBankName,InvoiceNumber
			)
			select @pIdContrato,		@pSourceAccount,	@pFinalAccount,	@pPaymentReference,
				@pPaymentForm,	@pPaymentDate,	@pPaidAmount,		@pCurrency,
				@pConcepto,		@pNumeroPolizaContable,@pPDF,		@pInterest,
				@pNamePayee,	@pSAPVendorId,	@pVendorBankName,@pInvoiceNumber	

	


		end
		else
		Begin			

			update CO_SAPPaymentData
			set PaymentForm = @pPaymentForm,
				---PaymentDate = @pPaymentDate,
				--PaidAmount = @pPaidAmount,
				Currency=@pCurrency,
				Concepto=@pConcepto,
				NumeroPolizaContable=@pNumeroPolizaContable,
				PDF=@pPDF,
				Interest=@pInterest,
				NamePayee = @pNamePayee,
				SAPVendorId = @pSAPVendorId,
				VendorBankName = @pVendorBankName
			where IdContrato = @pIdContrato and
			SourceAccount = @pSourceAccount and
			FinalAccount = @pFinalAccount and
			PaymentReference = @pPaymentReference and
			PaidAmount = @pPaidAmount and
			PaymentDate = @pPaymentDate and
			rtrim(isnull(InvoiceNumber,'')) = rtrim(@pInvoiceNumber)


		
			

			
		End


		if not exists (
			select 1 from CO_SAPVendor v (NOLOCK)
			INNER JOIN PV_Subcontratista sub (NOLOCK) on sub.RFC = v.TAXID
			inner join Petrovendor..S_Proveedor prov (NOLOCK) on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = v.TAXID COLLATE SQL_Latin1_General_CP1_CI_AS
			INNER JOIN PV_CuentaBancaria cb (NOLOCK) ON (cb.NumeroCuenta = @pFinalAccount	OR cb.CuentaClave = @pFinalAccount) and
											cb.IdProveedor = sub.IdSubcontratista
			where  v.VendorIDSAP =@pSAPVendorId and
			v.IdCOntrato = @pIdContrato
		)
		begin
			set @pError = 'No existe la cuenta ' + isnull(@pFinalAccount,'') +' del proveedor ' + isnull(@pNamePayee,'')+' .PaymentReference:'+@pPaymentReference
		end

		if not exists (
			SELECT 1
			FROM PV_CuentaBancaria C (NOLOCK)
			INNER JOIN CO_Contrato CO (NOLOCK) on CO.IdContrato = @pIdContrato AND
								CO.IdContratista = C.IdContratista AND
								C.Activa = 1 AND
								(RTRIM(C.NumeroCuenta) = RTRIM(@pSourceAccount) OR RTRIM(C.CuentaClave)  =RTRIM(@pSourceAccount))
		)
		BEGIN
			set @pError = 'No existe la cuenta Origen ' + isnull(@pSourceAccount,'') +' .PaymentReference:'+@pPaymentReference
		END



		commit tran

		exec p_COSAP_Transferencia_Gen @pCreadoPor

		END TRY  
		BEGIN CATCH  

			rollback tran
			set @pError = Concat( 'Error sp: ',ERROR_PROCEDURE(), ' - Error Line: ', ERROR_LINE(), ' - Error Message: ' , ERROR_MESSAGE() )
			
			
		END CATCH 



