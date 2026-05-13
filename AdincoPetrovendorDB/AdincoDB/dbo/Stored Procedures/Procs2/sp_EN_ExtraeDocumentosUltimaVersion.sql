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

	CREATE TABLE #Archivos
	(
		DocumentoEntregableId	INT,
		idContratoEntregable	INT,
		idInstanciaEntregable	INT,
		Bucket					VARCHAR(1500),
		Folder					VARCHAR(1500),
		UUIDAmazon				uniqueidentifier,
		NombreArchivo			VARCHAR(1500),
		Meta					VARCHAR(1500),
		Tipo					VARCHAR(200),
		idTipoArchivo			INT
	)

	DECLARE @VersionMax INT= 0,
		@IsEquinor bit = 0
	
	if exists(
		select		COUNT(1)
		from		CO_Contrato			c
		inner join	CO_Contratista		ct
		on			c.IdContratista		=		ct.IdContratista
		where		IdContrato			=		@IdContrato
		and			NombreContratista	like	'%Equinor%'-- Cambiar por 'Equinor'
	)
	begin
		select @IsEquinor	=	cast(1 as bit)
	end
	

	SELECT @VersionMax = MAX(IdLineaTiempo)
	FROM
		EN_HistorialAprobacionesLineaTiempo
	WHERE 
		idInstanciaEntregable	=	@IdInstanciaEntregable

	INSERT INTO #Archivos
	(
		DocumentoEntregableId,
		idContratoEntregable,
		idInstanciaEntregable,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		Tipo,
		idTipoArchivo
	)
	SELECT 
		ED.DocumentoEntregableId,
		ED.idContratoEntregable,
		ED.idInstanciaEntregable,
		ED.Bucket,
		ED.Folder,
		ED.UUIDAmazon,
		--ED.NombreArchivo,
--SE REALIZA REPLACE A CARACTERES SUBSTRING A NOMBRE DEL ARCHIVO SOLO A 30 CARACTERES Y SE CONCATENA LA EXTENCIÓN
	CONCAT(	SUBSTRING(REPLACE(REVERSE(SUBSTRING(REVERSE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ED.NombreArchivo)),'-',''),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','')),
	CHARINDEX('.', REVERSE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ED.NombreArchivo)),'-',''),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','')))+1, 200)),'.',''),0,20),
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ED.NombreArchivo)),'-',''),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?',''),REVERSE(SUBSTRING(REVERSE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ED.NombreArchivo)),'-',''),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','')),CHARINDEX('.', REVERSE(REPLACE
(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ED.NombreArchivo)),'-',''),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','')))+1, 200)),'')
			 ) AS NombreArchivo,
		ED.Meta,
		T.Nombrearchivo AS Tipo,
		T.idTipoArchivo
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
 
 IF 0 < (SELECT COUNT(1)
	FROM #Archivos
	WHERE	idTipoArchivo	in	(10001, 10002)) AND @IsEquinor = 1
BEGIN
	SELECT
		DocumentoEntregableId,
		idContratoEntregable,
		idInstanciaEntregable,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		Tipo
	FROM
		#Archivos
	WHERE
		idTipoArchivo	in	(10001, 10002)
END
ELSE
BEGIN
	SELECT
		DocumentoEntregableId,
		idContratoEntregable,
		idInstanciaEntregable,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		Tipo
	FROM
		#Archivos
END

END
