-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <06/08/2022>
-- Description:	<Consulta de reportes que se descargaran entre 2 fechas por contrato>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultaReportesEvaluacionPorFechasContrato]
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@fechainicio DATETIME,
	@fechafin DATETIME,
	@Page INT,
	@Buscar NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;

	CREATE TABLE #OFERTAS_AGRUPADAS (IdSolicitudPedido INT);

		--OBTENER LAS OFERTAS AGRUPADAS YA QUE POR SOLPED PUEDEN EXISITIR N
		INSERT INTO #OFERTAS_AGRUPADAS
		SELECT
			SP.IdSolicitudPedido
		FROM MM_PeticionOferta AS PO
			JOIN MM_SolicitudPedido AS SP ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		WHERE SP.IdContrato = @IdContrato
		AND SP.FechaAlta BETWEEN @fechainicio AND @fechafin
		AND PO.IdPeticionOferta IS NOT NULL
		GROUP BY SP.IdSolicitudPedido

		--OBTENER LAS COMPARATIVAS YA QUE PUEDEN SER N ASOCIADAS A UNA SOLA
		SELECT
			C.IdComparativa,
			C.IdSolicitudPedido
		INTO #COMPARATIVAS_AGRUPADAS
		FROM AX_Comparativa AS C
		JOIN #OFERTAS_AGRUPADAS AS OA ON C.IdSolicitudPedido = OA.IdSolicitudPedido
		WHERE IdContrato = @IdContrato
		AND OA.IdSolicitudPedido IS NOT NULL
		GROUP BY C.IdComparativa,
				C.IdSolicitudPedido;

	IF @Page = 0--DESCARGA DE ARCHIVOS
	BEGIN

		SELECT
			O.IdSolicitudPedido,
			C.IdComparativa,
			SP.FechaAlta AS FechaAltaSolicitudPedido,
			CONCAT('TablaComparativa_',ISNULL(C.IdComparativa,CAST(SP.IdSolicitudPedido AS VARCHAR)),'.pdf') AS Documento
		FROM #OFERTAS_AGRUPADAS AS O
			LEFT JOIN #COMPARATIVAS_AGRUPADAS AS C ON O.IdSolicitudPedido = C.IdSolicitudPedido
			JOIN MM_SolicitudPedido AS SP ON O.IdSolicitudPedido = SP.IdSolicitudPedido

	END
	ELSE--GRID
	BEGIN

		SET @AllRecords = (SELECT
							COUNT(1)
						FROM #OFERTAS_AGRUPADAS AS O
							LEFT JOIN #COMPARATIVAS_AGRUPADAS AS C ON O.IdSolicitudPedido = C.IdSolicitudPedido
						);

		SELECT *,
			@AllRecords AS Records,
			@RecordsByPage AS RecordsByPage
		FROM
		(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY SP.FechaAlta ORDER BY SP.FechaAlta DESC) AS R,
			O.IdSolicitudPedido,
			C.IdComparativa,
			SP.FechaAlta AS FechaAltaSolicitudPedido,
			CONCAT('TablaComparativa_',ISNULL(C.IdComparativa,CAST(SP.IdSolicitudPedido AS VARCHAR)),'.pdf') AS Documento,
			(ROW_NUMBER() OVER(ORDER BY SP.FechaAlta DESC) - 1) / @RecordsByPage AS _Page
		FROM #OFERTAS_AGRUPADAS AS O
			LEFT JOIN #COMPARATIVAS_AGRUPADAS AS C ON O.IdSolicitudPedido = C.IdSolicitudPedido
			JOIN MM_SolicitudPedido AS SP ON O.IdSolicitudPedido = SP.IdSolicitudPedido
		) AS R
		WHERE R.R = 1 AND
				R._Page = (@Page - 1)
		ORDER BY R.FechaAltaSolicitudPedido DESC;

	END

END
