IF OBJECT_ID('[dbo].[USP_SEL_REL_Fact_EPT]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].USP_SEL_REL_Fact_EPT
GO
CREATE PROCEDURE [dbo].[USP_SEL_REL_Fact_EPT]
(
    @IdUsuario INT,
    @IdContrato INT,
    @Data Type_REL_Fact_EPT READONLY
)
AS
BEGIN
   SET NOCOUNT ON;

	CREATE TABLE #Data (
		FilaExcel INT,
		Anio VARCHAR(100),
        Contratista VARCHAR(100),
        Contrato VARCHAR(200),
        IdEstudioPrecioTransfer INT,
        IdentificadorDelDocumento VARCHAR(100),
        Mes VARCHAR(50),
        NombreDelDocumento VARCHAR(500),
        Observaciones VARCHAR(MAX)
	);
	DECLARE 
	@TipoPedimentoImportacion INT = 2,
	@TipoComprobante INT = 3,
	@IdEstudioPrecioTransfer INT = 0,
	@IdSubcontratista INT = 0;

	INSERT INTO #Data (Anio, Contratista, Contrato, IdEstudioPrecioTransfer, IdentificadorDelDocumento, Mes, NombreDelDocumento, Observaciones, FilaExcel)
	SELECT 
		ISNULL(LTRIM(RTRIM(Anio)), ''), 
		ISNULL(LTRIM(RTRIM(Contratista)), ''), 
		ISNULL(Contrato, ''), 
		IdEstudioPrecioTransfer, 
		ISNULL(IdentificadorDelDocumento, ''), 
		ISNULL(LTRIM(RTRIM(Mes)), ''), 
		ISNULL(LTRIM(RTRIM(NombreDelDocumento)), ''), 
		ISNULL(Observaciones, ''),
		FilaExcel
	FROM @Data

	SELECT TOP 1 @IdEstudioPrecioTransfer = IdEstudioPrecioTransfer FROM #Data 
	SELECT TOP 1 @IdSubcontratista = IdSubcontratista FROM FI_EstudioPreciosTransfer WHERE IdEstudioPrecioTransfer = @IdEstudioPrecioTransfer

   -- Validación: Facturas que ya tienen un EPT asignado
   UPDATE datos
   SET datos.Observaciones = CONCAT(ISNULL(datos.Observaciones, ''), 
	' Para esta factura, el estudio de precio de transferencia (EPT) ya fue asignado anteriormente. ',
	'[', CAST(FI_EstudioPreciosTransfer.IdEstudioPrecioTransfer AS NVARCHAR), '] ', ' [', FI_EstudioPreciosTransfer.Nombre, ']')	
   FROM #Data datos
   INNER JOIN FI_Factura
		ON FI_Factura.IdContrato = @IdContrato
		AND LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento))) = LTRIM(RTRIM(UPPER(FI_Factura.UUID)))
   INNER JOIN FI_EstudioPreciosTransfer
		ON 	FI_Factura.IdEstudioPrecioTransfer = FI_EstudioPreciosTransfer.IdEstudioPrecioTransfer 
   WHERE ISNULL(FI_Factura.IdEstudioPrecioTransfer, 0) <> 0

   -- Validación: Identificadores no encontrados en FI_Factura
   UPDATE datos
   SET datos.Observaciones = ISNULL(datos.Observaciones, '') + ' No se encontró el UUID [' + datos.IdentificadorDelDocumento + ']. '
   FROM #Data datos
   LEFT JOIN FI_Factura
		ON FI_Factura.IdContrato = @IdContrato
		AND LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento))) = LTRIM(RTRIM(UPPER(FI_Factura.UUID)))
   WHERE FI_Factura.IdFactura IS NULL
   AND TRY_CONVERT(UNIQUEIDENTIFIER, datos.IdentificadorDelDocumento) IS NOT NULL -- Que sea un UUID valido

   
   -- Validación: UUID no correponde a empresa relacionada
   UPDATE datos
   SET datos.Observaciones = ISNULL(datos.Observaciones, '') + ' El CFDI no corresponde a la empresa relacionada al estudio de Precios de Transferencia seleccionado. '
   FROM #Data datos
   JOIN FI_Factura
		ON FI_Factura.IdContrato = @IdContrato
		AND LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento))) = LTRIM(RTRIM(UPPER(FI_Factura.UUID)))
		AND FI_Factura.IdSubcontratista <> @IdSubcontratista

   -- Se establece cuáles registros deben actualizarse
   UPDATE datos 
   SET datos.Observaciones = 'Se relacionó'
   FROM #Data datos
   INNER JOIN FI_Factura
	   ON FI_Factura.IdContrato = @IdContrato
	   AND LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento))) = LTRIM(RTRIM(UPPER(FI_Factura.UUID)))
   WHERE 
    ISNULL(FI_Factura.IdEstudioPrecioTransfer, 0) = 0
	AND ISNULL(datos.Observaciones, '') = ''
    AND (
		(FI_Factura.TipoComprobanteEstandarizado = 'I' AND FI_Factura.MetodoPagoEstandarizado = 'PUE')
		OR (FI_Factura.TipoComprobanteEstandarizado = 'P' AND FI_Factura.MetodoPagoEstandarizado = 'PPD')
		)
    

   -- Solo se actualizan las facturas que no tienen un estudio relacionado
   UPDATE FI_Factura
   SET IdEstudioPrecioTransfer = datos.IdEstudioPrecioTransfer
   FROM FI_Factura  
   INNER JOIN #Data datos 
	   ON FI_Factura.IdContrato = @IdContrato
	   AND LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento))) = LTRIM(RTRIM(UPPER(FI_Factura.UUID)))
   WHERE ISNULL(FI_Factura.IdEstudioPrecioTransfer, 0) = 0
	   AND datos.Observaciones = 'Se relacionó'
	   AND (
			(FI_Factura.TipoComprobanteEstandarizado = 'I' AND FI_Factura.MetodoPagoEstandarizado = 'PUE')
			OR (FI_Factura.TipoComprobanteEstandarizado = 'P' AND FI_Factura.MetodoPagoEstandarizado = 'PPD')
			)

	-- Validación: Campos ya registrados
	 UPDATE datos
	 SET datos.Observaciones = CONCAT(ISNULL(datos.Observaciones, ''), 
	' Para este CP, el estudio de precio de transferencia (EPT) ya fue asignado anteriormente. ',
	'[', CAST(FI_EstudioPreciosTransfer.IdEstudioPrecioTransfer AS NVARCHAR), '] ', ' [', FI_EstudioPreciosTransfer.Nombre, ']')	 
	 FROM #Data datos
	INNER JOIN FI_CPDocRelacionado
	   ON LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento))) = LTRIM(RTRIM(UPPER(FI_CPDocRelacionado.IdDocumento)))
	INNER JOIN FI_ComplementoDePago
	   ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
	INNER JOIN FI_Factura
	   ON FI_Factura.IdContrato = @IdContrato
	   AND FI_Factura.IdFactura = FI_ComplementoDePago.IdFactura
	INNER JOIN FI_EstudioPreciosTransfer
		ON 	FI_Factura.IdEstudioPrecioTransfer = FI_EstudioPreciosTransfer.IdEstudioPrecioTransfer 
	WHERE 
	   ISNULL(datos.Observaciones, '') = ''
	   AND ISNULL(FI_Factura.IdEstudioPrecioTransfer, 0) <> 0
	   AND FI_Factura.IdContrato = @IdContrato
	   AND FI_Factura.TipoComprobanteEstandarizado = 'P' 
	   AND FI_Factura.MetodoPagoEstandarizado = 'PPD'

	-- Se establece cuáles son los registros que se van a actualizar por el complemento CP
	UPDATE datos
	SET Observaciones = 'Se relacionó por CP'
	FROM #Data datos
	INNER JOIN FI_CPDocRelacionado
	   ON LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento))) = LTRIM(RTRIM(UPPER(FI_CPDocRelacionado.IdDocumento)))
	INNER JOIN FI_ComplementoDePago
	   ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
	INNER JOIN FI_Factura
	   ON FI_Factura.IdContrato = @IdContrato
	   AND FI_Factura.IdFactura = FI_ComplementoDePago.IdFactura
	WHERE 
	   ISNULL(datos.Observaciones, '') = ''
	   AND ISNULL(FI_Factura.IdEstudioPrecioTransfer, 0) = 0
	   AND FI_Factura.IdContrato = @IdContrato
	   AND FI_Factura.TipoComprobanteEstandarizado = 'P' 
	   AND FI_Factura.MetodoPagoEstandarizado = 'PPD'


	-- Si no ha sido procesado, se busca el UUID del complemento
	UPDATE FI_Factura
	SET FI_Factura.IdEstudioPrecioTransfer = datos.IdEstudioPrecioTransfer
	FROM FI_Factura
	INNER JOIN FI_ComplementoDePago
		ON FI_Factura.IdContrato = @IdContrato
		AND FI_Factura.IdFactura = FI_ComplementoDePago.IdFactura
	INNER JOIN FI_CPDocRelacionado
		ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
	INNER JOIN #Data datos 
	   ON LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento))) = LTRIM(RTRIM(UPPER(FI_CPDocRelacionado.IdDocumento)))
	WHERE
		ISNULL(datos.Observaciones, '') = 'Se relacionó por CP' 
		AND ISNULL(FI_Factura.IdEstudioPrecioTransfer, 0) = 0
		AND FI_Factura.IdContrato = @IdContrato
		AND FI_Factura.TipoComprobanteEstandarizado = 'P' 
	    AND FI_Factura.MetodoPagoEstandarizado = 'PPD'


	-- Ahora buscar los PE y PI --

	-- Validación: Comprobantes y Pedimentos que ya tienen un EPT asignado
	UPDATE datos
	SET datos.Observaciones = CONCAT(
		ISNULL(datos.Observaciones, ''), 
		CASE 
			WHEN FI_PedimentoComprobante.CvTipoDocFacturacion = @TipoComprobante 
			THEN ' Para este PE, el estudio de precio de transferencia (EPT) ya fue asignado anteriormente. '
			WHEN FI_PedimentoComprobante.CvTipoDocFacturacion = @TipoPedimentoImportacion
			THEN ' Para este PI, el estudio de precio de transferencia (EPT) ya fue asignado anteriormente. '
			ELSE ' El estudio de precio de transferencia (EPT) ya fue asignado anteriormente. '
		END,
		' [', CAST(FI_EstudioPreciosTransfer.IdEstudioPrecioTransfer AS NVARCHAR), '] ',
		' [', ISNULL(FI_EstudioPreciosTransfer.Nombre, ''), ']'
	) 
	FROM #Data datos 
	LEFT JOIN FI_PedimentoComprobante
		ON (
			LTRIM(RTRIM(UPPER(FI_PedimentoComprobante.NumeroPedimento))) = LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento)))
			OR 
			LTRIM(RTRIM(UPPER(FI_PedimentoComprobante.IdDocFacturacionSIPAC))) = LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento)))
		)
		AND FI_PedimentoComprobante.IdContrato = @IdContrato
	INNER JOIN FI_EstudioPreciosTransfer
		ON FI_PedimentoComprobante.IdEstudioPrecioTransfer = FI_EstudioPreciosTransfer.IdEstudioPrecioTransfer
	WHERE ISNULL(datos.Observaciones, '') = '' 
		AND ISNULL(FI_PedimentoComprobante.IdEstudioPrecioTransfer, 0) <> 0

	   -- Validación: PE o PI no correponde a empresa relacionada
	   UPDATE datos
		SET datos.Observaciones = CONCAT(
			ISNULL(datos.Observaciones, ''), 
			CASE 
				WHEN FI_PedimentoComprobante.CvTipoDocFacturacion = @TipoComprobante 
				THEN ' El PE no corresponde a la empresa relacionada al estudio de Precios de Transferencia seleccionado. '
				WHEN FI_PedimentoComprobante.CvTipoDocFacturacion = @TipoPedimentoImportacion
				THEN ' El PI no corresponde a la empresa relacionada al estudio de Precios de Transferencia seleccionado. '
				ELSE ''
			END
			) 
				FROM #Data datos 
		 JOIN FI_PedimentoComprobante
			ON (
				LTRIM(RTRIM(UPPER(FI_PedimentoComprobante.NumeroPedimento))) = LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento)))
				OR 
				LTRIM(RTRIM(UPPER(FI_PedimentoComprobante.IdDocFacturacionSIPAC))) = LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento)))
			)
			AND FI_PedimentoComprobante.IdContrato = @IdContrato
				AND (FI_PedimentoComprobante.IdSubcontratistaExportador <> @IdSubcontratista OR FI_PedimentoComprobante.IdSubcontratistaImportador <> @IdSubcontratista)
   
	-- Validación: Identificadores no encontrados en FI_PedimentoComprobante
	UPDATE datos
	SET datos.Observaciones = CONCAT(
		ISNULL(datos.Observaciones, ''), 
		' No se encontró [', datos.IdentificadorDelDocumento, ']')
	FROM #Data datos 
	LEFT JOIN FI_PedimentoComprobante
		ON (
			LTRIM(RTRIM(UPPER(FI_PedimentoComprobante.NumeroPedimento))) = LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento)))
			OR 
			LTRIM(RTRIM(UPPER(FI_PedimentoComprobante.IdDocFacturacionSIPAC))) = LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento)))
		)
		AND FI_PedimentoComprobante.IdContrato = @IdContrato
	LEFT JOIN CO_Registro
		ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
		AND YEAR(CO_Registro.MesPresentacion) = datos.Anio
		AND MONTH(CO_Registro.MesPresentacion) = datos.Mes
	WHERE ISNULL(datos.Observaciones, '') = '' 
	AND FI_PedimentoComprobante.IdPedimentoComprobante IS NULL
	AND TRY_CONVERT(UNIQUEIDENTIFIER, datos.IdentificadorDelDocumento) IS NULL

	-- Se establece cuáles son los registros que se van a actualizar PE y PI
	UPDATE datos
	SET Observaciones = 
	CASE 
		WHEN FI_PedimentoComprobante.CvTipoDocFacturacion = @TipoComprobante 
		THEN 'Se relacionó PE'
		WHEN FI_PedimentoComprobante.CvTipoDocFacturacion = @TipoPedimentoImportacion 
		THEN 'Se relacionó PI'
	END
	FROM #Data datos  
	LEFT JOIN FI_PedimentoComprobante
    ON FI_PedimentoComprobante.IdContrato = @IdContrato 
	AND (
        LTRIM(RTRIM(UPPER(FI_PedimentoComprobante.NumeroPedimento))) = LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento)))
        OR 
        LTRIM(RTRIM(UPPER(FI_PedimentoComprobante.IdDocFacturacionSIPAC))) = LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento)))
    )
	LEFT JOIN CO_Registro
		ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
		AND YEAR(CO_Registro.MesPresentacion) = datos.Anio
		AND MONTH(CO_Registro.MesPresentacion) = datos.Mes
	WHERE ISNULL(datos.Observaciones, '') = ''  

	-- Se relacionan PE
	UPDATE FI_PedimentoComprobante
	SET FI_PedimentoComprobante.IdEstudioPrecioTransfer = datos.IdEstudioPrecioTransfer
	FROM FI_PedimentoComprobante  
	LEFT JOIN #Data datos 
		ON FI_PedimentoComprobante.IdContrato = @IdContrato
	AND (
        LTRIM(RTRIM(UPPER(FI_PedimentoComprobante.NumeroPedimento))) = LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento)))
        OR 
        LTRIM(RTRIM(UPPER(FI_PedimentoComprobante.IdDocFacturacionSIPAC))) = LTRIM(RTRIM(UPPER(datos.IdentificadorDelDocumento)))
    )
	INNER JOIN CO_Registro
		ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
		AND YEAR(CO_Registro.MesPresentacion) = datos.Anio
		AND MONTH(CO_Registro.MesPresentacion) = datos.Mes
	WHERE ISNULL(datos.Observaciones, '') = 'Se relacionó PE' 
			OR ISNULL(datos.Observaciones, '') = 'Se relacionó PI'

	-- Última validación: Identificadores no encontrados
	UPDATE datos
	SET datos.Observaciones = CONCAT(ISNULL(datos.Observaciones, ''), ' No se encontró el identificador [', datos.IdentificadorDelDocumento, ']') 
	FROM #Data datos 
	WHERE ISNULL(datos.Observaciones, '') = ''

	SELECT * FROM #Data

END