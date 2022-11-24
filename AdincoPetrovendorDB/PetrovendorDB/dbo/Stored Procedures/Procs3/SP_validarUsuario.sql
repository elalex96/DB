-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_validarUsuario]

@nombre varchar(50),
@contrasena varchar(50)
	
AS
BEGIN

	
	
	SET NOCOUNT ON;

	select * from S_Usuario where Correo = @nombre and contrasena = @contrasena;

END



