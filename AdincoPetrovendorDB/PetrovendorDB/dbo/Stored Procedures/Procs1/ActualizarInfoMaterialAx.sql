CREATE PROCEDURE ActualizarInfoMaterialAx
@IdProveedor INT,
@IdMaterialAx INT,
@IdUnidad INT,
@DescripcionCorta NVARCHAR(MAX),
@IdUsuario INT
AS
BEGIN
    DECLARE @IdUnidadActual INT

    UPDATE m
    SET m.DescripcionCorta = @DescripcionCorta,
        m.DescripcionLarga = @DescripcionCorta
    FROM dbo.AX_MATERIAL ax
        INNER JOIN dbo.MM_Material m
            ON ax.IdMaterialPetrov = m.IdMaterial
    WHERE m.IdProveedor = @IdProveedor
          AND ax.IdMaterialAx = @IdMaterialAx
	
    SELECT @IdUnidadActual = m.IdUnidad
    FROM dbo.AX_MATERIAL ax
        INNER JOIN dbo.MM_Material m
            ON ax.IdMaterialPetrov = m.IdMaterial
    WHERE m.IdProveedor = @IdProveedor
          AND ax.IdMaterialAx = @IdMaterialAx
	
	INSERT INTO dbo.AX_HistoricoMaterial
	(
	    IdMaterialAx,
	    Descripcion,
	    FechaModificado,
	    UsuarioModifico,
	    IdUnidadAnterior
	)
	SELECT @IdMaterialAx, @DescripcionCorta, GETDATE(), @IdUsuario, @IdUnidadActual

    IF (@IdUnidad <> @IdUnidadActual)
    BEGIN
        UPDATE m
        SET m.IdUnidad = @IdUnidad
        FROM dbo.AX_MATERIAL ax
            INNER JOIN dbo.MM_Material m
                ON ax.IdMaterialPetrov = m.IdMaterial
        WHERE m.IdProveedor = @IdProveedor
              AND ax.IdMaterialAx = @IdMaterialAx
    END
END







