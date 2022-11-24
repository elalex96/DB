-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date:  03/11/2017
-- Description:	Descargar documento anexo de una cotización (Bases/Fianza)
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <11/04/2018>
-- Description:	<Se agrega la descarga de documentos anexos>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 27/04/2018
-- Description:	<Se agrega la descarga de documentos anexos S3 CONSULTA IDENTIFICADORES>
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 21/09/2021
-- Description:	<SE AGREGA EL BUCKET A LA CONSULTA>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultaDocumentoAnexoCotizacion] @IdDocumento INT ,
																@TipoDocumento NVARCHAR(350) ,
																/*--------------------parametros contrato  --------------------*/
																@IdContrato INT = NULL, @IdUsuario INT = NULL ,
																@FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		IF @TipoDocumento = 'Fianza'
			BEGIN
				SELECT	F.IdDocFianza, F.NombreDoc, '' AS Documento, F.Carpeta, F.Identificador, F.Extension, F.Mime, ISNULL(F.Bucket,'') AS Bucket
				FROM	dbo.TA_DocFianzaOperacion AS F
				WHERE
						F.IdDocFianza = @IdDocumento
						AND F.Activo = 1
			END

		IF @TipoDocumento = 'Bases'
			BEGIN
				SELECT	B.IdDocBases, B.NombreDoc, '' AS Documento, B.Carpeta, B.Identificador, B.Extension, B.Mime, ISNULL(B.Bucket,'') AS Bucket
				FROM	dbo.TA_DocBasesOperacion AS B
				WHERE
						B.IdDocBases = @IdDocumento
						AND B.Activo = 1
			END

		IF @TipoDocumento = 'Anexo'
			BEGIN
				SELECT	SP.IdDocumento, SP.NombreDoc, '' AS Documento, SP.Carpeta, SP.Identificador, SP.Extension, SP.Mime, ISNULL(SP.Bucket,'') AS Bucket
				FROM	MM_DocumentosSolPed SP
				WHERE
						IdDocumento = @IdDocumento
						AND SP.Activo = 1
			END
	END