-- =============================================
-- Author:		Alexander Enriquez
-- Create date: 30/06/2017
-- Description:	Procedimiento que obtiene el porcentaje de el llenado de datos Generales del Proveedor
-- =============================================
CREATE PROCEDURE [dbo].[sp_PorceDatosGeneralesProveedor] 
	-- Add the parameters for the stored procedure here
	@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here 
	DECLARE @DIAS_CEDITO DECIMAL = 0
	DECLARE @PONDERACION DECIMAL 
	DECLARE @PorcentajeRestante DECIMAL
	DECLARE @PorcentajeSubido DECIMAL

	SET @PONDERACION = 6.25


	SET @DIAS_CEDITO = (SELECT COUNT (CP.DiasCredito) 
	                    FROM PV_CondicionesPago CP
						INNER JOIN PV_ContratistaSubContratista CSC ON CP.IdContratistaSubContratista =  CSC.IdRelacion
						INNER JOIN S_Proveedor P ON P.IdProveedor = CSC.IdContratista  
						WHERE P.IdProveedor = @IdProveedor AND CP.DiasCredito != 0
						) 

	IF (@DIAS_CEDITO > 0 )
	BEGIN
	SET @DIAS_CEDITO = 6.25
	END

	DECLARE @IMAGEN DECIMAL = 0
	SET @IMAGEN = (SELECT COUNT (Imagen) FROM S_ImagenPerfil WHERE IdProveedor = @IdProveedor)

    IF (@IMAGEN > 0 )
	BEGIN
	SET @IMAGEN = 6.25
	END

	DECLARE @TIPO_REGIMEN NVARCHAR(30) 
	SET @TIPO_REGIMEN = (SELECT TR.TipoRegimen 
	                            FROM S_TipoRegimen TR
								INNER JOIN S_Proveedor P
								ON TR.IdTipoRegimen = P.IdTipoRegimen
								WHERE P.IdProveedor = @IdProveedor
								)

	IF (@TIPO_REGIMEN = 'Persona Moral')
	BEGIN

	  --      SET @PorcentajeSubido =(SELECT ((CASE WHEN IdNacionalidad IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN RFC IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN IdTipoRegimen IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN RazonSocial IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN FechaConstitucion IS NULL THEN 0 ELSE @PONDERACION END)
			----+ (CASE WHEN FechaOperacion IS NULL THEN 0 ELSE 5.88 END)
			--+ (CASE WHEN FechaCambioSituacion IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN SituacionContribuyente IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN Alias IS NULL THEN 0 ELSE @PONDERACION END)
			--+ @IMAGEN
			--+ @DIAS_CEDITO
			--+ (CASE WHEN CURP IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN RPPC IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN Giro IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN MonedaFacturar IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN IMSS IS NULL THEN 0 ELSE @PONDERACION END)
			--+ (CASE WHEN Telefono IS NULL THEN 0 ELSE @PONDERACION END)
			--) AS PorcentajePerfil 
			--FROM S_Proveedor 
			--WHERE IdProveedor = @IdProveedor)

				        SET @PorcentajeSubido =(SELECT ((CASE WHEN IdNacionalidad IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN RFC IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN IdTipoRegimen IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN RazonSocial IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN FechaConstitucion IS NULL THEN 0 ELSE 6.25 END)
			--+ (CASE WHEN FechaOperacion IS NULL THEN 0 ELSE 5.88 END)
			+ (CASE WHEN FechaCambioSituacion IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN SituacionContribuyente IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN Alias IS NULL THEN 0 ELSE 6.25 END)
			+ @IMAGEN
			+ @DIAS_CEDITO
			+ (CASE WHEN CURP IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN RPPC IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN Giro IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN MonedaFacturar IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN IMSS IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN Telefono IS NULL THEN 0 ELSE 6.25 END)
			) AS PorcentajePerfil 
			FROM S_Proveedor 
			WHERE IdProveedor = @IdProveedor)

						SET @PorcentajeRestante =(100 - @PorcentajeSubido)
			SELECT @PorcentajeSubido AS PORCENTAJECARGADO, @PorcentajeRestante AS PORCENTAJERESTANTE
	END
	IF (@TIPO_REGIMEN = 'Persona Fisica')
	BEGIN
      
	        SET @PorcentajeSubido =(SELECT ((CASE WHEN IdNacionalidad IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN RFC IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN IdTipoRegimen IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN RazonSocial IS NULL THEN 0 ELSE 6.25 END)
			--+ (CASE WHEN FechaConstitucion IS NULL THEN 0 ELSE @PONDERACION END)
			+ (CASE WHEN FechaOperacion IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN FechaCambioSituacion IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN SituacionContribuyente IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN Alias IS NULL THEN 0 ELSE 6.25 END)
			+ @IMAGEN
			+ @DIAS_CEDITO
			+ (CASE WHEN CURP IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN RPPC IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN Giro IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN MonedaFacturar IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN IMSS IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN Telefono IS NULL THEN 0 ELSE 6.25 END)
			) AS PorcentajePerfil 
			FROM S_Proveedor 
			WHERE IdProveedor = @IdProveedor)

						SET @PorcentajeRestante =(100 - @PorcentajeSubido)
			SELECT @PorcentajeSubido AS PORCENTAJECARGADO, @PorcentajeRestante AS PORCENTAJERESTANTE
	END
	
	IF (@TIPO_REGIMEN = 'Persona Moral Extranjera')
	BEGIN
				        SET @PorcentajeSubido =(SELECT ((CASE WHEN IdNacionalidad IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN RFC IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN IdTipoRegimen IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN RazonSocial IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN FechaConstitucion IS NULL THEN 0 ELSE 6.25 END)
			--+ (CASE WHEN FechaOperacion IS NULL THEN 0 ELSE 5.88 END)
			+ (CASE WHEN FechaCambioSituacion IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN SituacionContribuyente IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN Alias IS NULL THEN 0 ELSE 6.25 END)
			+ @IMAGEN
			+ @DIAS_CEDITO
			+ (CASE WHEN CURP IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN RPPC IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN Giro IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN MonedaFacturar IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN IMSS IS NULL THEN 0 ELSE 6.25 END)
			+ (CASE WHEN Telefono IS NULL THEN 0 ELSE 6.25 END)
			) AS PorcentajePerfil 
			FROM S_Proveedor 
			WHERE IdProveedor = @IdProveedor)

						SET @PorcentajeRestante =(100 - @PorcentajeSubido)
			SELECT @PorcentajeSubido AS PORCENTAJECARGADO, @PorcentajeRestante AS PORCENTAJERESTANTE
	END


END