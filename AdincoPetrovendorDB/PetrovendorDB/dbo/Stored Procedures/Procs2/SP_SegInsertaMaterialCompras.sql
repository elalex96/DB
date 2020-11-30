-- =============================================
-- Author:		Alexander G 
-- Create date: 13-07-17
-- Description:	Insertar Material y Compra
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegInsertaMaterialCompras] 
	-- Add the parameters for the stored procedure here
	@SubFamilia nvarchar(MAX),
	@Familia nvarchar(max),
	@Marca nvarchar(MAX),
	@Modelo nvarchar(MAX),
	@DescripcionCorta nvarchar(MAX),
	@DescripcionLarga nvarchar(MAX),
	@NumeroParte nvarchar(MAX),
	@IdUnidadAlterna int,
	@Presentacion nvarchar(MAX),
	@Consumible bit,
	@Inventariable bit, 
	@TiempoEntregaEstimado int,
	--@Costo varchar(200),
	--@IdMoneda int, 
	--@Ubicacion nvarchar(MAX),
	@Imagen nvarchar(MAX),
	@FichaTecnica nvarchar(MAX),
	@IdProveedor int,
	@IdUsuario int,
	@IdGrupoCBSH int,
	@IdActividadCBSH int,
	@IdMaestro int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
			DECLARE @IdUnidadF int;
			--DECLARE @IdMonedaF int; 
			DECLARE @IdUnidadAlternaF int;
			DECLARE @TiempoEntregaEstimadoF int;
			--DECLARE @CostoF money;
            DECLARE @IdMaterialNuevo int;
			DECLARE @IdTipoMaterial int;
			DECLARE @IdSubFamilia int;
			DECLARE @IdUnidad int

		
	SET NOCOUNT ON;
	IF @IdUnidad <> 0 
		SET @IdUnidadF=@IdUnidad
	
	--IF @IdMoneda <> 0 
	--SET @IdMonedaF=@IdMoneda

	IF @IdUnidadAlterna <> 0 
	SET @IdUnidadAlternaF=@IdUnidadAlternaF

	IF @TiempoEntregaEstimado <> 0 
	SET @TiempoEntregaEstimadoF=@TiempoEntregaEstimado

	--IF @Costo <> '' 
	--SET @CostoF=@Costo



	
    -- Insert statements for procedure here

	IF @Imagen IS NULL
	BEGIN
	SET @Imagen = ''
	END

	IF @FichaTecnica IS NULL
	BEGIN
	SET @FichaTecnica = ''
	END

	IF @IdMaterialNuevo IS NULL
	BEGIN
	SET @IdMaterialNuevo = ''
	END
	
	SET @IdSubFamilia = (SELECT GFDUT.IdSubFamilia
	FROM PV_MM_GrupoFamiliaSubFamiliaUnidadTipo AS GFDUT 
	INNER JOIN PV_MM_MaterialSubFamilia AS MSF ON MSF.IdSubFamilia = GFDUT.IdSubFamilia
	INNER JOIN PV_MM_MaterialFamilia AS MF ON MF.IdFamilia = GFDUT.IdFamilia
	WHERE MSF.SubFamilia = @SubFamilia AND MF.Familia = @Familia)

	SET @IdTipoMaterial = (SELECT GFDUT.IdTipoMaterial
	FROM PV_MM_GrupoFamiliaSubFamiliaUnidadTipo AS GFDUT 
	INNER JOIN PV_MM_MaterialSubFamilia AS MSF ON MSF.IdSubFamilia = GFDUT.IdSubFamilia
	INNER JOIN PV_MM_MaterialFamilia AS MF ON MF.IdFamilia = GFDUT.IdFamilia
	WHERE MSF.SubFamilia = @SubFamilia AND MF.Familia = @Familia)

	SET @IdUnidad = (SELECT GFDUT.IdUnidad
	FROM PV_MM_GrupoFamiliaSubFamiliaUnidadTipo AS GFDUT 
	INNER JOIN PV_MM_MaterialSubFamilia AS MSF ON MSF.IdSubFamilia = GFDUT.IdSubFamilia
	INNER JOIN PV_MM_MaterialFamilia AS MF ON MF.IdFamilia = GFDUT.IdFamilia
	WHERE MSF.SubFamilia = @SubFamilia AND MF.Familia = @Familia)

	INSERT INTO dbo.MM_Material
	(
	IdProveedor,
	IdSubFamilia,
	IdTipo,
	Marca,
	Modelo,
	DescripcionCorta,
	DescripcionLarga,
	NumeroParte,
	IdUnidad,
	IdUnidadAlterna,
	Presentacion,
	Consumible,
	Inventariable,
	TiempoEntregaEstimadoDias,
	--Costo,
	--IdMoneda,
	--Ubicacion,
	CreadoPor,
	Activo,
	FechaAlta,
	IsPublico,
	IdGrupo_CBSH,
	IdActividad_CBSH,
	IdMaestro,
	Imagen,
	FichaTecnica)
	VALUES
	(
	@IdProveedor,
	@IdSubFamilia,
	@IdTipoMaterial,
	@Marca,
	@Modelo,
	@DescripcionCorta,
	@DescripcionLarga,
	@NumeroParte,
	@IdUnidad,
	@IdUnidadAlterna,
	@Presentacion,
	@Consumible,
	@Inventariable, 
	@TiempoEntregaEstimadoF,
	--@CostoF,
	--@IdMonedaF, 
	--@Ubicacion,
	@IdUsuario,
	1,
	GETDATE(),
	0,
	@IdGrupoCBSH,
	@IdActividadCBSH,
	@IdMaestro,
	@Imagen,
	@FichaTecnica
	)

	SET @IdMaterialNuevo = (SELECT @@IDENTITY)
	
	IF @IdMaterialNuevo >0
	BEGIN
		INSERT INTO dbo.MM_MaterialesCompraProveedor
		(
		IdProveedor,
		IdMaterial,
		CreadoPor,
		CreadoEn,
		IsActivo,
		IsEliminado
		)
		VALUES
		(
		@IdProveedor,
		@IdMaterialNuevo,
		@IdUsuario,
		GETDATE(),
		1,
		0
		)
		SELECT 'Material Agregado Exitosamente' AS Respose
	END
END
