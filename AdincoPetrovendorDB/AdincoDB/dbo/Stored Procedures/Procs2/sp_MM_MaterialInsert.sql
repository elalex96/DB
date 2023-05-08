CREATE PROC [dbo].[sp_MM_MaterialInsert] 
    @IdAuxiliar nvarchar(MAX) = NULL,
    @IdEstadoMaterial int = NULL,
    @IdTipo int = NULL,
    @DescripcionCorta nvarchar(MAX) = NULL,
    @DescripcionLarga nvarchar(MAX),
    @IdMarca int = NULL,
    @Modelo nvarchar(MAX) = NULL,
    @NumeroParte nvarchar(MAX) = NULL,
    @IdUnidad int = NULL,
    @IdUnidadAlterna int = NULL,
    @Presentacion nvarchar(MAX) = NULL,
    @Consumible bit = NULL,
    @Inventariable bit = NULL,
    @Activo bit = NULL,
    @TiempoEntregaEstimadoDias int = NULL,
    @Costo money = NULL,
    @IdMoneda int = NULL,
    @IdTipoMaterial int = NULL,
    @IdGrupoDisciplina int = NULL,
    @IdFamilia int = NULL,
    @IdSubFamilia int = NULL,
    @Ubicacion nvarchar(MAX) = NULL,
    @CreadoPor int = NULL,
    @Marca nvarchar(MAX) = NULL,
    @FechaAlta datetime = NULL,
    @FechaAutorizacion datetime = NULL,
    @IsPublico bit = NULL,
    @IdAdminValidador int = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	INSERT INTO [dbo].[MM_Material] ([IdAuxiliar], [IdEstadoMaterial], [IdTipo], [DescripcionCorta], [DescripcionLarga], [IdMarca], [Modelo], [NumeroParte], [IdUnidad], [IdUnidadAlterna], [Presentacion], [Consumible], [Inventariable], [Activo], [TiempoEntregaEstimadoDias], [Costo], [IdMoneda], [IdTipoMaterial], [IdGrupoDisciplina], [IdFamilia], [IdSubFamilia], [Ubicacion], [CreadoPor], [Marca], [FechaAlta], [FechaAutorizacion], [IsPublico], [IdAdminValidador])
	SELECT @IdAuxiliar, @IdEstadoMaterial, @IdTipo, @DescripcionCorta, @DescripcionLarga, @IdMarca, @Modelo, @NumeroParte, @IdUnidad, @IdUnidadAlterna, @Presentacion, @Consumible, @Inventariable, @Activo, @TiempoEntregaEstimadoDias, @Costo, @IdMoneda, @IdTipoMaterial, @IdGrupoDisciplina, @IdFamilia, @IdSubFamilia, @Ubicacion, @CreadoPor, @Marca, @FechaAlta, @FechaAutorizacion, @IsPublico, @IdAdminValidador
	
	-- Begin Return Select <- do not remove
	SELECT [IdMaterial], [IdAuxiliar], [IdEstadoMaterial], [IdTipo], [DescripcionCorta], [DescripcionLarga], [IdMarca], [Modelo], [NumeroParte], [IdUnidad], [IdUnidadAlterna], [Presentacion], [Consumible], [Inventariable], [Activo], [TiempoEntregaEstimadoDias], [Costo], [IdMoneda], [IdTipoMaterial], [IdGrupoDisciplina], [IdFamilia], [IdSubFamilia], [Ubicacion], [CreadoPor], [Marca], [FechaAlta], [FechaAutorizacion], [IsPublico], [IdAdminValidador]
	FROM   [dbo].[MM_Material]
	WHERE  [IdMaterial] = SCOPE_IDENTITY()
	-- End Return Select <- do not remove
               
	COMMIT
