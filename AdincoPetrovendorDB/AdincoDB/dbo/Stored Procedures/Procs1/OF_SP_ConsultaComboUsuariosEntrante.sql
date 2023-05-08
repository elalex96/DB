-- =============================================
-- Author:		<Jose Roman>
-- Create date: <08/05/2018>
-- Description:	<Se crea consulta para los combos Remitente/Destinatario>
-- =============================================

create PROCEDURE OF_SP_ConsultaComboUsuariosEntrante
	@IdContrato INT
AS
BEGIN
	SELECT DISTINCT u.UsuarioID, 
			u.Nombre
		FROM dbo.AP_Usuario u 
		INNER JOIN dbo.OF_PermisosUsuario pe ON pe.IdUsuario = u.UsuarioID AND pe.IdContrato = @IdContrato
		INNER JOIN [AP_PerfilUsuario] PU on PU.UsuarioID= U.UsuarioId
		INNER JOIN AP_Perfil P on p.IdPerfil = PU.perfilID 
		WHERE p.IdContrato = @IdContrato
			AND pe.Aprobacion = 1
END