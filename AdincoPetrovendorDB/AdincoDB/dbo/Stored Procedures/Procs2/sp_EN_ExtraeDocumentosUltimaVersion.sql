-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/05/28
-- Description:	Extrae los documentos que fueron enviados de acuerdo a la version
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeDocumentosUltimaVersion]--255340,10061,3
	@IdInstanciaEntregable int,
	@IdUsuario int,
	@IdContrato int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @VersionMax INT= 0;

	SELECT @VersionMax = MAX(IdLineaTiempo)
	FROM
		EN_HistorialAprobacionesLineaTiempo
	WHERE 
		idInstanciaEntregable	=	@IdInstanciaEntregable

	SELECT 
		ED.DocumentoEntregableId,
		ED.idContratoEntregable,
		ED.idInstanciaEntregable,
		ED.Bucket,
		ED.Folder,
		ED.UUIDAmazon,
		--ED.NombreArchivo,
						--SE REALIZA REPLACE A CARACTERES SUBSTRING A NOMBRE DEL ARCHIVO SOLO A 30 CARACTERES Y SE CONCATENA LA EXTENCIÓN
		CONCAT(
				SUBSTRING(REPLACE(REVERSE(SUBSTRING(REVERSE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ED.NombreArchivo)),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','')),CHARINDEX('.', REVERSE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ED.NombreArchivo)),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','')))+1, 200)),'.',''),0,30),
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ED.NombreArchivo)),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?',''),REVERSE(SUBSTRING(REVERSE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ED.NombreArchivo)),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','')),CHARINDEX('.', REVERSE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ED.NombreArchivo)),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','')))+1, 200)),'')

			 ) AS NombreArchivo,
		ED.Meta,
		T.Nombrearchivo AS Tipo
	FROM
		EN_DocumentoVersion	DV
	JOIN 
		EN_EntregableDocumento	ED 
		ON	Dv.DocumentoEntregableId	=	ED.DocumentoEntregableId
	JOIN 
		EN_TipoArchivo	T 
		ON	T.idTipoArchivo	=	ED.idTipoArchivo
	WHERE 
		DV.idInstanciaEntregable	=	@IdInstanciaEntregable
		AND DV.Activo	=	1
		AND	N_version	=	@VersionMax 
 
END




