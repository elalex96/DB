IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ObtenerTodosLosContratos'
)
    DROP PROCEDURE USP_SEL_CO_ObtenerTodosLosContratos;
GO

CREATE PROCEDURE USP_SEL_CO_ObtenerTodosLosContratos
    @ContratoId INT,
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IdContrato AS ContratoIdSeleccionado,
           CONCAT(CO_Contrato.NumeroContrato, ' - ', ISNULL(CO_AreaContractual.NombreAreaContractual, '')) AS Contrato
    FROM CO_Contrato (NOLOCK)
        JOIN CO_AreaContractual (NOLOCK)
            ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
               AND ISNULL(CO_Contrato.Activo, 0) = 1
               AND ISNULL(CO_AreaContractual.Activo, 0) = 1
    ORDER BY CO_Contrato.NumeroContrato ASC;
END;