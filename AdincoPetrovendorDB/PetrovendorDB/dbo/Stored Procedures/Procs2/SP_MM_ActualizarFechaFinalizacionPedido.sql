USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ActualizarFechaFinalizacionPedido'
)
    DROP PROCEDURE SP_MM_ActualizarFechaFinalizacionPedido;
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ActualizarFechaFinalizacionPedido]    Script Date: 25/03/2022 06:34:48 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- DANIEL AC /25-03-2022 --> SE JUNTA ACTUALIZACIÓN DE FECHA DE LIMITE CONFIRMACIÓN, ACTUALZIACIÓN DE PARTIDAS Y ENVIO DE CORREO DE ACTUALIZACIÓN
CREATE PROCEDURE [dbo].[SP_MM_ActualizarFechaFinalizacionPedido]
    @IdPedido INT,
    @NuevaFechaLimite DATETIME,
    @IdUsuario INT,
    @Motivo NVARCHAR(MAX),
	@MaterialesPedido TY_PedidoDetalle   READONLY
AS
BEGIN
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
		BEGIN TRY
		BEGIN TRAN		

			DECLARE @HorasVigencia INT,
					@OldFechaVigencia DATETIME,
					@IdSolicitudPedido INT, 
					@Version INT,
					@ProveedorComprasId INT,
					@ProveedorCompras VARCHAR(MAX),
					@NoPedidoGeneral INT
			
			DECLARE @Usuarios AS TABLE(
				Id INT IDENTITY(1,1),
				NombreUsuario VARCHAR(MAX),		
				CorreoUsuario VARCHAR(MAX),
				UsuarioId INT
			)

			DECLARE @PedidoDetalle AS TABLE(
				Id INT IDENTITY(1,1),
				IdSolicitudPedidoDetalle int NOT NULL,
				Cantidad FLOAT NOT NULL,
				CantidadSolicitar  float not NULL
			)

			DECLARE @IdNotificacion BIGINT

			DECLARE @HTML NVARCHAR(MAX),
				@Asunto NVARCHAR(MAX),
				@CuentaRegistro NVARCHAR(MAX), 
				@Contrasena VARCHAR(MAX), 
				@SMTP VARCHAR(MAX), 
				@Puerto INT,
				@BBC VARCHAR(MAX),
				@Dominio VARCHAR(MAX),
				@HTML_USER NVARCHAR(MAX),
				@URL_Detalle VARCHAR(MAX)

				DECLARE @RowId INT=1,
				@TotalUsuarios INT=0, 
				@Contador INT=0,
				@UsuarioNombre VARCHAR(MAX), 
				@UsuarioCorreo VARCHAR(MAX),
				@NotificarUsuario INT,
				@UsuarioId INT

				DECLARE @P_Id INT =1,
				@P_Total INT=0, 
				@P_Contador INT=1,
				@P_IdSolicitudPedidoDetalle INT ,
				@P_Cantidad FLOAT ,
				@P_ASolicitar FLOAT 

				-- OBTENER FECHAS ANTES DE CAMBIO
				SELECT	@HorasVigencia = HorasVigencia, 
				@OldFechaVigencia = FechaVigencia  
				FROM dbo.MM_HorasVigenciaPedido 
				WHERE IdPedido =  @IdPedido

				-- AGREGAR HISTORIAL
				INSERT INTO dbo.MM_HorasVigenciaPedidoHistorial
				(
					IdPedido,
					HorasVigencia,
					FechaVigencia,
					FechaCreacion,
					IdUsuarioCreador,
					Motivo
				)
				VALUES
				(   @IdPedido,         -- IdPedido - int
					@HorasVigencia,    -- HorasVigencia - int
					@OldFechaVigencia, -- FechaVigencia - datetime
					GETDATE(),         -- FechaCreacion - datetime
					@IdUsuario,        -- IdUsuarioCreador - int
					@Motivo            -- Motivo - nvarchar(max)
				)
	   	 
				--ACTUALIZAR NUEVAS FECHAS
				UPDATE MM_HorasVigenciaPedido
				SET FechaVigencia = @NuevaFechaLimite,
					HorasVigencia = DATEDIFF(HOUR, GETDATE() , @NuevaFechaLimite)
				 WHERE IdPedido = @IdPedido


				-- ACTUALIZAR PARTIDAS REFERENCIA EN SP --> SP_ModificarPedidoDetalle
				INSERT INTO @PedidoDetalle(Cantidad,CantidadSolicitar,IdSolicitudPedidoDetalle)
				SELECT Cantidad,CantidadSolicitar,IdSolicitudPedidoDetalle
				FROM @MaterialesPedido

				SET @P_Total = (SELECT COUNT(1) FROM @PedidoDetalle)

				WHILE @P_Total >=@P_Contador
				BEGIN 

					SELECT 
					@P_ASolicitar =CantidadSolicitar,
					@P_Cantidad = Cantidad,
					@P_IdSolicitudPedidoDetalle = IdSolicitudPedidoDetalle
					FROM @PedidoDetalle 
					WHERE Id=@P_Id
		

					IF ( @P_Cantidad != @P_ASolicitar )
						BEGIN
							--SE AGREGA AL HISTORICO ANTES DE MODIFICAR EL REGISTRO DE MM_PEDIDODETALLE
							INSERT INTO dbo.MM_PedidoDetalleHistorico
								( IdPedidoDetalle, IdPedido, IdMaterial, IdPeticionOfertaDetalle, Posicion, PrecioUnitario ,
								  Cantidad , PorcentajeIVA, Subtotal, Activo, ComentariosCompras, Entregado, AceptacionServicio ,
								  RecepcionPedido , FechaAceptacionServicio, IdUsuarioAceptacionServicio, FechaRecepcionPedido ,
								  IdUsuarioRecepcionServicio , ComentarioAceptacionServicio, PorcentajeContenidoNacional ,
								  PorcentajeContenidoExtranjero , IsBienServicioNacional, CreadoPor, CreadoEl, ModificadoPor ,
								  ModificadoEl , IdMoneda, IdMaterialVendedor, IdUnidad, IdUnidadProveedor
							)
							SELECT pedidoDetalle.IdPedidoDetalle, pedidoDetalle.IdPedido, pedidoDetalle.IdMaterial ,
								   pedidoDetalle.IdPeticionOfertaDetalle, pedidoDetalle.Posicion, pedidoDetalle.PrecioUnitario ,
								   pedidoDetalle.Cantidad, pedidoDetalle.PorcentajeIVA, pedidoDetalle.Subtotal ,
								   pedidoDetalle.Activo, pedidoDetalle.ComentariosCompras, pedidoDetalle.Entregado ,
								   pedidoDetalle.AceptacionServicio, pedidoDetalle.RecepcionPedido ,
								   pedidoDetalle.FechaAceptacionServicio, pedidoDetalle.IdUsuarioAceptacionServicio ,
								   pedidoDetalle.FechaRecepcionPedido, pedidoDetalle.IdUsuarioRecepcionServicio ,
								   pedidoDetalle.ComentarioAceptacionServicio, pedidoDetalle.PorcentajeContenidoNacional ,
								   pedidoDetalle.PorcentajeContenidoExtranjero, pedidoDetalle.IsBienServicioNacional ,
								   pedidoDetalle.CreadoPor, pedidoDetalle.CreadoEl, pedidoDetalle.ModificadoPor ,
								   pedidoDetalle.ModificadoEl, pedidoDetalle.IdMoneda, pedidoDetalle.IdMaterialVendedor ,
								   pedidoDetalle.IdUnidad, pedidoDetalle.IdUnidadProveedor
							FROM   MM_SolicitudPedidoDetalle solPedDetalle
							JOIN   MM_PedidoDetalle pedidoDetalle
								ON solPedDetalle.IdMaterial = pedidoDetalle.IdMaterial 
							WHERE
								   solPedDetalle.IdSolicitudPedidoDetalle = @P_IdSolicitudPedidoDetalle
								   AND pedidoDetalle.IdPedido = @IdPedido
								   AND pedidoDetalle.Activo = 1

							UPDATE pedidoDetalle
							SET	   pedidoDetalle.Cantidad = @P_ASolicitar ,
								   pedidoDetalle.Subtotal = (@P_ASolicitar * pedidoDetalle.PrecioUnitario),
								   pedidoDetalle.ModificadoEl = GETDATE (), 
								   pedidoDetalle.ModificadoPor = @IdUsuario
							FROM   MM_SolicitudPedidoDetalle solPedDetalle
							JOIN   MM_PedidoDetalle pedidoDetalle
								ON solPedDetalle.IdMaterial = pedidoDetalle.IdMaterial 
							WHERE
								   solPedDetalle.IdSolicitudPedidoDetalle = @P_IdSolicitudPedidoDetalle
								   AND pedidoDetalle.IdPedido = @IdPedido
								   AND pedidoDetalle.Activo = 1;
						END

					SET @P_Contador= @P_Contador+1
				END 


				-- DETALLE DEL PEDIDO INFO PARA CORREO
				SELECT 
				@IdSolicitudPedido = P.IdSolicitudPedido,
				@Version = P.Version,
				@ProveedorComprasId = P.IdProveedorCompras,
				@ProveedorCompras = PC.RazonSocial,
				@NoPedidoGeneral = PG.IdPedido
				FROM MM_Pedido P
				JOIN S_Proveedor PC 
					ON P.IdProveedorCompras = PC.IdProveedor
				JOIN MM_Pedidos AS PG 
					ON P.IdPedido = PG.IdIdentificador 
					AND  P.IdProveedorCompras =PG.IdProveedorCliente 
					AND PG.IdTipoPedido IN (2,4,6) 	--> CTES 
				WHERE P.IdPedido=@IdPedido


				INSERT INTO @Usuarios(NombreUsuario,CorreoUsuario)
				SELECT  U.Nombre, U.Correo
				FROM MM_Pedido AS P 
				JOIN S_Proveedor AS PR 
					ON P.IdSubcontratista = PR.IdProveedor 
				JOIN S_UsuarioProveedor AS UP
					ON PR.IdProveedor = UP.IdProveedor 
				JOIN S_Usuario AS U 
					ON U.IdUsuario = UP.IdUsuario 	
				WHERE (U.IdTipoUsuario = 4 --> CTE ROL ADMIN DE PETROVENDOR
				OR U.IdTipoUsuario = 3) --> CTE ROL VENTAS DE PETROVENDOR
				AND P.IdPedido = @IdPedido

	
				/*Obtener dominio de PETROVENDOR*/
				SELECT @Dominio= Url 
				FROM TA_Dominios 
				WHERE Identificador = 1 --> CTE 
				AND Activo = 1 
				AND IdServidor = 1 --> CTE 

				--OBTENER DETALLE DEL CORREO 
				SELECT @HTML = HTML,
				@Asunto = Asunto,
				@CuentaRegistro = CuentaRegistro, 
				@Contrasena = Contrasena, 
				@SMTP = SMTP, 
				@Puerto = Puerto,
				@BBC = BBC
				FROM TA_Correo AS C
				JOIN S_CorreoServidor AS S 
					ON C.IdServidor = S.IdCorreoServidor
				WHERE IdCorreo = 60   --> CTE CambioFechaPedido

				--REEMPLAZAR ENCABEZADO DEL HTML --> C# Tipo_Correo._CambioFechaPedido

				SET @URL_Detalle = CONCAT(@Dominio,'02Proveedores/OrdenesDetalle.aspx?pedido=',CAST(ISNULL(@IdPedido,0) AS nvarchar(MAX)),'&pc==',CAST(ISNULL(@ProveedorComprasId,0) AS nvarchar(MAX)))
	
				SET  @Asunto= REPLACE(@Asunto,'##NO_PEDIDO##',CAST(ISNULL(@NoPedidoGeneral,0) AS nvarchar(MAX)))	
				-- PERSONALIZAR DETALLE DEL CORREO 
				SET @HTML= REPLACE(@HTML,'##NO_PEDIDO##',CAST(ISNULL(@NoPedidoGeneral,0) AS nvarchar(MAX)))
				SET @HTML= REPLACE(@HTML,'##NOMBRE_CLIENTE##',@ProveedorCompras)
				SET @HTML= REPLACE(@HTML,'##FECHA_ANTERIOR##',FORMAT(@OldFechaVigencia,'dd/MM/yyyy hh:mm tt'))
				SET @HTML= REPLACE(@HTML,'##FECHA_NUEVA##',FORMAT(@NuevaFechaLimite,'dd/MM/yyyy hh:mm tt'))
				SET @HTML= REPLACE(@HTML,'##DESCRIPCION##',@Motivo)
				SET @HTML= REPLACE(@HTML,'##URL_PO##',@URL_Detalle)
				SET @HTML= REPLACE(@HTML,'##ANIO_ACTUAL##',CAST(YEAR(GETDATE()) AS nvarchar(MAX)))


				SET @TotalUsuarios = (SELECT COUNT(1) FROM @Usuarios)

				WHILE @TotalUsuarios>=@RowId
				BEGIN 
					SET @HTML_USER =@HTML;

					SELECT 
					@UsuarioNombre = NombreUsuario,
					@UsuarioCorreo = CorreoUsuario,
					@UsuarioId = UsuarioId
					FROM @Usuarios 
					WHERE Id= @RowId

		
					SET @HTML_USER= REPLACE(@HTML_USER,'##NOMBRE_USUARIO##',@UsuarioNombre)

		
					SET @NotificarUsuario =(SELECT COUNT(1)
												FROM TA_NoNotificacion
												WHERE  IdUsuario = @UsuarioId
												AND IdCorreo = 60 --> CTE _CambioFechaPedido
												AND ISNULL(IsEliminado,0) = 0)
		
		
							--GUARDAR ENVIO DEL CORREO A LOS USUARIOS DEL PROVEEDOR DEL PEDIDO
							BEGIN 
						
								SET @IdNotificacion = (SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1

								INSERT INTO Adinco.dbo.S_Notificacion
								(
									IdNotificacion,
									Para,
									Asunto,
									Mensaje,
									FechaProgramadaEnvio,
									Enviada,
									FechaEnvio,
									CreadoPor,
									CreadoEl,
									ModificadoPor,
									ModificadoEl,
									De
								)
								VALUES
								(   @IdNotificacion,         -- IdNotificacion - bigint
									@UsuarioCorreo,        -- Para - varchar(500)
									@Asunto,        -- Asunto - varchar(250)
									@HTML_USER,        -- Mensaje - text
									GETDATE(),--@FechaProgramada, -- FechaProgramadaEnvio - datetime
									CASE WHEN ISNULL(@NotificarUsuario,0) > 0 THEN 1 ELSE 0 END,      -- Enviada - bit
									CASE WHEN ISNULL(@NotificarUsuario,0) > 0 THEN GETDATE() ELSE NULL END, -- FechaEnvio - datetime
									1,	-- CTE @IdUsuario,         -- CreadoPor - int
									GETDATE(), -- CreadoEl - datetime
									NULL,         -- ModificadoPor - int
									NULL, -- ModificadoEl - datetime
									@CuentaRegistro         -- De - varchar(100)
								)

								INSERT INTO dbo.TA_EnvioCorreo
								(
									IdEnvioAdinco,
									IdCorreo,
									IdIdentificacion,
									EnviadoPor,
									EnviadoEl
								)
								VALUES
								(   @IdNotificacion, -- IdEnvioAdinco - int
									60, --> CTE _CambioFechaPedido
									CONCAT('0 - Cambio fecha de vigencia límite del pedido #',CAST(ISNULL(@NoPedidoGeneral,0) AS nvarchar(MAX)),						
									' -->(SP: SP_MM_ActualizarFechaFinalizacionPedido'
									,CASE WHEN ISNULL(@NotificarUsuario,0) > 0 THEN '*Correo no enviado por bloqueo de correo 60' ELSE '' END,')'),  -- IdIdentificacion - int
									@IdUsuario,
									GETDATE()
								);
								END 


					SET @RowId =@RowId +1
				END 

				 

	SELECT 1 AS RESPONSE--retorno algo para saber que llegue hasta aqui

	COMMIT TRAN
	END TRY
	BEGIN CATCH
		/*===========*/
		ROLLBACK TRAN	
		DECLARE @error VARCHAR(MAX)=
			CONCAT('ERROR- : PedidoId: ',cast(@IdPedido as nvarchar(MAX)),'ERROR-SP:SP_MM_ActualizarFechaFinalizacionPedido ['+ ERROR_MESSAGE() + '] LINEA ['+ CAST(ERROR_LINE() AS VARCHAR)+']' )
							
		/*===========*/	
		 RAISERROR(15600, -1, -1, @error);
	END CATCH
	END
END 