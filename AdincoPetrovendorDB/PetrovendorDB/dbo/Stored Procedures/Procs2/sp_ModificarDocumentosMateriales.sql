-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <08/Agosto/2017>
-- Description:	<Procedimiento para modificar el comentario del documento> 
-- UPDATE DANIEL AC CAMBIO DE REFERENCIA DE S_DOCUMENTO A S_DOCUMETO_S3
-- =============================================
CREATE PROCEDURE [dbo].[sp_ModificarDocumentosMateriales]
(
    @idUsuario INT,
    @comentario NVARCHAR(MAX),
    @idDocumento INT
)
AS
BEGIN
    UPDATE dbo.S_Documento_S3
    SET ModificadoEl = GETDATE(),
        ModificadoPor = @idUsuario,
        Descripcion = @comentario
    WHERE IdDocumento = @idDocumento
END