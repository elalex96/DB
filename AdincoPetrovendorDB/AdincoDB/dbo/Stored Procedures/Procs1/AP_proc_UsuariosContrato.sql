USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AP_proc_UsuariosContrato'
)
    DROP PROCEDURE AP_proc_UsuariosContrato;
GO
CREATE PROCEDURE [dbo].[AP_proc_UsuariosContrato]-- 3
@IdContrato INT
as
begin
	SELECT	DISTINCT
				AP_Usuario.UsuarioID,
				AP_Usuario.Nombre,AP_Usuario.Usuario
		  FROM	AP_PerfilUsuario AS PU
				INNER JOIN AP_Usuario
						   ON PU.UsuarioID = AP_Usuario.UsuarioID
				INNER JOIN AP_Perfil
						   ON PU.PerfilID = AP_Perfil.IdPerfil
				INNER JOIN AP_Rol
						   ON AP_Perfil.IdRol = AP_Rol.IdRol
				INNER JOIN CO_Contrato
						   ON AP_Perfil.IdContrato = CO_Contrato.IdContrato
				INNER JOIN CO_AreaContractual
						   ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
				INNER JOIN Petrovendor.dbo.S_UsuarioProveedor uProv
						   ON CO_Contrato.IdContrato = uProv.IdContrato
				INNER JOIN Petrovendor.dbo.S_Proveedor prov
						   ON uProv.IdProveedor = prov.IdProveedor
				INNER JOIN Petrovendor.dbo.S_Usuario u
						   ON uProv.IdUsuario = u.IdUsuario
							  AND	u.IdUsuarioADINCO = PU.UsuarioID
		 WHERE
		 CO_Contrato.idcontrato = @IdContrato 
		 AND
		 (prov.IsEliminado = 0 OR	prov.IsEliminado IS NULL )
		 ORDER BY AP_Usuario.Nombre DESC
end