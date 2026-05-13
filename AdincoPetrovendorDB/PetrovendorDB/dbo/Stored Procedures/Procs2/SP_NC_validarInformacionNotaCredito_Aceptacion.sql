CREATE PROCEDURE [dbo].[SP_NC_validarInformacionNotaCredito_Aceptacion]
    @IdUsuario INT,
    @IdProveedor INT,
    @RFCReceptor NVARCHAR(MAX),
    @RFCEmisor NVARCHAR(MAX),
    @CfdiRelacionados NVARCHAR(MAX),
    @NC_UUID NVARCHAR(MAX),
    @IdAceptacionPedido INT
AS
BEGIN
	/*SP PARA VALIDAR SI LOS CFDI´S RELACIONADOS ESTAS RELACIONADOS A UNA FACTURA DE LA ACEPTACIÓN PEDIDO ACTUAL */
    DECLARE @ID_FACTURA_AP INT;
	DECLARE @ID_NOTA_CREDITO INT 
    DECLARE @IdProveedorCliente INT;
    DECLARE @RFCProveedorCliente NVARCHAR(MAX);
    DECLARE @RFCProveedorVendedor NVARCHAR(MAX);
    DECLARE @UUID_FACTURAACEPTACION NVARCHAR(MAX);
    DECLARE @ID_CFDINOTACREDITO INT           
    DECLARE @ID_PEDIDOGENERAL INT
    DECLARE @ID_ESTATUS INT
    DECLARE @UUID_FACTURA_AP NVARCHAR(MAX);
    DECLARE @NUMERO_ACEPTACION_NC INT;
	DECLARE @UUID_RELACIONADO_VALIDO NVARCHAR(MAX)

    DECLARE @CFDIsRelacionados AS TABLE
    (
        id INT IDENTITY(1, 1),
        cfdiRelacionado VARCHAR(MAX) NULL        
    );

    /*OBTENER LOS CFDI´s RELACIONADOS*/
    IF LEN(@CfdiRelacionados) > 0
    BEGIN
        INSERT INTO @CFDIsRelacionados
        (
            cfdiRelacionado
        )
        SELECT Value
        FROM dbo.Split(LEFT(@CfdiRelacionados, (LEN(@CfdiRelacionados))), ',');
    END;
    ELSE
    BEGIN
        SELECT 'ERROR',
               'Error al realizar lectura los CFDIs relacionados en el XML, No se encontró ningún CFDI relacionado';
			   RETURN

    END;
	 

	/*OBTENER EL UUID DE LA FACTURA DE LA ACEPTACIÓN ACTUAL*/
    SELECT 
	@UUID_FACTURA_AP = FI.UUID, --> UUID DE LA FACTURA RELACIONADA A LA ACEPTACIÓN PEDIDO
	@IdProveedorCliente=PC.IdProveedor,		--> ID EL PROVEEDOR CLIENTE/OPERADORA
	@RFCProveedorCliente=PC.RFC, --> RFC DEL PROVEEDOR CLIENTE/OPERADORA
	@RFCProveedorVendedor=PV.RFC, --> RFC DEL PROVEEDOR VENTAS/PETROVENDOR
	@ID_FACTURA_AP=FI.IdFactura --> ID DE LA FACTURA RELACIONADA A LA ACEPTACIÓN DE PEDIDO 
    FROM dbo.MM_AceptacionFactura AF
        JOIN dbo.MM_AceptacionPedido AP
            ON AF.IdAceptacionPedido=AP.IdAceptacionPedido 
        JOIN dbo.FI_Factura FI
            ON AF.IdFactura=FI.IdFactura
		JOIN dbo.MM_Pedido P
			ON AP.IdPedido=P.IdPedido
		JOIN S_Proveedor PV
			ON P.IdSubcontratista=PV.IdProveedor
		JOIN dbo.S_Proveedor PC
			ON P.IdProveedorCompras=PC.IdProveedor
    WHERE AF.IdAceptacionPedido = @IdAceptacionPedido;

	--VALIDAR SI EN LOS CFDIS RELACIONADOS ESTA EL CFDI DE LA FACTURA DE LA ACEPTACIÓN ACTUAL, SI SI OBTENER EL UUID RELACIOANDO

	SELECT @UUID_RELACIONADO_VALIDO=cfdiRelacionado
	FROM @CFDIsRelacionados 
	WHERE cfdiRelacionado=@UUID_FACTURA_AP

	SET @UUID_RELACIONADO_VALIDO= ISNULL(@UUID_RELACIONADO_VALIDO,'')

	--VALIDAR SI EL EL VALOR DE @UUID_RELACIONADO_VALIDO ES VACIO ENTONCES EL UUID DE LA ACEPTACIÓN NO ESTA EN LOS CFDIS RELACIONADOS DE LA NOTA DE CREDITO ACTUAL 	
    IF ISNULL(@UUID_RELACIONADO_VALIDO,'')=''
    BEGIN
        SELECT 'ERROR_VALIDACION' AS RESPONSE,
               CONCAT(
                         'El UUID: ',@UUID_FACTURA_AP,
						 ' de la factura de la aceptación ',
						 @IdAceptacionPedido
						 ,' no se encuentra en los CFDI´S relacionados en estas nota de crédito, CFDIS relacionados:',
                         @CfdiRelacionados                        
                     ) AS Mensaje;
        RETURN;
    END;
	
    --> VALIDAR CLIENTE = RECEPTOR(OPERADORA)
    IF ISNULL(@RFCProveedorCliente, '') <> @RFCReceptor
    BEGIN
        SELECT 'ERROR_VALIDACION' AS RESPONSE,
               CONCAT(
                         'El RFC de Receptor no corresponde al cliente de la Aceptación No.',
                         CAST(@IdAceptacionPedido AS NVARCHAR(MAX))
                     ) AS Mensaje;
        RETURN;
    END;

    --> VALIDAR VENDEDOR = EMISOR(PROVEEDOR)
    IF ISNULL(@RFCProveedorVendedor, '') <> @RFCEmisor
    BEGIN
        SELECT 'ERROR_VALIDACION' AS RESPONSE,
               CONCAT(
                         'El RFC del emisor de la factura, no corresponde al RFC de tu empresa. Aceptación No.',
                         CAST(@IdAceptacionPedido AS NVARCHAR(MAX))
                     ) AS Mensaje;
        RETURN;
    END;

	/*CONSULTAR SI EL CDFI RELACIONADO NO ESTE EN CARGADO YA EN PETROVENDOR*/
	SELECT @ID_CFDINOTACREDITO = NC.IdAceptacionNotaCredito,
		@NUMERO_ACEPTACION_NC=NC.IdAceptacionPedido
        FROM dbo.FI_Factura F
            JOIN dbo.MM_AceptacionNotaCredito NC
                ON F.IdFactura=NC.IdFacturaNotaCredito 
            JOIN dbo.TA_Operacion O
                ON NC.IdAceptacionNotaCredito=O.IdDocumento 
        WHERE F.UUID = @NC_UUID
              AND NC.CFDIRelacionados = @UUID_RELACIONADO_VALIDO
              AND NC.Activo = 1
              AND O.IdTipoOperacion = 17 --> NOTA DE CREDITP
              AND O.IdEstatusOperacion IN ( 1, 2 ); --> SOLO SI ESTA EN APROBACIÓN O ESTA APROBADA


    -- VALIDAR LA NOTA DE CREDITO NO ESTE EN PETROVENDOR O ADINCO
    IF ISNULL(@ID_CFDINOTACREDITO, 0) > 0
    BEGIN
        SELECT 'ERROR_VALIDACION' AS RESPONSE,
               CONCAT(
                         'Esta nota de crédito ya se encuentrá, cargada en la Aceptación No.',
                         CAST(ISNULL(@NUMERO_ACEPTACION_NC, 0) AS NVARCHAR(MAX))
                     ) AS Mensaje;
        RETURN;
    END;

	
    --VALIDAR SI SE SE PUEDE CARGAR LA NOTA DE CREDITO PARA ESO LA FACTURA DEBE ESTAR APROBADA,
    -- CONSULTAR DETALLE DE LA FACTURA RELACIONADA
    SELECT @ID_ESTATUS = ISNULL(TAO.IdEstatusOperacion, 1),
           @ID_PEDIDOGENERAL = PG.IdPedido
    FROM dbo.MM_AceptacionPedido AS AP
        JOIN MM_Pedido AS P
            ON AP.IdPedido=P.IdPedido 
        JOIN S_Proveedor AS PR
            ON P.IdProveedorCompras=PR.IdProveedor
        JOIN MM_AceptacionFactura AS AF
            ON AP.IdAceptacionPedido=AF.IdAceptacionPedido
        JOIN TA_Operacion AS TAO
            ON AF.IdAceptacionFactura=TAO.IdDocumento
               AND TAO.IdTipoOperacion = 10 --> APROBACIÓN DE FACTURA
        JOIN MM_Pedidos AS PG
            ON P.IdPedido = PG.IdIdentificador
               AND PG.IdProveedorCliente = P.IdProveedorCompras
			   AND PG.IdTipoPedido NOT IN (7,1) --> NO SEA COMPRA DIRECTA NI COMPROBANTE EXTRANJERO       
    WHERE P.IdSubcontratista = @IdProveedor --> PROVEEDOR VENDEDOR/PETROVENDOR
          AND AP.IdAceptacionPedido = @IdAceptacionPedido
    GROUP BY AP.IdAceptacionPedido,
             AP.IdPedido,
             TAO.IdEstatusOperacion,
             PG.IdPedido;
	--VALIDAR SI EL ESTATUS ACTUAL DE LA FACTURA ES APROBADO
    IF ISNULL(@ID_ESTATUS, 0) <> 2 --> ESTATUS APROBADO
    BEGIN
        SELECT 'ERROR_VALIDACION' AS RESPONSE,
               CONCAT(
                         'Para poder cargar Notas de credito la factura de la Aceptación No.',
                         CAST(ISNULL(@IdAceptacionPedido, 0) AS NVARCHAR(MAX)),
                         ' debe estar en Estatus de Aprobada'
                     ) AS MENSAJE;
		RETURN
    END;

	--OBTENER EL ID DE LA NOTA DE CREDITA SI YA ESTA CARGADA 
	--SI HAY UN VALOR YA ESTA CARGADA Y NO ES NECESARIO VOLVERLA A CARGAR 
	SELECT @ID_NOTA_CREDITO=IdFactura
	FROM dbo.FI_Factura 
	WHERE UUID=@NC_UUID

    SELECT 'SUCCESS',
           @IdAceptacionPedido AS NoAceptacion,
           ISNULL(@ID_PEDIDOGENERAL, 0) AS Pedido,
           ISNULL(@ID_ESTATUS, 0) AS Estatus,
		   ISNULL(@UUID_RELACIONADO_VALIDO,'') AS UUID_VALIDO, --> ES EL UUID RELACIONADO PARA ESTA ACEPTACIÓN = UUID DE LA FACTURA DE ESTA ACEPTACIÓN
		   ISNULL(@ID_NOTA_CREDITO,0) AS IdFacturaNotaCredito

END;
