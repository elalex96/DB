USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_EnvioAprobacionFactura'
)
    DROP PROCEDURE SP_FI_EnvioAprobacionFactura;
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_EnvioAprobacionFactura]    Script Date: 01/10/2020 17:14:56 ******/
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28/09/2020>
-- Description:	<Envio de factura, creacion de la operacion y tareas de aprobacion y envio de correos>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 21/07/2025
-- Description:	Se retorna lista de correos para envio mediante SDK
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EnvioAprobacionFactura] --3499,670,2338
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdProveedor INT,
	@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #TemporalCorreosUsuario (  
		Para VARCHAR(500),  
		Asunto VARCHAR(500),  
		Mensaje NVARCHAR(MAX),  
		De VARCHAR(200),
		CreadoPor INT
	);  

	DECLARE @CorreoNotificaciones NVARCHAR(MAX);
	DECLARE @DESCRIPCION_HISTORIAL NVARCHAR(MAX);
	DECLARE @ID_ESTATUS_FLUJO INT = 1;
	DECLARE @ID_ESTATUS_OPERACION INT = 1;
	DECLARE @ID_OPERACION INT;
	DECLARE @ID_FLUJO_APROBACION INT;
	DECLARE @NOMBRE_APROBADOR NVARCHAR(200);
	DECLARE @CORREO_APROBADOR NVARCHAR(200);
	DECLARE @CONT INT;
	DECLARE @IDNOTIFICACION INT;
	DECLARE @CONTTOTAL INT;
	DECLARE @ID_TIPO_FLUJO INT;
	DECLARE @PLANTILLA_CORREO NVARCHAR(MAX);
	DECLARE @PLANTILLA_ASUNTO NVARCHAR(MAX);
	DECLARE @DominioProcura NVARCHAR(500) = (SELECT URL FROM TA_Dominios WHERE IdDominio = 2) --> CTE DOMINIO PROCURA
	DECLARE @NOMBRE_CONTRATO NVARCHAR(MAX) = (SELECT TOP 1 C.NumeroContrato + ' - ' + AC.NombreAreaContractual AS NombreContrato
													FROM dbo.MM_AceptacionPedido AP
													LEFT JOIN dbo.MM_Pedido P 
														ON AP.IdPedido = P.IdPedido
													LEFT JOIN Adinco.dbo.CO_Contrato C 
														ON P.IdContrato = C.IdContrato 
													LEFT JOIN Adinco.dbo.CO_AreaContractual AC 
														ON C.IdAreaContractual =  AC.IdAreaContractual
													WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);

	DECLARE @TABLE_APROBADORES TABLE(
		ID INT IDENTITY(1,1), 
		IdAprobador INT, 
		IdSecuencia INT, 
		Nombre NVARCHAR(200), 
		Correo NVARCHAR(200));
	DECLARE @ID_OPERADORA INT = ( SELECT IdProveedor 
								 FROM dbo.MM_AceptacionPedido
								 WHERE IdAceptacionPedido = @IdAceptacionPedido);
	DECLARE @ID_ACEPTACION_FACTURA int = (SELECT IdAceptacionFactura 
										  FROM MM_AceptacionFactura 
										WHERE IdAceptacionPedido = @IdAceptacionPedido);
	
	--SE ACTUALIZA EL ESTATUS DE LA APROBACION DE FACTURA(EN APROBACION)
	UPDATE MM_AceptacionFactura 
	SET [IdEstatusXML] = 1,
	[IdEstatusPDF] = 1,
	[ModificadoPor]  = @IdUsuario,
	[ModificadoEl] = getdate()
	WHERE IdAceptacionFactura = @ID_ACEPTACION_FACTURA;

	-- se valida si el proveedor es de DEA
	IF EXISTS (SELECT 1 FROM dbo.DEA_Proveedor WHERE IdProveedor = @ID_OPERADORA)
	BEGIN
			-- consultamos el flujo de aprobacion de fatura relacionado con el centro de costo de la requisicion
			SET @ID_FLUJO_APROBACION = (SELECT TOP 1 
											RCFA.IdFlujoFactura 
										FROM dbo.MM_SolicitudPedido SP
										LEFT JOIN dbo.MM_Pedido P 
											ON SP.IdSolicitudPedido = P.IdSolicitudPedido
										LEFT JOIN dbo.MM_AceptacionPedido AP 
											ON  P.IdPedido = AP.IdPedido
										LEFT JOIN dbo.MM_SolicitudPedidoDetalle SPD
											ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
										LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL
											ON SPD.IdSolicitudPedidoDetalle = SPDL.IdSolicitudPedidoDetalle
										LEFT JOIN dbo.RelacionCentroCostoFlujoAprob RCFA 
											ON SPDL.IdCentroCosto = RCFA.IdCentroCosto
										WHERE AP.IdAceptacionPedido = @IdAceptacionPedido 
											AND RCFA.IdFlujoFactura IS NOT NULL
											AND RCFA.Activo = 1
										GROUP BY RCFA.IdFlujoFactura,RCFA.IdCentroCosto);--1445

		   
	END
	ELSE
	BEGIN
			--CONSULTAMOS EL FLUJO DE APROBACION DE FACTURA PRETERMINADO DE LA OPERADORA
	    	SET @ID_FLUJO_APROBACION = (SELECT TOP 1 
											FT.IdFlujoTarea
										  FROM MM_AceptacionFactura AS AF
										  INNER JOIN MM_AceptacionPedido AS AP 
											ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
										  INNER JOIN MM_Pedido   AS P 
											on AP.IdPedido = P.IdPedido
										  INNER JOIN S_Proveedor AS PR 
											ON  P.IdProveedorCompras = PR.IdProveedor
										  INNER JOIN TA_FlujoTarea AS FT 
											ON P.IdProveedorCompras = FT.IdProveedor
										  WHERE AP.IdAceptacionPedido = @IdAceptacionPedido 
											  AND FT.IdTipoOperacion = 10 
											  AND FT.Activo=1 
											  AND FT.Predeterminado=1);
	END;

	--Agregar Operación Si IdFlujoTarea =  0 Es una operación que no tiene flujo de tarea
	IF ISNULL(@ID_FLUJO_APROBACION,0) = 0
	BEGIN

		SET @ID_ESTATUS_OPERACION = 9;
		SET @ID_ESTATUS_FLUJO = NULL;
		SET @ID_FLUJO_APROBACION = NULL;

	END;
	    --SE VALIDA LA INEXISTENCIA DE LA OPERACION PARA ESTA FACTURA
	SET @ID_OPERACION = (SELECT TOP 1 
								IdOperacion
							FROM dbo.TA_Operacion 
							WHERE IdDocumento = @ID_ACEPTACION_FACTURA 
								AND IdTipoOperacion = 10
								AND IdProveedor = @IdProveedor);

	IF ISNULL(@ID_OPERACION,0) = 0
	BEGIN

			INSERT INTO dbo.TA_Operacion
			(
			    IdDocumento,
			    IdTipoOperacion,
			    IdFlujoTarea,
			    IdEstatusOperacion,
			    IdEstadoFlujo,
			    IdProveedor,
			    IdAsignador,
			    FechaRegistro,
				IsMercadeo
			)
			VALUES
			(   @ID_ACEPTACION_FACTURA,          -- IdDocumento - int
			    10,          -- IdTipoOperacion - int
			    @ID_FLUJO_APROBACION,          -- IdFlujoTarea - int
			    @ID_ESTATUS_OPERACION,          -- IdEstatusOperacion - int
			    @ID_ESTATUS_FLUJO,          -- IdEstadoFlujo - int
			    @IdProveedor,          -- IdProveedor - int
			    @IdUsuario,          -- IdAsignador - int
			    GETDATE(),  -- FechaRegistro - datetime
				1
			  );


			SET @ID_OPERACION = SCOPE_IDENTITY();

			SET @DESCRIPCION_HISTORIAL = 'El Usuario' + (SELECT Nombre FROM S_USuario WHERE IdUsuario = @IdUsuario)+ ' ha registrado la Tarea de Tipo ' + (SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion = 10);

			INSERT INTO dbo.TA_HistorialFlujoTarea
			(
			    Descripcion,
			    IdOperacion,
			    Fecha,
			    IdEstadoFlujo
			)
			VALUES
			(   @DESCRIPCION_HISTORIAL,       -- Descripcion - nvarchar(max)
			    @ID_OPERACION,         -- IdOperacion - int
			    GETDATE(), -- Fecha - datetime
			    1          -- IdEstadoFlujo - int
			 );

			IF ISNULL(@ID_FLUJO_APROBACION,0) <> 0
	BEGIN
		
		--CONSULTA DE LOS APROBADORES DE LAS TAREAS
		INSERT INTO @TABLE_APROBADORES
		(
		    IdAprobador,
		    IdSecuencia,
		    Nombre,
		    Correo
		)
		SELECT
			US.IdUsuario,
			APR.NoSecuencia,
			US.Nombre,
			US.Correo
		FROM dbo.TA_Aprobador AS APR
			JOIN dbo.S_Usuario AS US 
				ON APR.IdUsuario = US.IdUsuario
				AND US.Activo = 1
		WHERE APR.IdFlujoTarea = @ID_FLUJO_APROBACION
		GROUP BY US.IdUsuario,
                 APR.NoSecuencia,
                 US.Nombre,
                 US.Correo
		ORDER BY APR.NoSecuencia ASC;

		SET @ID_TIPO_FLUJO = (SELECT IdTipoFlujo FROM dbo.TA_FlujoTarea WHERE IdFlujoTarea = @ID_FLUJO_APROBACION);

		--CREACION DE LAS TAREAS DE LOS APROBADORES
		INSERT INTO dbo.TA_Tarea
		(
			NombreTarea,
			IdAprobador,
			IdEstatus,
			FechaRegistro,
			Activo,
			NoSecuencia,
			IdOperacion
		)
		SELECT 
			'Aprobación de Factura',
			TAP.IdAprobador,
			1,
			GETDATE(),
			1,
			TAP.IdSecuencia,
			@ID_OPERACION
		FROM @TABLE_APROBADORES AS TAP;

		--ENVIO DE LOS CORREOS DE APROBACION
		IF @ID_TIPO_FLUJO = 1--FLUJO SERIAL
		BEGIN
		    
			SET @CONT = 1;
			SET @CONTTOTAL = 1;-- SOLO SE LE ENVIARA AL PRIMERO

		END

		IF @ID_TIPO_FLUJO = 2--FLUJO PARALELO
		BEGIN
		    
			SET @CONT = 1;
			SET @CONTTOTAL = (SELECT COUNT(1) FROM @TABLE_APROBADORES);--SE ENVIA A TODOS

		END
		
		SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
									FROM TA_Correo AS C
										INNER JOIN TA_CorreoServidor AS S
											ON C.IdServidor = S.IdServidor
									WHERE IdCorreo = 37) --> CTE NUMERO CORREO (TA_Correo)

		WHILE @CONT <= @CONTTOTAL
		BEGIN
			SET @NOMBRE_APROBADOR = (SELECT Nombre FROM @TABLE_APROBADORES WHERE ID = @CONT);
			SET @CORREO_APROBADOR = (SELECT Correo FROM @TABLE_APROBADORES WHERE ID = @CONT);
		    SET @PLANTILLA_CORREO = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 37);
			SET @PLANTILLA_ASUNTO = (SELECT Asunto FROM dbo.TA_Correo WHERE IdCorreo = 37);

			SET @PLANTILLA_ASUNTO = REPLACE(@PLANTILLA_ASUNTO,'##NUMERO_OPERACION##', CAST(@IdAceptacionPedido AS NVARCHAR));
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'##NUMERO_OPERACION##', CAST(@IdAceptacionPedido AS NVARCHAR));
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'##NOMBRE_USUARIO##', ISNULL(@NOMBRE_APROBADOR,''));
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'#CONTRATO#', ISNULL(@NOMBRE_CONTRATO,''));
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'##ANIO_ACTUAL##', YEAR(GETDATE()));
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'##TIPO_OPERACION##', 'Aprobación de Factura');
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'##URL_TAREA##', ISNULL(@DominioProcura,'')+'02Proveedores/RecepcionVentanillaDetalle.aspx?aceptacion=' + CAST(@IdAceptacionPedido AS NVARCHAR));


			INSERT INTO #TemporalCorreosUsuario (   
			Para,
            Asunto,
            Mensaje,                                       
            CreadoPor
            ) 			
			VALUES
			(	
				@CORREO_APROBADOR,        -- Para - varchar(1000)
				@PLANTILLA_ASUNTO,        -- Asunto - varchar(500)
				@PLANTILLA_CORREO,        -- Mensaje - text	
				@IdUsuario
			);
						
			INSERT INTO dbo.TA_BitacoraCorreo
			(
					IdDocumento,
					Detalle,
					Correo,
					Enviado,
					FechaEnvio,
					IdUsuarioEnvio,
					IdProveedorEnvio,
					IdUsuarioReceptor
			)
			VALUES
			(   @IdAceptacionPedido,         -- IdDocumento - int
				@PLANTILLA_ASUNTO,       -- Detalle - nvarchar(max)
				@CORREO_APROBADOR,       -- Correo - nvarchar(350)
				1,      -- Enviado - bit
				GETDATE(), -- FechaEnvio - datetime
				0,         -- IdUsuarioEnvio - int
				0,         -- IdProveedorEnvio - int
				0          -- IdUsuarioReceptor - int
			);

			SET @CONT = @CONT + 1;

		END

	END;
	END;

	SELECT 
	Para,
	Asunto,
	Mensaje,
	CreadoPor
	FROM #TemporalCorreosUsuario
	 
END
