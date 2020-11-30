CREATE  PROCEDURE [dbo].[Mobile_CambioEstatusAprobacionPedidoDEA]
    @IdOperacion INT,
    @IdAprobador INT,
    @IdTarea INT,
	@NoVersion INT 
AS
BEGIN

    DECLARE @ByAprobadaMovil INT;
	---OBTENER ESTATUS DE ORIGEN DE APROBACIÓN DESDE ADINCO APP
    SELECT @ByAprobadaMovil = ActualizadoByApp
    FROM Adinco..AM_Aprobacion
    WHERE IdTareaOrigen = @IdTarea;

    DECLARE @TipoAprobacion INT,
            @IdEstatusAprobacion INT;

	--- OBTENER EL TIPO DE OPERACIÓN Y EL ESTATUS DE LA APROBACIÓN
    SELECT @TipoAprobacion = IdTipoOperacion,
           @IdEstatusAprobacion = IdEstatusOperacion
    FROM dbo.TA_Operacion
    WHERE IdOperacion = @IdOperacion;

    IF ISNULL(@TipoAprobacion, 0) = 9   --> CTE APROBACIÓN DE PEDIDO
       AND ISNULL(@IdEstatusAprobacion, 0) = 2  -->CTE SI EL ESTATUS DE LA APROBACIÓN ES APROBADA
       AND ISNULL(@ByAprobadaMovil, 0) = 1  -->CTE SI LA APROBACIÓN SE REALIZO DESDE LA APP MOVIL 
    BEGIN
        -->SI LA OPERACIÓN ES SOLICITUD DE PEDIDO, ESTA APROBADA Y EL USUARIO ACTUAL APROBO DESDE LA APP
        DECLARE @IdProveedor INT,
                @EsProveedorDEA INT,
                @IdSolicitudPedido INT;

		 --ACTUALIZAR TA_TAREA DE PETROVENDOR CON BIT DE @UpdateByApp
			UPDATE dbo.TA_Tarea 
			SET UpdateByApp=@ByAprobadaMovil
			WHERE IdTarea=@IdTarea

        --OBTENER PROVEEDOR DE LA OPERADORA Y VALIDAR SEA PROVEEDOR DEA
        SELECT @IdProveedor = PP.IdProveedorCompras,
               @IdSolicitudPedido = PP.IdSolicitudPedido
        FROM dbo.MM_Pedido PP
            INNER JOIN dbo.TA_Operacion O
                ON O.IdDocumento = PP.IdSolicitudPedido
			AND O.NoVersion=PP.Version
        WHERE O.IdTipoOperacion = 9 --> CTE CTE APROBACION DE PEDIDO 
		AND PP.Version=@NoVersion
		AND O.IdOperacion=@IdOperacion

        SELECT @EsProveedorDEA = COUNT(1)
        FROM dbo.DEA_Proveedor
        WHERE IdProveedor = @IdProveedor;

        IF ISNULL(@EsProveedorDEA, 0) = 0
            RETURN; --NO ES PROVEEDOR DEA

        -- ES PROVEEDOR DEA CAMBIAR ESTATUS DE LA OPERACION 
        -- REFERENCIA SP SP_DEA_CambiarEstatusPedido
        
		 UPDATE dbo.TA_Operacion
		 SET IdEstatusOperacion=11 -->SELECT * FROM dbo.TA_Estatus WHERE IdEstatus = 11  --> APROBADO SIN DOCUMENTO
		 WHERE IdDocumento=@IdSolicitudPedido   --> NO DE SOLICITUD DE PEDIDO
		 AND IdOperacion=@IdOperacion --> NO DE LA OPERACION
		 AND NoVersion=@NoVersion --> VERSION DEL PEDIDO
		 AND IdTipoOperacion=9 ---> APROBACION DE PEDIDO

		-- REGRESAR LA FECHA DE ENVIO DEL PEDIDO A NULL 

		 UPDATE MM_Pedido 
		 SET FechaEnvioPedido =NULL
		 WHERE IdSolicitudPedido = @IdSolicitudPedido 
		 AND Version =@NoVersion
 					
		-- Actualizar fecha de vigencia de Recepción de pedido VOLVERLAS A REGRESAR A NULL POR QUE EL ESTATUS CAMBIA A APROBADA SIN DOCUMENTO 
		UPDATE HV SET FechaVigencia  = NULL ---> DATEADD(HOUR, ISNULL(HV.HorasVigencia,0) , GETDATE())
		FROM MM_HorasVigenciaPedido AS HV
		INNER JOIN MM_Pedido AS P ON P.IdPedido =  HV.IdPedido
		WHERE  P.IdSolicitudPedido = @IdSolicitudPedido AND P.Version =@NoVersion

		--OBTENER LA INFORMACIÓN DEL PEDIDO RELACIÓN CON LA PR 
		DECLARE @IdPedido INT 
		DECLARE @IdTipoPedido INT 
		DECLARE @IdPedidoGeneral INT 
		DECLARE @ID_PR NVARCHAR(MAX)


		SELECT 
		@ID_PR=ISNULL(PR.ID_PR,''), 
		@IdPedidoGeneral= PG.IdPedido,  
		@IdTipoPedido=PG.IdTipoPedido, 
		@IdPedido= P.IdPedido
		FROM dbo.MM_Pedido P
		INNER JOIN dbo.MM_SolicitudPedido SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
		LEFT JOIN dbo.DEA_AdjuntoPR PR ON PR.IdSolicitudPedido=SP.IdSolicitudPedido
		LEFT JOIN dbo.MM_Pedidos PG ON PG.IdIdentificador=P.IdPedido AND P.IdProveedorCompras=PG.IdProveedorCliente
		WHERE 
		P.IdSolicitudPedido=@IdSolicitudPedido
		AND P.Version=@NoVersion
		
		---OBTENER LOS USUARIOS RELACIONADOS A LOS CENTROS DE COSTO DE LA REQUISICIÓN ACTUAL
		 CREATE TABLE #CentroCosto(IdCentroCosto INT)
		
		INSERT INTO #CentroCosto
		(IdCentroCosto)
		
		SELECT SPLP.IdCentroCosto
		FROM dbo.MM_SolicitudPedidoDetalle SPD
		INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPLP 
			ON SPLP.IdSolicitudPedidoDetalle=SPD.IdSolicitudPedidoDetalle
		INNER JOIN dbo.CC_CentroCosto CC ON CC.IdCentroCosto=SPLP.IdCentroCosto		
		WHERE SPD.IdSolicitudPedido=@IdSolicitudPedido
		GROUP BY SPLP.IdCentroCosto

        -- GENERAR CORREOS DE SOLICITUD DE CARGA DE PR 

        ---REFERENCIA SP dbo.SP_DEA_ConsultarUsuarioNotificiacion88 
        --OBTENER LOS USUARIOS A NOTIFICAR CARGA DE PR 
        CREATE TABLE #CORREOS_NOTIFICACION
        (
            Id INT IDENTITY(1, 1),
            IdUsuario INT,
            Nombre NVARCHAR(MAX),
            Correo NVARCHAR(MAX)
            
        );

        --DEFINIR PARAMETROS PARA APLICAR EN EL REPLACE DEL CORREO
        DECLARE @SERVIDOR NVARCHAR(MAX) =
                (
                    SELECT Url
                    FROM TA_Dominios
                    WHERE Identificador = 2 --> URL PROCURA
                          AND Activo = 1
                );

        DECLARE @URL NVARCHAR(MAX)
            = CONCAT(
                        @SERVIDOR,
                        '/02Proveedores/PedidoDetalle.aspx?ped=',
                        CAST(ISNULL(@IdPedido,0) AS NVARCHAR(MAX)),
                        '&type=', CAST(ISNULL(@IdTipoPedido,0) AS NVARCHAR(MAX))                       
                    );

		DECLARE @URL_RELACION NVARCHAR(MAX)=CONCAT(@SERVIDOR,'/DEA/Relacion_PR_PO.aspx')
        DECLARE @CONTRATO NVARCHAR(MAX);

        SELECT DISTINCT
               @CONTRATO = ISNULL(AC.NombreAreaContractual, '')
        FROM Adinco.dbo.CO_Contrato C
            INNER JOIN Adinco.dbo.CO_AreaContractual AC
                ON C.IdAreaContractual = AC.IdAreaContractual
            INNER JOIN Petrovendor.dbo.MM_SolicitudPedido SP
                ON SP.IdContrato = C.IdContrato
        WHERE SP.IdSolicitudPedido = @IdSolicitudPedido;


        INSERT INTO #CORREOS_NOTIFICACION
        (IdUsuario,Nombre,Correo)
        SELECT U.IdUsuario, U.Nombre, U.Correo
		FROM dbo.DEA_UsuariosNotificar UN
		INNER JOIN dbo.S_Usuario U ON UN.IdUsuario=U.IdUsuario
		INNER JOIN #CentroCosto CC ON CC.IdCentroCosto = UN.IdCentroCosto
		WHERE UN.TipoNotificacion='SOLITAR_RELACION_PRPO'
		AND UN.Activo=1 
		AND U.Activo=1
		AND UN.IdProveedor=@IdProveedor

        DECLARE @IdCorreo INT = 88; --->CTE CORREO DE TIPO SOLICITUD DE RELACIONAR PR CON PO

        DECLARE @Asunto NVARCHAR(MAX) =
                (
                    SELECT Asunto FROM TA_Correo AS C WHERE IdCorreo = @IdCorreo
                );

        DECLARE @MensajeHTML NVARCHAR(MAX) =
                (
                    SELECT HTML
                    FROM TA_Correo AS C
                        INNER JOIN TA_CorreoServidor AS S
                            ON S.IdServidor = C.IdServidor
                    WHERE IdCorreo = @IdCorreo
                );

        DECLARE @De NVARCHAR(MAX) =
                (
                    SELECT CuentaRegistro
                    FROM TA_Correo AS C
                        INNER JOIN TA_CorreoServidor AS S
                            ON S.IdServidor = C.IdServidor
                    WHERE IdCorreo = @IdCorreo
                );

				
		SET @Asunto =  (REPLACE(@Asunto,'##NO_PR##',CAST(ISNULL(@ID_PR,0) AS NVARCHAR(MAX))));
		SET @Asunto =  (REPLACE(@Asunto,'##NO_SOLICITUD_PEDIDO##',CAST(ISNULL(@IdSolicitudPedido,0) AS NVARCHAR(MAX))));
		SET @Asunto =  (REPLACE(@Asunto,'##NO_PEDIDO##',CAST(ISNULL(@IdPedidoGeneral,0) AS NVARCHAR(MAX))));

        -- INSERTAR CORREOS DE NOTIFICACIÓN REFERENCIA SP TA_SP_EnviarCorreo
		DECLARE @IdIdentificacion NVARCHAR(MAX) = N'Solicitud Relacionar PR PO del pedido#'+CAST(ISNULL(@IdPedidoGeneral,0) AS NVARCHAR(MAX))
        DECLARE @Contador INT = 1;
        DECLARE @Count INT = 0;

        SELECT @Count = COUNT(1)
        FROM #CORREOS_NOTIFICACION;

        DECLARE @CorreoUsuario NVARCHAR(MAX);
		DECLARE @NombreUsuario NVARCHAR(MAX)
		DECLARE @IdUsuario INT
		DECLARE @HtmlUsuario NVARCHAR(MAX)
        WHILE @Contador <= @Count
        BEGIN
            --- REGISTRAR LOS CORREOS 
            
            SELECT @CorreoUsuario=Correo,
			@NombreUsuario=Nombre,
			@IdUsuario=IdUsuario
			FROM #CORREOS_NOTIFICACION
			WHERE Id = @Contador
            
			SET @HtmlUsuario= @MensajeHTML

			SET @HtmlUsuario= (REPLACE(@HtmlUsuario,'##NO_CONTRATO##',ISNULL(@CONTRATO,'')));
			SET @HtmlUsuario= (REPLACE(@HtmlUsuario,'##NOMBRE_USUARIO##',ISNULL(@NombreUsuario,'')));
			SET @HtmlUsuario= (REPLACE(@HtmlUsuario,'##NO_SOLICITUD_PEDIDO##',CAST(ISNULL(@IdSolicitudPedido,0) AS NVARCHAR(MAX))));
			SET @HtmlUsuario= (REPLACE(@HtmlUsuario,'##NO_PR##',CAST(ISNULL(@ID_PR,0) AS NVARCHAR(MAX))));
			SET @HtmlUsuario= (REPLACE(@HtmlUsuario,'##NO_PEDIDO##',CAST(ISNULL(@IdPedidoGeneral,0) AS NVARCHAR(MAX))));
			
			SET @HtmlUsuario= (REPLACE(@HtmlUsuario,'##URL_PEDIDO##',ISNULL(@URL,'')));
			SET @HtmlUsuario= (REPLACE(@HtmlUsuario,'##URL_RELACION_PO_PR##',ISNULL(@URL_RELACION,'')));
			SET @HtmlUsuario= (REPLACE(@HtmlUsuario,'##ANIO_ACTUAL##',CAST(ISNULL(YEAR(GETDATE()),0) AS NVARCHAR(MAX))));

            IF LEN(@CorreoUsuario) > 0 AND LEN(@De)>0 AND LEN(@Asunto)>0 --> si hay un correo enviar 
            BEGIN


                EXEC dbo.TA_SP_EnviarCorreo @Para =@CorreoUsuario,              -- varchar(500)
                                            @Asunto = @Asunto,            -- varchar(250)
                                            @Mensaje = @HtmlUsuario,           -- text
                                            @IdUsuario = @IdUsuario,          -- int
                                            @De = @De,                -- varchar(100)
                                            @IdCorreo = @IdCorreo,           -- int
                                            @IdIdentificacion = @IdIdentificacion; -- nvarchar(max)
            END;
			ELSE 
			BEGIN 
				INSERT INTO dbo.BitacoraErrores
				( HResult, Mensaje,  StackTrace,IdUsuario,IdProveedor,FechaRegistro)
				VALUES
				(   0,        -- HResult - int
				    CONCAT('Ha surguido un error al enviar mensaje de sol relación pedido po al usuario ',CAST(ISNULL(@IdUsuario,'') AS NVARCHAR(MAX))) ,      -- Mensaje - nvarchar(max)
				     CONCAT('Pedido ',CAST(ISNULL(@IdPedidoGeneral,'') AS NVARCHAR(MAX))),      -- StackTrace - nvarchar(max)
				    ISNULL(@IdAprobador,0),        -- IdUsuario - int
				    ISNULL(@IdProveedor,0),        -- IdProveedor - int
				    GETDATE() -- FechaRegistro - datetime
				 )
			END 
            SET @Contador = @Contador + 1;
        END;

		IF @Count = 0 
		BEGIN 
				INSERT INTO dbo.BitacoraErrores
				( HResult, Mensaje,  StackTrace,IdUsuario,IdProveedor,FechaRegistro)
				VALUES
				(   0,        -- HResult - int
				    N'No se encontraron usuarios para notificación de relación de Pedido PO DEA ' ,      -- Mensaje - nvarchar(max)
				    CONCAT('Requisición ',CAST(ISNULL(@IdSolicitudPedido,'') AS NVARCHAR(MAX))),      -- StackTrace - nvarchar(max)
				    ISNULL(@IdAprobador,0),        -- IdUsuario - int
				    ISNULL(@IdProveedor,0),        -- IdProveedor - int
				    GETDATE() -- FechaRegistro - datetime
				 )
		END 


    END;
END;
