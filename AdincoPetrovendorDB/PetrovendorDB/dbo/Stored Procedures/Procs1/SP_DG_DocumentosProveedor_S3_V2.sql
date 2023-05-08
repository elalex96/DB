---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:	DANIEL AC
-- Create date: 06/04/2018
-- Description:	Consulta la relación de Documento Proveedor mediante tipo de persona fiscal
-- =============================================
-- Author:	Pedro Acuña
-- Create date: 01/03/2019
-- Description:	Se modifica el como se descartan los documentos ya que el representante legal ahora puede contener mas de uno
-- =============================================

CREATE PROCEDURE SP_DG_DocumentosProveedor_S3_V2 @IdTipoRegimen INT, @IdProveedor INT
AS
	BEGIN
		SET NOCOUNT ON

		DECLARE @tablaTipoDocumentos TABLE
			( IdTipoDocumento INT ,
			  NombreTipoDocumento NVARCHAR (MAX))

		DECLARE @tablaDocumentos TABLE
			( IdTipoDocumento INT ,
			  IdDocumento INT ,
			  NombreDocumento NVARCHAR (MAX) ,
			  TipoValidacion NVARCHAR (MAX) ,
			  CreadoEl DATETIME )

		--Se enlistan los tipos de documentos filtrados por el tipo de regimen
		INSERT INTO @tablaTipoDocumentos
			( IdTipoDocumento, NombreTipoDocumento )
		SELECT	tipoDoc.IdTipoDocumento, tipoDoc.NombreTipoDocumento
		  FROM	S_TipoDocumento tipoDoc
				INNER JOIN dbo.S_TipoDocumentoTipoPersona tipoPersona
						   ON tipoDoc.IdTipoDocumento = tipoPersona.IdTipoDocumento
		 WHERE	tipoPersona.IdTipoRegimen = @IdTipoRegimen

		-- Se enlistan todos los documentos del proveedor
		INSERT INTO @tablaDocumentos
			( IdTipoDocumento, IdDocumento, NombreDocumento, TipoValidacion, CreadoEl )
		SELECT	s3.IdTipoDocumento, s3.IdDocumento, s3.NombreDocumento, tvd.TipoValidacion, s3.CreadoEl
		  FROM	dbo.S_Documento_S3 s3
				INNER JOIN dbo.S_TipoValidacionDoc tvd
						   ON s3.IdTipoValidacionDocumento = tvd.IdTipoValidacionDoc
		 WHERE
				s3.IdProveedor = @IdProveedor
				AND s3.Activo = 1

		-- Se filtran los documentos por los tipos de documentos dependiendo del tipo de regimen
		SELECT	tipoDoc.IdTipoDocumento ,
				CASE WHEN doc.IdTipoDocumento = 13 THEN
						 tipoDoc.NombreTipoDocumento + ': ' + repLegal.APaterno + ' ' + repLegal.AMaterno + ' '
						 + repLegal.Nombre
					ELSE
						tipoDoc.NombreTipoDocumento
				END AS NombreTipoDocumento, ISNULL ( doc.TipoValidacion, 'Sin Documento' ) AS TipoValidacionDocumento ,
				ISNULL ( doc.IdDocumento, 0 ) AS IdDocumento, doc.CreadoEl AS Fecha, doc.NombreDocumento
		  FROM	@tablaTipoDocumentos tipoDoc
				LEFT JOIN @tablaDocumentos doc
						  ON tipoDoc.IdTipoDocumento = doc.IdTipoDocumento
				LEFT JOIN dbo.DG_RepresentanteLegal repLegal
						  ON doc.IdDocumento = repLegal.IdDocumento
							 AND repLegal.IsActivo = 1
		 ORDER BY tipoDoc.IdTipoDocumento
	END
