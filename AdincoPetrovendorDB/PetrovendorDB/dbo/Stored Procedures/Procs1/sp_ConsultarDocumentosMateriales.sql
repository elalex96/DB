-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <08/Agosto/2017>
-- Description:	<Procedimiento para consultar si ya existe un documento de ese usuario> 
-- UPDATE DANIEL AC CAMBIO S_DOCUMENTO A S_DOCUMENTO_S3 08/05/2018
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConsultarDocumentosMateriales]
(
    @idTipoDocumento INT,
    @idusuario INT,
    @idProveedor INT,
    @idPeticionOferta INT,
	@idMaterial INT
)
AS
BEGIN

    SELECT doc.IdDocumento,
           doc.Descripcion,
		   doc.Documento,
		   rel.NombreArchivo
    FROM S_Documento_S3 doc
        INNER JOIN dbo.RelacionPDFMateriales rel
            ON rel.idDocumento = doc.IdDocumento
    WHERE doc.Activo = 1
          AND doc.IdTipoDocumento = @idTipoDocumento --Tipo de doumento(Documento de cotizacion (16))
          AND rel.solicitudCotizacion = @idPeticionOferta
          AND doc.IdUsuario = @idusuario
          AND doc.IdProveedor = @idProveedor
		  AND rel.IdPeticionOfertaDetalle = @idMaterial

END