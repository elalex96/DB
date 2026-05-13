
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_AgregarCuentaBancaria'
)
    DROP PROCEDURE SP_FI_AgregarCuentaBancaria
GO
-- =============================================
-- Author:		Daniel Antonio Cruz
-- Create date: 24/05/2017
-- Description:Agregar cuenta bancaria
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_AgregarCuentaBancaria]
    -- Add the parameters for the stored procedure here
    @IdTipoBanco INT,
    @TitularCuenta NVARCHAR(350),
    @CuentaSucursal NVARCHAR(300),
    @NumeroCuenta NVARCHAR(300),
    @NumeroTarjeta NVARCHAR(300),
    @CuentaClabe NVARCHAR(300),
    @IdMoneda INT,
    @IdTipoCuenta INT,
    @Predeterminado BIT,
    @IdProveedor INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @Contratista INT;

    SELECT @Contratista = CC.IdContratista
    FROM dbo.CO_Contratista CC (NOLOCK)
        JOIN dbo.CO_RelacionEmpresas RE (NOLOCK)
            ON CC.IdContratista = RE.IdContratista
    WHERE RE.IdRelacionada = @IdProveedor;

    IF (@Contratista IS NULL)
    BEGIN
        SELECT @Contratista = IdContratista
        FROM dbo.CO_Contratista (NOLOCK)
        WHERE IdProveedor = @IdProveedor;
    END;
    ELSE
    BEGIN
        SELECT @Contratista = NULL;
    END;


    IF (@Contratista IS NOT NULL)
    BEGIN
        INSERT INTO dbo.PV_CuentaBancaria
        (
            BancoID,
            Titular,
            Sucursal,
            NumeroCuenta,
            CuentaClave,
            TipoMonedaID,
            IdProveedor,
            IdTipoCuenta,
            Predeterminado,
            NumeroTarjeta,
            CreadoPor,
            CreadoEn,
            Activa,
            Eliminada,
            IdContratista
        )
        VALUES
        (@IdTipoBanco,
         @TitularCuenta,
         @CuentaSucursal,
         @NumeroCuenta,
         @CuentaClabe,
         @IdMoneda,
         @IdProveedor,
         @IdTipoCuenta,
         @Predeterminado,
         @NumeroTarjeta,
         @IdUsuario,
         GETDATE(),
         1  ,
         0  ,
         @Contratista
        );
    END;
    ELSE
    BEGIN
        INSERT INTO dbo.PV_CuentaBancaria
        (
            BancoID,
            Titular,
            Sucursal,
            NumeroCuenta,
            CuentaClave,
            TipoMonedaID,
            IdProveedor,
            IdTipoCuenta,
            Predeterminado,
            NumeroTarjeta,
            CreadoPor,
            CreadoEn,
            Activa,
            Eliminada
        )
        VALUES
        (@IdTipoBanco,
         @TitularCuenta,
         @CuentaSucursal,
         @NumeroCuenta,
         @CuentaClabe,
         @IdMoneda,
         @IdProveedor,
         @IdTipoCuenta,
         @Predeterminado,
         @NumeroTarjeta,
         @IdUsuario,
         GETDATE(),
         1  ,
         0
        );
    END;

    SELECT 'La cuenta ha sido registrada' AS Mensaje;
END;
