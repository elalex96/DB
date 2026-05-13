-- =============================================
-- Author:		Daniel Cruz 
-- Create date: 21-03-17
-- Description:	Actualizar Material = Producto - Servicio
-- =============================================
	CREATE PROCEDURE [dbo].[SP_MM_ActualizarMaterial_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdMaterial INT,
	@Con_CatalogoMaestro BIT,

--@SubFamilia            NVARCHAR(MAX),
--@Familia               NVARCHAR(max),

--@IdProveedor             INT,
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
@IdUsuario               INT,
@IdMaestro               INT,
--@IsClasificacionMaestro  BIT,
@IdBienServicioEconomica INT,
--@IdTipoProveedor         INT,
@IdUnidadOpcional_1      INT,
@IdUnidadOpcional_2      INT,
@IdUnidadOpcional_3      INT,
@IdTipoCatalogoMaestro   INT,
/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @FechaRegistro DATETIME
  /*--------------------
  --------------------*/ 


--@IdUnidadAlterna         INT,
--@Costo                   varchar(200),
--@IdMoneda                int, 
--@Ubicacion               nvarchar(MAX),
--@IdGrupoCBSH             INT,
--@IdActividadCBSH         INT,




AS
BEGIN

		--DECLARE @IdUnidadF              INT;
		--DECLARE @IdMonedaF int; 
		--DECLARE @IdUnidadAlternaF       INT;
		--DECLARE @TiempoEntregaEstimado  INT;
		--DECLARE @CostoF money;
        --DECLARE @IdMaterialNuevo        INT;
		--DECLARE @IdTipoMaterial         INT;
		--DECLARE @IdSubFamilia           INT;
		--DECLARE @IdUnidad               INT;

		--IF @IdUnidad <> 0 
		--SET @IdUnidadF=@IdUnidad

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

		IF (@IdSubFamilia = 0)
		SET @IdSubFamilia = NULL 

		IF(@IdBienServicioEconomica = 0)
			SET @IdBienServicioEconomica = NULL

	SET NOCOUNT ON;

	IF (@Con_CatalogoMaestro = 1)
	BEGIN

	UPDATE dbo.MM_Material
	SET
	    --IdProveedor = @IdProveedor,
	    IdSubFamilia = NULL,
	    IdUnidad = @IdUnidadPredeterminada,
	    --IdTipo = @IdTipoProveedor,
	    DescripcionCorta = @DescripcionCorta,
	    DescripcionLarga = @DescripcionLarga,
	    Modelo = @Modelo,
	    NumeroParte = @NumeroParte,
	    Presentacion = @Presentacion,
	    Consumible = @Consumible,
	    Inventariable = @Inventariable,
	    TiempoEntregaEstimadoDias = @TiempoEntregaEstimado,
	    Marca = @Marca,
	    IsPublico = 1,
	    Imagen_real = @Imagen,
		Imagen_thumb = @ImagenThumb,
	    FichaTecnica = @FichaTecnica,
	    FechaActualizacion = GETDATE(),
	    --Activo = 1,
	    --IsEliminado = 1,
	    ModificadoPor = @IdUsuario,
	    IdMaestro = @IdMaestro,
	    IsClasificionMaestro = 1,
	    IdBienServicioEconomia = @IdBienServicioEconomica,
	    --IdTipoProveedor = @IdTipoProveedor,
	    IdUnidad_1 = @IdUnidadOpcional_1,
	    IdUnidad_2 = @IdUnidadOpcional_2,
	    IdUnidad_3 = @IdUnidadOpcional_3,
		IdTipoCatalogoMaestro = @IdTipoCatalogoMaestro
		WHERE IdMaterial = @IdMaterial

	 SELECT 'Material Agregado Exitosamente' AS Respose

	END

	IF (@Con_CatalogoMaestro = 0)
	BEGIN
		
	UPDATE dbo.MM_Material
	SET
	    --IdProveedor = @IdProveedor,
	    IdSubFamilia = NULL,
	    IdUnidad = @IdUnidadPredeterminada,
	    --IdTipo = @IdTipoProveedor,
	    DescripcionCorta = @DescripcionCorta,
	    DescripcionLarga = @DescripcionLarga,
	    Modelo = @Modelo,
	    NumeroParte = @NumeroParte,
	    Presentacion = @Presentacion,
	    Consumible = @Consumible,
	    Inventariable = @Inventariable,
	    TiempoEntregaEstimadoDias = @TiempoEntregaEstimado,
	    Marca = @Marca,
	    IsPublico = 1,
	    Imagen_real = @Imagen,
		Imagen_thumb = @ImagenThumb,
	    FichaTecnica = @FichaTecnica,
	    --Activo = 1,
	    --IsEliminado = 1,
	    ModificadoPor = @IdUsuario,
		FechaActualizacion = GETDATE(),
	    IdMaestro = NULL,
	    IsClasificionMaestro = 0,
	    IdBienServicioEconomia = @IdBienServicioEconomica,
	    --IdTipoProveedor = @IdTipoProveedor,
	    IdUnidad_1 = @IdUnidadOpcional_1,
	    IdUnidad_2 = @IdUnidadOpcional_2,
	    IdUnidad_3 = @IdUnidadOpcional_3,
		IdTipoCatalogoMaestro = @IdTipoCatalogoMaestro
		WHERE IdMaterial = @IdMaterial

	 SELECT 'Material Actualizado Exitosamente' AS Respose

	END

END

