-- =============================================
-- Author:		ALEXANDER G
-- Create date: 21/12/2107
-- Description:	IMPORTAR MATERIAL DEL CATÁLOGO DE MATERIALES DEL OPERADOR
-- =============================================
-- =============================================
-- Author:		DANIEL AC 
-- Create date: 10/01/2018
-- Description:	AGREGUE VALIDACIÓN DE DUPLICADO 
-- =============================================
-- =============================================
-- Author: Daniel AC
-- Create date: 13-08-2019
-- Description: Add  No Parte y Marca al material importado
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_DuplicarMaterialProveedor_MV1_5]
    -- Add the parameters for the stored procedure here
    @IdMaterial INT,
    @IdProveedor INT,
    @IdCreadoPor INT,
    @DuplicarMaterial BIT,
	@IdContrato    INT,
	@IdUsuario     INT,
	@FechaRegistro DATETIME

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @IdTipoProveedor INT;
    DECLARE @FechaAlta DATETIME;
    DECLARE @IdNuevoMaterial INT;
    DECLARE @ExisteMaterialMiCatalogo INT;
	DECLARE @IdProveedorOperador INT 
    -- Donde @IdTipoProveedor = 2; Proveedor de Petrovendor
    SET @IdTipoProveedor = 2;
    

   IF @DuplicarMaterial = 0
   BEGIN

        SET @ExisteMaterialMiCatalogo =
        (
            SELECT COUNT(MI.IdMaterialImportado)
            FROM MM_MaterialImportado MI
                INNER JOIN MM_Material MP
                    ON MP.IdMaterial = MI.IdMaterial
                       AND MP.Activo = 1
                       AND ISNULL(MP.IsEliminado, 0) = 0
                INNER JOIN MM_Material MO
                    ON MO.IdMaterial = MI.IdMaterialOperador
            WHERE MI.IdMaterialOperador = @IdMaterial 
			AND MP.IdProveedor=@IdProveedor
			AND MP.DescripcionCorta=MO.DescripcionCorta 
			AND MP.DescripcionLarga=MO.DescripcionLarga 
			AND MP.IdUnidad=MO.IdUnidad 
			AND MP.IdTipoCatalogoMaestro=MO.IdTipoCatalogoMaestro
			AND MP.Modelo = MO.Modelo 
			AND MP.NumeroParte=MO.NumeroParte --ADD
			AND MP.Marca=MO.Marca --ADD
			AND ISNULL(MP.IdUnidad_1,0)=ISNULL(MO.IdUnidad_1,0)  
			AND ISNULL(MP.IdUnidad_2,0)=ISNULL(MO.IdUnidad_2,0)   
			AND ISNULL(MP.IdUnidad_3,0)=ISNULL(MO.IdUnidad_3,0) 
			AND ISNULL(MP.IdBienServicioEconomia,0)= ISNULL(MO.IdBienServicioEconomia,0)	
			AND ISNULL(MP.IdMaestro,0) = ISNULL(MO.IdMaestro,0)		  
        );



        IF @ExisteMaterialMiCatalogo = 0
			BEGIN

				INSERT INTO dbo.MM_Material
				(
					IdProveedor,
					IdTipoProveedor,
					CreadoPor,
					FechaAlta,
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
					Imagen,
					FichaTecnica,
					Activo,
					IsEliminado,
					IdMaestro,
					IsClasificionMaestro,
					IdBienServicioEconomia,
					IdUnidad_1,
					IdUnidad_2,
					IdUnidad_3,
					IdTipoCatalogoMaestro
				)
				SELECT @IdProveedor,	 --- PROVEEDOR ACTUAL 
					   @IdTipoProveedor, ---PROVEEDOR PETROVENDOR
					   @IdCreadoPor,    
					   GETDATE(),
					   IdSubFamilia,
					   IdUnidad,
					   IdTipo,
					   DescripcionCorta,
					   DescripcionLarga,
					   Modelo,
					   NumeroParte,
					   '',
					   0,
					   0,
					   0,
					   Marca,
					   IsPublico,
					   '',
					   '',
					   1,
					   0,
					   IdMaestro,
					   IsClasificionMaestro,
					   IdBienServicioEconomia,
					   IdUnidad_1,
					   IdUnidad_2,
					   IdUnidad_3,
					   IdTipoCatalogoMaestro
				FROM dbo.MM_Material
				WHERE IdMaterial = @IdMaterial;


				SET @IdNuevoMaterial =
				(
					SELECT @@IDENTITY
				);

				SET @IdProveedorOperador = (SELECT IdProveedor FROM dbo.MM_Material WHERE IdMaterial=@IdMaterial )

				INSERT INTO dbo.MM_MaterialImportado
				(
					IdMaterial,
					IdMaterialOperador,
					CreadorEl,
					CreadorPor,
					IdProveedorOperador
				)
				VALUES
				(   @IdNuevoMaterial,         -- IdMaterial - int
					@IdMaterial,         -- IdMaterialOperador - int
					GETDATE(), -- CreadorEl - datetime
					@IdCreadoPor,         -- CreadorPor - int
					@IdProveedorOperador          -- IdProveedorOperador - int
					)

				SELECT 'MATERIAL INSERTADO',@IdNuevoMaterial
			END;
		ELSE
			BEGIN 		

				SELECT 'MATERIAL DUPLICADO', DescripcionCorta
				FROM dbo.MM_Material 
				WHERE IdMaterial = @IdMaterial

			END 
   END;
   ELSE 
	BEGIN 
		INSERT INTO dbo.MM_Material
				(
					IdProveedor,
					IdTipoProveedor,
					CreadoPor,
					FechaAlta,
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
					Imagen,
					FichaTecnica,
					Activo,
					IsEliminado,
					IdMaestro,
					IsClasificionMaestro,
					IdBienServicioEconomia,
					IdUnidad_1,
					IdUnidad_2,
					IdUnidad_3,
					IdTipoCatalogoMaestro
				)
				SELECT @IdProveedor,	 --- PROVEEDOR ACTUAL 
					   @IdTipoProveedor, ---PROVEEDOR PETROVENDOR
					   @IdCreadoPor,    
					   GETDATE(),
					   IdSubFamilia,
					   IdUnidad,
					   IdTipo,
					   DescripcionCorta,
					   DescripcionLarga,
					   Modelo,
					   NumeroParte,
					   '',
					   0,
					   0,
					   0,
					   Marca,
					   IsPublico,
					   '',
					   '',
					   1,
					   0,
					   IdMaestro,
					   IsClasificionMaestro,
					   IdBienServicioEconomia,
					   IdUnidad_1,
					   IdUnidad_2,
					   IdUnidad_3,
					   IdTipoCatalogoMaestro
				FROM dbo.MM_Material
				WHERE IdMaterial = @IdMaterial;


				SET @IdNuevoMaterial =
				(
					SELECT @@IDENTITY
				);

				SET @IdProveedorOperador = (SELECT IdProveedor FROM dbo.MM_Material WHERE IdMaterial=@IdMaterial )

				INSERT INTO dbo.MM_MaterialImportado
				(
					IdMaterial,
					IdMaterialOperador,
					CreadorEl,
					CreadorPor,
					IdProveedorOperador
				)
				VALUES
				(   @IdNuevoMaterial,         -- IdMaterial - int
					@IdMaterial,         -- IdMaterialOperador - int
					GETDATE(), -- CreadorEl - datetime
					@IdCreadoPor,         -- CreadorPor - int
					@IdProveedorOperador          -- IdProveedorOperador - int
					)

				SELECT 'MATERIAL INSERTADO',@IdNuevoMaterial
	END 

END 



