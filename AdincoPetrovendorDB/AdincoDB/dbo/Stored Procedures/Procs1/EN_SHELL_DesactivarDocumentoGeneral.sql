CREATE PROCEDURE [dbo].[EN_SHELL_DesactivarDocumentoGeneral]    
	@ContratoId INT,
	@UsuarioId INT,
	@DocumentoId INT,
	@Origen NVARCHAR(100)
AS
BEGIN
		
		IF @Origen <> 'CARGADO_USUARIO'
		BEGIN
				
				UPDATE EN_DocumentoGeneral
				SET Activo=0,
				ModificadoEl=GETDATE(),
				ModificadoPor=@UsuarioId
				WHERE DocumentoId=@DocumentoId
				AND ContratoId=@ContratoId

		END
		ELSE
		BEGIN
			UPDATE CarpetasDocumentosEntregables
				SET Activo = 0
				WHERE ID=@DocumentoId
				AND IdContrato=@ContratoId
		END

		

		SELECT 'SUCCESS'

 END