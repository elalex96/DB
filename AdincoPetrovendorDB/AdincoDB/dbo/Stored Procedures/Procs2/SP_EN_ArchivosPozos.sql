-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/06/2021
-- Description:	Archivos cargados de las instancias de entregables, última versión y no reachazados.
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ArchivosPozos] 
	-- Add the parameters for the stored procedure here
	@IdContrato            INT, 
	@IdUsuario             INT, 
	@IDINSTALACION INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON

         -- Insert statements for procedure here
	DECLARE @NombrePozo VARCHAR(200);

	SELECT @NombrePozo = NOMBREINSTALACION
	FROM CO_INSTALACION
	WHERE IDINSTALACION = @IDINSTALACION;

    SELECT DISTINCT
		ED.DocumentoEntregableId,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.',ED.NOMBREARCHIVO,LEN(ED.NOMBREARCHIVO)-5), LEN(ED.NombreArchivo)))) AS TipoArchivo
	FROM
		EN_ENTREGABLE   E
	JOIN
		EN_CONTRATOENTREGABLE   CE
		ON  E.IDENTREGABLE = CE.IDENTREGABLE
		AND CE.IDCONTRATO   =   @IDCONTRATO
		AND E.DocumentoEntregable = 'Perforación del pozo: ' + ltrim(@NombrePozo)
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
		ON IE.idInstanciaEntregable =   ED.idInstanciaEntregable;
END