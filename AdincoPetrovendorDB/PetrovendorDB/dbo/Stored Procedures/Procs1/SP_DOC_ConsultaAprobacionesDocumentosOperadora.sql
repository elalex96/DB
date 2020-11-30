-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <25/07/2020>
-- Description:	<Consulta de la lista de documentos enviados por sus proveedores pendientes de enviar>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DOC_ConsultaAprobacionesDocumentosOperadora] --420,1,'',2199
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@Page INT,
	@Buscar NVARCHAR(MAX),
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;

	SET @AllRecords = (SELECT 
							COUNT(1)
						FROM dbo.MM_AceptacionDocumento_Proveedor AS ADP
							LEFT JOIN dbo.TA_Operacion AS OP 
								ON OP.IdDocumento = ADP.IdAceptacionDocumento
								AND OP.IdTipoOperacion = 18
							LEFT JOIN dbo.S_Proveedor AS PR
								ON PR.IdProveedor = ADP.IdProveedor
							LEFT JOIN dbo.TA_Estatus AS ES
								ON ES.IdEstatus = ADP.IdEstatus
							LEFT JOIN dbo.S_DocumentoPlantillaOperadora AS DPO
								ON DPO.IdDocumentoPlantilla = ADP.IdTipoDocumentoOperadora
							LEFT JOIN dbo.TA_FlujoTarea AS FT
								ON FT.IdFlujoTarea = OP.IdFlujoTarea
						WHERE OP.IdProveedor = @IdProveedor
							AND ADP.IdOperadora = @IdProveedor
							AND ADP.Activo = 1
							AND DPO.Activo = 1
							AND DPO.NombreDocumentoObligatorio LIKE '%' + @Buscar + '%');
	
	SELECT *,
		  @AllRecords AS Records,
		  @RecordsByPage AS RecordsByPage
	FROM
	(
	SELECT 
		ROW_NUMBER() OVER(PARTITION BY ADP.IdAceptacionDocumento ORDER BY ADP.IdAceptacionDocumento DESC) AS R,
		ADP.IdAceptacionDocumento,
		PR.RazonSocial AS Proveedor,
		ES.Nombre AS Estatus,
		ADP.CreadoEl AS FechaEnvioDoc,
		DPO.NombreDocumentoObligatorio,
		ADP.IdDocumentoS3Proveedor,
		FT.IdTipoFlujo,
		OP.IdOperacion,
		CAST(CASE
			WHEN FT.IdTipoFlujo = 2 THEN
										CASE
											WHEN
												ISNULL((SELECT TOP 1--SI ES PARALELO SE VALIDA AL USUARIO APROBADOR DENTRO DEL FLUJO
													IdAprobador
												FROM dbo.TA_Tarea
												WHERE FechaCambioEstatus IS NULL
													AND IdEstatus = 1
													AND IdAprobador = @IdUsuario
													AND IdOperacion = OP.IdOperacion),0) = @IdUsuario THEN 1
											ELSE 0
										END
			WHEN FT.IdTipoFlujo = 1 THEN
										CASE 
											WHEN 
												ISNULL((SELECT TOP 1
													IdAprobador
												FROM dbo.TA_Tarea
												WHERE FechaCambioEstatus IS NULL
													AND IdEstatus = 1
													AND IdOperacion = OP.IdOperacion
												ORDER BY NoSecuencia ASC),0) = @IdUsuario THEN 1
											ELSE 0
										END
		END AS BIT) AS SigAprobador,
		CASE
			WHEN FT.IdTipoFlujo = 2 THEN ISNULL((SELECT TOP 1--SI ES PARALELO SE VALIDA AL USUARIO APROBADOR DENTRO DEL FLUJO
													NoSecuencia
												FROM dbo.TA_Tarea
												WHERE FechaCambioEstatus IS NULL
													AND IdEstatus = 1
													AND IdAprobador = @IdUsuario
													AND IdOperacion = OP.IdOperacion),0)
			WHEN FT.IdTipoFlujo = 1 THEN ISNULL((SELECT TOP 1
												NoSecuencia
											  FROM dbo.TA_Tarea
											  WHERE FechaCambioEstatus IS NULL
												AND IdEstatus = 1
												AND IdOperacion = OP.IdOperacion
											  ORDER BY NoSecuencia ASC),0)
											
		END AS Secuencia,
		(ROW_NUMBER() OVER(ORDER BY ADP.CreadoEl DESC) - 1) / @RecordsByPage AS _Page
	FROM dbo.MM_AceptacionDocumento_Proveedor AS ADP
		LEFT JOIN dbo.TA_Operacion AS OP 
			ON OP.IdDocumento = ADP.IdAceptacionDocumento
			AND OP.IdTipoOperacion = 18
		LEFT JOIN dbo.S_Proveedor AS PR
			ON PR.IdProveedor = ADP.IdProveedor
		LEFT JOIN dbo.TA_Estatus AS ES
			ON ES.IdEstatus = ADP.IdEstatus
		LEFT JOIN dbo.S_DocumentoPlantillaOperadora AS DPO
			ON DPO.IdDocumentoPlantilla = ADP.IdTipoDocumentoOperadora
		LEFT JOIN dbo.TA_FlujoTarea AS FT
			ON FT.IdFlujoTarea = OP.IdFlujoTarea
	WHERE OP.IdProveedor = @IdProveedor
		AND ADP.IdOperadora = @IdProveedor
		AND ADP.Activo = 1
		AND DPO.Activo = 1
		AND DPO.NombreDocumentoObligatorio LIKE '%' + @Buscar + '%'
	) AS R
		WHERE R.R = 1 AND
			R._Page = (@Page - 1)
		ORDER BY R.IdAceptacionDocumento DESC;

END
