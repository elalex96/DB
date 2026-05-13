/****** Object:  StoredProcedure [dbo].[sp_SCOC_AgregaCamposContrato]    Script Date: 07/02/2019 12:31:47 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181220
-- Description:Agrega campos del contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCOC_AgregaCamposContrato] -- 3,10

    @idContrato INT,
    @idUsuario INT,
    @NombreCampo NVARCHAR(MAX),
  @GasEntregadoEn NVARCHAR(MAX),
@PetroleoEntregadoEn NVARCHAR(MAX),
@CondensadoEntregadoEn  NVARCHAR(MAX)
   --@Descripcion NVARCHAR(MAX)
AS
BEGIN
    DECLARE @CampoIDCount INT,
            @CampoID INT,
            @CampoIDContrato INT;

    SELECT @CampoIDCount = COUNT(*)
    FROM dbo.SCOC_Campo
    WHERE RTRIM(LTRIM(NombreCampo)) = RTRIM(LTRIM(@NombreCampo));


    SELECT @CampoID = CampoID
    FROM SCOC_Campo
    WHERE RTRIM(LTRIM(NombreCampo)) = RTRIM(LTRIM(@NombreCampo));


    IF (@CampoIDCount <> 0)
    BEGIN

        SELECT @CampoIDContrato = COUNT(*)
        FROM SCOC_Campo
            JOIN dbo.SCOC_CampoContrato
                ON SCOC_CampoContrato.CampoID = SCOC_Campo.CampoID
        WHERE RTRIM(LTRIM(NombreCampo)) = RTRIM(LTRIM(@NombreCampo))
              AND IdContrato = @idContrato;

        IF (@CampoIDContrato = 0)
        BEGIN
            INSERT INTO dbo.SCOC_CampoContrato
            (
                IdContrato,
                CampoID,
                Bit_Activo,
                CreadoPor,
                CreadoEn,
                ModificadoPor,
                ModificadoEn
            )
            VALUES
            (   @idContrato, -- IdContrato - int
                @CampoID,    -- CampoID - int
                1,           -- Bit_Activo - bit
                @idUsuario,  -- CreadoPor - int
                GETDATE(),   -- CreadoEn - datetime
                @idUsuario,  -- ModificadoPor - int
                GETDATE()    -- ModificadoEn - datetime
                );
        END;
    END;
    ELSE
    BEGIN
        INSERT INTO dbo.SCOC_Campo
            (
                NombreCampo,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                Activo,
				GasEntregadoEn,
				PetroleoEntregadoEn,
				CondensadoEntregadoEn
            )
       
        VALUES
        (   RTRIM(LTRIM(@NombreCampo)), -- NombreCampo - nvarchar(max)
            @idUsuario,
			GETDATE(),
			@idUsuario,
			GETDATE(),
			1,
			@GasEntregadoEn,
			@PetroleoEntregadoEn,
			@CondensadoEntregadoEn)

        SELECT @CampoID = CampoID
        FROM dbo.SCOC_Campo
        WHERE RTRIM(LTRIM(NombreCampo)) = RTRIM(LTRIM(@NombreCampo));
        INSERT INTO dbo.SCOC_CampoContrato
        (
            IdContrato,
            CampoID,
            Bit_Activo,
            CreadoPor,
            CreadoEn,
            ModificadoPor,
            ModificadoEn
        )
        VALUES
        (   @idContrato, -- IdContrato - int
            @CampoID,    -- CampoID - int
            1,           -- Bit_Activo - bit
            @idUsuario,  -- CreadoPor - int
            GETDATE(),   -- CreadoEn - datetime
            @idUsuario,  -- ModificadoPor - int
            GETDATE()    -- ModificadoEn - datetime
            );
    END;



END;
