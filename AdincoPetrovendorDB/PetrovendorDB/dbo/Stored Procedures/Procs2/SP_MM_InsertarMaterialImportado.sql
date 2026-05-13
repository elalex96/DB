-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- Author:		<Luis David>
-- Create date: <12/07/2022>
-- Description:	<Se eliminan los espacios en blanco>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_InsertarMaterialImportado] 
	-- Add the parameters for the stored procedure here
@Con_CatalogoMaestro BIT,
@IdProveedor             INT,
@IdUnidadPredeterminada  INT,
@DescripcionCorta        NVARCHAR(MAX),
@DescripcionLarga	     NVARCHAR(MAX),
@Modelo                  NVARCHAR(MAX),
@NumeroParte             NVARCHAR(MAX),
@Presentacion            NVARCHAR(MAX),
@Consumible              BIT,
@Inventariable           BIT, 
@TiempoEntregaEstimado   INT,
@Marca                   NVARCHAR(MAX),
@IdUsuario               INT,
@IdMaestro               INT,
@IdTipoProveedor         INT,
@IdUnidadOpcional_1      INT,
@IdUnidadOpcional_2      INT,
@IdUnidadOpcional_3      INT,
@IdTipo INT,
/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    --@IdUsuario     INT,
    @FechaRegistro DATETIME
  /*--------------------
  --------------------*/


AS
BEGIN


		IF (@TiempoEntregaEstimado IS NULL)
		    SET @TiempoEntregaEstimado = 0

		IF (@IdUnidadPredeterminada = 0)
		    SET @IdUnidadPredeterminada = NULL 
		IF (@IdUnidadOpcional_1 = 0)
			SET @IdUnidadOpcional_1 = NULL 
		IF (@IdUnidadOpcional_2 = 0)
			SET @IdUnidadOpcional_2 = NULL 
		IF (@IdUnidadOpcional_3 = 0)
			SET @IdUnidadOpcional_3 = NULL 


	SET NOCOUNT ON;
		
	INSERT INTO dbo.MM_Material
	(
	    IdProveedor,
	    IdUnidad,
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
	    ModificadoPor,
	    IdTipoProveedor,
	    IdUnidad_1,
	    IdUnidad_2,
	    IdUnidad_3,
		IdTipoCatalogoMaestro
	)
	VALUES
	(   
	    @IdProveedor,               -- IdProveedor - int
	    @IdUnidadPredeterminada,    -- IdUnidad - int
	    LTRIM(RTRIM(@DescripcionCorta)),          -- DescripcionCorta - nvarchar(max)
	    LTRIM(RTRIM(@DescripcionLarga)),          -- DescripcionLarga - nvarchar(max)
	    LTRIM(RTRIM(@Modelo)),                    -- Modelo - nvarchar(max)
	    LTRIM(RTRIM(@NumeroParte)),               -- NumeroParte - nvarchar(max)
	    LTRIM(RTRIM(@Presentacion)),              -- Presentacion - nvarchar(max)
	    @Consumible,                -- Consumible - bit
	    @Inventariable,             -- Inventariable - bit
	    @TiempoEntregaEstimado,     -- TiempoEntregaEstimadoDias - int
	    LTRIM(RTRIM(@Marca)),                     -- Marca - nvarchar(200)
	    0,                          -- IsPublico - bit
	    GETDATE(),                  -- FechaAlta - datetime
	    1,                          -- Activo - bit
	    0,                          -- IsEliminado - bit 
	    @IdUsuario,                 -- CreadoPor - int
	    0,                          -- ModificadoPor - int
	    @IdTipoProveedor,           -- IdTipoProveedor - int
	    @IdUnidadOpcional_1,        -- IdUnidad_1 - int
	    @IdUnidadOpcional_2,        -- IdUnidad_2 - int
	    @IdUnidadOpcional_3,       -- IdUnidad_3 - int
		@IdTipo
	 )

	 SELECT 'Material Agregado Exitosamente' AS Respose

END