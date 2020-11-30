-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		DANIEL AC 
-- Create date: 27/04/2018
-- Description:	AGRESAR SOPORTES DE ACEPTACION DE PEDIDO
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_AgregarAceptacionDocumentos_S3]

	-----S_Documento-------
	@IdTipoDocumento INT, @IdUsuario INT, @IdProveedor INT, @Documento NVARCHAR(MAX) ,

	-----MM_AceptacionDocumento------
	@IdAceptacionDocumento INT, @Comentario NVARCHAR(MAX), @NombreDocumento NVARCHAR(MAX) ,

	--- NUEVOS PARAMETROS ----
	@Mime NVARCHAR(MAX), @Extension NVARCHAR(MAX), @IdetificadorS3 NVARCHAR(MAX), @Carpeta NVARCHAR(MAX)
AS
	DECLARE @IdDocumento INT

	BEGIN
		SET NOCOUNT ON 

		INSERT INTO S_Documento_S3
			( IdTipoDocumento, IdUsuario, IdProveedor, Activo, Documento, CreadoPor, CreadoEl, NombreDocumento ,
			  Extension , Mime, Carpeta, Identificador )
		VALUES
			( @IdTipoDocumento, @IdUsuario, @IdProveedor, 1, @Documento, @IdUsuario, GETDATE (), @NombreDocumento ,
			  @Extension , @Mime, @Carpeta, @IdetificadorS3 )

		SET @IdDocumento =
			( SELECT @@IDENTITY	   )

		INSERT INTO MM_AceptacionDocumento
			( IdAceptacionDocumento, IdDocumento, Comentario, NombreDocumento, Activo )
		VALUES
			( @IdAceptacionDocumento, @IdDocumento, @Comentario, @NombreDocumento, 1 )

		SELECT @@IDENTITY  
	END