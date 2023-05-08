CREATE PROCEDURE [dbo].[SP_SegInsertaMaterial] 
	-- Add the parameters for the stored procedure here
	@IdGrupoDisciplina int,
	@IdFamilia int,
	@IdSubFamilia int,
	@IdTipoMaterial int,
	@Marca nvarchar(MAX),
	@Modelo nvarchar(MAX),
	@DescripcionCorta nvarchar(MAX),
	@DescripcionLarga nvarchar(MAX),
	@NumeroParte nvarchar(MAX),
	@IdUnidad int,
	@IdUnidadAlterna int,
	@Presentacion nvarchar(MAX),
	@Consumible bit,
	@Inventariable bit, 
	@TiempoEntregaEstimado int,
	@Costo varchar(200),
	@IdMoneda int, 
	@Ubicacion nvarchar(MAX),
	@IdProveedor int 
AS
BEGIN
-- =============================================
-- Author:		Manuel Cruz 
-- Create date: 09-02-17
-- Description:	Insertar Material = Producto - Servicio
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.MM_Material
	(IdGrupoDisciplina
	,IdFamilia,
	IdSubFamilia,
	IdTipoMaterial,
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
	Costo,
	IdMoneda,
	Ubicacion,
	CreadoPor,
	Activo,
	FechaAlta,
	IsPublico)
	VALUES
	(@IdGrupoDisciplina,
	@IdFamilia,
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
	@TiempoEntregaEstimado,
	@Costo,
	@IdMoneda, 
	@Ubicacion,
	@IdProveedor,
	0,
	GETDATE(),
	0)

	SELECT 'Producto Agregado' AS Respose

END
