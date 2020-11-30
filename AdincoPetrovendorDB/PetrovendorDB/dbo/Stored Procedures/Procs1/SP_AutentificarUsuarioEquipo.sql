-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AutentificarUsuarioEquipo]
(
@idusuario int
)
AS
BEGIN
	
select IdUsuario, IdEquipo from AP_UsuarioEquipo where IdUsuario = (select IdUsuario from S_Usuario where IdUsuario = @idusuario )

END


