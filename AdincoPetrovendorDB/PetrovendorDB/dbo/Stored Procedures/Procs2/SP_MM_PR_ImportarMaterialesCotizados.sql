-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <10-07-2019>
-- Description:	<sp para importar los materiales cotizados de una cotizacion restringida>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_PR_ImportarMaterialesCotizados]
	-- Add the parameters for the stored procedure here
	@IdPeticionOferta INT,
	@IdProveedor INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #MATERIALESCOTIZADOS(
		
		IdRow INT IDENTITY(1,1),
		IdMaterial INT,
		IdPeticionOfertaDetalle INT,
		IdUnidad INT
	);

	--OBETENER TODOS LOS MATERIALEZ QUE FUERON COTIZADOS EN LA PETICION OFERTA
	INSERT INTO #MATERIALESCOTIZADOS
	SELECT
		IdMaterial,
		IdPeticionOfertaDetalle,
		IdUnidad
	FROM dbo.MM_PeticionOfertaDetalle
	WHERE IdPeticionOferta = @IdPeticionOferta 
		AND Disponibilidad > 0 
		AND ISNULL(NoCotizar,0) = 0;

	DECLARE @CONT INT = 1;
	DECLARE @CANT INT = (SELECT COUNT(IdRow) FROM #MATERIALESCOTIZADOS);
	DECLARE @IDPROVEEDOROPERADORA INT;
	DECLARE @IDPETICIONOFERTADETALLE INT;
	DECLARE @IDMATERIAL INT;
	DECLARE @DESCMATERIAL NVARCHAR(MAX);
	DECLARE @IDMATERIALPROVEEDOR INT;
	DECLARE @IDUNIDAD INT;
	DECLARE @DESCCORTAMAT NVARCHAR(MAX);

	--ITERAR PARA VALIDAR QUE EL MATERIAL EXISTE O NO
	WHILE @CONT <= @CANT
	BEGIN
	    
		--VALIDAMOS QUE NO EXISTA EL MATERIAL
		SET @IDMATERIAL = (SELECT IdMaterial FROM #MATERIALESCOTIZADOS WHERE IdRow = @CONT);
		SET @IDPETICIONOFERTADETALLE = (SELECT IdPeticionOfertaDetalle FROM #MATERIALESCOTIZADOS WHERE IdRow = @CONT);
		SET @DESCMATERIAL = (SELECT DescripcionLarga FROM dbo.MM_Material WHERE IdMaterial = @IDMATERIAL);
		SET @DESCCORTAMAT = (SELECT DescripcionCorta FROM dbo.MM_Material WHERE IdMaterial = @IDMATERIAL);
		SET @IDUNIDAD = (SELECT IdUnidad FROM #MATERIALESCOTIZADOS WHERE IdRow = @CONT)
		SET @IDMATERIALPROVEEDOR = (SELECT TOP 1 IdMaterial FROM dbo.MM_Material 
									WHERE IdProveedor = @IdProveedor 
										AND DescripcionLarga = @DESCMATERIAL 
										AND IdTipoProveedor = 2
										AND IdUnidad = @IDUNIDAD);
		
		IF ISNULL(@IDMATERIALPROVEEDOR,0) = 0
		BEGIN
		    --SI EL MATERIAL NO EXISTE SE INSERTA EN EL CATALOGO DEL PROVEEDOR
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
					   2, ---PROVEEDOR PETROVENDOR
					   @IdUsuario,    
					   GETDATE(),
					   IdSubFamilia,
					   @IDUNIDAD,
					   IdTipo,
					   DescripcionCorta,
					   DescripcionLarga,
					   Modelo,
					   '',
					   '',
					   0,
					   0,
					   0,
					   '',
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
				WHERE IdMaterial = @IDMATERIAL;


				SET @IDMATERIALPROVEEDOR =(SCOPE_IDENTITY());

				SET @IDPROVEEDOROPERADORA = (SELECT IdProveedor FROM dbo.MM_Material WHERE IdMaterial=@IDMATERIAL )

				INSERT INTO dbo.MM_MaterialImportado
				(
					IdMaterial,
					IdMaterialOperador,
					CreadorEl,
					CreadorPor,
					IdProveedorOperador
				)
				VALUES
				(   @IDMATERIALPROVEEDOR,         -- IdMaterial - int
					@IdMaterial,         -- IdMaterialOperador - int
					GETDATE(), -- CreadorEl - datetime
					@IdUsuario,         -- CreadorPor - int
					@IDPROVEEDOROPERADORA          -- IdProveedorOperador - int
					);
		END

		--SE ACTUALIZA EL DETALLE DE LA PETICION OFERTA DEL NUEVO MATERIAL IMPORTADO
		UPDATE dbo.MM_PeticionOfertaDetalle
		SET IdMaterialVendedor = @IDMATERIALPROVEEDOR,
			IdUnidadProveedor = @IDUNIDAD,
			MaterialCotizadoTextoC = @DESCCORTAMAT,
			MaterialCotizadoTextoL = @DESCMATERIAL
		WHERE IdPeticionOfertaDetalle = @IDPETICIONOFERTADETALLE

		SET @CONT = @CONT + 1;
	END

END
