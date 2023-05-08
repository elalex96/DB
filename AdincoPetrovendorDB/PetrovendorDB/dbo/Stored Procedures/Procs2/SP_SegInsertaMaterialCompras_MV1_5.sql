-- =============================================
-- Author:	ABEL RIVERA
-- Create date: 26/12/2017
-- Description: AGREGAR MATERIAL 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_SegInsertaMaterialCompras_MV1_5]

@Con_CatalogoMaestro BIT,

--@SubFamilia            NVARCHAR(MAX),
--@Familia               NVARCHAR(max),

@IdProveedor             INT,
@IdSubFamilia            INT,
@IdUnidadPredeterminada  INT,
--@IdTipo                  INT,
@DescripcionCorta        NVARCHAR(MAX),
@DescripcionLarga	     NVARCHAR(MAX),
@Modelo                  NVARCHAR(MAX),
@NumeroParte             NVARCHAR(MAX),
@Presentacion            NVARCHAR(MAX),
@Consumible              BIT,
@Inventariable           BIT, 
@TiempoEntregaEstimado   INT,
@Marca                   NVARCHAR(MAX),
@Imagen                  IMAGE,
@ImagenThumb             IMAGE,
@FichaTecnica            NVARCHAR(MAX),
@IdMaestro               INT,
--@IsClasificacionMaestro  BIT,
@IdBienServicioEconomica INT,
@IdTipoProveedor         INT,
@IdUnidadOpcional_1      INT,
@IdUnidadOpcional_2      INT,
@IdUnidadOpcional_3      INT,
@IdTipoCatalogoMaestro   INT, 


	/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME 
  /*--------------------
  --------------------*/

AS
BEGIN


		IF (@TiempoEntregaEstimado IS NULL)
		    SET @TiempoEntregaEstimado = 0

		IF (@Imagen IS NULL)
			SET @Imagen = ''

		IF (@FichaTecnica IS NULL)
			SET @FichaTecnica = ''

		IF (@IdUnidadPredeterminada = 0)
		    SET @IdUnidadPredeterminada = NULL 
		IF (@IdUnidadOpcional_1 = 0)
			SET @IdUnidadOpcional_1 = NULL 
		IF (@IdUnidadOpcional_2 = 0)
			SET @IdUnidadOpcional_2 = NULL 
		IF (@IdUnidadOpcional_3 = 0)
			SET @IdUnidadOpcional_3 = NULL 

	    IF(@IdSubFamilia = 0)
			SET @IdSubFamilia = NULL

		  IF(@IdBienServicioEconomica = 0)
			SET @IdBienServicioEconomica = NULL


	SET NOCOUNT ON;

	IF (@Con_CatalogoMaestro = 1)
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
	    Imagen_real,
		Imagen_thumb,
	    FichaTecnica,
	    FechaAlta,
	    Activo,
	    IsEliminado,
	    CreadoPor,
	    ModificadoPor,
	    IdMaestro,
	    IsClasificionMaestro,
	    IdBienServicioEconomia,
	    IdTipoProveedor,
	    IdUnidad_1,
	    IdUnidad_2,
	    IdUnidad_3,
		IdTipoCatalogoMaestro
	)
	VALUES
	(   
	    @IdProveedor,               -- IdProveedor - int
	    @IdSubFamilia,              -- IdSubFamilia - int
	    @IdUnidadPredeterminada,    -- IdUnidad - int
	    NULL,                       -- IdTipo - int
	    @DescripcionCorta,          -- DescripcionCorta - nvarchar(max)
	    @DescripcionLarga,          -- DescripcionLarga - nvarchar(max)
	    @Modelo,                    -- Modelo - nvarchar(max)
	    @NumeroParte,               -- NumeroParte - nvarchar(max)
	    @Presentacion,              -- Presentacion - nvarchar(max)
	    @Consumible,                -- Consumible - bit
	    @Inventariable,             -- Inventariable - bit
	    @TiempoEntregaEstimado,     -- TiempoEntregaEstimadoDias - int
	    @Marca,                     -- Marca - nvarchar(200)
	    0,                          -- IsPublico - bit
	    @Imagen,					-- Imagen_real - Image
		@ImagenThumb,               -- Imagen_thumb - Image
	    @FichaTecnica,              -- FichaTecnica - nvarchar(max)
	    GETDATE(),                  -- FechaAlta - datetime
	    1,                          -- Activo - bit
	    0,                          -- IsEliminado - bit 
	    @IdUsuario,                 -- CreadoPor - int
	    0,                          -- ModificadoPor - int
	    @IdMaestro,                 -- IdMaestro - int
	    1,                          -- IsClasificionMaestro - bit
	    @IdBienServicioEconomica,   -- IdBienServicioEconomia - int
	    @IdTipoProveedor,           -- IdTipoProveedor - int
	    @IdUnidadOpcional_1,        -- IdUnidad_1 - int
	    @IdUnidadOpcional_2,        -- IdUnidad_2 - int
	    @IdUnidadOpcional_3,         -- IdUnidad_3 - int
		@IdTipoCatalogoMaestro
	 )

	 SELECT 'Material Agregado Exitosamente' AS Respose

	END

	IF (@Con_CatalogoMaestro = 0)
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
	    Imagen_real,
		Imagen_thumb,
	    FichaTecnica,
	    FechaAlta,
	    Activo,
	    IsEliminado,
	    CreadoPor,
	    ModificadoPor,
	    IdMaestro,
	    IsClasificionMaestro,
	    IdBienServicioEconomia,
	    IdTipoProveedor,
	    IdUnidad_1,
	    IdUnidad_2,
	    IdUnidad_3,
		IdTipoCatalogoMaestro
	)
	VALUES
	(   
	    @IdProveedor,               -- IdProveedor - int
	    NULL,                       -- IdSubFamilia - int
	    @IdUnidadPredeterminada,    -- IdUnidad - int
	    NULL,                       -- IdTipo - int
	    @DescripcionCorta,          -- DescripcionCorta - nvarchar(max)
	    @DescripcionLarga,          -- DescripcionLarga - nvarchar(max)
	    @Modelo,                    -- Modelo - nvarchar(max)
	    @NumeroParte,               -- NumeroParte - nvarchar(max)
	    @Presentacion,              -- Presentacion - nvarchar(max)
	    @Consumible,                -- Consumible - bit
	    @Inventariable,             -- Inventariable - bit
	    @TiempoEntregaEstimado,     -- TiempoEntregaEstimadoDias - int
	    @Marca,                     -- Marca - nvarchar(200)
	    0,                          -- IsPublico - bit
	    @Imagen,					-- Imagen_real - Image
		@ImagenThumb,               -- Imagen_thumb - Image
	    @FichaTecnica,              -- FichaTecnica - nvarchar(max)
	    GETDATE(),                  -- FechaAlta - datetime
	    1,                          -- Activo - bit
	    0,                          -- IsEliminado - bit 
	    @IdUsuario,                 -- CreadoPor - int
	    0,                          -- ModificadoPor - int
	    NULL,                       -- IdMaestro - int
	    0,                          -- IsClasificionMaestro - bit
	    @IdBienServicioEconomica,   -- IdBienServicioEconomia - int
	    @IdTipoProveedor,           -- IdTipoProveedor - int
	    @IdUnidadOpcional_1,        -- IdUnidad_1 - int
	    @IdUnidadOpcional_2,        -- IdUnidad_2 - int
	    @IdUnidadOpcional_3,        -- IdUnidad_3 - int
		@IdTipoCatalogoMaestro
	 )

	 SELECT 'Material Agregado Exitosamente' AS Respose

	END

END
