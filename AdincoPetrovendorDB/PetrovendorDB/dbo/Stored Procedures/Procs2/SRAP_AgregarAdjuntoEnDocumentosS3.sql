USE [Petrovendor]
GO


IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SRAP_AgregarAdjuntoEnDocumentosS3'
)
    DROP PROCEDURE SRAP_AgregarAdjuntoEnDocumentosS3;

/****** Object:  StoredProcedure [dbo].[SP_MM_AgregarAceptacionDocumentos_S3]    Script Date: 17/06/2021 10:05:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		DANIEL AC 
-- Create date: 17/06/2021
-- Description:	Guardar relación de documento adjunto en la aprobación de solicitud de aceptación de pedido
-- =============================================

CREATE PROCEDURE [dbo].[SRAP_AgregarAdjuntoEnDocumentosS3]

	@IdTipoDocumento INT, 
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
		/*GUARDAR LOS ARCHIVOS CARGADOS EN UNA APROBACIÓN DE SOLICITUD DE ACEPTACIÓNDE PEDIDO
		DONDE LA REFERENCIA PARA LOCALIZARLOS ES LA @IdSolicitudAceptacionPedido EN LA COLUMNA S_Documento_S3.IdDocumentoTabla
		EL TIPO VA SER EL MISMO DE LA ACEPTACION DE PEDIDO
		SRAP --> SOLICITUD RECEPCIÓN ACEPTACION PEDIDO
		*/

		INSERT INTO S_Documento_S3
			( IdTipoDocumento, IdUsuario, IdProveedor, Activo, Documento, CreadoPor, CreadoEl, NombreDocumento ,
			  Extension , Mime, Carpeta, Identificador, Bucket,SizeDocumento, IdDocumentoTabla,Descripcion )
		VALUES
			( @IdTipoDocumento, @IdUsuario, @IdProveedor, 1, @Documento, @IdUsuario, GETDATE (), @NombreDocumento ,
			  @Extension , @Mime, @Carpeta, @IdetificadorS3,@Bucket,@SizeDocumento,@IdSolicitudAceptacionPedido,'SRAP')

		SET @IdDocumento =( SELECT @@IDENTITY)				
			 
END