-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/06/2021
-- Description:	Archivos cargados de las instancias de entregables, última versión y no reachazados.
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ArchivosPozos] 
	-- Add the parameters for the stored procedure here
	@IdContrato            INT, 
	@IdUsuario             INT, 
	@IDINSTALACION		   INT,
	@Page INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON

         -- Insert statements for procedure here
	DECLARE @NombrePozo VARCHAR(200);
	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;

	SELECT @NombrePozo = NOMBREINSTALACION
	FROM CO_INSTALACION
	WHERE IDINSTALACION = @IDINSTALACION;

	--SET @AllRecords = (SELECT COUNT(1)
	--					FROM
	--						EN_ENTREGABLE   E
	--					JOIN
	--						EN_CONTRATOENTREGABLE   CE
	--						ON  E.IDENTREGABLE = CE.IDENTREGABLE
	--						AND CE.IDCONTRATO   =   @IDCONTRATO
	--						AND E.DocumentoEntregable = 'Perforación del pozo: ' + ltrim(@NombrePozo)
	--					JOIN
	--						EN_INSTANCIASENTREGABLE IE
	--						ON CE.IDCONTRATOENTREGABLE = IE.IDCONTRATOENTREGABLE
	--					JOIN
	--						EN_HistorialAprobacionesLineaTiempo FINR    (NOLOCK)
	--						ON  IE.idInstanciaEntregable    =   FINR.idInstanciaEntregable
	--						AND FINR.idTipoOperacion IN (2,3,4)
	--					JOIN
	--						EN_DocumentoVersion DV
	--						ON  IE.idInstanciaEntregable    =   DV.idInstanciaEntregable
	--						AND FINR.IdLineaTiempo  =   DV.N_version
	--						AND DV.Activo = 1
	--					JOIN
	--						EN_EntregableDocumento ED
	--						ON IE.idInstanciaEntregable =   ED.idInstanciaEntregable);


	--SELECT *,
	--		  @AllRecords AS Records,
	--		  @RecordsByPage AS RecordsByPage
	--	FROM
	--	(
    SELECT DISTINCT
	--	ROW_NUMBER() OVER(PARTITION BY ED.DocumentoEntregableId ORDER BY ED.DocumentoEntregableId DESC) AS R,
		ED.DocumentoEntregableId,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.',ED.NOMBREARCHIVO,LEN(ED.NOMBREARCHIVO)-5), LEN(ED.NombreArchivo)))) AS TipoArchivo,
		CASE
			WHEN NombreArchivo LIKE '%RAP%' THEN 'label label-success'
			WHEN NombreArchivo LIKE '%ACUSE%' THEN 'label label-primary'
			WHEN NombreArchivo LIKE '%FORMATO%' THEN 'label label-danger'
			ELSE 'label label-default'
		END AS TipoArchivoENTSPAN,
		CASE
			WHEN NombreArchivo LIKE '%RAP%' THEN 'RAP'
			WHEN NombreArchivo LIKE '%ACUSE%' THEN 'ACUSE'
			WHEN NombreArchivo LIKE '%FORMATO%' THEN 'FORMATO'
			ELSE 'OTROS'
		END AS TipoArchivoENTTEXT
		--(ROW_NUMBER() OVER(ORDER BY ED.DocumentoEntregableId DESC) - 1) / @RecordsByPage AS _Page
	FROM
		EN_ENTREGABLE   E
	JOIN
		EN_CONTRATOENTREGABLE   CE
		ON  E.IDENTREGABLE = CE.IDENTREGABLE
		AND CE.IDCONTRATO   =   @IDCONTRATO
		AND E.DocumentoEntregable = 'Inicio de Perforación del pozo: ' + ltrim(@NombrePozo)
	JOIN
		EN_INSTANCIASENTREGABLE IE
		ON CE.IDCONTRATOENTREGABLE = IE.IDCONTRATOENTREGABLE
	JOIN
		EN_HistorialAprobacionesLineaTiempo FINR    (NOLOCK)
		ON  IE.idInstanciaEntregable    =   FINR.idInstanciaEntregable
		AND FINR.idTipoOperacion IN (2,3,4)
	JOIN
		EN_DocumentoVersion DV
		ON  IE.idInstanciaEntregable    =   DV.idInstanciaEntregable
		AND FINR.IdLineaTiempo  =   DV.N_version
		AND DV.Activo = 1
	JOIN
		EN_EntregableDocumento ED
		ON IE.idInstanciaEntregable =   ED.idInstanciaEntregable
		--) AS R
		-- WHERE R.R = 1 AND R._PAGE = (@Page - 1)
		-- ORDER BY R.DocumentoEntregableId DESC;
END
