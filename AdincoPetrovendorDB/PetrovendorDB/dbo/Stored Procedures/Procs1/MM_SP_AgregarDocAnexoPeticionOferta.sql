-- =============================================
-- Author:		<Jose Roman>
-- Create date: <05-04-2018>
-- Description:	<Se guarda un documento anexo en la peticion oferta en petrovendor>
-- Update: Daniel AC 10/05/2018 Se agrego parametros de Archivo S3
-- =============================================

CREATE procedure [dbo].[MM_SP_AgregarDocAnexoPeticionOferta]
	@IdPeticionOferta INT,
	@Documento NVARCHAR(max),
	@NomDocumento NVARCHAR(max),
	/*NUEVOS PARAMETROS*/
	@Carpeta  NVARCHAR(max),
	@Identificador  NVARCHAR(max),
	@Extension  NVARCHAR(max),
	@Mime  NVARCHAR(max),
	/*FIN NUEVOS PARAMETROS*/
	@Comentario VARCHAR(1500) = null,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = NULL	
AS
BEGIN
	INSERT INTO dbo.MM_DocAnexosPeticionOferta
	(
	    IdPeticionOferta,
	    Documento,
	    NomDocumento,
	    SubidoPor,
	    SubidoEl,
	    Comentario,
	    Eliminado,
		Carpeta,
		Identificador,
		Extension,
		Mime
	)
	VALUES
	(   @IdPeticionOferta,                     -- IdPeticionOferta - int
	    @Documento,                   -- Documento - nvarchar(max)
	    @NomDocumento,                   -- NomDocumento - nvarchar(max)
	    @IdUsuario,                     -- SubidoPor - int
	    GETDATE(), -- SubidoEl - smalldatetime
	    @Comentario,                    -- Comentario - varchar(1500)
	    0,                   -- Eliminado - bit
		@Carpeta,
		@Identificador,
		@Extension,
		@Mime
	)

	SELECT @@IDENTITY
END