-- =============================================
-- Author:		Pedro Acuña
-- Create date: 13-08-2019
-- Description:	Carga de contratos filtrados por el proveedor
-- =============================================

CREATE PROCEDURE Sp_CargaContratos @IdProveedor INT
AS
BEGIN
    SELECT DISTINCT
           CO_Contrato.NumeroContrato,
           CO_AreaContractual.NombreAreaContractual,
           CO_Contrato.NumeroContrato + ' - ' + CO_AreaContractual.NombreAreaContractual AS Contrato,
           CO_Contrato.IdContrato,
           CO_AreaContractual.IdAreaContractual
    FROM Adinco.dbo.AP_PerfilUsuario AS PU
        INNER JOIN Adinco.dbo.AP_Perfil
            ON PU.PerfilID = AP_Perfil.IdPerfil
        INNER JOIN Adinco.dbo.AP_Rol
            ON AP_Perfil.IdRol = AP_Rol.IdRol
        INNER JOIN Adinco.dbo.CO_Contrato
            ON AP_Perfil.IdContrato = CO_Contrato.IdContrato
        INNER JOIN Adinco.dbo.CO_AreaContractual
            ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
        INNER JOIN Petrovendor.dbo.S_UsuarioProveedor uProv
            ON CO_Contrato.IdContrato = uProv.IdContrato
        INNER JOIN Petrovendor.dbo.S_Proveedor prov
            ON uProv.IdProveedor = prov.IdProveedor
        INNER JOIN Adinco.dbo.CO_PeriodoContrato per
            ON per.IdContrato = CO_Contrato.IdContrato
    WHERE ISNULL(prov.IsEliminado, 0) = 0
          AND prov.IdProveedor = @IdProveedor
    ORDER BY CO_Contrato.NumeroContrato DESC
END
