-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/02/2023
-- Description:	consultar los documentos de soporte para aceptaciones
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_DescargaArchivosSoporteProcura] --'2023-02-01','2023-02-28',10038,21
	-- Add the parameters for the stored procedure here
	@FechaInicio DATE,
	@FechaFin DATE,
	@IdContrato INT,
	@IdSolicitud INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #ARCHIVOS_ADINCO(
		Identificador NVARCHAR(1000),
		Bucket NVARCHAR(500),
		Carpeta NVARCHAR(1000)
	)

	CREATE TABLE #ARCHIVOS(
		IdDocumento INT,
		NombreDocumento NVARCHAR(1000),
		Comentario NVARCHAR(1000),
		CreadoEl DATETIME,
		Carpeta NVARCHAR(1000),
		Extension NVARCHAR(10),
		Identificador NVARCHAR(1000),
		Bucket NVARCHAR(500),
		Mime NVARCHAR(1000),
		IdAceptacionPedido INT
	); 

	DECLARE @IdDocumentoFieldTicket INT = (SELECT IdTipoDocumento FROM S_TipoDocumento (NOLOCK) WHERE NombreTipoDocumento = 'FIELD TICKET'),
		    @IdDocumentoProforma INT = (SELECT IdTipoDocumento FROM S_TipoDocumento (NOLOCK) WHERE NombreTipoDocumento = 'PROFORMA');
	DECLARE @ID_TIPO INT = (SELECT IdTipoDocumento FROM S_TipoDocumento (NOLOCK) WHERE NombreTipoDocumento = 'Reporte' );

	INSERT INTO #ARCHIVOS
	SELECT   
		AD.[IdDocumento], 
		AD.[NombreDocumento], 
		AD.[Comentario], 
		D.CreadoEl,
		D.[Carpeta],
		ISNULL(D.[Extension],RIGHT(AD.[NombreDocumento], 4)) AS 'Extension',
		D.Identificador,
		d.Bucket AS Bucket,
		D.Mime,
		AP.IdAceptacionPedido
    FROM  [dbo].[MM_AceptacionDocumento] AS AD (NOLOCK)
		JOIN  [dbo].[MM_AceptacionPedido] AS AP (NOLOCK)
                ON AD.[IdAceptacionDocumento] = AP.[IdAceptacionPedido] 
				AND AP.Creado BETWEEN @FechaInicio AND @FechaFin
				AND AP.Activo = 1
				AND ISNULL(AP.IdEliminado,0) = 0
				AND AD.[IdDocumento] IS NOT NULL
				AND AD.Activo = 1
		JOIN MM_Pedido AS P (NOLOCK)
			ON AP.IdPedido = P.IdPedido
			AND P.IdContrato = @IdContrato
		INNER JOIN  [dbo].[S_Documento_S3] AS D (NOLOCK)
				ON	AD.[IdDocumento] = D.[IdDocumento] 
     WHERE AD.[IdDocumento] IS NOT NULL
          AND AD.Activo = 1
	UNION--PROFORMA
	SELECT   
		D.IdDocumento, 
		D.NombreDocumento, 
		'' AS Comentario, 
		D.CreadoEl,
		D.[Carpeta],
		ISNULL(D.[Extension],RIGHT(D.NombreDocumento, 4)) AS 'Extension',
		D.Identificador,
		d.Bucket AS Bucket,
		D.Mime,
		AP.IdAceptacionPedido
    FROM [dbo].[MM_AceptacionPedido] AS AP (NOLOCK)
		JOIN MM_Pedido AS P (NOLOCK)
			ON AP.IdPedido = P.IdPedido
			AND P.IdContrato = @IdContrato
			AND AP.Creado BETWEEN @FechaInicio AND @FechaFin
			AND AP.Activo = 1
			AND ISNULL(AP.IdEliminado,0) = 0
		JOIN MM_SolicitudAceptacionPedido AS SAP (NOLOCK)
			ON AP.IdPedido = SAP.IdPedido
			AND AP.IdAceptacionPedido = SAP.IdAceptacionPedido
			AND SAP.Activo = 1
		JOIN  [dbo].[S_Documento_S3] AS D (NOLOCK)
				ON	SAP.IdSolicitudAceptacionPedido = D.IdDocumentoTabla
				AND D.IdTipoDocumento = @IdDocumentoProforma
				AND D.Activo = 1
	UNION--FIELD TICKET
	SELECT   
		D.IdDocumento, 
		D.NombreDocumento, 
		'' AS Comentario, 
		D.CreadoEl,
		D.[Carpeta],
		ISNULL(D.[Extension],RIGHT(D.NombreDocumento, 4)) AS 'Extension',
		D.Identificador,
		d.Bucket AS Bucket,
		D.Mime,
		AP.IdAceptacionPedido
    FROM [dbo].[MM_AceptacionPedido] AS AP (NOLOCK)
		JOIN MM_Pedido AS P (NOLOCK)
			ON P.IdPedido = AP.IdPedido
			AND P.IdContrato = @IdContrato
			AND AP.Creado BETWEEN @FechaInicio AND @FechaFin
			AND AP.Activo = 1
			AND ISNULL(AP.IdEliminado,0) = 0
		JOIN MM_SolicitudAceptacionPedido AS SAP (NOLOCK)
			ON AP.IdPedido = SAP.IdPedido
			AND AP.IdAceptacionPedido = SAP.IdAceptacionPedido
			AND SAP.Activo = 1
		JOIN  [dbo].[S_Documento_S3] AS D (NOLOCK)
				ON	SAP.IdSolicitudAceptacionPedido = D.IdDocumentoTabla
				AND D.IdTipoDocumento = @IdDocumentoFieldTicket
				AND D.Activo = 1;

	INSERT INTO #ARCHIVOS_ADINCO
	SELECT
		UUIDAmazon,
		Bucket,
		Folder
	FROM Adinco..AWS_Documentos (NOLOCK)
	WHERE UUIDAmazon IN (SELECT Identificador FROM #ARCHIVOS)

	SELECT
		AP.IdDocumento,
		AP.NombreDocumento,
		AP.Comentario,
		AP.CreadoEl,
		ISNULL(AA.Carpeta,AP.Carpeta) AS Carpeta,
		AP.Extension,
		AP.Identificador,
		CASE 
			WHEN ISNULL(AA.Bucket,'') != '' THEN AA.Bucket
			ELSE AP.Bucket
		END AS Bucket,
		AP.Mime,
		AP.IdAceptacionPedido
	FROM #ARCHIVOS AS AP
	LEFT JOIN #ARCHIVOS_ADINCO AS AA
		ON AP.Identificador = AA.Identificador;

END