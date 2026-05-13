-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegEnviaCorreo]
	-- Add the parameters for the stored procedure here
	@idusuario int,
	@idcorreo int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	declare @nombreremitente nvarchar(MAX) = (select nombre from S_Usuario where IdUsuario = @idusuario)
	declare @asunto nvarchar(MAX) = (select Asunto from S_Correo where IdCorreo = @idcorreo)
	declare @cuerpo1 nvarchar(MAX) = (select Cuerpo1 from S_Correo where IdCorreo = @idcorreo)
	declare @cuerpo2 nvarchar(MAX) = (select Cuerpo2 from S_Correo where IdCorreo = @idcorreo)
	declare @cuerpo nvarchar(MAX)
	declare @idcorreoservidor int = (select IdCorreoServidor from S_CorreoServidor as SC where  sc.IdCorreoServidor= 1)

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--set @nombreremitente 
	set @cuerpo = (SELECT REPLACE(@Cuerpo1, '(nombre)' ,@nombreremitente))

	select @asunto as asunto, @cuerpo as cuerpo1, @cuerpo2 as cuerpo2, @idcorreoservidor as servidor from S_Correo where idcorreo = @idcorreo
END

