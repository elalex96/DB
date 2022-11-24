-- =============================================
-- Author:		Luis David
-- Create date: 16/03/2022
-- Description:	Guardar relación de documento adjunto en la aprobación de solicitud de aceptación de pedido
-- =============================================

CREATE PROCEDURE [dbo].[SRAP_sp_AgregarAdjuntoEnDocumentosS3]
	@TipoDocumento VARCHAR(500),
	@IdUsuario INT, 
	@IdProveedor INT, 
	@Documento NVARCHAR(MAX),		
	@Comentario NVARCHAR(MAX), 
	@NombreDocumento NVARCHAR(MAX),	
	@Mime NVARCHAR(MAX), 
	@Extension NVARCHAR(MAX), 
	@IdetificadorS3 NVARCHAR(MAX), 
	@Carpeta NVARCHAR(MAX),	
	@Bucket NVARCHAR(MAX),
	@SizeDocumento FLOAT,
	@IdSolicitudAceptacionPedido INT
AS
	DECLARE @IdDocumento INT

	BEGIN
		SET NOCOUNT ON 
		DECLARE @IdTipoDocumento INT = (SELECT IdTipoDocumento FROM S_TipoDocumento WHERE NombreTipoDocumento = @TipoDocumento);
		/*GUARDAR LOS ARCHIVOS CARGADOS EN UNA APROBACIÓN DE SOLICITUD DE ACEPTACIÓNDE PEDIDO
		DONDE LA REFERENCIA PARA LOCALIZARLOS ES LA @IdSolicitudAceptacionPedido EN LA COLUMNA S_Documento_S3.IdDocumentoTabla
		EL TIPO VA SER EL MISMO DE LA ACEPTACION DE PEDIDO
		SRAP --> SOLICITUD RECEPCIÓN ACEPTACION PEDIDO
		*/
		IF ISNULL(@IdTipoDocumento,0) > 0
		BEGIN
		INSERT INTO S_Documento_S3
			( IdTipoDocumento, IdUsuario, IdProveedor, Activo, Documento, CreadoPor, CreadoEl, NombreDocumento ,
			  Extension , Mime, Carpeta, Identificador, Bucket,SizeDocumento, IdDocumentoTabla,Descripcion )
		VALUES
			( @IdTipoDocumento, @IdUsuario, @IdProveedor, 1, @Documento, @IdUsuario, GETDATE (), @NombreDocumento ,
			  @Extension , @Mime, @Carpeta, @IdetificadorS3,@Bucket,@SizeDocumento,@IdSolicitudAceptacionPedido,'SRAP')

		SET @IdDocumento =( SELECT @@IDENTITY)				
		END
END