/****** Object:  StoredProcedure [dbo].[sp_SCOC_GuardaDatosContrato]    Script Date: 07/02/2019 11:52:40 a. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181220
-- Description:Guarda la info del contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCOC_GuardaDatosContrato] -- 3,10
    @idContrato INT,
    @idUsuario INT,
    @SubdireccionProduccion NVARCHAR(MAX),
    @ActivoIntegral NVARCHAR(MAX),
    @PetroleoEntregadoA NVARCHAR(MAX),
					@PetroleoEntregadoEn NVARCHAR(MAX),
	--@PetroleoEntregadoDireccion NVARCHAR(MAX),
    @PetroleoTransporte NVARCHAR(MAX),
    @GasEntregadoA NVARCHAR(MAX),
						@GasEntregadoEn NVARCHAR(MAX),
	--@GasEntregadoDireccion NVARCHAR(MAX),
    @GasTransporte NVARCHAR(MAX),
    @CondensadoEntregadoA NVARCHAR(MAX),
					@CondensadoEntregadoEn NVARCHAR(MAX),
	--@CondensadoEntregadoDireccion NVARCHAR(MAX),
    @CondensadoTransporte NVARCHAR(MAX),
    @AplicaFactorCompresibilidad INT,
    @Balance INT,
    @Condensable INT,
	@InicialesSocio NVARCHAR(MAX),
	@DescripcionSocio NVARCHAR(MAX),
	@PuntosLecturaCromatografia NVARCHAR(MAX)
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*)
    FROM dbo.SCOC_Contrato
    WHERE IdContrato = @idContrato;
    IF @count = 0
    BEGIN
        INSERT INTO dbo.SCOC_Contrato
        (
            IdContrato,
            SubdireccionProduccion,
            ActivoIntegral,
            PetroleoEntregadoA,
           -- PetroleoEntregadoEn,
					DireccionPetroleoEntregadoA,
            PetroleoTransporte,
            GasEntregadoA,
					DireccionGasEntregadoA,
           -- GasEntregadoEn,
            GasTransporte,
            CondensadoEntregadoA,
					DireccionCondensadoEntregadoA,
           -- CondensadoEntregadoEn,
            CondensadoTransporte,
            AplicaFactorCompresibilidad,
            Balance,
            Condensable,
            CreadoPor,
            CreadoEn,
            ModificadoPor,
            ModificadoEn,
			InicialesSocio,
			DescripcionSocio,
			PuntosLecturaCroma
        )
        VALUES
        (@idContrato, @SubdireccionProduccion, @ActivoIntegral, @PetroleoEntregadoA,
								@PetroleoEntregadoEn,
		-- @PetroleoEntregadoDireccion,
         @PetroleoTransporte, @GasEntregadoA, 
								 @GasEntregadoEn,
		-- @GasEntregadoDireccion,
		 @GasTransporte, @CondensadoEntregadoA,
							 @CondensadoEntregadoEn, 
		-- @CondensadoEntregadoDireccion,
		 @CondensadoTransporte, @AplicaFactorCompresibilidad, @Balance, @Condensable,
         @idUsuario, GETDATE(), @idUsuario, GETDATE(),@InicialesSocio,@DescripcionSocio,@PuntosLecturaCromatografia);

        IF @@ERROR <> 0
            SELECT 0 AS Resultado,
                   CAST(@@ERROR AS NVARCHAR(8)) AS Error;
        ELSE
            SELECT 1 AS Resultado,
                   '' AS Error;
    END;
    ELSE IF @count >= 1
    BEGIN
        UPDATE dbo.SCOC_Contrato
        SET SubdireccionProduccion = @SubdireccionProduccion,
            ActivoIntegral = @ActivoIntegral,
            PetroleoEntregadoA = @PetroleoEntregadoA,
								 DireccionPetroleoEntregadoA = @PetroleoEntregadoEn,
							--DireccionPetroleoEntregadoA=@PetroleoEntregadoDireccion,
            PetroleoTransporte = @PetroleoTransporte,
            GasEntregadoA = @GasEntregadoA,
									DireccionGasEntregadoA = @GasEntregadoEn,
									 --DireccionGasEntregadoA=@GasEntregadoDireccion,
            GasTransporte = @GasTransporte,
            CondensadoEntregadoA = @CondensadoEntregadoA,
           					DireccionCondensadoEntregadoA = @CondensadoEntregadoEn,
						--DireccionCondensadoEntregadoA=@CondensadoEntregadoDireccion,
            CondensadoTransporte = @CondensadoTransporte,
            AplicaFactorCompresibilidad = @AplicaFactorCompresibilidad,
            Balance = @Balance,
            Condensable = @Condensable,
            CreadoPor = @idUsuario,
            CreadoEn = GETDATE(),
            ModificadoPor = @idUsuario,
            ModificadoEn = GETDATE(),
			InicialesSocio=@InicialesSocio,
			DescripcionSocio=@DescripcionSocio,
			PuntosLecturaCroma=@PuntosLecturaCromatografia
        WHERE IdContrato = @idContrato;
        IF @@ERROR <> 0
            SELECT 0 AS Resultado,
                   CAST(@@ERROR AS NVARCHAR(8)) AS Error;
        ELSE
            SELECT 1 AS Resultado,
                   '' AS Error;
    END;

END;
