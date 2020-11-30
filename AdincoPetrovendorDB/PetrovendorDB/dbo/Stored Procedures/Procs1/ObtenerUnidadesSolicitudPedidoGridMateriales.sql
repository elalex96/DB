-- =============================================  
CREATE PROCEDURE ObtenerUnidadesSolicitudPedidoGridMateriales
@IdMaterial INT,
@IdProveedor INT
AS
BEGIN
    IF (@IdMaterial = -1) --para cargar todos los materiales del grid
    BEGIN
        SELECT unidad.IdUnidad,
               unidad.Unidad
        FROM dbo.PV_MM_MaterialUnidad unidad
            INNER JOIN dbo.MM_Material m
                ON m.IdUnidad = unidad.IdUnidad
        WHERE m.Activo = 1
              AND m.IdProveedor = @IdProveedor
        UNION
        SELECT unidad.IdUnidad,
               unidad.Unidad
        FROM dbo.PV_MM_MaterialUnidad unidad
            INNER JOIN dbo.MM_Material m
                ON m.IdUnidad_1 = unidad.IdUnidad
        WHERE m.Activo = 1
              AND m.IdProveedor = @IdProveedor
        UNION
        SELECT unidad.IdUnidad,
               unidad.Unidad
        FROM dbo.PV_MM_MaterialUnidad unidad
            INNER JOIN dbo.MM_Material m
                ON m.IdUnidad_2 = unidad.IdUnidad
        WHERE m.Activo = 1
              AND m.IdProveedor = @IdProveedor
        UNION
        SELECT unidad.IdUnidad,
               unidad.Unidad
        FROM dbo.PV_MM_MaterialUnidad unidad
            INNER JOIN dbo.MM_Material m
                ON m.IdUnidad_3 = unidad.IdUnidad
        WHERE m.Activo = 1
              AND m.IdProveedor = @IdProveedor
    END
    ELSE
    BEGIN
        SELECT unidad.IdUnidad,
               unidad.Unidad
        FROM dbo.PV_MM_MaterialUnidad unidad
            INNER JOIN dbo.MM_Material m
                ON m.IdUnidad = unidad.IdUnidad
        WHERE m.Activo = 1
              AND m.IdMaterial = @IdMaterial
              AND m.IdProveedor = @IdProveedor
        UNION
        SELECT unidad.IdUnidad,
               unidad.Unidad
        FROM dbo.PV_MM_MaterialUnidad unidad
            INNER JOIN dbo.MM_Material m
                ON m.IdUnidad_1 = unidad.IdUnidad
        WHERE m.Activo = 1
              AND m.IdMaterial = @IdMaterial
              AND m.IdProveedor = @IdProveedor
        UNION
        SELECT unidad.IdUnidad,
               unidad.Unidad
        FROM dbo.PV_MM_MaterialUnidad unidad
            INNER JOIN dbo.MM_Material m
                ON m.IdUnidad_2 = unidad.IdUnidad
        WHERE m.Activo = 1
              AND m.IdMaterial = @IdMaterial
              AND m.IdProveedor = @IdProveedor
        UNION
        SELECT unidad.IdUnidad,
               unidad.Unidad
        FROM dbo.PV_MM_MaterialUnidad unidad
            INNER JOIN dbo.MM_Material m
                ON m.IdUnidad_3 = unidad.IdUnidad
        WHERE m.Activo = 1
              AND m.IdMaterial = @IdMaterial
              AND m.IdProveedor = @IdProveedor
    END
END