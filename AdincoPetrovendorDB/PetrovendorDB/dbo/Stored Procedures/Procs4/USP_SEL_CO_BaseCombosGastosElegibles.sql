IF EXISTS
(
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[USP_SEL_CO_BaseCombosGastosElegibles]')
          AND type = 'P'
)
BEGIN
    DROP PROCEDURE [dbo].[USP_SEL_CO_BaseCombosGastosElegibles];
END
GO

CREATE PROCEDURE USP_SEL_CO_BaseCombosGastosElegibles
    @IdContrato INT = 0,
    @IdUsuario INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        IdPresupuesto,
        Presupuesto,
        [CGE Aprobado Pemex] AS FechaAprobadoPemex
    FROM GastosAmatitlan2020 WITH (NOLOCK)
    WHERE IdPresupuesto IS NOT NULL
    AND Presupuesto IS NOT NULL
    AND MesPresentacion IS NOT NULL
    AND [Estatus Certificado] = 'Certificado GE Aprobado CACI'
    AND [CGE Aprobado Pemex] IS NOT NULL
    AND LTRIM(RTRIM([CGE Aprobado Pemex])) <> ''
    ORDER BY Presupuesto, [CGE Aprobado Pemex];
END