create proc p_CO_GastosActualizar_Ins
@pId int,
@pUUIDImport varchar(100),
@pRFCEmisor varchar(18),
@pUUID varchar(100),
@pCuentaContable varchar(20),
@pPoliza varchar(20),
@pGastoAdmon bit,
@pProcesado bit,
@pCreadoPor int,
@pIdLineaPresupuesto int
as

if @pIdLineaPresupuesto = 0
begin
	set @pIdLineaPresupuesto = (null);
end


	select @pId = isnull(max(Id),0)+1
	from  CO_GastosActualizar

	insert into [CO_GastosActualizar](
		Id,				UUIDImport,				RFCEmisor,		UUID,
		CuentaContable,	Poliza,					GastoAdmon,		Procesado,
		CreadoEl,		CreadoPor,				IdLineaPresupuesto
	)
	values(
		@pId,				@pUUIDImport,				@pRFCEmisor,		@pUUID,
		@pCuentaContable,	@pPoliza,					@pGastoAdmon,		0,
		getdate(),			@pCreadoPor,				@pIdLineaPresupuesto
	)
