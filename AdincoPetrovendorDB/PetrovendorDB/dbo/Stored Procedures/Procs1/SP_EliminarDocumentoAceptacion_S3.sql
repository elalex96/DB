-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <23/07/2020>
-- Description:	<Aplica un eliminado logico a los documentos de aceptacion y guarda un historial>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EliminarDocumentoAceptacion_S3]
@IdProveedor INT,
@IdUsuario INT,
@IdDocumento INT,
@IdAceptacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.S_Documento_S3
	SET Activo = 0
	WHERE IdDocumento = @IdDocumento

	UPDATE dbo.MM_AceptacionDocumento
	SET Activo = 0
	WHERE IdDocumento = @IdDocumento
	AND IdAceptacionDocumento = @IdAceptacion

	-- registramos el historial de quien elimino el documento
	INSERT INTO dbo.S_HistorialEliminacionDocumento_S3
	(
	    IdDocumento,
	    IdProveedor,
	    EliminadoPor,
	    EliminadoEl
	)
	VALUES
	(   
		@IdDocumento,        -- IdDocumento - int
	    @IdProveedor,        -- IdProveedor - int
	    @IdUsuario,        -- EliminadoPor - int
	    GETDATE() -- EliminadoEl - datetime
	)

	SELECT SCOPE_IDENTITY()

END
