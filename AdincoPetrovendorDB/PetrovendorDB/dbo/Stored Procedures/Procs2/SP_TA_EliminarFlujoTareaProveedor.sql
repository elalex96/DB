-- =============================================
-- Author:		Daniel Ac
-- Create date: 23/01/2018
-- Description:	Remover validación de flujo de aprobación
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 22/09/2020
-- Description:	Agregado de la validacion de eliminado en compras directas para DEA(tipo operacion 14)
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 22/09/2020
-- Description:	Agregado de la validacion de eliminado en pedimentos comprobantes para DEA(tipo operacion 19)
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_EliminarFlujoTareaProveedor]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdFlujoTarea INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @IsDEA BIT;
    DECLARE @ExisteRelCentroCostoFlujo BIT;

    DECLARE @Predeterminado BIT =
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
    IF (@IsDEA = 1)
    BEGIN
        --SET @ExisteRelCentroCostoFlujo =
        --(
        --    SELECT COUNT(1)
        --    FROM dbo.RelacionCentroCostoFlujoAprob
        --    WHERE IdFlujo = @IdFlujoTarea
        --          AND Activo = 1
        --);

		SET @IdTipoOperacion  = ( SELECT IdTipoOperacion FROM dbo.TA_FlujoTarea WHERE IdFlujoTarea = @IdFlujoTarea )
			
				IF @IdTipoOperacion = 2
				BEGIN
						SET @ExisteRelCentroCostoFlujo =
						(
							SELECT COUNT(1)
							FROM dbo.RelacionCentroCostoFlujoAprob
							WHERE IdFlujo = @IdFlujoTarea
									AND Activo = 1
						);
				END

				IF @IdTipoOperacion = 10
				BEGIN
						SET @ExisteRelCentroCostoFlujo =
						(
							SELECT COUNT(1)
							FROM dbo.RelacionCentroCostoFlujoAprob
							WHERE IdFlujoFactura = @IdFlujoTarea
									AND Activo = 1
						);
				END

				IF @IdTipoOperacion = 16
				BEGIN
						SET @ExisteRelCentroCostoFlujo =
						(
							SELECT COUNT(1)
							FROM dbo.RelacionCentroCostoFlujoAprob
							WHERE IdFlujoComprobante = @IdFlujoTarea
									AND Activo = 1
						);
				END

				IF @IdTipoOperacion = 14
				BEGIN
						SET @ExisteRelCentroCostoFlujo =
						(
							SELECT COUNT(1)
							FROM dbo.RelacionCentroCostoFlujoAprob
							WHERE IdFlujoComprobante = @IdFlujoTarea
									AND Activo = 1
						);
				END

				--SE AGREGA EL TIPO DE OPERACION 19 PARA ENTRAR A LA VALIDACION DE CENTROS DE COSTO
				--ALA FECHA 22/10/2020 NO APLICA ESTA VALIDACION PERO SE CONTEMPLA PARA FUTURAS IMPLEMENTACIONES
				IF @IdTipoOperacion = 19
				BEGIN
						SET @ExisteRelCentroCostoFlujo =
						(
							SELECT COUNT(1)
							FROM dbo.RelacionCentroCostoFlujoAprob
							WHERE IdFlujoComprobante = @IdFlujoTarea
									AND Activo = 1
						);
				END

		--DECLARE @counter INT = 1;
		--WHILE @counter <= 3 -- existen 3 tipos de flujo de aprobacion con relacion centro de costos
		--BEGIN

		--END



        IF (@ExisteRelCentroCostoFlujo = 0)
        BEGIN
				UPDATE [dbo].[TA_FlujoTarea]
				SET [Eliminado] = 1,
					[Activo] = 0,
					[Predeterminado] = 0,
					[IdModificadoPor] = @IdUsuario,
					[ModificadorEl] = GETDATE()
				WHERE [IdFlujoTarea] = @IdFlujoTarea
					  AND [IdProveedor] = @IdProveedor;
				-- Activa el flujo de aprobacion mas reciente para simpre tener un flujo activo  
				SET @IdTipoOperacion =
				(
					SELECT IdTipoOperacion
					FROM dbo.TA_FlujoTarea
					WHERE IdProveedor = @IdProveedor
						  --AND Activo = 1  
						  AND IdFlujoTarea = @IdFlujoTarea
				);
				IF (@IdTipoOperacion = 10)
				BEGIN
					IF (@Predeterminado = 1) -- Sig que se quiere eliminar el flujo activo  
					BEGIN
						SET @lastFecha =
						(
							SELECT MAX(FechaCreacion)
							FROM dbo.TA_FlujoTarea
							WHERE IdProveedor = @IdProveedor
								  AND Activo = 1
								  AND ISNULL(Eliminado, 0) = 0
								  AND IdTipoOperacion = 10
						);
						SET @UltimoFlujoFacturaAgregado =
						(
							SELECT IdFlujoTarea
							FROM dbo.TA_FlujoTarea
							WHERE IdProveedor = @IdProveedor
								  AND Activo = 1
								  AND ISNULL(Eliminado, 0) = 0
								  AND IdTipoOperacion = 10
								  AND FechaCreacion = @lastFecha
						);
						UPDATE dbo.TA_FlujoTarea
						SET Predeterminado = 1
						WHERE IdFlujoTarea = @UltimoFlujoFacturaAgregado;
					END;
				END;

				IF (@IdTipoOperacion = 16)
				BEGIN
					IF (@Predeterminado = 1) -- Sig que se quiere eliminar el flujo activo  
					BEGIN
						SET @lastFecha =
						(
							SELECT MAX(FechaCreacion)
							FROM dbo.TA_FlujoTarea
							WHERE IdProveedor = @IdProveedor
								  AND Activo = 1
								  AND ISNULL(Eliminado, 0) = 0
								  AND IdTipoOperacion = 16
						);
						SET @UltimoFlujoFacturaAgregado =
						(
							SELECT IdFlujoTarea
							FROM dbo.TA_FlujoTarea
							WHERE IdProveedor = @IdProveedor
								  AND Activo = 1
								  AND ISNULL(Eliminado, 0) = 0
								  AND IdTipoOperacion = 16
								  AND FechaCreacion = @lastFecha
						);
						UPDATE dbo.TA_FlujoTarea
						SET Predeterminado = 1
						WHERE IdFlujoTarea = @UltimoFlujoFacturaAgregado;
					END;
				END;

        -------------------------------------------------  
        END;
        ELSE
        BEGIN
            SELECT 'no se puede eliminar, relación encontrada';
        END;
    END;
    ELSE
    BEGIN
        UPDATE [dbo].[TA_FlujoTarea]
        SET [Eliminado] = 1,
            [Activo] = 0,
            [Predeterminado] = 0,
            [IdModificadoPor] = @IdUsuario,
            [ModificadorEl] = GETDATE()
        WHERE [IdFlujoTarea] = @IdFlujoTarea
              AND [IdProveedor] = @IdProveedor;
        -- Activa el flujo de aprobacion mas reciente para simpre tener un flujo activo  
        SET @IdTipoOperacion =
        (
            SELECT IdTipoOperacion
            FROM dbo.TA_FlujoTarea
            WHERE IdProveedor = @IdProveedor
                  --AND Activo = 1  
                  AND IdFlujoTarea = @IdFlujoTarea
        );
        IF (@IdTipoOperacion = 10)
        BEGIN
            IF (@Predeterminado = 1) -- Sig que se quiere eliminar el flujo activo  
            BEGIN
                SET @lastFecha =
                (
                    SELECT MAX(FechaCreacion)
                    FROM dbo.TA_FlujoTarea
                    WHERE IdProveedor = @IdProveedor
                          AND Activo = 1
                          AND ISNULL(Eliminado, 0) = 0
                          AND IdTipoOperacion = 10
                );
                SET @UltimoFlujoFacturaAgregado =
                (
                    SELECT IdFlujoTarea
                    FROM dbo.TA_FlujoTarea
                    WHERE IdProveedor = @IdProveedor
                          AND Activo = 1
                          AND ISNULL(Eliminado, 0) = 0
                          AND IdTipoOperacion = 10
                          AND FechaCreacion = @lastFecha
                );
                UPDATE dbo.TA_FlujoTarea
                SET Predeterminado = 1
                WHERE IdFlujoTarea = @UltimoFlujoFacturaAgregado;
            END;
        END;

        IF (@IdTipoOperacion = 16)
        BEGIN
            IF (@Predeterminado = 1) -- Sig que se quiere eliminar el flujo activo  
            BEGIN
                SET @lastFecha =
                (
                    SELECT MAX(FechaCreacion)
                    FROM dbo.TA_FlujoTarea
                    WHERE IdProveedor = @IdProveedor
                          AND Activo = 1
                          AND ISNULL(Eliminado, 0) = 0
                          AND IdTipoOperacion = 16
                );
                SET @UltimoFlujoFacturaAgregado =
                (
                    SELECT IdFlujoTarea
                    FROM dbo.TA_FlujoTarea
                    WHERE IdProveedor = @IdProveedor
                          AND Activo = 1
                          AND ISNULL(Eliminado, 0) = 0
                          AND IdTipoOperacion = 16
                          AND FechaCreacion = @lastFecha
                );
                UPDATE dbo.TA_FlujoTarea
                SET Predeterminado = 1
                WHERE IdFlujoTarea = @UltimoFlujoFacturaAgregado;
            END;
        END;

    -------------------------------------------------  
    END;

END;

