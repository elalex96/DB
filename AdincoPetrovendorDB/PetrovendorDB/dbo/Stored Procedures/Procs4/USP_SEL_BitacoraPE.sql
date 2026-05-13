IF EXISTS
(
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[USP_SEL_BitacoraPE]')
      AND type = 'P'
)
    DROP PROCEDURE [dbo].[USP_SEL_BitacoraPE];
GO

CREATE PROCEDURE [dbo].[USP_SEL_BitacoraPE]
(
    @IdContrato INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        Fecha,
        Tipo,
        Mensaje,
        Detalle,
        AP_Usuario.Nombre,
        ContratoId
    FROM AP_Bitacora (NOLOCK)
    INNER JOIN AP_Usuario (NOLOCK)
    ON AP_Bitacora.UsuarioId = AP_Usuario.UsuarioID
    WHERE ContratoId = @IdContrato
      AND Tipo IN (N'Importacion PE', N'Importacion PI', N'Importacion PE/PI')
    ORDER BY Fecha DESC;
END
GO
