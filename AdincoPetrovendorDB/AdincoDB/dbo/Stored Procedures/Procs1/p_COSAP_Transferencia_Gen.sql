-- =============================================
-- Author:		Reyna O.
-- Create date: 05-07-2022
-- Description: Se agrega NOLOCK, se eliminan comentarios y se mueven las creaciones 
-- de la tabla al inicio de procedure
-- =============================================
CREATE PROCEDURE p_COSAP_Transferencia_Gen
@pCreadoPor int
as
	CREATE TABLE #tmpCuentas
	(
		Vendor VARCHAR(50) null,
		Cuenta VARCHAR(50),
		EsOrigen BIT
	)
	CREATE TABLE #tmpTransfer
	(
			ID INT identity(1,1),
			IdContrato	INT,
			SourceAccount	VARCHAR(500),
			FinalAccount	VARCHAR(500),
			PaymentReference	VARCHAR(500),
			PaymentForm	VARCHAR(500),
			PaymentDate	VARCHAR(500),
			PaidAmount	FLOAT,
			Currency	VARCHAR(50),
			Concepto	VARCHAR(1000),
			NumeroPolizaContable	VARCHAR(500),
			PDF	VARCHAR(500),
			Interest FLOAT,
			NamePayee	VARCHAR(1000),
			SAPVendorId	VARCHAR(1000),
			VendorBankName	VARCHAR(1000),
			IdTransferencia	INT
	)

	DECLARE @IdMoneda INT,
			@IdMetodoPago INT,
			@IdTransferencia INT,
			@pCurrency	varchar(5),
			@IdTransferencia_last INT=0;

	DECLARE @id INT=0;

	INSERT INTO #tmpTransfer(
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
			IdTransferencia) 
	
	SELECT
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
	FROM 
		CO_SAPPaymentData	(NOLOCK)
	WHERE 
		IdTransferencia is null
	ORDER BY 
		PaymentDate;	

	SELECT @id = MIN(ID)
	FROM 
		#tmpTransfer;

	WHILE @id is not null
	BEGIN

		SET @IdTransferencia = 0

		SELECT 
			@pCurrency = Currency
		FROM 
			#tmpTransfer
		WHERE 
			id = @id;


		SELECT 
			@IdMoneda = IdMoneda
		FROM 
			PV_TipoMoneda	(NOLOCK)
		WHERE 
			TipoMOnedaCorto = @pCurrency;

		SELECT 
			@IdMetodoPago = IdMetodoPagoAdinco
		FROM
			#tmpTransfer	t
		JOIN 
			[CO_SAPTaxMinistry_detalle]	t2	(NOLOCK)
			ON	t2.SAPPayType	=	t.PaymentForm 
			AND	t2.IdContrato	=	t.IdCOntrato
		WHERE	t.id	=	@id;


		/**************SI NO EXISTE CUENTA DESTINO. GENERARLA AUTOMÁTICAMENTE**********************/
		IF NOT EXISTS (
			SELECT * 
			FROM 
				#tmpTransfer t
			JOIN 
				CO_SAPVendor	v	(NOLOCK)
				ON v.VendorIDSAP = t.SAPVendorId
				AND	t.id	=	@id
				AND	v.IdCOntrato	=	t.IdContrato
			JOIN 
				PV_Subcontratista	sub	(NOLOCK)
				ON sub.RFC = v.TAXID
			JOIN 
				Petrovendor..S_Proveedor	prov	(NOLOCK)
				ON prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = v.TAXID COLLATE SQL_Latin1_General_CP1_CI_AS
			JOIN 
				PV_CuentaBancaria	cb	(NOLOCK)
				ON (cb.NumeroCuenta = t.FinalAccount	OR	cb.CuentaClave = t.FinalAccount) 
				AND	cb.IdProveedor = sub.IdSubcontratista
			WHERE   
				t.id = @id			
				AND	v.IdCOntrato = t.IdContrato
		)
		BEGIN
			INSERT INTO PV_CuentaBancaria(
				/*DatoBancarioID,*/		BancoID,		Titular,		Sucursal,		NumeroCuenta,
				CuentaClave,		NumeroTarjeta,	TipoMonedaID,	IdProveedor,	Predeterminado,
				IdTipoCuenta,		TipoCuentaTemp,	Codigo,			claveBanco,		RFC,
				IdContratista,		Activa,			CreadoPor,		CreadoEn,		Eliminada,
				Alias
			)	
			SELECT					null,	prov.RazonSocial,			null,		t.FinalAccount,
			t.FinalAccount,			null,		@IdMoneda,				sub.IdSubcontratista,1,
			1,						null,			null,			null,			sub.RFC,
			null,					1,				@pCreadoPor,	getdate(),		0,
			null
			FROM 
				#tmpTransfer t
			JOIN 
				CO_SAPVendor	v	(NOLOCK) 
				ON v.VendorIDSAP = t.SAPVendorId
				AND	t.id	=	@id			
				AND	v.IdCOntrato	=	t.IdContrato
			JOIN 
				PV_Subcontratista	sub	(NOLOCK)
				ON	sub.RFC	=	v.TAXID
			JOIN 
				Petrovendor..S_Proveedor	prov	(NOLOCK)
				ON	prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = v.TAXID COLLATE SQL_Latin1_General_CP1_CI_AS						
			WHERE
				t.id = @id			
				AND	v.IdCOntrato = t.IdContrato;
		END

		/******************************************************************************************/
		
		BEGIN TRAN

			SELECT 
				@IdTransferencia =  tr.IdTransferencia
			FROM 	
				#tmpTransfer t
			JOIN 
				[PV_CuentaBancaria]	cOrig	(NOLOCK)
				ON	(
							rtrim(cOrig.NumeroCuenta) = rtrim(t.SourceAccount) OR
							rtrim(cOrig.CuentaClave) = rtrim(t.SourceAccount)														
					)
			JOIN 
				[PV_CuentaBancaria]	cDest	(NOLOCK)
				ON	(
						rtrim(cDest.NumeroCuenta) = rtrim(t.FinalAccount) OR
						rtrim(cDest.CuentaClave) = rtrim(t.FinalAccount) 
					)
					
			JOIN 
				FI_Transfer	tr	(NOLOCK)
				ON	tr.ReferenciaBancaria = t.PaymentReference 
					AND	tr.IdCuentaOrigen = cOrig.DatoBancarioID 
					AND	tr.IdCuentaDestino = cDest.DatoBancarioID 
					AND	tr.MontoPagado = t.PaidAmount  
					AND	convert(varchar,tr.FechaPago,112) = convert(varchar,t.PaymentDate,112)
					AND	TR.ReferenciaBancaria = T.PaymentReference
			WHERE 
				t.id = @id; 

			IF(ISNULL(@IdTransferencia,0) = 0)
			BEGIN

				INSERT INTO FI_Transfer(
					/*IdTransferencia,*/		IdContrato,		IdComprobantePago,		NombreExtencionArchivo,
					ReferenciaBancaria,		FechaPago,		IdCuentaOrigen,			IdCuentaDestino,
					MontoPagado,			IdMoneda,		IdClasificacionDocumento,Concepto,
					IdMetodoPago,			ProcesadoSIPAC,	NumeroPolizaContable,	Intereses,
					PDF,					CreadoPor,		CreadoEn,				ModificadoPor,
					ModificadoEn,			HashSHA256,		IdFacturaPago,			AWSPDFId)
				
				SELECT						t.IdContrato,			t.PaymentReference,		null,
					t.PaymentReference,		t.PaymentDate,	cOrig.DatoBancarioID,	cDest.DatoBancarioID,
					t.PaidAmount,			@IdMoneda,		1,						t.Concepto	,
					@IdMetodoPago,			0,				t.NumeroPolizaContable,	0,
					null,					@pCreadoPor,	getdate()	,			null,
					null,					null,			null,					null		
						
				FROM 
					#tmpTransfer t
				JOIN 
					[PV_CuentaBancaria]	cOrig	(NOLOCK)
					ON	(
							rtrim(cOrig.NumeroCuenta) = rtrim(t.SourceAccount) OR
							rtrim(cOrig.CuentaClave) = rtrim(t.SourceAccount)														
						)
				JOIN 
					[PV_CuentaBancaria]	cDest	(NOLOCK)
					ON	(
							rtrim(cDest.NumeroCuenta) = rtrim(t.FinalAccount) OR
							rtrim(cDest.CuentaClave) = rtrim(t.FinalAccount) 
						)									
				WHERE 
					t.id = @id;
			
				IF @@error <> 0
				BEGIN
					rollback tran
					goto fin
				END		

			END

			IF(@IdTransferencia_last <> @IdTransferencia)
			BEGIN
				SET @IdTransferencia_last = @IdTransferencia;

				IF(ISNULL(@IdTransferencia,0) > 0)
				BEGIN
					UPDATE 
						[CO_SAPPaymentData]
					SET 
						IdTransferencia = @IdTransferencia
					FROM 
						CO_SAPPaymentData pd	(NOLOCK)
					JOIN 
						#tmpTransfer t 
						ON t.Id = @id
					WHERE 			
						pd.IdContrato = t.IdContrato
						AND	pd.SourceAccount = t.SourceAccount
						AND	pd.FinalAccount = t.FinalAccount
						AND	pd.PaymentReference = t.PaymentReference
						AND	pd.PaidAmount = t.PaidAmount
						AND	pd.PaymentDate = t.PaymentDate;
				END

				IF @@error <> 0
				BEGIN
					rollback tran
					goto fin
				END
			END
			commit tran

		fin:

		SELECT 
			@id = min(ID)
		FROM 
			#tmpTransfer
		WHERE 
			id > @id;
	END