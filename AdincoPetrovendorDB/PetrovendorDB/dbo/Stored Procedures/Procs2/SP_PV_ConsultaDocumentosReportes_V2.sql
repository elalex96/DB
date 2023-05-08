-- =============================================
-- Author:		<Pedro, Acuña>
-- Modified date: <10/01/2018>
-- Description:	<Se quita el documento de la carga, ya que tarda mucho la pagina en cargar en su lugar la carga del documento se hace hasta que el usuario da click en el documento>
-- Update Daniel AC cambio de refrecnia de s_documento a s_documento_S3
-- =============================================
-- =============================================
-- Author:		Daniel Ac
-- Modified date: 04/01/2022
-- Description:	Se descarta que se muestren archivos de aceptacion de pedido
-- =============================================

CREATE PROCEDURE [dbo].[SP_PV_ConsultaDocumentosReportes_V2]
	-- Add the parameters for the stored procedure here
	@idProveedor INT, @Identificador INT
AS
	BEGIN
		SET NOCOUNT ON ;

		IF ( @Identificador = 1 ) --Si viene del grid
			BEGIN
				SELECT		doc.IdDocumento, tipo.NombreTipoDocumento,ISNULL(doc.ModificadoEl,doc.CreadoEl) AS UltimaVersion, doc.Extension
				FROM		dbo.S_Documento_S3 doc
				INNER JOIN	dbo.S_TipoDocumento tipo
					ON tipo.IdTipoDocumento = doc.IdTipoDocumento
				INNER JOIN	dbo.S_TipoValidacionDoc valid
					ON valid.IdTipoValidacionDoc = doc.IdTipoValidacionDocumento
				WHERE
							doc.IdProveedor = @idProveedor
							AND doc.Activo = 1
							AND doc.IdTipoValidacionDocumento = 1003
							AND doc.IdTipoDocumento NOT IN ( 23, 15,53,12 )	--No Carta de Contenido, No RPPC,Aceptacion de pedido
				UNION
SELECT				doc.IdDocumento, tipo.NombreTipoDocumento,ISNULL(doc.ModificadoEl,doc.CreadoEl) AS UltimaVersion,doc.Extension
				FROM		dbo.S_Documento_S3 doc
				INNER JOIN	dbo.S_TipoDocumento tipo
					ON tipo.IdTipoDocumento = doc.IdTipoDocumento
				WHERE
							doc.IdProveedor = @idProveedor
							AND doc.Activo = 1
							AND doc.IdTipoDocumento NOT IN ( 23, 15,53,12 )
			END
		ELSE
			BEGIN
				DECLARE @idTipoRegimen INT

				SET @idTipoRegimen =
					( SELECT IdTipoRegimen	  FROM S_Proveedor WHERE   IdProveedor = @idProveedor )

				EXEC [dbo].[SP_DG_DocumentosProveedor_S3] @IdProveedor = @idProveedor, @IdTipoRegimen = @idTipoRegimen
			END
	END