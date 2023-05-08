-- =============================================
-- Author:		<Jose Roman>
-- Create date: <04-05-2018>
-- Description:	<Consulta de permisos para los oficios entrantes y salientes>
-- =============================================

create PROCEDURE OF_SP_ConsultaPermisosOficios --3
	@IdContrato INT
AS
BEGIN
	SELECT DISTINCT u.UsuarioID, 
			u.Nombre,
			ISNULL(pe.Creacion, 0) AS Creacion,
			ISNULL(pe.Revision, 0) AS Revision,
			ISNULL(pe.Modificacion, 0) AS Modificacion,
			ISNULL(pe.Aprobacion, 0) AS Aprobacion,
			ISNULL(pe.Firma, 0) AS Firma
		FROM dbo.OF_PermisosUsuario pe
		RIGHT JOIN dbo.AP_Usuario u ON u.UsuarioID = pe.IdUsuario
		INNER JOIN [AP_PerfilUsuario] PU on PU.UsuarioID= U.UsuarioId
		INNER JOIN AP_Perfil P on p.IdPerfil = PU.perfilID 
		WHERE p.IdContrato = @IdContrato
			AND (pe.IdContrato = @IdContrato OR pe.IdContrato IS NULL)

END