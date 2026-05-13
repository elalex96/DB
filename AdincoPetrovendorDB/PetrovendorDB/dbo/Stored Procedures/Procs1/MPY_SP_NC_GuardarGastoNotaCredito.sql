CREATE procedure [dbo].[MPY_SP_NC_GuardarGastoNotaCredito]	

	@IdProveedor INT,
	@IdUsuario  INT,		    
	@IdNotaCredito INT 
AS
BEGIN
	--EXEC [dbo].[SP_NC_GuardarGastoNotaCredito]	420,2205,3

	DECLARE @SubTotalFactura MONEY 
	DECLARE @CantidadProductosAP INT
	DECLARE @MontoUnitarioPorProducto MONEY
	DECLARE @IdFacturaNotaFactura INT 
	DECLARE @IdAceptacionPedido INT 
	DECLARE @MontoTotalAceptacion MONEY
	DECLARE @IdMonedaPedido INT 
	DECLARE @IdMonedaFactura INT 
	declare @IdPrograma int,
			@uuid varchar(50)
	
	---SUBTOTAL DE NOTA DE CREDITO
	SELECT @SubTotalFactura=F.SubTotal,
	@IdFacturaNotaFactura= F.IdFactura , 
	@IdAceptacionPedido=NC.IdAceptacionPedido,
	@IdMonedaFactura=F.IdMoneda,
	@uuid = UPPER(f.uuid)
	FROM dbo.FI_Factura F
	INNER JOIN dbo.MPY_MM_AceptacionNotaCredito NC 
		ON NC.IdFacturaNotaCredito=F.IdFactura
	WHERE NC.IdAceptacionNotaCredito=@IdNotaCredito
	GROUP BY F.SubTotal, F.IdFactura,NC.IdAceptacionPedido,F.IdMoneda, f.uuid

	select @MontoTotalAceptacion = @SubTotalFactura,
	@IdMonedaPedido = m.IdMoneda
	from MPY_MM_AceptacionPedido ap
	inner join MPY_MM_AceptacionPedidoDetalle apd on apd.IdAceptacionPedido = ap.IdAceptacionPedido
	inner join PV_TipoMoneda m on m.TipoMonedaCorto = apd.IdMoneda
	where AP.IdAceptacionPedido = @IdAceptacionPedido

	select @IdPrograma = max(reg.IdPrograma) from [dbo].[MPY_MM_AceptacionNotaCredito] anc
	inner join [dbo].[MPY_MM_AceptacionPedido] ap on ap.IdAceptacionPedido = anc.IdAceptacionPedido
	inner join Adinco..FI_Factura fac on fac.IdContrato = ap.IdContrato
	inner join Adinco..CO_Registro reg on reg.IdFactura = fac.IdFactura
	where anc.IdAceptacionNotaCredito = @IdNotaCredito aND
	REG.IdEstado = 10004
	
	 declare @itemsAceptacion int

	select @itemsAceptacion = count(distinct IdAceptacionPedidoDetalle)
	FROM dbo.MPY_MM_AceptacionPedido ap
	INNER JOIN dbo.MPY_MM_AceptacionPedidoDetalle apd ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
	WHERE ap.IdAceptacionPedido = @IdAceptacionPedido

	INSERT INTO dbo.CO_Registro
    (
        IdFactura,
		IdPrograma,
        MontoRegistro,
        InicioEjecucion,
        FinEjecucion,
        Comentarios,
        MesPresentacion,
        IdUsuarioCreadoPor,
        FecMovto,
        IdInstalacion,
        CreadoPor,
        IdCatalogoCuentasSH,
        CentroCostos,
        CuentaContable,
        IdLineaPresupuestoMes,
		Poliza,
		CostosAtribuiblesAdministracion,
		PCN,
		IdGastoRubro,
		IdCBSISH,
		IdAceptacionPedidoDetalle
    )
   SELECT
		@IdFacturaNotaFactura, 
		@IdPrograma,			
		--((((APD.Cantidad*aPD.PrecioUnitario)/@MontoTotalAceptacion))*
		--	@SubTotalFactura)-
		--	(((((APD.Cantidad*aPD.PrecioUnitario)/@MontoTotalAceptacion))*@SubTotalFactura)*2), ---> CANTIDAD PROPORCIONAL DEL MONTO DE LA NOTA DE CRÉDITO (% PORCENTAJE DEL MONTO DE ACEPTACIÓN)*MONTO DE LA NOTA DE CREDITO
		(@SubTotalFactura / @itemsAceptacion)*-1,
		FechaRecepcionServicio = ap.Creado,
		ap.Creado,
		apd.Detalle + ' Nota de Crédito:'+ ISNULL(@uuid,''), --CONCAT(POD.MaterialCotizadoTextoC, ' - ', i.NombreInstalacion COLLATE Modern_Spanish_CI_AS),
		DATEADD(MONTH, DATEDIFF(MONTH, 0,ap.Creado), 0), ---> DUDA QUE MES SE PONE 
		@IdUsuario,
		GETDATE(),
		max(i.IdInstalacion),--APDI.IdInstalacion,
		@IdUsuario,
		NULL,
		IdCentroCosto = null,--spdlp.IdCentroCosto,
		NULL,	
		IdLineaPresupuesto=null,--APDI.IdLineaPresupuesto,
		NULL,
		0,
		apd.PCN,
		apd.ClasificacionCN,
		vp.IdCatalogoHidrocarburos,
		apd.IdAceptacionPedidoDetalle
	FROM dbo.MPY_MM_AceptacionPedido ap
	INNER JOIN dbo.MPY_MM_AceptacionPedidoDetalle apd ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
	inner join ADINCO..CO_Contrato con on con.IdContrato = ap.IdContrato
	inner join Adinco..CO_Areacontractual ac on ac.IdAreaContractual = con.IdAreaContractual
	--INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
	--INNER JOIN dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido
	--INNER JOIN dbo.MM_PeticionOfertaDetalle pod ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle
	--INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
	--LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI ON APDI.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
	LEFT JOIN Adinco.dbo.CO_Instalacion i ON i.IdAreaContractual = ac.IdAreaContractual and i.Activo = 1
	LEFT JOIN MM_PCN_ValoresPesos vp ON vp.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
	WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
	group by APD.Cantidad,aPD.PrecioUnitario,i.IdInstalacion,apd.PCN,apd.ClasificacionCN,vp.IdCatalogoHidrocarburos,
	apd.IdAceptacionPedidoDetalle,ap.Creado,apd.Detalle

	IF(ISNULL(@uuid,'') <> '')
	BEGIN
		update Adinco..CO_Registro
		set IdPrograma = @IdPrograma
		where IdPrograma is null and
		Comentarios like '%'+@uuid+'%'
	END

	
	 
	 
END 

