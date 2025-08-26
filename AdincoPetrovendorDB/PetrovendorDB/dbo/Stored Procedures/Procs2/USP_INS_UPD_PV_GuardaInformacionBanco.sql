USE Petrovendor
GO
DROP PROC IF EXISTS USP_INS_UPD_PV_GuardaInformacionBanco
GO

CREATE PROC USP_INS_UPD_PV_GuardaInformacionBanco
    @BancoID INT,
    @Banco VARCHAR(1000),
    @Clave VARCHAR(100) = NULL,
    @RazonSocial VARCHAR(1000),
    @Nacional BIT,
    @Activo BIT,
    @CreadoPor INT,
    @IdContrato INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DiaActual DATETIME = GETDATE();
    DECLARE @BancoNormalizado VARCHAR(1000);

    -- Normalizar el nombre del banco: quitar signos y términos de régimen, convertir a UPPER
    SET @BancoNormalizado = UPPER(@Banco);
    SET @BancoNormalizado = REPLACE(@BancoNormalizado, '.', '');
    SET @BancoNormalizado = REPLACE(@BancoNormalizado, ',', '');
    SET @BancoNormalizado = REPLACE(@BancoNormalizado, ' S.A.', '');
    SET @BancoNormalizado = REPLACE(@BancoNormalizado, ' S.A DE C.V', '');
    SET @BancoNormalizado = REPLACE(@BancoNormalizado, ' S. DE R.L. DE C.V', '');
    SET @BancoNormalizado = LTRIM(RTRIM(@BancoNormalizado));

    IF ISNULL(@BancoID,0) = 0
    BEGIN
        -- INSERT: Validación duplicados

        -- Verificar duplicado en Banco
        IF EXISTS (
            SELECT 1 FROM PV_Banco 
            WHERE UPPER(REPLACE(REPLACE(Banco, '.', ''), ',', '')) LIKE '%' + @BancoNormalizado + '%'
        )
        BEGIN
            RAISERROR('El banco ya existe.', 16, 1);
            RETURN;
        END

        -- Verificar duplicado en RazonSocial
        IF EXISTS (
            SELECT 1 FROM PV_Banco 
            WHERE UPPER(RazonSocial) = UPPER(@RazonSocial)
        )
        BEGIN
            RAISERROR('La razón social ya existe.', 16, 1);
            RETURN;
        END

        -- Insertar registro nuevo
        INSERT INTO PV_Banco (Banco, Clave, RazonSocial, Nacional, Activo, CreadoPor, CreadoEl)
        VALUES (@Banco, @Clave, @RazonSocial, @Nacional, @Activo, @CreadoPor, @DiaActual)
    END
    ELSE
    BEGIN
        -- UPDATE: Validación duplicados, excluyendo el propio registro

        -- Verificar duplicado en Banco
        IF EXISTS (
            SELECT 1 FROM PV_Banco 
            WHERE BancoID <> @BancoID
              AND UPPER(REPLACE(REPLACE(Banco, '.', ''), ',', '')) LIKE '%' + @BancoNormalizado + '%'
        )
        BEGIN
            RAISERROR('El banco ya existe.', 16, 1);
            RETURN;
        END

        -- Verificar duplicado en RazonSocial
        IF EXISTS (
            SELECT 1 FROM PV_Banco 
            WHERE BancoID <> @BancoID
              AND UPPER(RazonSocial) = UPPER(@RazonSocial)
        )
        BEGIN
            RAISERROR('La razón social ya existe.', 16, 1);
            RETURN;
        END

        -- Actualizar registro existente
        UPDATE PV_Banco
        SET Banco = @Banco,
            Clave = @Clave,
            RazonSocial = @RazonSocial,
            Nacional = @Nacional,
            Activo = @Activo,
            ModificadoPor = @CreadoPor,
            ModificadoEl = @DiaActual
        WHERE BancoID = @BancoID
    END
END
