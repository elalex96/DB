/****** Object:  StoredProcedure [dbo].[sp_SCOC_EditaCamposContrato]    Script Date: 07/02/2019 01:09:24 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181220
-- Description:Agrega campos del contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCOC_EditaCamposContrato] -- 3,10

    @idContrato            INT,
    @idUsuario             INT,
    @NombreCampo           NVARCHAR(MAX),
    @GasEntregadoEn        NVARCHAR(MAX),
    @PetroleoEntregadoEn   NVARCHAR(MAX),
    @CondensadoEntregadoEn NVARCHAR(MAX),
    @CampoID               INT
AS
    BEGIN
        DECLARE @CampoIDCount INT;

        SELECT
            @CampoIDCount = COUNT(*)
        FROM
            SCOC_Campo
        WHERE
            RTRIM(LTRIM(NombreCampo)) = RTRIM(LTRIM(@NombreCampo))
            AND CampoID <> @CampoID;
        IF (@CampoIDCount = 0)
            BEGIN
                UPDATE
                    dbo.SCOC_Campo
                SET
                    NombreCampo = @NombreCampo,
                    GasEntregadoEn = @GasEntregadoEn,
                    PetroleoEntregadoEn = @PetroleoEntregadoEn,
                    CondensadoEntregadoEn = @CondensadoEntregadoEn
                WHERE
                    CampoID = @CampoID;
            END;
    END;
