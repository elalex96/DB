-- =============================================  
-- Author:   Daniel AC  
-- Create date: 26/10/2020  
-- Description:  Guardar los comentarios de un entregable instancia
-- ============================================= 
CREATE procedure [dbo].[EN_GuardarComentariosEntregableInstancia]	
@EntregableInstanciaId INT,
@UsuarioId INT,
@ContratoId INT,
@Comentario NVARCHAR(MAX)
AS
BEGIN
	/*SP PARA CONSULTAR LOS COMENTARIOS DE LOS USUARIOS*/

	INSERT INTO EN_EntregableInstanciaComentario(EntregableInstanciaId,Comentario,ContratoId,UsuarioId,CreadoEl,Activo)
	VALUES (@EntregableInstanciaId,@Comentario,@ContratoId,@UsuarioId,GETDATE(),1)
	
	SELECT SCOPE_IDENTITY()
	 
END    

