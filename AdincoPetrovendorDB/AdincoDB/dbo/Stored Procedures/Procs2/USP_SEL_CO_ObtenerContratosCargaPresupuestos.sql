IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ObtenerContratosCargaPresupuestos'
)
    DROP PROCEDURE USP_SEL_CO_ObtenerContratosCargaPresupuestos;
GO

CREATE PROCEDURE USP_SEL_CO_ObtenerContratosCargaPresupuestos 
    @UsuarioId INT,
    @ContratoId INT
AS
SET NOCOUNT ON;  
SELECT IdContrato,
       CO_Contrato.NumeroContrato + ' - ' + ISNULL(CO_AreaContractual.NombreAreaContractual, '') AS Contrato
FROM CO_Contrato (NOLOCK)
    INNER JOIN CO_AreaContractual (NOLOCK)
        ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
		AND ISNULL(CO_Contrato.Activo, 0) = 1   AND ISNULL(CO_AreaContractual.Activo , 0) = 1
ORDER BY CO_Contrato.NumeroContrato ASC