-- =============================================
-- Author:		DANIEL AC
-- Create date: 26/04/2018
-- Description: Consultar Estatus del documento
-- =============================================
CREATE PROCEDURE[dbo].[SP_DG_ValidarSiExisteDocumento_S3]

@IdProveedor int, 
@IdTipoDocumento int,
@TipoConsulta int

AS

BEGIN
	
	DECLARE @NombreDocumento NVARCHAR(350)= (SELECT D.NombreTipoDocumento
												FROM S_TipoDocumento AS D
												INNER JOIN dbo.S_Documento_S3 AS TD ON TD.IdTipoDocumento = D.IdTipoDocumento
												WHERE D.IdTipoDocumento =@IdTipoDocumento
												GROUP BY D.NombreTipoDocumento)


	

	IF @TipoConsulta = 1 ---Consulta solo de estatus de documento
	BEGIN
		SELECT COUNT(D.IdDocumento) AS DocumentoCargado,D.IdDocumento, @NombreDocumento AS NombreDocumento, TV.TipoValidacion, D.IdTipoValidacionDocumento
		fROM dbo.S_Documento_S3 AS D
		LEFT JOIN S_Proveedor AS P ON P.IdProveedor = D.IdProveedor 
		LEFT JOIN S_TipoDocumento AS TD ON TD.IdTipoDocumento = D.IdTipoDocumento
		LEFT JOIN S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc = D.IdTipoValidacionDocumento
		WHERE D.IdTipoDocumento = @IdTipoDocumento AND P.IdProveedor= @IdProveedor AND D.Activo = 1
		GROUP BY D.IdDocumento,TV.TipoValidacion,D.IdTipoValidacionDocumento
	END 
	
	IF  @TipoConsulta = 2 ---Consulta información del documento
	BEGIN 
		SELECT COUNT(D.IdDocumento) AS DocumentoCargado,D.IdDocumento, @NombreDocumento AS NombreDocumento, TV.TipoValidacion, D.IdTipoValidacionDocumento,D.Documento, D.Carpeta, D.Identificador
		fROM dbo.S_Documento_S3 AS D
		LEFT JOIN S_Proveedor AS P ON P.IdProveedor = D.IdProveedor 
		LEFT JOIN S_TipoDocumento AS TD ON TD.IdTipoDocumento = D.IdTipoDocumento
		LEFT JOIN S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc = D.IdTipoValidacionDocumento
		WHERE D.IdTipoDocumento = @IdTipoDocumento AND P.IdProveedor= @IdProveedor AND D.Activo = 1
	GROUP BY D.IdDocumento,TV.TipoValidacion,D.IdTipoValidacionDocumento,D.Documento, D.Carpeta, D.Identificador
	END 

END