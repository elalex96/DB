


create PROCEDURE [dbo].[p_PMY_NC_validarInformacionNotaCredito_Aceptacion]
	@IdUsuario INT,
	@IdProveedor INT,
	@RFCReceptor NVARCHAR(MAX),
	@RFCEmisor NVARCHAR(MAX),
	@CfdiRelacionados NVARCHAR(MAX),
	@NC_UUID NVARCHAR(MAX),
	@IdAceptacionPedido INT
AS
BEGIN
	 
	 DECLARE @ID_CFDIRELACIONADO INT 
	 DECLARE @IdProveedorCliente INT 
	 DECLARE @RFCProveedorCliente NVARCHAR(MAX) 
	 DECLARE @RFCProveedorVendedor NVARCHAR(MAX)
	 DECLARE @UUID_FACTURAACEPTACION NVARCHAR(MAX) 
	 DECLARE @ID_CFDINOTACREDITO INT , @ID_CFDINOTACREDITO_ADINCO INT
	 DECLARE @ID_PEDIDOGENERAL INT, @ID_ESTATUS INT  
	 DECLARE @CFDI_FACTURA_AP NVARCHAR(MAX)
	 DECLARE @NUMERO_ACEPTACION_NC INT 

	 -->BUSCAR FACTURA RELACIONADA EN PETROVENDOR
	 SELECT @ID_CFDIRELACIONADO=IdFactura FROM dbo.FI_Factura WHERE UUID=@CfdiRelacionados AND Activa=1
	 
	 SELECT 
			@ID_CFDINOTACREDITO= F.IdFactura , 
			@NUMERO_ACEPTACION_NC =NC.IdAceptacionPedido
	 FROM dbo.FI_Factura F
	 INNER JOIN dbo.MPY_MM_AceptacionNotaCredito NC ON NC.IdFacturaNotaCredito=F.IdFactura
	 --INNER JOIN dbo.TA_Operacion O ON O.IdDocumento=NC.IdAceptacionNotaCredito
	 LEFT JOIN dbo.MPY_MM_AceptacionPedido AP ON AP.IdAceptacionPedido=NC.IdAceptacionPedido
	 WHERE UUID=@NC_UUID AND Activa=1
	 
	 AND NC.IdEstatus IN (1,2) --> SOLO SI ESTA EN APROBACIÓN O ESTA APROBADA

	 Select @ID_CFDINOTACREDITO_ADINCO = IdFactura from  Adinco.dbo.FI_Factura   WHERE UUID = @NC_UUID
	 	 	 
	--set @ID_CFDINOTACREDITO_ADINCO = 0;
	-- SI EXISTE ESTA FACTURA EN PETROVENDOR, ENTONCES DEBE TENER UNA ACEPTACIÓN DE PEDIDO 
	-- VALIDAR QUE LA FACTURA RELACIONADA ESTE LIGADA AL PROVEEDOR ACTUAL(EMISOR)
	SELECT 
	@IdProveedorCliente =P2.IdProveedor,
	@ID_CFDIRELACIONADO = AF.IdFactura
	FROM  dbo.MPY_MM_AceptacionFactura AF
	LEFT JOIN dbo.MPY_MM_AceptacionPedido AP ON AP.IdAceptacionPedido=AF.IdAceptacionPedido
	inner join S_Proveedor as P on P.IdProveedor = @IdProveedor
	join Adinco..CO_SAPVendor as V on V.TaxID collate Modern_Spanish_CI_AS = p.RFC collate Modern_Spanish_CI_AS
	join Adinco..CO_Contrato as C on AP.IdContrato = C.IdContrato
	join Adinco..CO_Contratista as CA on CA.IdContratista = C.IdContratista
	join S_Proveedor as P2 on CA.RFC collate Modern_Spanish_CI_AS = P2.RFC collate Modern_Spanish_CI_AS
	AND ISNULL(AF.IdEstatusEliminado,0)=0 --> ACEPTACIÓN DEBE ESTAR ACTIVA 
	AND AF.IdAceptacionPedido=@IdAceptacionPedido

	--@ID_CFDIRELACIONADO= AF.IdFactura
	--AF.IdFactura=@ID_CFDIRELACIONADO --> FACTURA ENCONTRADA EN PETROVENDOR
	--AND
	SELECT @UUID_FACTURAACEPTACION=UUID FROM dbo.FI_Factura WHERE IdFactura=@ID_CFDIRELACIONADO  
	SELECT @RFCProveedorCliente=RFC  FROM dbo.S_Proveedor WHERE IdProveedor=@IdProveedorCliente
	SELECT @RFCProveedorVendedor=RFC  FROM dbo.S_Proveedor WHERE IdProveedor=@IdProveedor

	SELECT 
		@CFDI_FACTURA_AP=FI.UUID 
	FROM dbo.MPY_MM_AceptacionFactura AF
	INNER JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
	INNER JOIN dbo.FI_Factura FI ON FI.IdFactura=AF.IdFactura
	WHERE AF.IdAceptacionPedido=@IdAceptacionPedido

	IF ISNULL(@UUID_FACTURAACEPTACION,0) <> @CfdiRelacionados 
	 BEGIN 
		SELECT 'ERROR_VALIDACION' AS RESPONSE, CONCAT('La factura relacionada en este nota de crédito no coincide con la factura de esta aceptación de pedido, UUID relacionada en la nota de crédito:', @CfdiRelacionados,', UUID de factura de esta aceptación: ', 
@CFDI_FACTURA_AP) AS Mensaje 
		RETURN        
	 END 
	

	--> VALIDAR CLIENTE = RECEPTOR(OPERADORA)
	IF ISNULL(@RFCProveedorCliente,'') <>  @RFCReceptor 
	BEGIN
		SELECT 'ERROR_VALIDACION' AS RESPONSE, CONCAT('El RFC de Receptor no corresponde al cliente de la Aceptación No.', CAST(@IdAceptacionPedido AS NVARCHAR(MAX))) AS Mensaje 
		RETURN
	END 
	--> VALIDAR VENDEDOR = EMISOR(PROVEEDOR)
	IF ISNULL(@RFCProveedorVendedor,'') <>   @RFCEmisor 
	BEGIN
		SELECT 'ERROR_VALIDACION' AS RESPONSE, CONCAT('El RFC del emisor de la factura, no corresponde al RFC de tu empresa. Aceptación No.', CAST(@IdAceptacionPedido AS NVARCHAR(MAX))) AS Mensaje 
		RETURN
	END 

	-- VALIDAR LA NOTA DE CREDITO NO ESTE EN PETROVENDOR O ADINCO
	IF ISNULL(@ID_CFDINOTACREDITO,0) > 0 
	 BEGIN 
		SELECT 'ERROR_VALIDACION' AS RESPONSE, CONCAT('Esta nota de crédito ya se encuentrá, cargada en la Aceptación No.', CAST(ISNULL(@NUMERO_ACEPTACION_NC,0) AS NVARCHAR(MAX))) AS Mensaje 
		RETURN        
	 END 

	 IF ISNULL(@ID_CFDINOTACREDITO_ADINCO,0) > 0 
	 BEGIN 
		SELECT 'ERROR_VALIDACION' AS RESPONSE, CONCAT('Esta nota de crédito ya se encuentrá, cargada en el sistema de Adinco.','') AS MENSAJE
		RETURN        
	 END 

	 --VALIDAR SI SE SE PUEDE CARGAR LA NOTA DE CREDITO PARA ESO LA FACTURA DEBE ESTAR APROBADA,
	 -- CONSULTAR DETALLE DE LA FACTURA RELACIONADA
	    SELECT 
		@ID_ESTATUS= ISNULL(MPY_AF.IdEstatus,0),
		@ID_PEDIDOGENERAL = 0
		FROM MPY_MM_AceptacionFactura AS MPY_AF
		WHERE MPY_AF.IdAceptacionPedido = @IdAceptacionPedido
		

	 IF ISNULL(@ID_ESTATUS,0)<>2
	 BEGIN 
		SELECT 'ERROR_VALIDACION' AS RESPONSE, 
		CONCAT('Para poder cargar Notas de credito la factura de la Aceptación No.',CAST(ISNULL(@IdAceptacionPedido,0) AS NVARCHAR(max)), ' debe estar en Estatus de Aprobada') AS MENSAJE
	 END

	SELECT 'SUCCESS',@IdAceptacionPedido AS NoAceptacion,ISNULL(@ID_PEDIDOGENERAL,0) AS Pedido, ISNULL(@ID_ESTATUS,0) AS Estatus

	
END