-- =============================================
-- Author:		DANIEL AC 
-- Create date: 22-12-17
-- Description:	Insertar Material Express petrovendor
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarMaterialExpress_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdTipoMaterial INT,
	@DescripcionCorta nvarchar(MAX),
	@DescripcionLarga nvarchar(MAX),	
	@Marca nvarchar(MAX),
	@Modelo nvarchar(MAX),
	@IdUnidad INT,	
	@IdProveedor INT,
	@IdUsuario INT,
	/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @FechaRegistro DATETIME
  /*--------------------
  --------------------*/
	

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.		
	SET NOCOUNT ON;
	DECLARE @IdMaterial INT 
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
	    Imagen,
	    FichaTecnica,
	    FechaAlta,
	    FechaActualizacion,
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
	(   @IdProveedor,         -- IdProveedor - int
	    NULL,         -- IdSubFamilia - int
	    @IdUnidad,         -- IdUnidad - int
	    NULL,         -- IdTipo - int
	    @DescripcionCorta,       -- DescripcionCorta - nvarchar(max)
	    @DescripcionLarga,       -- DescripcionLarga - nvarchar(max)
	    @Modelo,       -- Modelo - nvarchar(max)
	    N'',       -- NumeroParte - nvarchar(max)
	    N'',       -- Presentacion - nvarchar(max)
	    0,      -- Consumible - bit
	    0,      -- Inventariable - bit
	    0,         -- TiempoEntregaEstimadoDias - int
	    @Marca,       -- Marca - nvarchar(200)
	    0,      -- IsPublico - bit
	    N'',       -- Imagen - nvarchar(max)
	    N'',       -- FichaTecnica - nvarchar(max)
	    GETDATE(), -- FechaAlta - datetime
	    NULL, -- FechaActualizacion - datetime
	    1,      -- Activo - bit
	    0,      -- IsEliminado - bit
	    @IdUsuario,         -- CreadoPor - int
	    NULL,         -- ModificadoPor - int
	    NULL,         -- IdMaestro - int
	    0,      -- IsClasificionMaestro - bit
	    NULL,         -- IdBienServicioEconomia - int
	    2,         -- IdTipoProveedor - int PROVEEDOR PETROVENDOR
	    NULL,         -- IdUnidad_1 - int
	    NULL,         -- IdUnidad_2 - int
	    NULL,         -- IdUnidad_3 - int
	    @IdTipoMaterial  -- IdTipoCatalogoMaestro - int SERCIVIO -->  2 O MATERIAL --> 1
	    )

	SELECT @IdMaterial =(SELECT @@IDENTITY)
	--Agregar a bitacora que materiales fueron dados de alta con alta express
	INSERT INTO dbo.MM_MaterialAltaExpress(IdMaterial)VALUES (@IdMaterial)
	
	SELECT  'SUCCESS', @IdMaterial
	   
END