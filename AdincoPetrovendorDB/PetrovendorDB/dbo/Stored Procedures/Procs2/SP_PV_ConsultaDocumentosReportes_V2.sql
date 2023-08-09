USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PV_ConsultaDocumentosReportes_V2'
)
    DROP PROCEDURE SP_PV_ConsultaDocumentosReportes_V2;
/****** Object:  StoredProcedure [dbo].[SP_PV_ConsultaDocumentosReportes_V2]    Script Date: 08/08/2023 12:15:24 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Pedro, Acuña>
-- Modified date: <10/01/2018>
-- Description:	<Se quita el documento de la carga, ya que tarda mucho la pagina en cargar en su lugar la carga del documento se hace hasta que el usuario da click en el documento>
-- Update Daniel AC cambio de refrecnia de s_documento a s_documento_S3
-- =============================================
-- =============================================
-- Author:		Daniel Ac
-- Modified date: 08/08/2023
-- Description:	Se descarta que se muestren archivos de aceptacion de pedido, proforma y fielticket
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
				FROM		dbo.S_Documento_S3 doc (NOLOCK)
				INNER JOIN	dbo.S_TipoDocumento tipo  (NOLOCK)
					ON		tipo.IdTipoDocumento  = doc.IdTipoDocumento 
				INNER JOIN	dbo.S_TipoValidacionDoc valid  (NOLOCK)
							ON doc.IdTipoValidacionDocumento = valid.IdTipoValidacionDoc 
				WHERE
							doc.IdProveedor = @idProveedor
							AND doc.Activo = 1
							AND doc.IdTipoValidacionDocumento = 1003
							AND doc.IdTipoDocumento NOT IN (23, 15,53,12,55,56)	-- CTES 15 No Carta de Contenido,23 No RPPC, 12 Aceptacion de pedido, 56 FIELD TICKET, 55 PROFORMA
				UNION
				SELECT		doc.IdDocumento, tipo.NombreTipoDocumento,ISNULL(doc.ModificadoEl,doc.CreadoEl) AS UltimaVersion,doc.Extension
				FROM		dbo.S_Documento_S3 doc  (NOLOCK)
				INNER JOIN	dbo.S_TipoDocumento tipo  (NOLOCK)
					ON		doc.IdTipoDocumento = tipo.IdTipoDocumento 
				WHERE
							doc.IdProveedor = @idProveedor
							AND doc.Activo = 1
							AND doc.IdTipoDocumento NOT IN (23, 15,53,12,55,56 ) -- CTES 15 No Carta de Contenido,23 No RPPC, 12 Aceptacion de pedido, 56 FIELD TICKET, 55 PROFORMA
			END
		ELSE
			BEGIN
				DECLARE @idTipoRegimen INT

				SET @idTipoRegimen =
					( SELECT IdTipoRegimen	  FROM S_Proveedor WHERE   IdProveedor = @idProveedor )

				EXEC [dbo].[SP_DG_DocumentosProveedor_S3] @IdProveedor = @idProveedor, @IdTipoRegimen = @idTipoRegimen
			END
	END