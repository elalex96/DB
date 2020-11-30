CREATE PROCEDURE AgregarMaterialAx
@IdProveedor INT,
@Item NVARCHAR(MAX),
@IdUnidad INT,
@IdUsuario INT,
@IdMaterialAx INT
AS
BEGIN
    DECLARE @IdMaterial INT



    --si hay mas de 1 registro entonces se esta repitiendo arrojar la excepcion para que haga rollback
    IF EXISTS
    (   SELECT 1
        FROM dbo.AX_MATERIAL ax
            INNER JOIN dbo.MM_Material m
                ON ax.IdMaterialPetrov = m.IdMaterial
        WHERE m.IdProveedor = @IdProveedor
              AND ax.IdMaterialAx = @IdMaterialAx)
    BEGIN
        RAISERROR('Id Material Ax ya registrado', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO dbo.MM_Material
        (
            IdProveedor,
            IdSubFamilia,
            IdUnidad,
            IdTipo,
            DescripcionCorta,
            DescripcionLarga,
            Modelo,
            NumeroParte,
            Presentacion,
            Consumible,
            Inventariable,
            TiempoEntregaEstimadoDias,
            Marca,
            IsPublico,
            FechaAlta,
            Activo,
            IsEliminado,
            CreadoPor,
            IdTipoCatalogoMaestro,
            IdTipoProveedor
        )
        SELECT @IdProveedor,
               NULL,
               @IdUnidad,
               0,
               @Item,
               @Item,
               '',
               '',
               '',
               0,
               0,
               0,
               '',
               0,
               GETDATE(),
               1,
               0,
               @IdUsuario,
               2,
               1

        SELECT @IdMaterial = SCOPE_IDENTITY()

        INSERT INTO dbo.AX_MATERIAL (IdMaterialAx, IdMaterialPetrov)
        VALUES
        (   @IdMaterialAx, -- IdMaterialAx - bigint
            @IdMaterial    -- IdMaterialPetrov - int
        )
    END



END







