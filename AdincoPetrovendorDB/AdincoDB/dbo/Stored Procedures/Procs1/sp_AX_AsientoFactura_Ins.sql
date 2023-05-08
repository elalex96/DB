CREATE PROC [dbo].[sp_AX_AsientoFactura_Ins] --'XCGS',assdf,'sfd',62
(
    @IdAsientoFactura VARCHAR(MAX),
    @UUID VARCHAR(8000),
    @DataAreaId VARCHAR(MAX),
    @CuentaSectorHidrocarburos VARCHAR(8000),
    @NumeroPoliza INT
)
AS
BEGIN


    DECLARE @ERROR NVARCHAR(MAX) = N'DATO(S) FALTANTE(S): ';
    DECLARE @ERRORDATO NVARCHAR(MAX) = N'';

    IF ISNULL(LTRIM(RTRIM(@IdAsientoFactura)), '') = ''
    BEGIN
        IF @ERRORDATO <> ''
        BEGIN
            SET @ERRORDATO = @ERRORDATO + N', IdAsientoFactura'
        END
        ELSE
        BEGIN
            SET @ERRORDATO = N'IdAsientoFactura'
        END;

    END;

    IF ISNULL(LTRIM(RTRIM(@UUID)), '') = ''
    BEGIN
        IF @ERRORDATO <> ''
        BEGIN
            SET @ERRORDATO = @ERRORDATO + N', UUID'
        END
        ELSE
        BEGIN
            SET @ERRORDATO = N'UUID'
        END;

    END;

    IF ISNULL(LTRIM(RTRIM(@DataAreaId)), '') = ''
    BEGIN

        IF @ERRORDATO <> ''
        BEGIN
            SET @ERRORDATO = @ERRORDATO + N', DataAreaID'
        END
        ELSE
        BEGIN
            SET @ERRORDATO = N'DataAreaId'
        END;

    END;

    IF ISNULL(LTRIM(RTRIM(@CuentaSectorHidrocarburos)), '') = ''
    BEGIN

        IF @ERRORDATO <> ''
        BEGIN
            SET @ERRORDATO = @ERRORDATO + N', Cuenta SH'
        END
        ELSE
        BEGIN
            SET @ERRORDATO = N' Cuenta SH'
        END;

    END;

    IF ISNULL(LTRIM(RTRIM(@NumeroPoliza)), '') = ''
    BEGIN

        IF @ERRORDATO <> ''
        BEGIN
            SET @ERRORDATO = @ERRORDATO + N', Poliza'
        END
        ELSE
        BEGIN
            SET @ERRORDATO = N' Poliza'
        END;

    END;

    IF @ERRORDATO = ''
    BEGIN


        /* Validacion si el UUID existe en FI_Factura ADINCO, los valores se reescriben ( Si el UUID no existe, hay que regresar qye el UUID no existe)**/
        IF EXISTS (SELECT 1 FROM Adinco.dbo.FI_Factura WHERE UUID = @UUID)
        BEGIN
            DECLARE @IdCuentaSectorHidro INT

            INSERT INTO dbo.AX_AsientoFactura
            (
                UUID,
                DataAreaId,
                CuentaSectorHidrocarburos,
                NumeroPoliza,
                RECID,
                FechaRegistro
            )
            VALUES
            (@UUID, @DataAreaId, @CuentaSectorHidrocarburos, @NumeroPoliza, @IdAsientoFactura, GETDATE())

            SELECT @IdCuentaSectorHidro = c.IdCatalogoCuentasSH
            FROM Adinco.dbo.CO_VersionCatalogoCuentasSH v
                INNER JOIN Adinco.dbo.CO_CatalogoCuentaSH c
                    ON c.IdVersion = v.IdVersion
            WHERE v.Activo = 1
                  AND c.Nivel3 = @CuentaSectorHidrocarburos

            UPDATE r
            SET r.Poliza = @NumeroPoliza,
                r.IdCatalogoCuentasSH = @IdCuentaSectorHidro
            FROM Adinco.dbo.FI_Factura f
                INNER JOIN Adinco.dbo.CO_Registro r
                    ON r.IdFactura = f.IdFactura
            WHERE f.UUID = @UUID

            SELECT CONCAT('Recepción exitosa ', @IdAsientoFactura),
                   '',
                   '',
                   '',
                   ''
        END
        ELSE
        BEGIN
            SELECT CONCAT('ERROR ON ', @UUID, ' - ', 'No existe'),
                   '',
                   '',
                   '',
                   ''
        END

    END
    ELSE
    BEGIN
        SELECT CONCAT('ERROR ON ', @UUID + ' - ' + @ERROR + @ERRORDATO, @ERRORDATO),
               '',
               '',
               '',
               ''
    END
END



