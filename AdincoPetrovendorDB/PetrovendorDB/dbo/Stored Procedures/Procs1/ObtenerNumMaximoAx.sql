CREATE PROCEDURE ObtenerNumMaximoAx
@IdProveedor INT
AS
BEGIN
    
	SELECT ISNULL(MAX(ax.IdMaterialAx), 0) + 1
    FROM dbo.AX_MATERIAL ax
        INNER JOIN dbo.MM_Material m
            ON ax.IdMaterialPetrov = m.IdMaterial
    WHERE m.IdProveedor = @IdProveedor

END







