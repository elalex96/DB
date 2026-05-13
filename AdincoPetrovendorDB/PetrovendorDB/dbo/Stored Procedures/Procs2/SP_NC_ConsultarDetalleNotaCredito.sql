-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 11/09/2019
-- Description: Consultar detalle de nota de credito del lado de la operadora 
-- =============================================
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 14/10/2019
-- Description: se agregaron columnas de error SAT
-- =============================================
CREATE PROCEDURE [dbo].[SP_NC_ConsultarDetalleNotaCredito]
    -- Add the parameters for the stored procedure here	
    @IdProveedor INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT,
    @IdNoNotaCredito INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	DECLARE @TipoMonedaAceptacion INT

	SELECT @TipoMonedaAceptacion = pd.IdMoneda
	FROM dbo.MM_AceptacionPedidoDetalle ap
        INNER JOIN dbo.MM_PedidoDetalle pd
            ON pd.IdPedidoDetalle = ap.IdPedidoDetalle
    WHERE IdAceptacionPedido = @IdAceptacionPedido
	GROUP BY pd.IdMoneda
	
	DECLARE @MONTO_FACTURA_ACEPTACION_SUBTOTAL MONEY 
	DECLARE @MONTO_FACTURA_ACEPTACION_TOTAL MONEY	
	DECLARE @MONTO_NOTASCREDITO_ACEPTACION_SUBTOTAL MONEY 
	DECLARE @MONTO_NOTASCREDITO_ACEPTACION_TOTAL MONEY

	DECLARE @MONTO_NOTASCREDITO_ACEPTACION_SUBTOTAL_sinactual MONEY 
	DECLARE @MONTO_NOTASCREDITO_ACEPTACION_TOTAL_sinactual MONEY

	DECLARE @MONTO_NOTASCREDITO_SUBTOTALactual MONEY 
	DECLARE @MONTO_NOTASCREDITO_TOTALactual MONEY


	SELECT 
	@MONTO_NOTASCREDITO_SUBTOTALactual =
	CASE WHEN F.IdMoneda = @TipoMonedaAceptacion THEN 	--> SI FACTURA ES IGUAL AL TIPO DE MONEDA DE LA ACEPTACION 
		F.SubTotal	
	WHEN @TipoMonedaAceptacion=1 THEN 	 --Si el tipo de moneda de la aceptacion es Pesos  y el factura en DLS 
		F.SubTotal * CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	WHEN @TipoMonedaAceptacion=2 THEN   --Si el tipo de moneda de la aceptacion son dolares y la factura en PESOS
		F.SubTotal / CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	END,
	@MONTO_NOTASCREDITO_TOTALactual =
	CASE WHEN F.IdMoneda = @TipoMonedaAceptacion THEN 	--> SI FACTURA ES IGUAL AL TIPO DE MONEDA DE LA ACEPTACION 
		F.MontoConIva	
	WHEN @TipoMonedaAceptacion=1 THEN 	 --Si el tipo de moneda de la aceptacion es Pesos  y el factura en DLS 
		F.MontoConIva * CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	WHEN @TipoMonedaAceptacion=2 THEN   --Si el tipo de moneda de la aceptacion son dolares y la factura en PESOS
		F.MontoConIva / CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	END		
	FROM dbo.FI_Factura F
	INNER JOIN dbo.MM_AceptacionNotaCredito NC 
	ON NC.IdFacturaNotaCredito = F.IdFactura
	WHERE NC.IdAceptacionNotaCredito=@IdNoNotaCredito
	
	SELECT 
	@MONTO_FACTURA_ACEPTACION_SUBTOTAL =
	CASE WHEN F.IdMoneda = @TipoMonedaAceptacion THEN 	--> SI FACTURA ES IGUAL AL TIPO DE MONEDA DE LA ACEPTACION 
		F.SubTotal	
	WHEN @TipoMonedaAceptacion=1 THEN 	 --Si el tipo de moneda de la aceptacion es Pesos  y el factura en DLS 
		F.SubTotal * CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	WHEN @TipoMonedaAceptacion=2 THEN   --Si el tipo de moneda de la aceptacion son dolares y la factura en PESOS
		F.SubTotal / CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	END,
	@MONTO_FACTURA_ACEPTACION_TOTAL =
	CASE WHEN F.IdMoneda = @TipoMonedaAceptacion THEN 	--> SI FACTURA ES IGUAL AL TIPO DE MONEDA DE LA ACEPTACION 
		F.MontoConIva	
	WHEN @TipoMonedaAceptacion=1 THEN 	 --Si el tipo de moneda de la aceptacion es Pesos  y el factura en DLS 
		F.MontoConIva * CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	WHEN @TipoMonedaAceptacion=2 THEN   --Si el tipo de moneda de la aceptacion son dolares y la factura en PESOS
		F.MontoConIva / CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	END		
	FROM dbo.FI_Factura F
	INNER JOIN dbo.MM_AceptacionFactura AF 
	ON AF.IdFactura = F.IdFactura
	WHERE AF.IdAceptacionPedido=@IdAceptacionPedido

	
	SELECT 
	@MONTO_NOTASCREDITO_ACEPTACION_SUBTOTAL =SUM(
	CASE WHEN F.IdMoneda = @TipoMonedaAceptacion THEN 	--> SI FACTURA ES IGUAL AL TIPO DE MONEDA DE LA ACEPTACION 
		F.SubTotal	
	WHEN @TipoMonedaAceptacion=1 THEN 	 --Si el tipo de moneda de la aceptacion es Pesos  y el factura en DLS 
		F.SubTotal * CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	WHEN @TipoMonedaAceptacion=2 THEN   --Si el tipo de moneda de la aceptacion son dolares y la factura en PESOS
		F.SubTotal / CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	END),
	@MONTO_NOTASCREDITO_ACEPTACION_TOTAL =SUM(
	CASE WHEN F.IdMoneda = @TipoMonedaAceptacion THEN 	--> SI FACTURA ES IGUAL AL TIPO DE MONEDA DE LA ACEPTACION 
		F.MontoConIva	
	WHEN @TipoMonedaAceptacion=1 THEN 	 --Si el tipo de moneda de la aceptacion es Pesos  y el factura en DLS 
		F.MontoConIva * CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	WHEN @TipoMonedaAceptacion=2 THEN   --Si el tipo de moneda de la aceptacion son dolares y la factura en PESOS
		F.MontoConIva / CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	END)
	FROM dbo.MM_AceptacionNotaCredito NC 
	INNER JOIN dbo.TA_Operacion O ON O.IdDocumento=NC.IdAceptacionNotaCredito
	INNER JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido=NC.IdAceptacionPedido
	LEFT JOIN dbo.FI_Factura F ON F.IdFactura=NC.IdFacturaNotaCredito
	WHERE AP.IdAceptacionPedido=@IdAceptacionPedido
    AND O.IdTipoOperacion=17
	AND ISNULL(NC.IdEstatusEliminada,0)=0
	AND O.IdEstatusOperacion=2 --> APROBADAS


	SELECT @MONTO_NOTASCREDITO_ACEPTACION_SUBTOTAL_sinactual =SUM(
	CASE WHEN F.IdMoneda = @TipoMonedaAceptacion THEN 	--> SI FACTURA ES IGUAL AL TIPO DE MONEDA DE LA ACEPTACION 
		F.SubTotal	
	WHEN @TipoMonedaAceptacion=1 THEN 	 --Si el tipo de moneda de la aceptacion es Pesos  y el factura en DLS 
		F.SubTotal * CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	WHEN @TipoMonedaAceptacion=2 THEN   --Si el tipo de moneda de la aceptacion son dolares y la factura en PESOS
		F.SubTotal / CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	END),
	@MONTO_NOTASCREDITO_ACEPTACION_TOTAL_sinactual =SUM(
	CASE WHEN F.IdMoneda = @TipoMonedaAceptacion THEN 	--> SI FACTURA ES IGUAL AL TIPO DE MONEDA DE LA ACEPTACION 
		F.MontoConIva	
	WHEN @TipoMonedaAceptacion=1 THEN 	 --Si el tipo de moneda de la aceptacion es Pesos  y el factura en DLS 
		F.MontoConIva * CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	WHEN @TipoMonedaAceptacion=2 THEN   --Si el tipo de moneda de la aceptacion son dolares y la factura en PESOS
		F.MontoConIva / CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
	END)
	FROM dbo.MM_AceptacionNotaCredito NC 
	INNER JOIN dbo.TA_Operacion O ON O.IdDocumento=NC.IdAceptacionNotaCredito
	INNER JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido=NC.IdAceptacionPedido
	LEFT JOIN dbo.FI_Factura F ON F.IdFactura=NC.IdFacturaNotaCredito
	WHERE AP.IdAceptacionPedido=@IdAceptacionPedido
    AND O.IdTipoOperacion=17
	AND ISNULL(NC.IdEstatusEliminada,0)=0
	AND O.IdEstatusOperacion=2 --> APROBADAS
	AND NC.IdAceptacionNotaCredito NOT IN(@IdNoNotaCredito)


    SELECT NC.IdAceptacionNotaCredito,
           F.ComprobantePDFByte,
           F.ComprobanteXMLByte,
           O.Descripcion,
           E.Nombre AS Estatus,
           FORMAT(NC.CreadoEl,'dd/MM/yyyy hh:mm tt') AS CreadoEl,
           UC.Nombre AS CargadoPor,
           F.IdFactura,
           F.SubTotal,
		   TMF.TipoMonedaCorto AS MonedaFacturaNotaCredito,
           F.MontoConIva,          
           O.IdOperacion,
           FORMAT(O.FechaModificacion,'dd/MM/yyyy hh:mm tt') AS FechaCambioEstatus,
           '' AS ComentarioAprobador,
           F.Moneda,
           FT.Nombre AS NombreFlujo,
           FT.Descripcion AS DetalleFlujo,
           TFT.Nombre AS NombreTipoFlujo,
           ISNULL(NC.IdEstatusEliminada, 0) AS IdEstatusEliminada,
           NC.IdEliminado,
		   FORMAT(RE.FechaRegistro,'dd/MM/yyyy hh:mm tt')  AS FechaRegistro,
		   RE.ComentarioExterno,
		   RE.ComentarioInterno,
		   CONCAT('Nota crédito No. ',CAST(NC.IdAceptacionNotaCredito AS NVARCHAR(MAX))) AS NombreArchivo,
		   PV.RazonSocial AS Proveedor,
		   TM.TipoMonedaCorto AS MonedaAceptacion,
		   NC.CFDIRelacionados,	
		   NC.IdAceptacionPedido, 
		   O.IdEstatusOperacion, 
		   F.UUID,
		   ISNULL(@MONTO_FACTURA_ACEPTACION_SUBTOTAL,0) AS MontoFacturaAceptacionSubtotal, 
	       ISNULL(@MONTO_FACTURA_ACEPTACION_TOTAL,0) AS MontoFacturaAceptacionTotal,
		   ISNULL(@MONTO_NOTASCREDITO_ACEPTACION_SUBTOTAL,0) AS MontoNotasCreditoSubtotal, 
	       ISNULL(@MONTO_NOTASCREDITO_ACEPTACION_TOTAL,0) AS MontoNotasCreditoTotal,
		   (ISNULL(@MONTO_NOTASCREDITO_ACEPTACION_SUBTOTAL_sinactual,0)+ISNULL(@MONTO_NOTASCREDITO_SUBTOTALactual,0)) AS MontoNotasCreditoSubtotalTemporal,
		   (ISNULL(@MONTO_NOTASCREDITO_ACEPTACION_TOTAL_sinactual,0)+ISNULL(@MONTO_NOTASCREDITO_TOTALactual,0)) AS MontoNotasCreditoTotalTemporal,
		   ISNULL(@MONTO_NOTASCREDITO_SUBTOTALactual,0) AS SubTotalConversion, 
		   ISNULL(@MONTO_NOTASCREDITO_TOTALactual,0) AS TotalConversion,
		   F.Emisor,
		   F.Receptor,
		   ISNULL(F.IdLectorXMLSAT,1) AS IdLectorXMLSAT,
		   REPLACE(ISNULL(F.ErroSAT,''),'Error SAT:','') AS ErrorSAT, 
		   ISNULL(ISAT.DireccionWeb,'') AS DireccionWeb
    FROM dbo.MM_AceptacionNotaCredito NC
        LEFT JOIN dbo.MM_AceptacionPedido AP
            ON AP.IdAceptacionPedido = NC.IdAceptacionPedido
        LEFT JOIN dbo.MM_Pedido P
            ON P.IdPedido = AP.IdPedido
		LEFT JOIN dbo.PV_TipoMoneda TM 
			ON TM.IdMoneda = P.IdMoneda
        LEFT JOIN dbo.TA_Operacion O
            ON O.IdDocumento = NC.IdAceptacionNotaCredito
               AND O.IdTipoOperacion = 17 --> APROBACIÓN NOTA DE CREDITO
        LEFT JOIN dbo.TA_Estatus E
            ON E.IdEstatus = O.IdEstatusOperacion
        LEFT JOIN dbo.FI_Factura F
            ON F.IdFactura = NC.IdFacturaNotaCredito
		LEFT JOIN dbo.PV_TipoMoneda TMF ON TMF.IdMoneda = F.IdMoneda
        LEFT JOIN dbo.S_Usuario UC
            ON UC.IdUsuario = NC.CreadoPor
        LEFT JOIN dbo.TA_FlujoTarea FT
            ON FT.IdFlujoTarea = O.IdFlujoTarea
        LEFT JOIN dbo.TA_TipoFlujoTarea TFT
            ON TFT.IdTipoFlujoTarea = FT.IdTipoFlujo
        LEFT JOIN dbo.AD_RegistroEliminacion RE
            ON RE.IdEliminacion = NC.IdEliminado
		LEFT JOIN dbo.S_Proveedor PV ON PV.IdProveedor=P.IdSubcontratista
		LEFT JOIN dbo.InfoSAT ISAT ON ISAT.Id = 1
    WHERE NC.IdAceptacionPedido = @IdAceptacionPedido
          AND P.IdProveedorCompras = @IdProveedor
          AND NC.IdAceptacionNotaCredito = @IdNoNotaCredito


		-- VER SI ES APROBADOR EL USUARIO ACTUAL 
		SELECT T.IdTarea,
		T.IdEstatus,
		E.Nombre AS EstatusAprobador,
		O.IdOperacion,
		T.NoSecuencia
		FROM dbo.TA_Tarea T 
		LEFT JOIN dbo.TA_Operacion O 
		ON O.IdOperacion=T.IdOperacion
		LEFT JOIN dbo.MM_AceptacionNotaCredito NC 
		ON NC.IdAceptacionNotaCredito= O.IdDocumento
		AND O.IdTipoOperacion=17 ---> APROBACIÓN DE NOTA DE CREDITO
		LEFT JOIN dbo.TA_Estatus E ON E.IdEstatus=T.IdEstatus
		WHERE T.IdAprobador=@IdUsuario
		AND NC.IdAceptacionNotaCredito=@IdNoNotaCredito
		AND NC.IdAceptacionPedido=@IdAceptacionPedido
		AND T.Activo=1


END;



