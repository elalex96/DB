CREATE PROCEDURE [dbo].[SP_TA_ValidacionFlujoTareaProveedorDEA]  
-- Add the parameters for the stored procedure here  
@IdProveedor  INT, 
@IdFlujoTarea INT, 
@IdUsuario    INT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @IsDEA BIT;
        DECLARE @ExisteRelCentroCostoFlujo BIT;
        DECLARE @CentroCosto NVARCHAR(MAX);
        DECLARE @Predeterminado BIT=
        (
            SELECT Predeterminado
            FROM dbo.TA_FlujoTarea
            WHERE IdFlujoTarea = @IdFlujoTarea
                  AND IdProveedor = @IdProveedor
        );
        DECLARE @IdTipoOperacion INT;
        DECLARE @lastFecha DATETIME;
        DECLARE @UltimoFlujoFacturaAgregado INT;
        IF EXISTS
        (
            SELECT 1
            FROM dbo.DEA_Proveedor
            WHERE IdProveedor = @IdProveedor
                  AND ISNULL(Activo, 0) = 1
        )
            SET @IsDEA = 1;
            ELSE
            SET @IsDEA = 0;
        IF(@IsDEA = 1)
            BEGIN
                SET @IdTipoOperacion =
                (
                    SELECT IdTipoOperacion
                    FROM dbo.TA_FlujoTarea
                    WHERE IdFlujoTarea = @IdFlujoTarea
                );
                IF @IdTipoOperacion = 2
                    BEGIN
                        SET @ExisteRelCentroCostoFlujo =
                        (
                            SELECT COUNT(1)
                            FROM dbo.RelacionCentroCostoFlujoAprob
                            WHERE IdFlujo = @IdFlujoTarea
                                  AND Activo = 1
                        );
                        SELECT @CentroCosto = CentroCosto
                        FROM dbo.RelacionCentroCostoFlujoAprob
                             INNER JOIN dbo.CC_CentroCosto ON CC_CentroCosto.IdCentroCosto = RelacionCentroCostoFlujoAprob.IdCentroCosto
                        WHERE IdFlujo = @IdFlujoTarea
                              AND Activo = 1;
                END;
                IF @IdTipoOperacion = 10
                    BEGIN
                        SET @ExisteRelCentroCostoFlujo =
                        (
                            SELECT COUNT(1)
                            FROM dbo.RelacionCentroCostoFlujoAprob
                            WHERE IdFlujoFactura = @IdFlujoTarea
                                  AND Activo = 1
                        );
                        SELECT @CentroCosto = CentroCosto
                        FROM dbo.RelacionCentroCostoFlujoAprob
                             INNER JOIN dbo.CC_CentroCosto ON CC_CentroCosto.IdCentroCosto = RelacionCentroCostoFlujoAprob.IdCentroCosto
                        WHERE IdFlujoFactura = @IdFlujoTarea
                              AND Activo = 1;
                END;
                IF @IdTipoOperacion = 16
                    BEGIN
                        SET @ExisteRelCentroCostoFlujo =
                        (
                            SELECT COUNT(1)
                            FROM dbo.RelacionCentroCostoFlujoAprob
                            WHERE IdFlujoComprobante = @IdFlujoTarea
                                  AND Activo = 1
                        );
                        SELECT @CentroCosto = CentroCosto
                        FROM dbo.RelacionCentroCostoFlujoAprob
                             INNER JOIN dbo.CC_CentroCosto ON CC_CentroCosto.IdCentroCosto = RelacionCentroCostoFlujoAprob.IdCentroCosto
                        WHERE IdFlujoComprobante = @IdFlujoTarea
                              AND Activo = 1;
                END;
                IF(@ExisteRelCentroCostoFlujo > 0)
                    BEGIN
                        SELECT 'No se puede eliminar, este flujo de aprobación tiene una relación encontrada con el Centro de Costo: ' + ISNULL(@CentroCosto, '');
                END;
        END;
    END;