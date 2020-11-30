-- =============================================
-- Author:		Daniel AC
-- Create date: 08/08/2017
-- Description:	 Comente la actualización automatica de la petición de oferta 
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ActualizarDetallePeticionMaterial]
    -- Add the parameters for the stored procedure here

    @IdPeticionOfertaDetalle INT,
    @PrecioUnitario FLOAT,
    @Disponibilidad FLOAT,
    @IdMoneda INT,
    @ComentarioSubcontratista NVARCHAR(MAX),
    @IdUsuario INT,
    @IdMaterialVendedor INT,
    @IdPeticionOferta INT,
    @FechaVigencia DATETIME,
    @IdProveedorActual INT,
    @NoCotizar BIT,
    @IdEdicionCotizacion INT,
    @IdEstatusEdicionCotizacion INT

	--@Disponibilidad NVARCHAR(MAX),
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @PrecioUnitario_Actual FLOAT,
            @Disponibilidad_Actual FLOAT,
            @IdMoneda_Actual INT,
            @MONEDA_ACTUAL NVARCHAR(300),
            @MONEDA NVARCHAR(300),
            @ComentarioSubcontratista_Actual NVARCHAR(MAX),
            ----------------------
            @IdMaterialVendedor_Actual INT,
            @FechaVigencia_Actual DATETIME,
            @NoCotizar_Actual BIT,
            @Detalle NVARCHAR(MAX) = '',
            @Subtotal FLOAT,
			@DisponibilidadNEW DECIMAL(10,2);
			
	---SET @DisponibilidadNEW= CAST(ISNULL(@Disponibilidad,'0') AS DECIMAL(10,2))
	SET @DisponibilidadNEW= CAST(@Disponibilidad AS DECIMAL(10,2))

    --#EDICION COTIZAR SIN EDICION EN HISTORIAL
    IF @NoCotizar = 0
       AND @IdEdicionCotizacion = 0
       AND @IdEstatusEdicionCotizacion = 0
    BEGIN
        SET @Subtotal = @PrecioUnitario * @DisponibilidadNEW;

        UPDATE [dbo].[MM_PeticionOfertaDetalle]
        SET [PrecioUnitario] = CAST(@PrecioUnitario AS NUMERIC(18, 2)),
            [ComentarioSubcontratista] = @ComentarioSubcontratista,
            [ModificadoPor] = @IdUsuario,
            [ModificadoEl] = GETDATE(),
            [IdMoneda] = @IdMoneda,
            [Disponibilidad] = @DisponibilidadNEW,
            [Cotizado] = 1,
            [SubTotal] = @Subtotal,
            [FechaVigencia] = @FechaVigencia,
            [ModificadoProveedorPor] = @IdProveedorActual,
            [IdMaterialVendedor] = @IdMaterialVendedor,
            [NoCotizar] = @NoCotizar
        WHERE [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle;
    END;

    --#EDICION NO COTIZAR SIN EDICION EN HISTORIAL
    IF @NoCotizar = 1
       AND @IdEdicionCotizacion = 0
       AND @IdEstatusEdicionCotizacion = 0
    BEGIN
        UPDATE [dbo].[MM_PeticionOfertaDetalle]
        SET [NoCotizar] = @NoCotizar,
            [PrecioUnitario] = NULL,
            [ComentarioSubcontratista] = NULL,
            [ModificadoPor] = @IdUsuario,
            [ModificadoEl] = GETDATE(),
            [IdMoneda] = NULL,
            [Disponibilidad] = NULL,
            [Cotizado] = 0,
            [SubTotal] = NULL,
            [FechaVigencia] = NULL,
            [ModificadoProveedorPor] = @IdProveedorActual,
            [IdMaterialVendedor] = NULL
        WHERE [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle;
    END;

    --#EDICION COTIZAR CON EDICION
    IF @NoCotizar = 0
       AND @IdEdicionCotizacion <> 0
       AND @IdEstatusEdicionCotizacion = 1
    BEGIN

		SET @NoCotizar_Actual =
        (
            SELECT NoCotizar
            FROM dbo.MM_PeticionOfertaDetalle
            WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
        );

		IF ISNULL(@NoCotizar_Actual, 0) <> @NoCotizar
			BEGIN
				SET @Detalle = (@Detalle + ' *Se cambio de no cotizar a  cotizar servicio/material, con los siguientes datos: ');

				SET @Detalle
					= (@Detalle + ' *Material a cotizar: '
					   + CAST(ISNULL(@IdMaterialVendedor, 0) AS NVARCHAR(MAX)) + ' - ' +
					   (
						   SELECT DescripcionCorta
						   FROM dbo.MM_Material
						   WHERE IdMaterial = @IdMaterialVendedor
					   ))

				SET @Detalle
					= (@Detalle + ' *Precio unitario: '
					   + CAST(ISNULL(@PrecioUnitario, 0) AS NVARCHAR(MAX)));

				SET @Detalle
					= (@Detalle + ' *Disponibilidad a cotizar de: ' + CAST(ISNULL(@DisponibilidadNEW, 0) AS NVARCHAR(MAX)));

				SET @MONEDA =
				(
					SELECT TipoMonedaCorto FROM dbo.PV_TipoMoneda WHERE IdMoneda = @IdMoneda
				);
				SET @Detalle
					= (@Detalle + ' *Moneda: ' + ISNULL(@MONEDA, ''));

				SET @Detalle
					= (@Detalle + ' *Comentario: ' + ISNULL(@ComentarioSubcontratista, ''));

				SET @Detalle
					= (@Detalle + ' *Fecha vigencia cotización de: '
					   + CAST(ISNULL(@FechaVigencia, '') AS NVARCHAR(MAX)) );

			END;
		ELSE 
			BEGIN 
					
			SET @IdMaterialVendedor_Actual =
			(
				SELECT IdMaterialVendedor
				FROM dbo.MM_PeticionOfertaDetalle
				WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			);

			SET @PrecioUnitario_Actual =
			(
				SELECT PrecioUnitario
				FROM dbo.MM_PeticionOfertaDetalle
				WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			);
			SET @Disponibilidad_Actual =
			(
				SELECT Disponibilidad
				FROM dbo.MM_PeticionOfertaDetalle
				WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			);
			SET @IdMoneda_Actual =
			(
				SELECT IdMoneda
				FROM dbo.MM_PeticionOfertaDetalle
				WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			);
			SET @ComentarioSubcontratista_Actual =
			(
				SELECT ComentarioSubcontratista
				FROM dbo.MM_PeticionOfertaDetalle
				WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			);
			SET @FechaVigencia_Actual =
			(
				SELECT FechaVigencia
				FROM dbo.MM_PeticionOfertaDetalle
				WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			);
        

			IF ISNULL(@IdMaterialVendedor_Actual, 0) <> @IdMaterialVendedor 
			BEGIN
				SET @Detalle
					= (@Detalle + ' *Cambio material a cotizar de: '
					   + CAST(ISNULL(@IdMaterialVendedor_Actual, 0) AS NVARCHAR(MAX)) + ' - ' +
					   (
						   SELECT DescripcionCorta
						   FROM dbo.MM_Material
						   WHERE IdMaterial = @IdMaterialVendedor_Actual
					   ) + ' a: ' + CAST(ISNULL(@IdMaterialVendedor, 0) AS NVARCHAR(MAX)) + ' - ' +
					   (
						   SELECT DescripcionCorta
						   FROM dbo.MM_Material
						   WHERE IdMaterial = @IdMaterialVendedor
					   )
					  );
			END;
			
			IF ISNULL(@PrecioUnitario_Actual, 0) <> @PrecioUnitario
			BEGIN
				SET @Detalle
					= (@Detalle + ' *Cambio precio unitario de: '
					   + CAST(ISNULL(@PrecioUnitario_Actual, 0) AS NVARCHAR(MAX)) + ' a: '
					   + CAST(ISNULL(@PrecioUnitario, 0) AS NVARCHAR(MAX)) + ' '
					  );

			END;

			IF ISNULL(@Disponibilidad_Actual, 0) <> @DisponibilidadNEW
			BEGIN
				SET @Detalle
					= (@Detalle + ' *Cambio cantidad de: ' + CAST(ISNULL(@Disponibilidad_Actual, 0) AS NVARCHAR(MAX))
					   + ' a: ' + CAST(ISNULL(@DisponibilidadNEW, 0) AS NVARCHAR(MAX)) + ' '
					  );

			END;

			IF ISNULL(@IdMoneda_Actual, 0) <> @IdMoneda
			BEGIN
				SET @MONEDA_ACTUAL =
				(
					SELECT TipoMonedaCorto
					FROM dbo.PV_TipoMoneda
					WHERE IdMoneda = @IdMoneda_Actual
				);
				SET @MONEDA =
				(
					SELECT TipoMonedaCorto FROM dbo.PV_TipoMoneda WHERE IdMoneda = @IdMoneda
				);

				SET @Detalle
					= (@Detalle + ' *Cambio moneda de: ' + ISNULL(@MONEDA_ACTUAL, '') + ' a: ' + ISNULL(@MONEDA, '') + ' ');

			END;


			IF ISNULL(@ComentarioSubcontratista_Actual, '') <> @ComentarioSubcontratista
			BEGIN
				SET @Detalle
					= (@Detalle + ' *Cambio comentario de: ' + ISNULL(@ComentarioSubcontratista_Actual, '') + ' a: '
					   + ISNULL(@ComentarioSubcontratista, '') + ' '
					  );

			END;

			
			IF @FechaVigencia_Actual <> @FechaVigencia
			BEGIN
				SET @Detalle
					= (@Detalle + ' *Cambio fecha vigencia cotización de: '
					   + CAST(ISNULL(@FechaVigencia_Actual, '') AS NVARCHAR(MAX)) + ' a: '
					   + CAST(ISNULL(@FechaVigencia, '') AS NVARCHAR(MAX)) + ' '
					  );

			END;

		END 


        SET @Subtotal = @PrecioUnitario * @DisponibilidadNEW;

        UPDATE [dbo].[MM_PeticionOfertaDetalle]
        SET [PrecioUnitario] = CAST(@PrecioUnitario AS NUMERIC(18, 2)),
            [ComentarioSubcontratista] = @ComentarioSubcontratista,
            [ModificadoPor] = @IdUsuario,
            [ModificadoEl] = GETDATE(),
            [IdMoneda] = @IdMoneda,
            [Disponibilidad] = @DisponibilidadNEW,
            [Cotizado] = 1,
            [SubTotal] = @Subtotal,
            [FechaVigencia] = @FechaVigencia,
            [ModificadoProveedorPor] = @IdProveedorActual,
            [IdMaterialVendedor] = @IdMaterialVendedor,
            [NoCotizar] = @NoCotizar
        WHERE [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle;


        INSERT INTO MM_HistorialEdicionCotizacion
        (
            [IdEdicionCotizacion],
            [IdUsuario],
            [IdProveedor],
            [Fecha],
            [IdPeticionOfertaDetalle],
            [Descripcion]
        )
        VALUES
        (@IdEdicionCotizacion, @IdUsuario, @IdProveedorActual, GETDATE(), @IdPeticionOfertaDetalle, ISNULL(@Detalle,'Texto no identificado.'));

        SELECT 'SUCCESS';
    END;

    --#EDICION NO COTIZAR CON EDICION
    IF @NoCotizar = 1
       AND @IdEdicionCotizacion <> 0
       AND @IdEstatusEdicionCotizacion = 1
    BEGIN


        SET @NoCotizar_Actual =
        (
            SELECT NoCotizar
            FROM dbo.MM_PeticionOfertaDetalle
            WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
        );


        IF @NoCotizar_Actual <> @NoCotizar
        BEGIN
				
			SET @IdMaterialVendedor_Actual =
			(
				SELECT IdMaterialVendedor
				FROM dbo.MM_PeticionOfertaDetalle
				WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			);

            SET @PrecioUnitario_Actual =
            (
                SELECT PrecioUnitario
                FROM dbo.MM_PeticionOfertaDetalle
                WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
            );
            SET @Disponibilidad_Actual =
            (
                SELECT Disponibilidad
                FROM dbo.MM_PeticionOfertaDetalle
                WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
            );
            SET @IdMoneda_Actual =
            (
                SELECT IdMoneda
                FROM dbo.MM_PeticionOfertaDetalle
                WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
            );
            SET @ComentarioSubcontratista_Actual =
            (
                SELECT ComentarioSubcontratista
                FROM dbo.MM_PeticionOfertaDetalle
                WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
            );
            SET @FechaVigencia_Actual =
            (
                SELECT FechaVigencia
                FROM dbo.MM_PeticionOfertaDetalle
                WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
            );

            
                SET @Detalle = (@Detalle + ' *Se cambio de Cotizar a No Cotizar servicio/material. Datos anteriores: ');

				 SET @Detalle
                    = (@Detalle + ' *Material a cotizar de: '
                       + CAST(ISNULL(@IdMaterialVendedor_Actual, 0) AS NVARCHAR(MAX)) + ' - ' +
                       (
                           SELECT DescripcionCorta
                           FROM dbo.MM_Material
                           WHERE IdMaterial = @IdMaterialVendedor_Actual
                       ));

				  SET @Detalle
					= (@Detalle + ' *Precio unitario de: ' + CAST(ISNULL(@PrecioUnitario_Actual, 0) AS NVARCHAR(MAX))
					  + ' ');
				 SET @Detalle
					= (@Detalle + ' *Disponibilidad de: ' + CAST(ISNULL(@Disponibilidad_Actual, 0) AS NVARCHAR(MAX)) + ' ');

				  SET @MONEDA_ACTUAL =
					(
						SELECT TipoMonedaCorto
						FROM dbo.PV_TipoMoneda
						WHERE IdMoneda = @IdMoneda_Actual
					);


				SET @Detalle = (@Detalle + ' *Moneda de: ' + ISNULL(@MONEDA_ACTUAL, '') + ' ');

				SET @Detalle = (@Detalle + ' *Comentario de: ' + ISNULL(@ComentarioSubcontratista_Actual, '') + ' ');
				SET @Detalle
					= (@Detalle + ' *Fecha vigencia cotización '
					  + CAST(ISNULL(@FechaVigencia_Actual, '') AS NVARCHAR(MAX)) + ' ');

           
			           
        END;



        UPDATE [dbo].[MM_PeticionOfertaDetalle]
        SET [NoCotizar] = @NoCotizar,
            [PrecioUnitario] = NULL,
            [ComentarioSubcontratista] = NULL,
            [ModificadoPor] = @IdUsuario,
            [ModificadoEl] = GETDATE(),
            [IdMoneda] = NULL,
            [Disponibilidad] = NULL,
            [Cotizado] = 0,
            [SubTotal] = NULL,
            [FechaVigencia] = NULL,
            [ModificadoProveedorPor] = @IdProveedorActual,
            [IdMaterialVendedor] = NULL
        WHERE [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle;


        IF @NoCotizar_Actual <> @NoCotizar
        BEGIN
            INSERT INTO MM_HistorialEdicionCotizacion
            (
                [IdEdicionCotizacion],
                [IdUsuario],
                [IdProveedor],
                [Fecha],
                [IdPeticionOfertaDetalle],
                [Descripcion]
            )
            VALUES
            (@IdEdicionCotizacion, @IdUsuario, @IdProveedorActual, GETDATE(), @IdPeticionOfertaDetalle, ISNULL(@Detalle,'Cambio no identificado.'));
        END;
        SELECT 'SUCCESS';
    END;

END;



