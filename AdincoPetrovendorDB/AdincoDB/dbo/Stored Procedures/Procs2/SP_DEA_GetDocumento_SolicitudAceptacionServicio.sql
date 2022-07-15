USE PETROVENDOR
GO
DROP PROCEDURE IF EXISTS SP_DEA_GetDocumento_SolicitudAceptacionServicio
GO
-- =============================================
-- Author:		ALEXANDER GOMEZ
-- Create date: <29/03/2022>
-- Description:	<obtiene la informacion del documento de la solicitud de aceptacion se servicio>
-- =============================================
-- Author:		LUIS DAVID
-- Create date: <14/07/2022>
-- Description:	Se elimina la proforma y field ticket de la consulta ya que se concatenará en el documento adjunto Issue #1920(Petrovendor)
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_GetDocumento_SolicitudAceptacionServicio] --907,0,17166
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacion INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @DOCUMENTO_TIPO_OTROS_DOCUMENTOS INT = (SELECT TOP 1 IdTipoDocumento FROM S_TipoDocumento WHERE NombreTipoDocumento = 'Aceptacion Pedido');

	CREATE TABLE #DOCUMENTOS_SOLICITUD_ACEPTACION(
		NombreDocumento NVARCHAR(1000),
		Extension NVARCHAR(30),
		Mime NVARCHAR(100),
		Carpeta NVARCHAR(1000),
		Identificador NVARCHAR(200),
		Bucket NVARCHAR(200)
	);
	--INSERTAR OTROS DOCUMENTOS
	INSERT INTO #DOCUMENTOS_SOLICITUD_ACEPTACION
	SELECT
		SUBSTRING(REPLACE(DS3.NombreDocumento,DS3.Extension,''),0,20) + DS3.Extension,
		DS3.Extension,
		DS3.Mime,
		DS3.Carpeta,
		DS3.Identificador,
		DS3.Bucket
	FROM MM_SolicitudAceptacionPedido AS SAP
	JOIN MM_AceptacionPedido AS AP
		ON SAP.IdAceptacionPedido = AP.IdAceptacionPedido
		AND AP.IdAceptacionPedido = @IdAceptacion
	JOIN S_Documento_S3 AS DS3
		ON DS3.IdDocumentoTabla = SAP.IdSolicitudAceptacionPedido
		AND DS3.IdTipoDocumento = @DOCUMENTO_TIPO_OTROS_DOCUMENTOS
		AND DS3.Activo = 1;

	SELECT
		NombreDocumento,
		Extension,
		Mime,
		Carpeta,
		Identificador,
		Bucket
	FROM #DOCUMENTOS_SOLICITUD_ACEPTACION;

END
