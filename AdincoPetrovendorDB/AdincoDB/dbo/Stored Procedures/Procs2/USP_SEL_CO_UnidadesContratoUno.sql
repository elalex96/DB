IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_UnidadesContratoUno'
)
    DROP PROCEDURE USP_SEL_CO_UnidadesContratoUno;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CO_UnidadesContratoUno]
    @UsuarioId INT,
    @ContratoId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdUnidad,
           Unidad
    FROM CO_Unidad (NOLOCK)
    WHERE IdContrato = 1;
END