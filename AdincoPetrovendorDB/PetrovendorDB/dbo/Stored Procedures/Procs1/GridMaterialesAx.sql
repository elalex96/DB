CREATE PROCEDURE GridMaterialesAx @IdProveedor INT
AS
BEGIN
    SELECT REPLICATE('0', (9 - LEN(IdMaterialAx))) + LTRIM(IdMaterialAx) AS IdMaterialAx,
           ax.IdMaterialPetrov,
           m.DescripcionCorta,
		   m.IdUnidad 
    FROM dbo.AX_MATERIAL ax
        LEFT JOIN dbo.MM_Material m
            ON ax.IdMaterialPetrov = m.IdMaterial
    WHERE m.IdProveedor = @IdProveedor
END







