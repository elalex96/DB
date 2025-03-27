-- Eliminar el procedimiento si ya existe
DROP PROCEDURE IF EXISTS [dbo].[USP_INS_AP_Notificacion]
GO

CREATE PROCEDURE [dbo].[USP_INS_AP_Notificacion]
    @Id INT OUT,
    @Para VARCHAR(5000),
    @Asunto VARCHAR(500),
    @Mensaje TEXT,
    @FechaProgramadaEnvio DATETIME = NULL, -- Permitir valor nulo
    @Enviada BIT = 0,
    @CreadoPor INT,
    @CCO VARCHAR(2000) = '',
    @Modulo VARCHAR(100) -- Parámetro para verificar el módulo
AS
BEGIN
    DECLARE @NewId INT, 
            @De VARCHAR(255);

    -- Crear tabla temporal para almacenar los correos 'Para' sin duplicados
    CREATE TABLE #tmpPara (
        Para VARCHAR(500)
    );

	 -- Crear tabla temporal para almacenar los correos 'CCO' sin duplicados
    CREATE TABLE #tmpCCO (
        CCO VARCHAR(500)
    );

    -- Si @FechaProgramadaEnvio es NULL, asignar GETDATE()
    IF @FechaProgramadaEnvio IS NULL
        SET @FechaProgramadaEnvio = DATEADD(MINUTE,1,GETDATE());

    -- Verificar si el módulo existe, si no existe, asignar el correo para 'Adinco'
    IF NOT EXISTS (SELECT 1 FROM AP_Notification2FAServicio WHERE Modulo = @Modulo)
    BEGIN
        -- Si el módulo no existe, obtener correo para el módulo 'Adinco'
        SELECT TOP 1 @De = Correo 
        FROM AP_Notification2FAServicio (NOLOCK) 
        WHERE Modulo = 'Adinco';
    END
    ELSE
    BEGIN 
        -- Si el módulo existe, obtener el correo asociado
        SELECT TOP 1 @De = Correo 
        FROM AP_Notification2FAServicio (NOLOCK) 
        WHERE Modulo = @Modulo;
    END 

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Quitar duplicados en 'Para' y cargar los correos únicos en la tabla temporal
        INSERT INTO #tmpPara (Para)
        SELECT DISTINCT splitdata
        FROM [dbo].[fnSplitString](@Para, ';')
        WHERE ISNULL(splitdata, '') <> ''
        ORDER BY splitdata;

        -- Reconciliando 'Para' de nuevo después de quitar duplicados
        SET @Para = '';
        SELECT @Para = @Para + ISNULL(Para, '') + ';'
        FROM #tmpPara;

        -- Quitar duplicados en 'CCO' y cargar los correos únicos en la tabla temporal
        IF ISNULL(@CCO, '') <> ''
        BEGIN
            INSERT INTO #tmpCCO (CCO)
            SELECT DISTINCT splitdata
            FROM [dbo].[fnSplitString](@CCO, ';')
            WHERE ISNULL(splitdata, '') <> ''
            ORDER BY splitdata;

            -- Reconciliando 'CCO' de nuevo después de quitar duplicados
            SET @CCO = '';
            SELECT @CCO = @CCO + ISNULL(CCO, '') + ';'
            FROM #tmpCCO;
        END

        -- Verificar que los parámetros esenciales no estén vacíos
        IF ISNULL(@Para, '') <> '' AND ISNULL(CAST(@Mensaje AS VARCHAR(8000)), '') <> ''
        BEGIN
            -- Insertar una nueva notificación
            INSERT INTO dbo.AP_Notificacion
            (
                Para,                  
                Asunto,               
                Mensaje,               
                FechaProgramadaEnvio,   
                Enviada,              
                CreadoPor,              
                CreadoEl,               
                ModificadoPor,          
                ModificadoEl,           
                De,                     
                CCO,
                Modulo
            )
            VALUES
            (      
                @Para,                 
                ISNULL(@Asunto, ''),   
                ISNULL(@Mensaje, ''),  
                @FechaProgramadaEnvio,  
                @Enviada,              
                @CreadoPor,            
                GETDATE(),              
                NULL,                   
                NULL,                   
                @De,                   
                @CCO,
                @Modulo
            );

            -- Obtener el ID generado
            SET @NewId = SCOPE_IDENTITY();
            SET @Id = @NewId;
        END;

     -- Limpiar las tablas temporales al final
        DROP TABLE #tmpPara;
        DROP TABLE #tmpCCO;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- No devuelve mensajes de error, solo revierte la transacción
    END CATCH;
END;
