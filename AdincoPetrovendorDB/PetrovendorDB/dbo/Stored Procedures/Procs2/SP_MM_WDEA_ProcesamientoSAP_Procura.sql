USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_MM_WDEA_ProcesamientoSAP_Procura
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/092021
-- Description:	Procesamiento Interfaz SAP-Procura
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 26/10/2022
-- Description:	Se evita el reprocesamiento de pedidos ya procesados, eliminación de SELECT INTOS... Petrovendor(#2094)
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_WDEA_ProcesamientoSAP_Procura]
	-- Add the parameters for the stored procedure here.
	@FileName NVARCHAR(MAX),
	@Asunto NVARCHAR(MAX),
	@Destinatario NVARCHAR(MAX),
	@IDBITACORA INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CONT INT = 1,
			@CONTTOTAL INT,
			@PURCHASING NVARCHAR(100),
			@CONTRATO INT,
			@CONT_PROCESADOS INT,
			@MENSAJE_ERORRES NVARCHAR(MAX) = '',
			@MENSAJE_EXITOSOS NVARCHAR(MAX) = '',
			@MENSAJE_FINAL NVARCHAR(MAX) = '',
			@CONT_ERRORES INT,
			@IdNotificacion INT,
			@HTML NVARCHAR(MAX),
			@HORADIA INT = (DATEPART(hour,GETDATE())),
			@ENVIO INT,
			@IdPedido INT,
			@REGISTROSGUARDADOS INT;


	DROP TABLE IF EXISTS #PENDIENTES_PROCESAR
	DROP TABLE IF EXISTS #REGISTROSGUARDADOS
	DROP TABLE IF EXISTS #PROCESADOS
	DROP TABLE IF EXISTS #MENSAJES
	CREATE TABLE #PENDIENTES_PROCESAR
	(
		RN INT,
		PURCHASING_DOCUMENT VARCHAR (300),
		IDCONTRATO INT
	);
	CREATE NONCLUSTERED INDEX ix_tempPurchasingDocument  ON #PENDIENTES_PROCESAR (PURCHASING_DOCUMENT);
	CREATE NONCLUSTERED INDEX ix_tempIdContrato  ON #PENDIENTES_PROCESAR (IDCONTRATO);
	CREATE TABLE #REGISTROSGUARDADOS
	(
		Purchasing_Document VARCHAR(300)
	);
	CREATE INDEX IX_Purchasing_Document ON #REGISTROSGUARDADOS(Purchasing_Document);
	CREATE TABLE #PROCESADOS(
		IdPedidoADINCO INT,
		PURCHASING_DOCUMENT VARCHAR(300),
		IDCONTRATO INT,
		IdBitacora INT
	);
	CREATE TABLE #MENSAJES
	(
		Mensaje VARCHAR(MAX)
	);
	IF @HORADIA <= 13
	BEGIN 
		SET @ENVIO = 1;
	END
	ELSE
	BEGIN
		SET @ENVIO = 2;
	END

	
	
	INSERT INTO #PENDIENTES_PROCESAR(
	RN,
	PURCHASING_DOCUMENT,
	IDCONTRATO)
	SELECT 
		ROW_NUMBER() over( order by PD.PURCHASING_DOCUMENT desc) as RN,
		PD.PURCHASING_DOCUMENT,
		PD.IDCONTRATO
	FROM WDEA_PurchasingDocumentsImportados AS PD
	JOIN PendientesProcesarProcura_WSDEA AS PP 
		ON PD.IdBitacora = PP.IdBitacora 
		AND 0 = ISNULL(PP.Procesado,0) --PENDIENTE DE PROCESAR
		AND PD.IdBitacora = @IDBITACORA
	GROUP BY PD.PURCHASING_DOCUMENT,
			PD.IDCONTRATO;

	SET @CONTTOTAL = (SELECT COUNT(RN) FROM #PENDIENTES_PROCESAR);

	WHILE @CONT <= @CONTTOTAL
	BEGIN

		SELECT
			@PURCHASING = PURCHASING_DOCUMENT,
			@CONTRATO = IDCONTRATO
		FROM #PENDIENTES_PROCESAR
		WHERE RN = @CONT;

		EXEC SP_MM_WDEA_NuevaSolicitudPedidoAutomatica_SAP @PURCHASING,
															@CONTRATO,
															@IDBITACORA;

		SET @IdPedido = (SELECT TOP 1 IdPedidoADINCO FROM WDEA_PurchasingDocumentsImportados WHERE IdBitacora = @IDBITACORA AND PURCHASING_DOCUMENT = @PURCHASING);


		SET @CONT = @CONT + 1;

	END

	INSERT INTO #REGISTROSGUARDADOS(Purchasing_Document)
	SELECT
		Purchasing_Document
	FROM WDEA_Layout_T
	WHERE IdBitacoraLectura = @IDBITACORA
	GROUP BY Purchasing_Document;

	SET @REGISTROSGUARDADOS = (SELECT COUNT(1) FROM #REGISTROSGUARDADOS);

	--PROCESADOS
	INSERT INTO #PROCESADOS(IdPedidoADINCO,PURCHASING_DOCUMENT,IDCONTRATO,IdBitacora)
	SELECT
		PD.IdPedidoADINCO,
		PD.PURCHASING_DOCUMENT,
		PD.IDCONTRATO,
		PD.IdBitacora
	FROM #PENDIENTES_PROCESAR AS PP
	JOIN dbo.WDEA_PurchasingDocumentsImportados AS PD
		ON PP.PURCHASING_DOCUMENT = PD.PURCHASING_DOCUMENT COLLATE Modern_Spanish_CI_AS
		AND PP.IDCONTRATO = PD.IDCONTRATO
		AND @IDBITACORA = PD.IdBitacora
	WHERE PD.IdPedidoADINCO IS NOT NULL--YA TIENEN UN PEDIDO EN ADINCO
	GROUP BY PD.IdPedidoADINCO,
				PD.PURCHASING_DOCUMENT,
				PD.IDCONTRATO,
				PD.IdBitacora; 

	--BUSCAR LOS MENSAJES EN CASO DE EXISTAN ERRORES
	INSERT INTO #MENSAJES(Mensaje)
	SELECT 
		B.Mensaje
	FROM WDEA_Bitacora_AdincoSAP AS B 
	WHERE ISNULL(B.IsImportacionExitosa,0) = 0--BIT DE IMPORTACION EXITOSA
	AND B.IdBitacoraLectura = @IDBITACORA;

	SET @CONT_PROCESADOS = (SELECT COUNT(1) FROM #PROCESADOS);
	SET @CONT_ERRORES = (SELECT COUNT(1) FROM #MENSAJES);

	UPDATE PendientesProcesarProcura_WSDEA
	SET Procesado = 1,
	ProcesadoEl = GETDATE()
	WHERE IdBitacora = @IDBITACORA;


	--MENSAJES DE ERRORES
	IF ISNULL(@CONT_ERRORES,0) > 0
	BEGIN
		--SE CONCATENAN TODOS LOS MENSAJES DE ERROR
		SET @MENSAJE_ERORRES = '<ul><li>' +
								(SELECT STUFF(
								(SELECT 'LX '  + Mensaje + ' PXP'
								FROM WDEA_Bitacora_AdincoSAP
								WHERE IdBitacoraLectura = @IDBITACORA
								AND ISNULL(IsImportacionExitosa,0) = 0
								FOR XML PATH('')),
								1, 2, '') As MENSAJES) +
								'</ul>';

		SET @MENSAJE_ERORRES = (REPLACE(@MENSAJE_ERORRES,'LX ','<li>'));
		SET @MENSAJE_ERORRES = (REPLACE(@MENSAJE_ERORRES,' PXP','</li>'));

	END;

	--MENSAJES EXITOSOS
	IF ISNULL(@CONT_PROCESADOS,0) > 0
	BEGIN
		--SE CONCATENAN TODOS LOS PEDIDOS PROCESADOS EXITOSAMENTE
		SET @MENSAJE_EXITOSOS = '<ul><li>' +
								(SELECT STUFF(
									(SELECT 'LX '  + 'Se Generó el Pedido #' +  
													CAST(P.IdPedidoADINCO AS NVARCHAR) + 
													' correspondiente al Purchasing #' + 
													P.PURCHASING_DOCUMENT + ' PXP'
									FROM #PROCESADOS AS P
									FOR XML PATH('')),
									1, 2, '') As MENSAJES) + '<ul>';

		SET @MENSAJE_EXITOSOS = (REPLACE(@MENSAJE_EXITOSOS,'LX ','<li>'));
		SET @MENSAJE_EXITOSOS = (REPLACE(@MENSAJE_EXITOSOS,' PXP','</li>'));


	END;

	--MENSAJE RESUMEN
	SET @MENSAJE_FINAL = ('<br><br>Se Procesó el Archivo ' + 
							@FileName + 
							' con el asunto ' + 
							@Asunto + 
							' enviado por ' + 
							@Destinatario + ' el ' + CONVERT(VARCHAR,GETDATE(),9) + ' con el Número de Procesamiento Interno #' + CAST(@IDBITACORA AS nvarchar) +'. <br><br>' +
							'Se detectaron ' + CAST(ISNULL(@CONTTOTAL,0) AS nvarchar) + ' Purchasing Document(s) Correctos' +
							' de ' + CAST(ISNULL(@REGISTROSGUARDADOS,0) as nvarchar) + ' Purchasing Document(s) en el Documento en total,' + 
							'de los cuales se generaron ' + CAST(ISNULL(@CONT_PROCESADOS,0) AS nvarchar) + ' Pedido(s) en ADINCO.');


	SET @HTML = (SELECT HTML FROM dbo.TA_Correo WHERE Asunto = 'Notificación de Resumen de Lectura de WDEA');

	SET @HTML = (REPLACE(@HTML,'##MENSAJE_GENERAL##',ISNULL(@MENSAJE_FINAL,'')));
	SET @HTML = (REPLACE(@HTML,'##MENSAJE_CORRECTOS##',ISNULL(@MENSAJE_EXITOSOS,'')));
	SET @HTML = (REPLACE(@HTML,'##MENSAJE_ERRORES##',ISNULL(@MENSAJE_ERORRES,'')));
	SET @HTML = (REPLACE(@HTML,'##ANIO_ACTUAL##',YEAR(GETDATE())));

	SET @IdNotificacion = (SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion);

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
	SELECT
			(@IdNotificacion + ROW_NUMBER() over( order by Destinatario desc)), 
			Destinatario, 
			CAST(CAST(GETDATE() AS DATE) AS nvarchar) + ' Reporte de interfase ADINCO SAP' + ' Envió ' + CAST(@ENVIO as nvarchar) + '/2',
			REPLACE(@HTML,'##NOMBRE_USUARIO##',ISNULL(Nombre,'Usuario de ADINCO')), 
			DATEADD(MINUTE, 1, GETDATE()), 
			0, 
			NULL, 
			3, 
			GETDATE(), 
			NULL, 
			NULL,
			'notificaciones@adinco.mx'
	FROM dbo.WDEA_CorreosResumenProcesamiento;

        INSERT INTO dbo.TA_EnvioCorreo 
		(
			IdEnvioAdinco, 
			IdCorreo, 
			IdIdentificacion, 
			EnviadoPor, 
			EnviadoEl
		)
		SELECT
			(@IdNotificacion + ROW_NUMBER() over( order by Destinatario desc)), 
			110, 
			'Notificación Lectura WDEA',
			NULL, 
			GETDATE()
		FROM dbo.WDEA_CorreosResumenProcesamiento;


        --BITACORA DE CORREO
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
		SELECT
			(@IdNotificacion + ROW_NUMBER() over( order by Destinatario desc)), 
			'Notificación Lectura WDEA', 
			Destinatario,
			1,                                            -- Enviado - bit
            GETDATE(),                                    -- FechaEnvio - datetime
            0,                                            -- IdUsuarioEnvio - int
            0,                                            -- IdProveedorEnvio - int
            0   
	FROM dbo.WDEA_CorreosResumenProcesamiento;

	INSERT INTO WDEA_Bitacora_AdincoSAP
	(
		Fecha,
		Mensaje,
		NoConsecutivoProcesamiento,
		IdBitacoraLectura
	)
	VALUES
	(
		GETDATE(),
		'SE PROCESARON ' + CAST((ISNULL(@CONT_PROCESADOS,0)) AS NVARCHAR) + ' PEDIDO(S) DE ' + CAST(@CONTTOTAL AS nvarchar) + ' PURCHASING CORRECTOS.',
		NULL,
		NULL
	);

END
