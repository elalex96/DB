-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_VerificarEquipoActivado]
@idusuario int
AS
BEGIN


select IdUsuario from AP_UsuarioEquipo where IdUsuario = (select IdUsuario from S_Usuario where IdUsuario = @idusuario ) and Activo = '1'
	
END


