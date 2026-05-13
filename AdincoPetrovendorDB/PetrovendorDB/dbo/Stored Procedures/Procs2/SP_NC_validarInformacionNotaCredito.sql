-- =============================================
-- Author:		Daniel AC
-- Update date: 12-10-2020
-- Description: Validar si los CFDI´s relacionados estas relacionados a una factura de una aceptación Factura 
-- =============================================
CREATE PROCEDURE [dbo].[SP_NC_validarInformacionNotaCredito]
    @IdUsuario INT,
    @IdProveedor INT,
    @RFCReceptor NVARCHAR(MAX),
    @RFCEmisor NVARCHAR(MAX),
    @CfdiRelacionados NVARCHAR(MAX),
    @NC_UUID NVARCHAR(MAX)
AS
BEGIN
    /*SP PARA VALIDAR SI LOS CFDI´S RELACIONADOS A LA NOTA DE CREDITO ACTUAL ESTAN RELACIONADOS A UNA FACTURA DE UNA ACEPTACIÓN FACTURA DEL PROVEEDOR ACTUAL*/
    DECLARE @ID_CFDIRELACIONADO INT = 0;
    DECLARE @NO_ACEPTACIONPEDIDO INT = 0;
    DECLARE @IdProveedorCliente INT = 0;
    DECLARE @RFCProveedorCliente NVARCHAR(MAX) = N'';
    DECLARE @RFCProveedorVendedor NVARCHAR(MAX) = N'';
    DECLARE @ID_CFDINOTACREDITO INT = 0;   
    DECLARE @ID_PEDIDOGENERAL INT = 0;
    DECLARE @ID_ESTATUS INT = 0;
    DECLARE @CFDI_ACTUAL VARCHAR(MAX) = '';
	DECLARE @CONTADOR INT = 1;
    DECLARE @TOTAL_REGISTROS INT;
	DECLARE @POSICION_ACTUAL INT

    DECLARE @CFDIsRelacionados AS TABLE
    (
        id INT IDENTITY(1, 1),
        cfdiRelacionado VARCHAR(MAX) NULL,
        Response VARCHAR(MAX) NULL,
        NoAceptacionPedido INT NULL,
        NoPedidoGeneral INT NULL,
        EstatusId INT NULL,
        Detalle NVARCHAR(MAX) NULL
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

        SELECT *
        FROM @CFDIsRelacionados;
        RETURN;
    END;

    /*REALIZAR VALIDACIÓN POR CFDI RELACIONADO*/  
    SELECT @TOTAL_REGISTROS = COUNT(1)
    FROM @CFDIsRelacionados;


    WHILE @TOTAL_REGISTROS >= @CONTADOR
    BEGIN
        --OBTENER INFORMACIÓN DETALLE 
        SET @ID_CFDIRELACIONADO = 0;
        SET @NO_ACEPTACIONPEDIDO = 0;
        SET @IdProveedorCliente = 0;
        SET @RFCProveedorCliente= N'';
        SET @RFCProveedorVendedor= N'';
        SET @ID_CFDINOTACREDITO = 0;       
        SET @ID_PEDIDOGENERAL = 0;
        SET @ID_ESTATUS = 0;
        SET @CFDI_ACTUAL = '';

        SET @POSICION_ACTUAL = @CONTADOR;

        --INCREMENTAR EL CONTADOR
        SET @CONTADOR = @CONTADOR + 1;

        --OBTENER EL UUID DE CFDI RELACIONADO ACTUAL
        SELECT @CFDI_ACTUAL = cfdiRelacionado
        FROM @CFDIsRelacionados
        WHERE id = @POSICION_ACTUAL;
        -->BUSCAR FACTURA RELACIONADA A UNA ACEPTACIÓN DE PEDIDO EN PETROVENDOR
        SELECT @ID_CFDIRELACIONADO = IdFactura
        FROM dbo.FI_Factura
        WHERE UUID = @CFDI_ACTUAL
              AND Activa = 1;

        --BUSCAR EL ID DE LA NOTA DE CREDITO CON RELACIÓN AL CFDI RELACIONADO ACTUAL 
        SELECT @ID_CFDINOTACREDITO = F.IdFactura
        FROM dbo.FI_Factura F
            JOIN dbo.MM_AceptacionNotaCredito NC
                ON NC.IdFacturaNotaCredito = F.IdFactura
            JOIN dbo.TA_Operacion O
                ON O.IdDocumento = NC.IdAceptacionNotaCredito
        WHERE F.UUID = @NC_UUID
              AND NC.CFDIRelacionados = @CFDI_ACTUAL
              AND Activa = 1
              AND O.IdTipoOperacion = 17 --> NOTA DE CREDITP
              AND O.IdEstatusOperacion IN ( 1, 2 ); --> SOLO SI ESTA EN APROBACIÓN O ESTA APROBADA

		/*VALIDAR SI EL EXISTE UN CFDI RELACIONADO A LA NOTA DE CREDITO*/
        IF ISNULL(@ID_CFDIRELACIONADO, 0) = 0
        BEGIN
            UPDATE @CFDIsRelacionados
            SET Response = 'ERROR_VALIDACION',
                Detalle = CONCAT(
                                    'No existe ninguna factura, con el UUID:',
                                    @CFDI_ACTUAL,
                                    ', con la que podamos relacionar esta nota de crédito'
                                )
            WHERE id = @POSICION_ACTUAL
                  AND ISNULL(Response, '') <> 'ERROR_VALIDACION';
        END;

        -- SI EXISTE ESTA FACTURA EN PETROVENDOR, ENTONCES DEBE TENER UNA ACEPTACIÓN DE PEDIDO 
        -- VALIDAR QUE LA FACTURA RELACIONADA ESTE LIGADA AL PROVEEDOR ACTUAL(EMISOR)
        SELECT @NO_ACEPTACIONPEDIDO = AF.IdAceptacionPedido,
               @IdProveedorCliente = P.IdProveedorCompras
        FROM dbo.MM_AceptacionFactura AF
            LEFT JOIN dbo.MM_AceptacionPedido AP
                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
            LEFT JOIN dbo.MM_Pedido P
                ON AP.IdPedido = P.IdPedido
        WHERE AF.IdFactura = @ID_CFDIRELACIONADO --> FACTURA ENCONTRADA EN PETROVENDOR
              AND P.IdSubcontratista = @IdProveedor --> ES EL VENDEDOR = EMISOR
              AND ISNULL(AF.IdEstatusEliminado, 0) = 0; --> ACEPTACIÓN DEBE ESTAR ACTIVA 


        SELECT @RFCProveedorCliente = RFC
        FROM dbo.S_Proveedor
        WHERE IdProveedor = @IdProveedorCliente;

        SELECT @RFCProveedorVendedor = RFC
        FROM dbo.S_Proveedor
        WHERE IdProveedor = @IdProveedor;

		/*NINGUN CFDI ESTA RELACIONADO A UNA ACEPTACIÓN DE PEDIDO/ NO HAY FACTURA CON ESE UUID*/
        IF ISNULL(@NO_ACEPTACIONPEDIDO, 0) = 0
        BEGIN
            UPDATE @CFDIsRelacionados
            SET Response = 'ERROR_VALIDACION',
                Detalle = CONCAT(
                                    'No hay ninguna aceptación de pedido en petrovendor relacionada a tu empresa, relacionada al UUID: ',
                                    @CFDI_ACTUAL
                                )
            WHERE id = @POSICION_ACTUAL
                  AND ISNULL(Response, '') <> 'ERROR_VALIDACION';
        END;

        --> VALIDAR CLIENTE = RECEPTOR(OPERADORA)
        IF ISNULL(@RFCProveedorCliente, '') <> @RFCReceptor
        BEGIN
            UPDATE @CFDIsRelacionados
            SET Response = 'ERROR_VALIDACION',
                Detalle = CONCAT(
                                    'El RFC de Receptor no corresponde al cliente de la Aceptación No.',
                                    CAST(@NO_ACEPTACIONPEDIDO AS NVARCHAR(MAX))
                                )
            WHERE id = @POSICION_ACTUAL
                  AND ISNULL(Response, '') <> 'ERROR_VALIDACION';
        END;
        --> VALIDAR VENDEDOR = EMISOR(PROVEEDOR)
        IF ISNULL(@RFCProveedorVendedor, '') <> @RFCEmisor
        BEGIN
            UPDATE @CFDIsRelacionados
            SET Response = 'ERROR_VALIDACION',
                Detalle = CONCAT(
                                    'El RFC del emisor de la factura, no corresponde al RFC de tu empresa. Aceptación No.',
                                    CAST(@NO_ACEPTACIONPEDIDO AS NVARCHAR(MAX))
                                )
            WHERE id = @POSICION_ACTUAL
                  AND ISNULL(Response, '') <> 'ERROR_VALIDACION';
        END;

        -- VALIDAR LA NOTA DE CREDITO NO ESTE EN PETROVENDOR O ADINCO
        IF ISNULL(@ID_CFDINOTACREDITO, 0) > 0
        BEGIN
            UPDATE @CFDIsRelacionados
            SET Response = 'ERROR_VALIDACION',
                Detalle = CONCAT(
                                    'Esta nota de crédito ya se encuentrá, cargada en la Aceptación No.',
                                    CAST(ISNULL(@NO_ACEPTACIONPEDIDO, 0) AS NVARCHAR(MAX))
                                )
            WHERE id = @POSICION_ACTUAL
                  AND ISNULL(Response, '') <> 'ERROR_VALIDACION';
        END;

        --VALIDAR SI SE SE PUEDE CARGAR LA NOTA DE CREDITO PARA ESO LA FACTURA DEBE ESTAR APROBADA,
        -- CONSULTAR DETALLE DE LA FACTURA RELACIONADA
        SELECT @ID_ESTATUS = ISNULL(TAO.IdEstatusOperacion, 1),
               @ID_PEDIDOGENERAL = PG.IdPedido
        FROM dbo.MM_AceptacionPedido AS AP
            INNER JOIN dbo.MM_Pedido AS P
                ON AP.IdPedido=P.IdPedido 
            INNER JOIN dbo.S_Proveedor AS PR
                ON  P.IdProveedorCompras=PR.IdProveedor
            LEFT JOIN dbo.MM_AceptacionFactura AS AF
                ON AP.IdAceptacionPedido=AF.IdAceptacionPedido 
            LEFT JOIN dbo.TA_Operacion AS TAO
                ON AF.IdAceptacionFactura=TAO.IdDocumento 
                   AND TAO.IdTipoOperacion = 10 --> APROBACIÓN DE FACTURA
            INNER JOIN dbo.MM_Pedidos AS PG
                ON P.IdPedido = PG.IdIdentificador
                AND P.IdProveedorCompras=PG.IdProveedorCliente
            LEFT JOIN dbo.MM_TipoPedido AS TP
                ON PG.IdTipoPedido=TP.IdTipoPedido 
        WHERE P.IdSubcontratista = @IdProveedor
              AND AP.IdAceptacionPedido = @NO_ACEPTACIONPEDIDO
        GROUP BY AP.IdAceptacionPedido,
                 AP.IdPedido,
                 TAO.IdEstatusOperacion,
                 TAO.FechaModificacion,
                 TAO.IdOperacion,
                 PG.IdPedido;
		
		--PARA PODER CARGAR UNA NOTA DE CREDITO LA FACTURA DE LA ACEPTACIÓN DE PEDIDO DEBE ESTAR APROBADA
        IF ISNULL(@ID_ESTATUS, 0) <> 2
        BEGIN
            UPDATE @CFDIsRelacionados
            SET Response = 'ERROR_VALIDACION',
                Detalle = CONCAT(
                                    'Para poder cargar Notas de credito la factura de la Aceptación No.',
                                    CAST(ISNULL(@NO_ACEPTACIONPEDIDO, 0) AS NVARCHAR(MAX)),
                                    ' debe estar en Estatus de Aprobada'
                                )
            WHERE id = @POSICION_ACTUAL
                  AND ISNULL(Response, '') <> 'ERROR_VALIDACION';
        END;

        --VALIDAR SI EL CFDI ACTUAL NO TRAE UN ERROR ENTONCES NO AGREGAR DETALLE DE SUCCESS		 
        UPDATE @CFDIsRelacionados
        SET Response = 'SUCCESS',
            NoAceptacionPedido = @NO_ACEPTACIONPEDIDO,
            NoPedidoGeneral = ISNULL(@ID_PEDIDOGENERAL, 0),
            EstatusId = ISNULL(@ID_ESTATUS, 0),
            Detalle = CONCAT(
                                'Se ha encontrado la relación del CFDI relacionado, con la factura de la aceptación de servicio  No.',
                                @NO_ACEPTACIONPEDIDO
                            )
        WHERE id = @POSICION_ACTUAL
              AND ISNULL(Response, '') <> 'ERROR_VALIDACION';


    END;


    SELECT 'SUCCESS',
           'MOSTRAR DETALLE DE LOS CFDIS RELACIONADOS';
    SELECT id,                 --0
           cfdiRelacionado,    --1
           Response,           --2
           NoAceptacionPedido, --3
           NoPedidoGeneral,    --4
           EstatusId,          --5
           Detalle             --6
    FROM @CFDIsRelacionados;

END;



