-- =============================================
-- Author:	Daniel AC
-- Create date: <01/02/2023>
-- Description:	Consulta de la respuesta o comentario segun el tipo de comentario solicitado
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConsultarComentarioCotizacionPorTipo] (
@Id INT,
@TipoComentario VARCHAR(100))
AS
BEGIN

 IF @TipoComentario ='RESPUESTA'
 BEGIN 
	
	SELECT IdComentarioRespuesta  AS Id,
	Respuesta AS Comentario
	FROM dbo.JA_ComentarioRespuesta respuesta (NOLOCK)   
	WHERE respuesta.IdComentarioRespuesta=@Id
	
 END 

  IF @TipoComentario ='COMENTARIO'
 BEGIN 
	  SELECT IdComentarioBase AS Id,
	  Comentario AS Comentario
	  FROM dbo.JA_ComentarioBase   (NOLOCK)
	  WHERE IdComentarioBase = @Id
 END 

END
