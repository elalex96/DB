--===================================
-- Actualizado por :Luis David De La Cruz
-- Descripción : Se quitan columnas A y B del archivo de importación 
CREATE PROC p_FI_TransferImportacion_InsUpd
@pIdTransferenciaImportacion int,
@pId int out,
@pIdContratistaSesion int,
@pRFCEmisor	varchar(15),
@pProveedor varchar(350),
@pFormaPago varchar(50),
@pBancoOrigen  varchar(50),
@pCuentaOrigen varchar(20),
@pBancoDestino varchar(50),
@pCuentaDestino varchar(20),
@pFechaPago DateTime,
@pMontoPagado float,
@pInteres float,
@pMonedaPago varchar(5),
@pConcepto varchar(250),
@pNumeroPoliza int,
@pUUIDFactura varchar(60),
@pValorFactura float,
@pMonedaFactura varchar(5),
@pContrato varchar(100),
@pCreadoPor int,
@pError varchar(250) out
as

	DECLARE @pIdContrato int
	set @pError = ''

	select @pIdTransferenciaImportacion = isnull(max(IdTransferenciaImportacion),0) + 1
	from [FI_TransferImportacion]

	--Obtener contrato
	SELECT @pIdContrato  =IdContrato
	FROM CO_Contrato
	where upper(NumeroContrato) = upper(@pContrato) and
	IdContratista = @pIdContratistaSesion

	if isnull(@pIdContrato,0) = 0
	begin
		set @pError = 'No fue posible obtener el contrato ' + ISNULL(@pContrato,'') + '. Revise que el contrato corresponda al contratista'
	end

	if isnull(@pError,'') <> ''
		return

	if isnull(@pId,0) = 0
	begin
		select @pId = isnull(max(Id),0) + 1
		from [FI_TransferImportacion]
	end


	--if not exists (
	--	select 1
	--	from [FI_TransferImportacion]
	--	where IdContrato = @pIdContrato and
	--	CuentaOrigen = @pCuentaOrigen and
	--	CuentaDestino = @pCuentaDestino and
	--	convert(varchar,FechaPago,112) = convert(varchar,@pFechaPago,112)

	--)
	--begin

	insert into [dbo].[FI_TransferImportacion](
			IdTransferenciaImportacion,			IdContrato,			
			RFCEmisor,							Proveedor,			FormaPago,		BancoOrigen,
			CuentaOrigen,						BancoDestino,		CuentaDestino,	FechaPago,
			MontoPagado,						Interes,			MonedaPago,		Concepto,
			NumeroPoliza,						UUIDFactura,		ValorFactura,	MonedaFactura,
			Sincronizar,						IdTransferFactura,	CreadoEl,		ModificadoEl,
			TieneError,							Contrato,			Id
	)
	select 
			@pIdTransferenciaImportacion,			@pIdContrato,			
			@pRFCEmisor,							@pProveedor,			@pFormaPago,		@pBancoOrigen,
			@pCuentaOrigen,						@pBancoDestino,			@pCuentaDestino,		@pFechaPago,
			@pMontoPagado,						@pInteres,				@pMonedaPago,			@pConcepto,
			@pNumeroPoliza,						@pUUIDFactura,			@pValorFactura,			@pMonedaFactura,
			1,						null,	getdate(),				null,
			0,									@pContrato,			@pId

	--End
	--Else
	--Begin
	--	update [FI_TransferImportacion]
	--	set RFCEmisor = @pRFCEmisor,
	--	Proveedor = @pProveedor,
	--	FormaPago = @pFormaPago,
	--	MontoPagado = @pMontoPagado,
	--	MonedaPago = @pMonedaPago,
	--	Concepto = @pConcepto,
	--	NumeroPoliza = @pNumeroPoliza,
	--	ValorFactura = @pValorFactura,
	--	Sincronizar = 1,
	--	ModificadoEl = getdate(),
	--	Contrato = @pContrato
	--	where IdContrato = @pIdContrato and
	--	CuentaOrigen = @pCuentaOrigen and
	--	CuentaDestino = @pCuentaDestino and
	--	convert(varchar,FechaPago,112) = convert(varchar,@pFechaPago,112)
	--End