CREATE PROCEDURE [dbo].[Mobile_ContratosPorUsuario]
	@IdUsuario int = 0
AS
BEGIN
--Luis David De La Cruz Bautista
SELECT distinct    
CO_Contrato.IdContrato, CO_AreaContractual.IdAreaContractual,CO_Contrato.NumeroContrato, CO_AreaContractual.NombreAreaContractual, CO_Contrato.NumeroContrato + ' - ' + CO_AreaContractual.NombreAreaContractual AS Contrato
                          
FROM            AP_PerfilUsuario AS PU INNER JOIN
                         AP_Usuario ON PU.UsuarioID = AP_Usuario.UsuarioID INNER JOIN
                         AP_Perfil ON PU.PerfilID = AP_Perfil.IdPerfil INNER JOIN
                         AP_Rol ON AP_Perfil.IdRol = AP_Rol.IdRol INNER JOIN
                         CO_Contrato ON AP_Perfil.IdContrato = CO_Contrato.IdContrato INNER JOIN
                         CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
WHERE        (@IdUsuario = PU.UsuarioID)

order by NumeroContrato desc
end

