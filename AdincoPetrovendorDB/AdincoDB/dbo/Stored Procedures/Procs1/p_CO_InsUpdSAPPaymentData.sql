IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_CO_InsUpdSAPPaymentData'
)
    DROP PROCEDURE p_CO_InsUpdSAPPaymentData
GO

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
			select 1 from CO_SAPVendor v 
			INNER JOIN PV_Subcontratista sub on sub.RFC = v.TAXID
			inner join Petrovendor..S_Proveedor prov on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = v.TAXID COLLATE SQL_Latin1_General_CP1_CI_AS
			INNER JOIN PV_CuentaBancaria cb ON (cb.NumeroCuenta = @pFinalAccount	OR cb.CuentaClave = @pFinalAccount) and
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
			inner join PV_TipoMoneda m on m.TipoMonedaCorto = @pCurrency	
			where  v.VendorIDSAP =@pSAPVendorId and
			v.IdCOntrato = @pIdContrato
		end


		/******************************************************************************************/

	

		if not exists (
			select 1
			from [CO_SAPPaymentData]
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


		IF NOT EXISTS(select 1 from CO_SAPVendor where VendorIDSAP = @pSAPVendorId)
		BEGIN
			SELECT @pError = concat('No se encontró el proveedor: ', isnull(@pNamePayee,'NULL'), ' con el VendorIDSAP: ', ISNULL(@pSAPVendorId, 'NULL') ,' de la tabla CO_SAPVendor. ')
		END

		IF NOT EXISTS(select 1 from PV_CuentaBancaria where NumeroCuenta = @pFinalAccount or CuentaClave = @pFinalAccount)
		BEGIN
			SELECT @pError += CONCAT( ' No se encontró la cuenta bancaria: ', ISNULL(@pFinalAccount, 'NULL'), '. ')
		END

		DECLARE @IdSubcontratista INT
		select @IdSubcontratista = IdProveedor from PV_CuentaBancaria where NumeroCuenta = @pFinalAccount or CuentaClave = @pFinalAccount
		IF NOT EXISTS(select 1 from PV_Subcontratista where IdSubcontratista = @IdSubcontratista)
		BEGIN
			SELECT @pError += CONCAT( ' No se encontró el Subcontratista con IdSubcontratista: ', ISNULL(@IdSubcontratista, 'NULL'), ' de la tabla PV_Subcontratista. ')
		END

		DECLARE @RFC varchar(50)
		SELECT @RFC = LTRIM(RTRIM(TaxID)) FROM CO_SAPVendor WHERE VendorIDSAP = @pSAPVendorId
		IF NOT EXISTS(SELECT 1 FROM Petrovendor..S_Proveedor WHERE RFC = @RFC)
		BEGIN
			SELECT @pError += CONCAT( ' No se encontró el RFC en Petrovendor: ', ISNULL(@RFC, 'NULL'), ' de la tabla Petrovendor..S_Proveedor. ')
		END



		IF(ISNULL(@pError, '') = '')
		BEGIN
			if not exists (
				select 1 from CO_SAPVendor v 
				INNER JOIN PV_Subcontratista sub on sub.RFC = v.TAXID
				inner join Petrovendor..S_Proveedor prov on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = v.TAXID COLLATE SQL_Latin1_General_CP1_CI_AS
				INNER JOIN PV_CuentaBancaria cb ON (cb.NumeroCuenta = @pFinalAccount	OR cb.CuentaClave = @pFinalAccount) and
												cb.IdProveedor = sub.IdSubcontratista
				where  v.VendorIDSAP =@pSAPVendorId and
				v.IdCOntrato = @pIdContrato
			)
			begin
				set @pError = CONCAT('No existe la cuenta ', isnull(@pFinalAccount, 'NULL'), ' del proveedor: ', isnull(@pNamePayee,' NULL'), ' .PaymentReference: ', ISNULL(@pPaymentReference, 'NULL'))
			end

			DECLARE @IdContratista INT
			SELECT @IdContratista = IdContratista FROM CO_Contrato WHERE IdContrato = @pIdContrato
			if not exists (
				SELECT 1
				FROM PV_CuentaBancaria C
				INNER JOIN CO_Contrato CO on CO.IdContrato = @pIdContrato AND
									CO.IdContratista = C.IdContratista AND
									C.Activa = 1 AND
									(RTRIM(C.NumeroCuenta) = RTRIM(@pSourceAccount) OR RTRIM(C.CuentaClave)  =RTRIM(@pSourceAccount))
			)
			BEGIN
				set @pError = CONCAT('No se encontró la cuenta Origen: ', isnull(@pSourceAccount, 'NULL') , ' .PaymentReference: ', @pPaymentReference, ' en el contrato con el IdContratista: ', ISNULL(@IdContratista, 'NULL'), ' en la tabla de PV_CuentaBancaria.')
			END
		END


		commit tran

		exec p_COSAP_Transferencia_Gen @pCreadoPor

		END TRY  
		BEGIN CATCH  

			rollback tran
			set @pError = Concat( 'Error sp: ',ERROR_PROCEDURE(), ' - Error Line: ', ERROR_LINE(), ' - Error Message: ' , ERROR_MESSAGE() )
			
			
		END CATCH 



