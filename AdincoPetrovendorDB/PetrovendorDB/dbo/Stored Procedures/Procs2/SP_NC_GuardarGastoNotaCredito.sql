-- =============================================  
-- Author:   Daniel AC  
-- Create date: 14/10/2020  
-- Description:   Se adapta subtotal asignado a la factura de la aceptación actual 
-- ============================================= 
CREATE procedure [dbo].[SP_NC_GuardarGastoNotaCredito]	

	@IdProveedor INT,
	@IdUsuario  INT,		    
	@IdNotaCredito INT 
AS
BEGIN
	/*SP PARA GUARDAR EL GASTOS PROPORCIONAL DE LA NOTA DE CREDITO RELACIANDA A LOS DETALLES DE ACEPTACIÓN PEDIDO*/

	DECLARE @SubTotalNotaCredito MONEY 
	DECLARE @SubTotalFactura MONEY
	DECLARE @CantidadProductosAP INT
	DECLARE @MontoUnitarioPorProducto MONEY
	DECLARE @IdFacturaNotaFactura INT 
	DECLARE @IdAceptacionPedido INT 
	DECLARE @MontoTotalAceptacion MONEY
	DECLARE @SubtotalFacturaAceptacion MONEY
	DECLARE @IdMonedaPedido INT 
	DECLARE @IdMonedaFactura INT 
	DECLARE @TotalAcumuladoFacturas MONEY 
	DECLARE @UUID_NOTACREDITO VARCHAR(MAX)
	DECLARE @tbSubtotal AS TABLE(SubTotal money)

	---SUBTOTAL DE NOTA DE CREDITO
	SELECT @SubTotalNotaCredito=F.SubTotal,
	@IdFacturaNotaFactura= F.IdFactura , 
	@IdAceptacionPedido=NC.IdAceptacionPedido,
	@IdMonedaFactura=F.IdMoneda,
	@UUID_NOTACREDITO=F.UUID
	FROM dbo.FI_Factura F
	JOIN dbo.MM_AceptacionNotaCredito NC 
		ON F.IdFactura=NC.IdFacturaNotaCredito
	WHERE NC.IdAceptacionNotaCredito=@IdNotaCredito
	GROUP BY F.SubTotal, F.IdFactura,NC.IdAceptacionPedido,F.IdMoneda, F.UUID
	
	---OBTENER MONTO ACUMULADO DE LAS FACTURAS RELACIONADAS A LA NOTA DE CREDITO
	INSERT INTO @tbSubtotal
	(
	    SubTotal
	)	
	SELECT FI.SubTotal  --> TOTAL DE LAS FACTURAS RELACIONADAS A LA NOTA DE CREDITO 
	FROM dbo.FI_Factura FNC
	JOIN dbo.MM_AceptacionNotaCredito NC
	ON FNC.IdFactura=NC.IdFacturaNotaCredito
	JOIN dbo.FI_Factura FI
	ON NC.CFDIRelacionados=FI.UUID --> UUID DE LAS FACTURAS DE LAS ACEPTACIONES DE PEDIDO QUE TIENE RELACIÓN A LA NOTA DE CREDITO ACTUAL 
	WHERE FNC.UUID=@UUID_NOTACREDITO --> UUID DE LA NOTA DE CREDITO 
	GROUP BY NC.IdAceptacionPedido,FNC.UUID, FI.UUID, FI.SubTotal
	
	--SUMAR SUBTOTALES DE LAS FACTURAS RELACIONADAS A LA NOTA DE CREDITO 
	SELECT @TotalAcumuladoFacturas= SUM(SubTotal) FROM @tbSubtotal
	
	SELECT
		@MontoTotalAceptacion=SUM(PD.PrecioUnitario* APD.Cantidad),
		@IdMonedaPedido=P.IdMoneda
	FROM dbo.MM_AceptacionPedido AP
	INNER JOIN dbo.MM_AceptacionPedidoDetalle APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
	INNER JOIN dbo.MM_PedidoDetalle PD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
	INNER JOIN dbo.MM_Pedido P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOfertaDetalle POD ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
	INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
	LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI ON APDI.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
	LEFT JOIN Adinco.dbo.CO_Instalacion i ON i.IdInstalacion = APDI.IdInstalacion
	LEFT JOIN MM_PCN_ValoresPesos vp ON vp.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
	WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
	GROUP BY P.IdMoneda

	
	--OBTENER SUBTOTAL DE LA FACTURA ACTUAL DE LA ACEPTACION DE PEDIDO 
	SELECT @SubtotalFacturaAceptacion=FI.SubTotal
	FROM dbo.MM_AceptacionFactura AF
	JOIN dbo.FI_Factura FI
	ON AF.IdFactura=FI.IdFactura
	WHERE AF.IdAceptacionPedido=@IdAceptacionPedido


	--OBTENER EL VALOR QUE LE CORRESPONDE A LA FACTURA RELACIONADA DEL SUBTOTAL DE LA NOTA DE CREDITO
	-- SI HAY UNA FACTURA RELACIOANDA LE DEBE CORRESPONDER EL 100% DEL SUBTOTAL DE LA NOTA DE CREDITO
	-- SI HAY N FACTURAS RELACIONADAS SE DEBE OBTENER EL VALOR QUE LE CORRESPONDE DEL SUBTOTAL DE LA NOTA DE CREDITO
	--PARA ESO SE OBTIENE UNA REGLA DE 3 
	-- EL MONTO ACUMULADO DE LAS FACTURAS RELACIONADAS = 100% DEL SUBTOTAL DE LA NOTA DE CREDITO
	-- EL MONTO POR FACTURA RELACIONADA = X DEL SUBTOTAL DE LA NOTA DE CREDITO
	IF ISNULL(@TotalAcumuladoFacturas,0)>0
		SET @SubTotalFactura = (ISNULL(@SubtotalFacturaAceptacion,0)/ISNULL(@TotalAcumuladoFacturas,0))*@SubTotalNotaCredito
	ELSE 
		SET @SubTotalFactura = @SubTotalNotaCredito

	--VALIDAR SI EL SUBTOTAL FACTURA(PORCENTAJE DEL SUBTOTAL DE LA NOTA DE CREDITO) SOBREPASA EL SUBTOTAL DE LA FACTURA DE LA ACEPTACIÓN, IGUALAR
	IF @SubTotalFactura>@SubtotalFacturaAceptacion
		SET @SubTotalFactura=@SubtotalFacturaAceptacion 

    --CREAR LOS GASTOS EN PETROVENDOR 
	INSERT INTO dbo.CO_Registro
    (
        IdFactura,
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
		((((APD.Cantidad*PD.PrecioUnitario)/@MontoTotalAceptacion))*@SubTotalFactura)-(((((APD.Cantidad*PD.PrecioUnitario)/@MontoTotalAceptacion))*@SubTotalFactura)*2), ---> CANTIDAD PROPORCIONAL DEL MONTO DE LA NOTA DE CRÉDITO (% PORCENTAJE DEL MONTO DE ACEPTACIÓN)*MONTO DE LA NOTA DE CREDITO
		P.FechaRecepcionServicio,
		ap.Creado,
		CONCAT(POD.MaterialCotizadoTextoC, ' - ', i.NombreInstalacion COLLATE Modern_Spanish_CI_AS),
		DATEADD(MONTH, DATEDIFF(MONTH, 0,P.FechaRecepcionServicio), 0), ---> DUDA QUE MES SE PONE 
		@IdUsuario,
		GETDATE(),
		APDI.IdInstalacion,
		@IdUsuario,
		NULL,
		spdlp.IdCentroCosto,
		NULL,	
		APDI.IdLineaPresupuesto,
		NULL,
		0,
		apd.PCN,
		apd.ClasificacionCN,
		vp.IdCatalogoHidrocarburos,
		apd.IdAceptacionPedidoDetalle
	FROM dbo.MM_AceptacionPedido ap
	INNER JOIN dbo.MM_AceptacionPedidoDetalle apd ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
	INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
	INNER JOIN dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido
	INNER JOIN dbo.MM_PeticionOfertaDetalle pod ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle
	INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
	LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI ON APDI.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
	LEFT JOIN Adinco.dbo.CO_Instalacion i ON i.IdInstalacion = APDI.IdInstalacion
	LEFT JOIN MM_PCN_ValoresPesos vp ON vp.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
	WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
	 
END    

