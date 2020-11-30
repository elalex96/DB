CREATE PROCEDURE p_SC_InsUpImportaContrato
(
@IdSCCarga int,
@pRFCContratista varchar(20),
@pRFCProveedor varchar(20),
@pFechaPedido varchar(50),
@pNumeroPedido varchar(50),
@pFechaContratoIni DateTime,
@FechaContratoFin DateTime,

@pDescripcion varchar(500),
@DiasCredito smallint,
@pPartida varchar(20),
@pDescripcionPartida varchar(1000),
@pUnidadMedida  varchar(50),
@pCantidad float,
@pPrecioUnitario float,
@pMoneda varchar(20),
@pImporte float,
@pTipoPedido VARCHAR(100)
)
AS
BEGIN
	declare @IdSCDetalle int = (select ISNULL(max(IdSCDetalle + 1),1) from SC_importacion )
	,@IdTipoPedido int = (SELECT top 1 IdTipoPedido FROM PETROVENDOR.[dbo].[MM_TipoPedido] where TipoPedido LIKE '%' + @pTipoPedido + '%')
	if @pTipoPedido = ''
	begin
		set @IdTipoPedido = null;
	end

	IF EXISTS (SELECT * FROM SC_importacion where rfccontratista = @pRFCContratista and NumeroPedido = @pNumeroPedido and IdSCCarga < @IdSCCarga )
	BEGIN
		select 0 as num 
	END
	ELSE
	BEGIN

		INSERT INTO Adinco..SC_importacion(IdSCDetalle,
			IdSCCarga,		RFCContratista,		RFCProveedor,		FechaPedido,
			NumeroPedido,	FechaContratoIni,	FechaContratoFin,	
			Descripcion,	DiasCredito,		Partida,			DescripcionPartida,
			UnidadMedida,	Cantidad,			PrecioUnitario,		Moneda,
			Importe,		CreadoEl, IdTipoPedido)
			VALUES
			(@IdSCDetalle,
			@IdSCCarga,	@pRFCContratista,	@pRFCProveedor,		@pFechaPedido,
			@pNumeroPedido,	@pFechaContratoIni, @FechaContratoFin,	
			@pDescripcion,  @DiasCredito,		@pPartida,			@pDescripcionPartida,
			@pUnidadMedida,	@pCantidad,			@pPrecioUnitario,	@pMoneda,
			@pImporte,		GETDATE(), @IdTipoPedido)
	END
	
END



