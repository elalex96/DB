-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ActivarEquipo]
@idusuario int
AS
BEGIN
	
update  AP_UsuarioEquipo  set Activo = '1'  where IdUsuario = (select IdUsuario from S_Usuario where IdUsuario = @idusuario )

END


