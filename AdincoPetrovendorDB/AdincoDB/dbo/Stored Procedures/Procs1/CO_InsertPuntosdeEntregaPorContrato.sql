CREATE PROCEDURE [dbo].[CO_InsertPuntosdeEntregaPorContrato]
    @Nombre NVARCHAR(MAX),
    @TagPatinMedicion NVARCHAR(100),
    @TipoMedidor NVARCHAR(100),
    @TagMedidor NVARCHAR(100),
    @Clasificacion NVARCHAR(100),
    @idUsuario INT,
    @idContrato INT
AS
BEGIN
    -- =============================================
    -- Author:		Reyna Olvera
    -- Create date: 20180825
    -- Description:	inserta al catalogo de puntos de entrega al contrato logueado
    -- =============================================
    SET NOCOUNT ON;
    -- =============================================
    DECLARE @cont INT;

    SELECT @cont = COUNT(PuntoEntregaID)
    FROM CO_PuntosdeEntrega
    WHERE Nombre = LTRIM(RTRIM(@Nombre));

    IF (@cont >= 1)
    BEGIN
        --SE VALIDA SI EL PUNTO QUE YA EXISTE ESTA INACTIVO, EN ESE CASO SE HABILITA, EN CASO CONTRARIO; SE ENVIA MENSAJE
        UPDATE dbo.CO_PuntosdeEntrega
        SET Activo = 1
        WHERE Nombre = LTRIM(RTRIM(@Nombre));
		
		PRINT('1');
        IF
        (
            SELECT COUNT(PuntoEntregaContratoID)
            FROM dbo.CO_PuntosdeEntregaContrato
                JOIN dbo.CO_PuntosdeEntrega
                    ON CO_PuntosdeEntrega.PuntoEntregaID = CO_PuntosdeEntregaContrato.PuntoEntregaID
            WHERE Nombre = LTRIM(RTRIM(@Nombre))
                  AND idContrato = @idContrato
        ) > 0
        BEGIN
		PRINT('2');
            UPDATE dbo.CO_PuntosdeEntregaContrato
            SET Activo = 1
            FROM CO_PuntosdeEntregaContrato
                JOIN dbo.CO_PuntosdeEntrega
                    ON CO_PuntosdeEntrega.PuntoEntregaID = CO_PuntosdeEntregaContrato.PuntoEntregaID
            WHERE Nombre = LTRIM(RTRIM(@Nombre))
                  AND idContrato = @idContrato;
        END;
        ELSE
        BEGIN
		PRINT('3');
            INSERT INTO dbo.CO_PuntosdeEntregaContrato
            (
                PuntoEntregaID,
                idContrato,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                Activo
            )
            VALUES
            (
                (
                    SELECT PuntoEntregaID
                    FROM dbo.CO_PuntosdeEntrega
                    WHERE Nombre = LTRIM(RTRIM(@Nombre))
                ),           -- PuntoEntregaID - int
                @idContrato, -- idContrato - int
                @idUsuario,  -- CreadoPor - int
                GETDATE(),   -- CreadoEl - datetime
                @idUsuario,  -- ModificadoPor - int
                GETDATE(),   -- ModificadoEl - datetime
                1            -- Activo - bit
                );
        END;

    END;
    ELSE
    BEGIN
	PRINT('4');
        INSERT INTO CO_PuntosdeEntrega
        (
            Nombre,
            TagPatinMedicion,
            TipoMedidor,
            TagMedidor,
            Clasificacion,
            Activo,
            CreadoPor,
            CreadoEl
        )
        VALUES
        (LTRIM(RTRIM(@Nombre)), LTRIM(RTRIM(@TagPatinMedicion)), LTRIM(RTRIM(@TipoMedidor)), LTRIM(RTRIM(@TagMedidor)),
         LTRIM(RTRIM(@Clasificacion)), 1, @idUsuario, GETDATE());

        INSERT INTO dbo.CO_PuntosdeEntregaContrato
        (
            PuntoEntregaID,
            idContrato,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            Activo
        )
        VALUES
        (
            (
                SELECT MAX(PuntoEntregaID) FROM dbo.CO_PuntosdeEntrega
            ),           -- PuntoEntregaID - int
            @idContrato, -- idContrato - int
            @idUsuario,  -- CreadoPor - int
            GETDATE(),   -- CreadoEl - datetime
            @idUsuario,  -- ModificadoPor - int
            GETDATE(),   -- ModificadoEl - datetime
            1            -- Activo - bit
            );
    END;
END;