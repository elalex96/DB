---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Josue Glez
-- Create date: 03-05-2017
-- Description:	Elimina una relacion factura- transferencia
-- =============================================
CREATE PROCEDURE [dbo].SP_AP_PerfilUsuarioXUsuarioID
	@IdUsuario int,
	@IdContrato int
AS
BEGIN
	SET NOCOUNT ON;

	--select * from Ap_Usuario
	--select * from Ap_Perfil
	--select * from AP_Rol
	--Select * from AP_UsuarioPerfilSeguridad
	--select A.idUsuarioPerfilSeguridad, A.IdPerfil, B.Descripcion, B.IdRol 
	--	from AP_UsuarioPerfilSeguridad A
	--	inner join AP_Perfil B on B.IdPerfil = A.IdPerfil
	--	where A.IdUsuario = @IdUsuario
	--	and B.IdContrato = @IdContrato

		select A.PerfilUsuarioID as idUsuarioPerfilSeguridad, A.PerfilID as IdPerfil, B.Descripcion, B.IdRol 
		from AP_PerfilUsuario A
		inner join AP_Perfil B on B.IdPerfil = A.PerfilID
		where A.UsuarioID = @IdUsuario
		and B.IdContrato = @IdContrato
END