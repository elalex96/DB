-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <06/Agosto/2017>
-- Description:	<Procedimiento para insertar documentos PDF a los materiales de la cotizacion> 
-- Description:	UPDATE DANIEL AC CAMBIO DEREFERENCIAS DE D_DOCUMENTO A S_DOCUEMENTO_S3 
-- =============================================

CREATE PROCEDURE [dbo].[sp_DocumentosMateriales]
(
    @idDocumento INT,
    @idTipoDocumento INT,
    @idusuario INT,
    @idProveedor INT,
    @activo BIT,
    @documento NVARCHAR(MAX),
    @comentario NVARCHAR(MAX),
    @idPeticionOferta INT,
    @idMaterial INT,
	@nombreArchivo NVARCHAR(100)
)
AS
BEGIN
   --Insertar
    INSERT INTO dbo.S_Documento_S3
    (
        IdTipoDocumento,
        IdUsuario,
        IdProveedor,
        Activo,
        Documento,
        CreadoPor,
        CreadoEl,
        Descripcion
    )
    VALUES
    (   @idTipoDocumento, -- IdTipoDocumento - int
        @idusuario,       -- IdUsuario - int
        @idProveedor,     -- IdProveedor - int
        @activo,          -- Activo - bit
        @documento,       -- Documento - nvarchar(max)
        @idusuario,       -- CreadoPor - int
        GETDATE(),        -- CreadoEl - datetime
        @comentario       -- Descripcion - nvarchar(max)
    )
    --necesito saber cual es valor del idDocumento que se inserto para hacer la relacion con la tabla
    SELECT @idDocumento = @@IDENTITY

	--al guardar se debe de borrar el archivo anterior con con el mismo material y usuario ya que solo debe de agregar uno el usuario
	DELETE dbo.RelacionPDFMateriales WHERE IdPeticionOfertaDetalle = @idMaterial AND IdDocumento != @idDocumento

    INSERT INTO dbo.RelacionPDFMateriales
    (
        IdDocumento,
        NombreArchivo,
        SolicitudCotizacion,
        IdPeticionOfertaDetalle
    )
    VALUES
    (   @idDocumento,   -- IdDocumento - int
        @nombreArchivo, -- NombreArchivo - nvarchar(100)
        @idPeticionOferta,   -- SolicitudCotizacion - int
        @idMaterial    -- IdPeticionOfertaDetalle - int
    )
    
	DECLARE @tablaBorrar TABLE(idDocumentoBorrar INT)
	--lista a borrar de documentos
	INSERT INTO @tablaBorrar
	(
	    idDocumentoBorrar
	)
	SELECT IdDocumento FROM dbo.RelacionPDFMateriales WHERE IdDocumento != @idDocumento AND IdPeticionOfertaDetalle = @idMaterial

	DELETE dbo.S_Documento_S3 WHERE IdDocumento IN (SELECT idDocumentoBorrar FROM @tablaBorrar)

END