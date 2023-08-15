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
-- Author:		LUIS DAVID
-- Create date: 26/10/2022
-- Description:	Se agrega espaciado para mejor formato en mensaje de procesamiento
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
BEGIN TRY
    -- Insert statements for procedure here
	DECLARE @CONT INT = 1,
			@CONTTOTAL INT,
			@PURCHASING NVARCHAR(100),
			@CONTRATO INT,
			@CONT_PROCESADOS INT,
			@MENSAJE_ERORRES NVARCHAR(MAX) = '',
			@MENSAJE_EXITOSOS NVARCHAR(MAX) = '',
			@MENSAJE_FINAL NVARCHAR(MAX) = '',
			@IdNotificacion INT,
			@HTML NVARCHAR(MAX),
			@HORADIA INT = (DATEPART(hour,GETDATE())),
			@ENVIO INT,
			@IdPedido INT,
			@REGISTROSGUARDADOS INT,
			@CatidadFilas Int = (select count(1) from WDEA_Layout_T where IdbitacoraLectura = @IDBITACORA),
			@POSAPIncorrectos INT,
			@tableHTML varchar(max);;


	DROP TABLE IF EXISTS #PENDIENTES_PROCESAR
	DROP TABLE IF EXISTS #REGISTROSGUARDADOS
	DROP TABLE IF EXISTS #PROCESADOS
	DROP TABLE IF exists #TablaFinal
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
	CREATE TABLE #TablaFinal
	(
		POSAP varchar(300),
		ESTATUS varchar(300),
		Pedido VARCHAR(300),
		Contrato varchar(300),
		Mensaje varchar(max)
	)
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

	SET @CONT_PROCESADOS = (SELECT COUNT(1) FROM #PROCESADOS);

	UPDATE PendientesProcesarProcura_WSDEA
	SET Procesado = 1,
	ProcesadoEl = GETDATE()
	WHERE IdBitacora = @IDBITACORA;


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
	SET @POSAPIncorrectos = (@REGISTROSGUARDADOS - @CONT_PROCESADOS);
	SET @MENSAJE_FINAL = ('<br><br>Se procesó el correo con el asunto <strong>'+ '"'+
							@Asunto + '</strong>'+ '"'+ ' enviado por <strong>' +
							@Destinatario +'</strong> en <strong>"' +
							CONVERT(VARCHAR,GETDATE(),9)+ '"</strong> <br><br>' + 
							'<em> RESUMEN DE PROCESAMIENTO ('+CAST(@IDBITACORA AS nvarchar)+')</em> <br><br>'+
							'<div> <ul style="text-align: left">'+
								'<li> Se procesaron un total de <strong>'+CAST(@CatidadFilas AS nvarchar)+ '</strong> filas del archivo adjunto <strong>'+ @FileName+'</strong> </li>'+
								'<li> Se identificaron <strong>' + CAST(@REGISTROSGUARDADOS AS nvarchar)+ '</strong> PO de SAP </li>'+
								'<li style="color:Green"> Se generaron <strong>' + CAST(@CONT_PROCESADOS AS nvarchar)+ '</strong> Pedido(s) en ADINCO </li>'+
								'<li style="color:Red"> PO SAP con error: <strong>' + CAST(@POSAPIncorrectos AS nvarchar)+ '</strong></li>'+
							'</ul> </div> <br><br>'

							);
	
	INSERT INTO #TablaFinal
	(POSAP,ESTATUS,Pedido,Contrato,Mensaje)
	SELECT 
		BAS.Purchasing_Document AS 'POSAP',
		CASE WHEN BAS.IsImportacionExitosa = 1
		THEN 'VERDE'
		ELSE 'ROJO' end as 'ESTATUS',
		CASE WHEN BAS.IsImportacionExitosa = 1
		THEN cast(PPC.IdPedidoGeneral AS varchar)
		ELSE 'No se generó pedido en ADINCO' end as 'Pedido',
		CASE WHEN BAS.IsImportacionExitosa = 1
		THEN AC.NombreAreaContractual
		ELSE ' ' end as 'Contrato',
		CASE WHEN BAS.IsImportacionExitosa = 1
		THEN 'Pedido generado exitosamente'
		ELSE Petrovendor.dbo.WDEA_MensajesError_Purchasing(BAS.Purchasing_Document,@IDBITACORA) end as 'Mensaje'
	FROM WDEA_Bitacora_AdincoSAP as BAS
	LEFT JOIN WDEA_PedidosPendientesCorreosConfirmacion AS PPC
		ON BAS.IDBITACORALECTURA = PPC.IDBITACORALECTURA
		and BAS.Purchasing_Document = PPC.Purchasing_Document
	LEFT JOIN WDEA_PurchasingDocumentsImportados AS PDI
		ON BAS.Purchasing_Document = PDI.PURCHASING_DOCUMENT
		AND @IDBITACORA = PDI.IdBitacora
	LEFT JOIN Adinco..CO_Contrato AS C
		ON PDI.IDCONTRATO = C.IdContrato
	LEFT JOIN  ADINCO..CO_AreaContractual AS AC
		ON C.IdAreaContractual = AC.IdAreaContractual
	WHERE 
		BAS.IDBITACORALECTURA = @IDBITACORA
		and 
		BAS.Purchasing_Document is not null


	SET @tableHTML =
	N'<table style="border: 1px solid black">' +
	N'<tr ><th style="background-color: #376eeb ;color:white">PO SAP</th>
	<th style="background-color: #376eeb ;color:white;border: 1px solid black">Estado</th>
	<th style="background-color: #376eeb ;color:white;border: 1px solid black">Pedido ADINCO</th>
	<th style="background-color: #376eeb ;color:white;border: 1px solid black">Contrato</th>
	<th style="background-color: #376eeb ;color:white;border: 1px solid black">Mensaje de interface</th>
	</tr>' +
	CAST ( (
	SELECT 
	'td' = ISNULL(POSAP,' - '),'',
	'td' = ISNULL(ESTATUS,' - '),'',
	'td' = ISNULL(Pedido,' - '),'',
	'td' = ISNULL(Contrato,' - '),'',
	'td' = isnull(Mensaje,' -' ),''
	FROM #TablaFinal
	group by POSAP,
	ESTATUS,
		Pedido,
		Contrato,
		Mensaje 
	FOR XML PATH('tr'), TYPE
	) AS NVARCHAR(MAX) ) +
	N'</table>'


	SET @tableHTML = (REPLACE(@tableHTML,'<td>VERDE</td>','<td style="background-color:green;border: 1px solid black"> </td>'));
	SET @tableHTML = (REPLACE(@tableHTML,'<td>ROJO</td>','<td style="background-color:red;border: 1px solid black"> </td>'));
	SET @tableHTML = (REPLACE(@tableHTML,'<td>No se generó pedido en ADINCO</td>','<td style="color:red;border: 1px solid black">No se generó pedido en ADINCO</td>'));
	SET @tableHTML = (REPLACE(@tableHTML,'<td>','<td style="border: 1px solid black">'));
	SET @HTML = (SELECT HTML FROM dbo.TA_Correo WHERE Asunto = 'Notificación de Resumen de Lectura de WDEA');
	SET @HTML = (REPLACE(@HTML,'##MENSAJE_GENERAL##',ISNULL(@MENSAJE_FINAL,'')));
	SET @HTML = (REPLACE(@HTML,'##MENSAJE_CORRECTOS##',ISNULL('','')));
	SET @HTML = (REPLACE(@HTML,'##MENSAJE_ERRORES##',ISNULL(@tableHTML,'')));
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
END TRY
BEGIN CATCH
	
	insert into WDEA_Bitacora_AdincoSAP(
		Fecha,					Mensaje,			NoConsecutivoProcesamiento,	
		IdBitacoraLectura,		IsImportacionExitosa)
	  SELECT
		GETDATE(),				ERROR_MESSAGE(),	ERROR_LINE(),
		@IDBITACORA,		0;

END CATCH;
END
