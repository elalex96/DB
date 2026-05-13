-- =============================================
-- Author:	Daniel AC
-- Create date: <01/02/2023>
-- Description:	Actualizar comentarios y respuestas del blog de cotizaciones de la oferta
-- =============================================
CREATE PROCEDURE [dbo].[sp_ActualizarComentarioCotizacionesPorTipo] (
@Id INT,
@TipoComentario VARCHAR(100),
@Comentario NVARCHAR(MAX),
@ProveedorId INT,
@UsuarioId INT
)
AS
BEGIN
DECLARE @Mensaje NVARCHAR(MAX)=''
DECLARE @ComentarioAnterior  NVARCHAR(MAX)=''

 
 IF @TipoComentario ='RESPUESTA'
 BEGIN 
	
	SELECT @ComentarioAnterior=  Respuesta
	FROM JA_ComentarioRespuesta respuesta (NOLOCK)   
	WHERE respuesta.IdComentarioRespuesta=@Id

	UPDATE JA_ComentarioRespuesta
	SET Respuesta = @Comentario	
	WHERE IdComentarioRespuesta=@Id

	IF LTRIM(RTRIM(@ComentarioAnterior))<>LTRIM(RTRIM(@Comentario))
	BEGIN
	
	SET @Mensaje =CONCAT('ANTES: ',@ComentarioAnterior,', DESPUÉS: ',@Comentario)
	INSERT INTO dbo.BitacoraErrores (HResult, Mensaje, StackTrace, IdUsuario, IdProveedor, FechaRegistro)
    VALUES
    (   @Id,    -- HResult - int
        CONCAT('Edición respuestas-oferta IdComentarioRespuesta #',@Id),    -- Mensaje - nvarchar(max)
        @Mensaje, 
        @UsuarioId, 
        @ProveedorId,
		GETDATE())

    END 

 END 

  IF @TipoComentario ='COMENTARIO'
 BEGIN 
	
	SELECT @ComentarioAnterior=	Comentario 
	FROM dbo.JA_ComentarioBase   (NOLOCK)
	WHERE IdComentarioBase = @Id

	UPDATE JA_ComentarioBase
	SET Comentario = @Comentario	  
	WHERE IdComentarioBase = @Id

	IF LTRIM(RTRIM(@ComentarioAnterior))<>LTRIM(RTRIM(@Comentario))
	BEGIN
	
	SET @Mensaje =CONCAT('ANTES: ',@ComentarioAnterior,', DESPUÉS: ',@Comentario)
	INSERT INTO dbo.BitacoraErrores (HResult, Mensaje, StackTrace, IdUsuario, IdProveedor, FechaRegistro)
    VALUES
    (   @Id,    -- HResult - int
        CONCAT('Edición comentarios-oferta IdComentarioBase #',@Id),    -- Mensaje - nvarchar(max)
        @Mensaje, 
        @UsuarioId, 
        @ProveedorId,
		GETDATE())

    END 
 END 

END
