-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 14-01-2022
-- Description:	 Se agrega ENVIO de correo si existe aprobador siguiente y es flujo serial
--**************************************************************

CREATE PROCEDURE [dbo].[Mobile_EnviarNotificacionAprobacionPedido] 
-- Add the parameters for the stored procedure here
@IdTareaActual INT

AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

				/*CTES PARA FORMAR TABLA DE PEDIDOS*/
		DECLARE @tabla NVARCHAR(MAX)= N'<table width="100%" bordercolor="#5e5f5e" style="border-collapse: collapse; font: 200 14px ''Open Sans'', Arial, Helvetica, sans-serif; color: black;"><tr bgcolor="#C9E3FF"><th style="padding: 5px;">Material / Servicio Cotizado por el proveedor</th><th style="padding: 5px;">Precio Unitario</th><th style="padding: 5px;">Cantidad</th><th style="padding: 5px;">Unidad</th><th style="padding: 5px;">Subtotal</th><th style="padding: 5px;">Moneda</th></tr>';
        DECLARE @cierreTabla NVARCHAR(MAX)= '</table>';
        DECLARE @fila NVARCHAR(MAX)= '<tr>';
        DECLARE @cierreFila NVARCHAR(MAX)= '</tr>';
        DECLARE @columnaProveedor NVARCHAR(MAX)= '<td colspan="6" align="center" bgcolor="#e6e6e6" style="padding: 5px;border-bottom: double;border-color: black;border-top: double;">';
        DECLARE @columna NVARCHAR(MAX)= '<td style="padding: 5px;">';
        DECLARE @columnaMoney NVARCHAR(MAX)= '<td align="right" style="padding: 5px;">';
        DECLARE @cierreColumna NVARCHAR(MAX)= '</td>';
        DECLARE @tablaTotal NVARCHAR(MAX)= '<table width="20%" bordercolor="#5e5f5e" align="right" style="border-collapse: collapse; font: 200 14px ''Open Sans'', Arial, Helvetica, sans-serif; color: black;">';
        DECLARE @cierretablaTotal NVARCHAR(MAX)= '</table >';
        DECLARE @totalFila NVARCHAR(MAX)= '<tr bgcolor="#C9E3FF">';
        DECLARE @totalColumna NVARCHAR(MAX)= '<th style="padding: 5px;">';
        DECLARE @cierretotalColumna NVARCHAR(MAX)= '</th>';
		DECLARE @Contrato NVARCHAR(MAX)=''
		DECLARE @IdPedido1 INT =0, @IdPedido2 INT =0

		DECLARE @HTML NVARCHAR(MAX),
		@Asunto NVARCHAR(MAX),
		@CuentaRegistro NVARCHAR(MAX), 
		@Contrasena NVARCHAR(MAX), 
		@SMTP NVARCHAR(MAX), 
		@Puerto INT,
		@BBC NVARCHAR(MAX)

		--DECLARE @IdTareaActual INT = 105829;
		DECLARE @IdOperacion INT, 
		@EstatusAprobadorId INT, 
		@EstatusOperacionId INT, 
		@TipoFlujoId INT, 
		@VersionAprobacion INT, 		
		@NoPedidoGeneral INT,
		@TipoCompra  NVARCHAR(MAX),
		@Moneda  NVARCHAR(MAX),
		@NoSecuenciaActual INT,
		@NoSecuenciaSiguiente INT,
		@IdAprobadorSiguiente INT,		
		@EstatusAprobadorSiguienteId INT,
		@SolicitudPedidoId INT,
		@ContratoId INT,
		@ContratoNombre  NVARCHAR(MAX),
		@AreaContractualNombre  NVARCHAR(MAX),		
		@Asignador NVARCHAR(MAX),
		@CorreoAprobador NVARCHAR(MAX),
		@NombreAprobador NVARCHAR(MAX),
		@SumTotalPedido NVARCHAR(MAX),
		@URL_Detalle NVARCHAR(MAX),
		@URL_DetalleAprobar NVARCHAR(MAX),
		@URL_DetalleRechazar NVARCHAR(MAX),
		@Dominio NVARCHAR(MAX),
		@UsuarioActualId INT
		

		DECLARE @RowId INT=1,
		@TotalProductos INT=0, 
		@Contador INT=0, 
		@PreTabla  NVARCHAR(MAX)='', 
		@TablaHTMLTotal  NVARCHAR(MAX)='',		
		@RowDescripcion NVARCHAR(MAX)='',
		@RowPrecioUnitario NVARCHAR(MAX)='', 
		@RowCantidad  NVARCHAR(MAX)='', 
		@RowUnidad  NVARCHAR(MAX)='', 
		@RowMoneda  NVARCHAR(MAX)='',
		@RowSubtotal  NVARCHAR(MAX)='',
		@RowObjetivoPedido  NVARCHAR(MAX)='',
		@RowPedidoGral  NVARCHAR(MAX)='',
		@RowContrato  NVARCHAR(MAX)=''

		DECLARE @IdNotificacion BIGINT

		DECLARE @Productos AS Table (
				Id INT IDENTITY(1,1),
				IdSubcontratista INT, 
				Objetivo NVARCHAR(MAX), 
				IdPedido INT, 
				DescripcionCorta NVARCHAR(MAX),
				PrecioUnitario FLOAT, 
				Cantidad FLOAT,
				Unidad NVARCHAR(MAX),
				Subtotal FLOAT,
				TipoMonedaCorto NVARCHAR(MAX),
				Contrato  NVARCHAR(MAX),
				TipoPedido  NVARCHAR(MAX))

		/*Obtener informacion del aprobador actual*/
		SELECT TOP 1 
			@IdOperacion =  TA.IdOperacion,
			@EstatusOperacionId = TAO.IdEstatusOperacion,
			@EstatusAprobadorId = TA.IdEstatus,
			@TipoFlujoId = FT.IdTipoFlujo,
			@VersionAprobacion = TAO.NoVersion,
			@NoSecuenciaActual = TA.NoSecuencia,
			@UsuarioActualId = TA.IdAprobador
            FROM TA_Tarea AS TA
                JOIN TA_Operacion AS TAO 
				ON TAO.IdOperacion = TA.IdOperacion   
				LEFT JOIN TA_FlujoTarea FT 
					ON TAO.IdFlujoTarea = FT.IdFlujoTarea
            WHERE TAO.IdTipoOperacion = 9--> CTE APROBACION DE PEDIDO
                AND TA.IdTarea = @IdTareaActual


		IF ISNULL(@EstatusOperacionId,0) =  1 
		AND ISNULL(@TipoFlujoId,0) = 1  
		AND ISNULL(@EstatusAprobadorId,0) = 2 /*SI LA OPERACION ESTA EN ESTATUS APROBACION Y EL FLUJO ES SERIAL Y EL APROBADOR ACTUAL YA APROBO SU TAREA*/
		BEGIN 

		/*BUSCAR SI HAY APROBADOR SIGUIENTE*/
			    SELECT                         
				@Asignador = UA.Nombre,
                @IdAprobadorSiguiente = T.IdAprobador, 
                @NombreAprobador= U.Nombre, 
                @CorreoAprobador = U.Correo, 
                @NoSecuenciaSiguiente = T.NoSecuencia, 
                @EstatusAprobadorSiguienteId= T.IdEstatus,                 
				@NoPedidoGeneral = PG.IdPedido,
				@ContratoId = P.IdContrato,
				@SolicitudPedidoId = P.IdSolicitudPedido,
				@ContratoNombre = (CONCAT(ISNULL(C.NumeroContrato,''),' - ',ISNULL(AC.NombreAreaContractual,''))),
				@AreaContractualNombre = ISNULL(AC.NombreAreaContractual,''),
				@TipoCompra =TP.TipoPedido,
				@Moneda = MO.TipoMonedaCorto
                FROM TA_Operacion AS O
                     JOIN MM_Pedido AS P 
						ON O.IdDocumento = P.IdSolicitudPedido 
						AND O.NoVersion = P.Version
                     JOIN TA_Tarea AS T 
						ON  O.IdOperacion = T.IdOperacion 
                     JOIN S_Usuario AS U 
						ON T.IdAprobador = U.IdUsuario 
                     JOIN TA_FlujoTarea AS FT 
						ON O.IdFlujoTarea = FT.IdFlujoTarea 
                     JOIN TA_Estatus AS E 
						ON O.IdEstatusOperacion = E.IdEstatus 
					 JOIN dbo.MM_Pedidos PG 
						ON P.IdPedido = PG.IdIdentificador 
						AND P.IdProveedorCompras=PG.IdProveedorCliente
						AND PG.IdTipoPedido IN (2,4,6) --> CTE Mercadeo,Adjudicación Directa,Orden de Trabajo
					 LEFT JOIN S_Usuario UA
						ON O.IdAsignador	= UA.IdUsuario
					 LEFT JOIN Adinco.dbo.CO_Contrato C 
						ON P.IdContrato = C.IdContrato
					LEFT JOIN Adinco.dbo.CO_AreaContractual AC
						ON C.IdAreaContractual = AC.IdAreaContractual
					LEFT JOIN MM_TipoPedido TP
						ON PG.IdTipoPedido = TP.IdTipoPedido
					LEFT JOIN PV_TipoMoneda MO
						ON P.IdMoneda = MO.IdMoneda
                WHERE O.IdOperacion = @IdOperacion
                      AND P.Version = @VersionAprobacion
					  AND T.NoSecuencia = (@NoSecuenciaActual+1) --> SEA EL APROBADOR SIGUIENTE
                GROUP BY  				               
				UA.Nombre,
                T.IdAprobador, 
                U.Nombre, 
                U.Correo, 
                T.NoSecuencia, 
                T.IdEstatus,                 
				PG.IdPedido,
				P.IdContrato,
				P.IdSolicitudPedido,				
				C.NumeroContrato,
				AC.NombreAreaContractual,				
				TP.TipoPedido,
				MO.TipoMonedaCorto
                ORDER BY T.NoSecuencia ASC;


				/*Validar si el aprobador siguiente esta como pendiente de aprobación y exista una TareaId*/
				IF ISNULL(@EstatusAprobadorSiguienteId,0) = 1 AND ISNULL(@IdAprobadorSiguiente,0) <> 0
			    BEGIN 

				/*Reenviar correo de aprobación serial*/

				SELECT @HTML = HTML,
				@Asunto = Asunto,
				@CuentaRegistro = CuentaRegistro, 
				@Contrasena = Contrasena, 
				@SMTP = SMTP, 
				@Puerto = Puerto,
				@BBC = BBC
				FROM TA_Correo AS C
				INNER JOIN S_CorreoServidor AS S ON S.IdCorreoServidor=C.IdServidor
				WHERE IdCorreo = 19   --> CTE Aprobación de Pedido 

				/*Obtener dominio de PROCURA*/
				SELECT @Dominio= Url FROM TA_Dominios 
				WHERE Identificador = 2 --> CTE 
				AND Activo = 1 
				AND IdServidor = 2 --> CTE 

				/*Armar URL que redireccionaran a las paginas de aprobacion*/
				SET @URL_Detalle = CONCAT(@Dominio,'04Tareas/redireccion.aspx?accion=redireccionar&pagina=DETALLE_PEDIDO&num_ped=',CAST(ISNULL(@SolicitudPedidoId,0) AS nvarchar(MAX)),'&num_user=',CAST(ISNULL(@IdAprobadorSiguiente,0) AS nvarchar(MAX)),'&origin=t&tp_user=1&version=',CAST(ISNULL(@VersionAprobacion,0) AS nvarchar(MAX)))
				SET @URL_DetalleAprobar = CONCAT(@Dominio,'04Tareas/redireccion.aspx?accion=redireccionar&pagina=APROBACION_PEDIDO&nump=',CAST(ISNULL(@SolicitudPedidoId,0) AS nvarchar(MAX)),'&response=2&num_tarea=&num_user=',CAST(ISNULL(@IdAprobadorSiguiente,0) AS nvarchar(MAX)),'&version=',CAST(ISNULL(@VersionAprobacion,0) AS nvarchar(MAX)))
				SET @URL_DetalleRechazar = CONCAT(@Dominio,'04Tareas/redireccion.aspx?accion=redireccionar&pagina=APROBACION_PEDIDO&nump=',CAST(ISNULL(@SolicitudPedidoId,0) AS nvarchar(MAX)),'&response=3&num_tarea=&num_user=',CAST(ISNULL(@IdAprobadorSiguiente,0) AS nvarchar(MAX)),'&version=',CAST(ISNULL(@VersionAprobacion,0) AS nvarchar(MAX)))


				SET  @Asunto= REPLACE(@Asunto,'##NO_OPERACION##',CAST(ISNULL(@NoPedidoGeneral,0) AS nvarchar(MAX)))	
				SET  @HTML= REPLACE(@HTML,'##NOMBRE_USUARIO##',CAST(ISNULL(@NombreAprobador,'') AS nvarchar(MAX)))
				SET  @HTML= REPLACE(@HTML,'##NO_PEDIDO##',CAST(ISNULL(@NoPedidoGeneral,0) AS nvarchar(MAX)))
				SET  @HTML= REPLACE(@HTML,'##TIPO_COMPRA##',ISNULL(@TipoCompra,''))
				SET  @HTML= REPLACE(@HTML,'##NO_SOLICITUDPEDIDO##',CAST(ISNULL(@SolicitudPedidoId,0) AS nvarchar(MAX)))
				SET  @HTML= REPLACE(@HTML,'##AREA_CONTRACTUAL##',ISNULL(@AreaContractualNombre,''))
				SET  @HTML= REPLACE(@HTML,'##VERSION##',CAST(ISNULL(@VersionAprobacion,0) AS nvarchar(MAX)))
				SET  @HTML= REPLACE(@HTML,'##NOMBRE_SOLICITANTE##',ISNULL(@Asignador,''))
				SET  @HTML= REPLACE(@HTML,'##CONTRATO##',ISNULL(@ContratoNombre,''))
				SET  @HTML= REPLACE(@HTML,'##URL_TAREA##',ISNULL(@URL_Detalle,''))
				SET  @HTML= REPLACE(@HTML,'##URL_TAREA_ACEPTAR##',ISNULL(@URL_DetalleAprobar,''))
				SET  @HTML= REPLACE(@HTML,'##URL_TAREA_RECHAZAR##',ISNULL(@URL_DetalleRechazar,''))
				SET  @HTML= REPLACE(@HTML,'##ANIO_ACTUAL##',CAST(YEAR(GETDATE()) AS nvarchar(MAX)))

				/*SE EJECUTA SP QUE OBTIENE DETALLE DE LOS PRODUCTOS DEL PEDIDO*/			
				INSERT INTO @Productos(IdSubcontratista,Objetivo,IdPedido,DescripcionCorta,PrecioUnitario,Cantidad,Unidad,Subtotal,TipoMonedaCorto,Contrato,TipoPedido)
				EXEC [dbo].[MM_SP_ConsultaPedidoNotificacion] 
				@IdSolicitudPedido = @SolicitudPedidoId,
				@Version = @VersionAprobacion,	
				@IdContrato  = @ContratoId,
				@IdUsuario    = null,
				@FechaRegistro  = null
					

				SET @TotalProductos= (SELECT COUNT(1) FROM @Productos)
				IF @TotalProductos >0 
					BEGIN 

					SELECT 
					@Contrato = Contrato,
					@IdPedido1 = IdPedido,
					@RowPedidoGral = IdPedido,
					@RowObjetivoPedido = Objetivo,
					@RowContrato = Contrato
					FROM @Productos 
					WHERE Id=@RowId --> VARIABLE INICIAL EN 1

					SET @PreTabla = CONCAT(@PreTabla,@tabla,@fila,@columnaProveedor,'<b>No. Pedido: ',ISNULL(@RowPedidoGral,''),'</b><br/><b>Proveedor: </b>',@RowObjetivoPedido,'<br/><b>Contrato: </b>',@RowContrato,@cierreColumna,@cierreFila)
					
					/*RECORRER PRODUCTOS PARA TABLA DETALLE DE PRODUCTOS*/
					WHILE @TotalProductos>=@RowId
					BEGIN

						SELECT 
						@IdPedido2 = IdPedido,						
						@RowObjetivoPedido = Objetivo,
						@RowDescripcion = DescripcionCorta,
						@RowPrecioUnitario = '$' + CONVERT(VARCHAR, CONVERT(VARCHAR, CAST(ISNULL(PrecioUnitario,0)  AS MONEY), 1)),
						@RowCantidad = CONVERT(VARCHAR, CONVERT(VARCHAR, CAST(ISNULL(Cantidad,0)  AS MONEY), 1)),
						@RowSubtotal = '$' + CONVERT(VARCHAR, CONVERT(VARCHAR, CAST(ISNULL(Subtotal,0)  AS MONEY), 1)),
						@RowUnidad = Unidad,
						@RowMoneda = TipoMonedaCorto,
						@RowPedidoGral = CAST(IdPedido AS NVARCHAR(MAX)),
						@RowContrato = Contrato
						FROM @Productos WHERE Id=@RowId
											   
						IF @IdPedido1 = @IdPedido2
						BEGIN 

							SET @PreTabla = CONCAT(@PreTabla,@fila)
							SET @PreTabla = CONCAT(@PreTabla,@columna,@RowDescripcion,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@columnaMoney,@RowPrecioUnitario,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@columnaMoney,@RowCantidad,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@columna,@RowUnidad,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@columnaMoney,@RowSubtotal,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@columna,@RowMoneda,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@cierreFila)							

						END 
						ELSE 
						BEGIN 
							
							SELECT @IdPedido1 = IdPedido
							FROM @Productos WHERE Id=@RowId

							SET @PreTabla = CONCAT(@PreTabla,@fila,@columnaProveedor,'"<b>No. Pedido: ',ISNULL(@RowPedidoGral,''),'</b><br/><b>Proveedor: </b>',@RowObjetivoPedido,'<br/><b>Contrato: </b>',@RowContrato,@cierreColumna,@cierreFila)
							SET @PreTabla = CONCAT(@PreTabla,@fila)
							SET @PreTabla = CONCAT(@PreTabla,@columna,@RowDescripcion,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@columnaMoney,@RowPrecioUnitario,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@columnaMoney,@RowCantidad,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@columna,@RowUnidad,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@columnaMoney,@RowSubtotal,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@columna,@RowMoneda,@cierreColumna)
							SET @PreTabla = CONCAT(@PreTabla,@cierreFila)

						END 
						
						SET @RowId = @RowId+1 
					END 

					SET @PreTabla = CONCAT(@PreTabla,@cierreTabla)

					select   @SumTotalPedido= '$' + CONVERT(VARCHAR, CONVERT(VARCHAR, CAST(ISNULL(SUM(Subtotal),0)  AS MONEY), 1))
					from @Productos 

					/*HACER TABLA DE TOTAL DE PEDIDO*/
					SET @TablaHTMLTotal = CONCAT(@TablaHTMLTotal,@tablaTotal,@totalFila)
					SET @TablaHTMLTotal = CONCAT(@TablaHTMLTotal,@totalColumna,'Total Pedido: ', @cierretotalColumna)
					SET @TablaHTMLTotal = CONCAT(@TablaHTMLTotal,@totalColumna,@SumTotalPedido,@cierretotalColumna)
					SET @TablaHTMLTotal = CONCAT(@TablaHTMLTotal,@totalColumna,@Moneda,@cierretotalColumna)
					SET @TablaHTMLTotal = CONCAT(@TablaHTMLTotal,@cierreFila,@cierretablaTotal)

					SET @PreTabla = CONCAT(@PreTabla,@TablaHTMLTotal)

					SET  @HTML= REPLACE(@HTML,'##TABLA_PEDIDOS##',ISNULL(@PreTabla,''))
					
					/*GUARDAR ENVIO DEL CORREO*/
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
								@CorreoAprobador,        -- Para - varchar(500)
								@Asunto,        -- Asunto - varchar(250)
								@HTML,        -- Mensaje - text
								GETDATE(),--@FechaProgramada, -- FechaProgramadaEnvio - datetime
								0,      -- Enviada - bit
								NULL, -- FechaEnvio - datetime
								1,-- CTE @IdUsuario,         -- CreadoPor - int
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
								19, -- CTE IdCorreo - int
								CONCAT(CAST(ISNULL(@IdOperacion,0) AS NVARCHAR(MAX)),' - Aprobación de Pedido de Solicitud Pedido #',CAST(ISNULL(@SolicitudPedidoId,0) AS nvarchar(MAX)),' Versión #',CAST(ISNULL(@VersionAprobacion,0) AS nvarchar(MAX)),' -->(SP: Mobile_EnviarNotificacionAprobacionPedido)'),  -- IdIdentificacion - int
								@UsuarioActualId,
								GETDATE()
							);


					END 
					
				END

		END

        
	END
 END;
