-- =============================================
-- Author:		Pedro Acuña
-- Create date: 10-01-2019
-- Description:	Carga de contratos para la carga del popUp de procura y la carga del combo de contratos en el login 
--				Se ocupa en Petrovendor
-- =============================================

CREATE PROCEDURE [dbo].[Sp_CargaContratosPorUsuario]
	-- Add the parameters for the stored procedure here
	@IdUsuario INT = 0
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SELECT	DISTINCT
				AP_Usuario.Nombre, AP_Usuario.Idioma, CO_Contrato.NumeroContrato, CO_AreaContractual.NombreAreaContractual ,
				CO_Contrato.NumeroContrato + ' - ' + CO_AreaContractual.NombreAreaContractual AS Contrato ,
				CO_Contrato.IdContrato, CO_AreaContractual.IdAreaContractual
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
				( PU.UsuarioID = @IdUsuario )
				AND (	prov.IsEliminado = 0
						OR	prov.IsEliminado IS NULL )
		 ORDER BY NumeroContrato DESC
	END
