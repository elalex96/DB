----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create procedure [dbo].[p_EN_InsertarDocumentoFormatoFichaTecnica]
    @pAWSDocumentoId INT OUT,
    @idEntregable int,
    @pNombreArchivo VARCHAR(250),
    @pFolder VARCHAR(100),
    @pUUIDAmazon UNIQUEIDENTIFIER,
    @pMeta VARCHAR(50),
    @pBucket VARCHAR(50),
    @pCreadoPor INT,
	@idTipoFormatoFichaTecnica INT
AS
BEGIN

INSERT INTO EN_DocumentoFormatoFichaTecnica(idEntregable,
											NombreArchivo,
											UUIDAmazon,
											Meta,
											Bucket,
											Folder,
											idTipoFormatoFichaTecnica,
											CreadoPor,
											CreadoEl,
											ModificadoPor,
											ModificadoEl,
											Activo
									)
									VALUES
									( 
										   @idEntregable,
										   @pNombreArchivo,
										   @pUUIDAmazon,
										   @pMeta,
										   @pBucket,
										   @pFolder,
										   @idTipoFormatoFichaTecnica,
										   @pCreadoPor,
										   GETDATE(),
											@pCreadoPor,
										   GETDATE(),
										   1
									);

				Set @pAWSDocumentoId =@@IDENTITY;

END