-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <01-02-18>
-- Description:	<Valida que el identificador(numero) no se repita mas de una vez por proveedor>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarCentrosDeCosto]
    @numeros NVARCHAR(MAX),
    --@IdCentroCostro INT,
    @IdProveedor INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @TablaCentro TABLE
    (
        NumeroCentroCosto NVARCHAR(MAX)
    )
    DECLARE @TablaCuenta TABLE
    (
        NumeroCentroCosto NVARCHAR(MAX),
        Cantidad INT
    )

    INSERT INTO @TablaCentro
    (
        NumeroCentroCosto
    )
    SELECT numero
    FROM dbo.CC_CentroCosto
    WHERE IdProveedor = @IdProveedor
          AND numero IS NOT NULL
          AND IsActivo = 1

    INSERT INTO @TablaCentro
    (
        NumeroCentroCosto
    )
    SELECT Value
    FROM dbo.Split(@numeros, ',')

    INSERT INTO @TablaCuenta
    SELECT NumeroCentroCosto,
           COUNT(1)
    FROM @TablaCentro
    GROUP BY NumeroCentroCosto
    HAVING COUNT(NumeroCentroCosto) > 1

    IF EXISTS (SELECT 1 FROM @TablaCuenta WHERE Cantidad > 1)
        SELECT 'NUMEROS_REPETIDOS'
    ELSE
        SELECT 'NUMEROS_NUEVOS'

END

