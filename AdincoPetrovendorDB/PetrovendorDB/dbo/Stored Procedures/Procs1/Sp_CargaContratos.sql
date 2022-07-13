USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Sp_CargaContratos'
)
    DROP PROCEDURE Sp_CargaContratos;
/****** Object:  StoredProcedure [dbo].[Sp_CargaContratos]    Script Date: 12/07/2022 12:24:11 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 13-08-2019
-- Description:	Carga de contratos filtrados por el proveedor
-- =============================================
--=============================================
-- Author:		Daniel AC
-- Create date: 13/07/2022
-- Description:	Orden de tablas 
--=============================================
CREATE PROCEDURE [dbo].[Sp_CargaContratos] @IdProveedor INT
AS
BEGIN
    SELECT DISTINCT
           CO_Contrato.NumeroContrato,
           CO_AreaContractual.NombreAreaContractual,
           CO_Contrato.NumeroContrato + ' - ' + CO_AreaContractual.NombreAreaContractual AS Contrato,
           CO_Contrato.IdContrato,
           CO_AreaContractual.IdAreaContractual
    FROM Adinco.dbo.AP_PerfilUsuario AS PU (NOLOCK) 
        JOIN Adinco.dbo.AP_Perfil (NOLOCK) 
            ON PU.PerfilID = AP_Perfil.IdPerfil
        JOIN Adinco.dbo.AP_Rol (NOLOCK) 
            ON AP_Perfil.IdRol = AP_Rol.IdRol
        JOIN Adinco.dbo.CO_Contrato (NOLOCK) 
            ON AP_Perfil.IdContrato = CO_Contrato.IdContrato
        JOIN Adinco.dbo.CO_AreaContractual (NOLOCK) 
            ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
        JOIN Petrovendor.dbo.S_UsuarioProveedor uProv (NOLOCK) 
            ON CO_Contrato.IdContrato = uProv.IdContrato
        JOIN Petrovendor.dbo.S_Proveedor prov (NOLOCK) 
            ON uProv.IdProveedor = prov.IdProveedor
        JOIN Adinco.dbo.CO_PeriodoContrato per (NOLOCK) 
            ON CO_Contrato.IdContrato = per.IdContrato 
    WHERE ISNULL(prov.IsEliminado, 0) = 0
          AND prov.IdProveedor = @IdProveedor
    ORDER BY CO_Contrato.NumeroContrato DESC
END
