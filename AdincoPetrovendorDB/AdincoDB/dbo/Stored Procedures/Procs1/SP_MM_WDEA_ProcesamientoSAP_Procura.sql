USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_WDEA_ProcesamientoSAP_Procura]    Script Date: 10/09/2021 10:06:01 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/092021
-- Description:	Procesamiento Interfaz SAP-Procura
-- =============================================
ALTER PROCEDURE [dbo].[SP_MM_WDEA_ProcesamientoSAP_Procura]
	-- Add the parameters for the stored procedure here
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
			@IDBITACORA INT;

	SELECT 
		ROW_NUMBER() over( order by PD.PURCHASING_DOCUMENT desc) as RN,
		PD.PURCHASING_DOCUMENT,
		PD.IDCONTRATO
	INTO #PENDIENTES_PROCESAR
	FROM WDEA_PurchasingDocumentsImportados AS PD
	JOIN PendientesProcesarProcura_WSDEA AS PP ON PD.IdBitacora = PP.IdBitacora 
		AND ISNULL(PP.Procesado,0) = 0 --PENDIENTE DE PROCESAR
	GROUP BY PD.PURCHASING_DOCUMENT,
			PD.IDCONTRATO;

	SET @CONTTOTAL = (SELECT COUNT(RN) FROM #PENDIENTES_PROCESAR);

	WHILE @CONT <= @CONTTOTAL
	BEGIN

		SELECT
			@PURCHASING = PURCHASING_DOCUMENT,
			@CONTRATO = IDCONTRATO
		FROM #PENDIENTES_PROCESAR;

		SET @IDBITACORA = (SELECT TOP 1 IdBitacora FROM WDEA_PurchasingDocumentsImportados WHERE PURCHASING_DOCUMENT = @PURCHASING AND IDCONTRATO = @CONTRATO);

		EXEC SP_MM_WDEA_NuevaSolicitudPedidoAutomatica_SAP @PURCHASING,
															@CONTRATO,
															@IDBITACORA;

		UPDATE PendientesProcesarProcura_WSDEA
		SET Procesado = 1
		WHERE IdBitacora = @IDBITACORA;

		SET @CONT = @CONT + 1;

	END

	SELECT @CONT AS PROCESADOS;


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
		'SE PROCESARON ' + CAST((@CONT - 1) AS NVARCHAR) + ' PEDIDO(S).',
		NULL,
		NULL
	);

END
