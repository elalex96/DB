-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <09/Agosto/2017>
-- Description:	<Procedimiento para eliminar el documento pdf de los materiales a solicitar > 
-- UPDATE DANIEL AC CAMBIO DE REFERENCIA DE S_DOCUMENTO  A S_DOCUMENTO_S3 08/05/2018 
-- =============================================
CREATE PROCEDURE [dbo].[sp_EliminarDocumentoMateriales]
(
    @idUsuario INT,
    @idDocumento INT,
    @idPeticionOferta INT,
    @idMaterial INT
)
AS
BEGIN
    DELETE dbo.S_Documento_S3
    WHERE IdTipoDocumento = 16 --Tipo de doumento(Documento de cotizacion)
          AND IdUsuario = @idUsuario
          AND IdDocumento = @idDocumento

    DELETE RelacionPDFMateriales
    WHERE IdDocumento = @idDocumento
          AND SolicitudCotizacion = @idPeticionOferta
          AND IdPeticionOfertaDetalle = @idMaterial
END