
CREATE PROCEDURE ObtenerFlujosDEA @IdProveedor INT
AS
BEGIN

    SELECT FT.IdFlujoTarea,
           FT.Nombre,
           FT.Descripcion,
           TF.Nombre AS TipoFlujo
    FROM dbo.TA_FlujoTarea FT
        INNER JOIN dbo.TA_TipoFlujoTarea AS TF
            ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
    WHERE FT.IdProveedor = @IdProveedor
          AND FT.IdTipoOperacion = 2
          AND ISNULL(FT.Eliminado, 0) = 0

END


