-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama los entregables
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_GuardaActividades] --3,10061,'test',30,0,'10678,10684'
    @idContrato INT,
    @idUsuario INT,
    @idProceso INT,
    @NombreActividad VARCHAR(MAX),
    @Dias INT,
    @DiasNaturales INT, --Dias Naturales=1, dias hablies =0
    @IdEntregables VARCHAR(MAX),
    @idActividad INT,
	@idRegulador INT 
AS
BEGIN
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..#idEntregables') IS NOT NULL
        DROP TABLE #idEntregables;
    CREATE TABLE #idEntregables
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        idEntregable INT
    );
    DECLARE @Count INT,
            @error NVARCHAR(MAX),
            @CountEstatus INT,
            @CountEntregables INT,
            @MaxOrden INT,
            @CountOrden INT,
            @Abreviatura VARCHAR(7);

    INSERT INTO #idEntregables (idEntregable)
    SELECT splitdata AS idEntregable
    FROM [dbo].[fnSplitString](@IdEntregables, ',');

    --SELECT @Abreviatura = ISNULL(CI.Abreviatura, A.NombreAreaContractual)
    --FROM CO_Contrato C
    --    JOIN dbo.CO_Contratista CI
    --        ON C.IdContratista = CI.IdContratista
    --    JOIN dbo.CO_AreaContractual A
    --        ON C.IdAreaContractual = A.IdAreaContractual
    --WHERE C.IdContrato = @idContrato;

	--SET @NombreActividad=REPLACE(@NombreActividad,'-' + @Abreviatura,'');

    --SET @NombreActividad = @NombreActividad + '-' + @Abreviatura;
	IF(@idRegulador=0)BEGIN SET @idRegulador=null; END
    IF (@idActividad = 0)
    BEGIN
        IF (@NombreActividad <> '')
        BEGIN
            SELECT @Count = COUNT(*)
            FROM EN_Actividades A
                JOIN dbo.EN_ProcesosActividades PA
                    ON A.IdActividad = PA.idActividad
                       AND PA.IdProceso = @idProceso
            WHERE LTRIM(RTRIM(A.NombreActividad)) = LTRIM(RTRIM(@NombreActividad));

            -----------------------------------------Actividades
            IF (@Count = 0)
            BEGIN
                INSERT INTO dbo.EN_Actividades (NombreActividad, Dias, DiasNaturales, CreadoPor, CreadoEl,
                                                ModificadoPor, ModificadoEl, Activo,IdRegulador)
                VALUES
                (   @NombreActividad,           -- NombreActividad - nvarchar(150)
                    @Dias,                      -- Dias - int
                    @DiasNaturales, @idUsuario, -- CreadoPor - int
                    GETDATE(),                  -- CreadoEl - datetime
                    @idUsuario,                 -- ModificadoPor - int
                    GETDATE(),                  -- ModificadoEl - datetime
                    1  ,                         -- Activo - bit
                    @idRegulador);
                ---------------------------------------------- actividades Entregables
                SELECT @idActividad = SCOPE_IDENTITY();

                INSERT INTO EN_ActividadesEntregables (IdActividad, IdEntregable, CreadoPor, CreadoEl, ModificadoPor,
                                                       ModificadoEl, Activo)
                (SELECT @idActividad,
                        idEntregable,
                        @idUsuario, -- CreadoPor - int
                        GETDATE(),  -- CreadoEl - datetime
                        @idUsuario, -- ModificadoPor - int
                        GETDATE(),  -- ModificadoEl - datetime
                        1           -- Activo - bit
                 FROM #idEntregables);


                SELECT @CountOrden = ISNULL(COUNT(Orden), 0)
                FROM EN_ProcesosActividades
                WHERE IdProceso = @idProceso
					AND Orden > = 0;

                SELECT @MaxOrden = ISNULL(MAX(Orden), 0)
                FROM EN_ProcesosActividades
				WHERE IdProceso = @idProceso
				AND Orden > = 0;

                IF @CountOrden = 0
                BEGIN
                    SET @MaxOrden = 0;
                END;
                ELSE
                BEGIN
                    SET @MaxOrden = @MaxOrden + 1;
                END;

                INSERT INTO dbo.EN_ProcesosActividades (IdProceso, idActividad, IdContrato, Orden, CreadoPor, CreadoEl,
                                                        ModificadoPor, ModificadoEl, Activo)
                (SELECT @idProceso,   -- IdProceso - int
                        @idActividad, -- idActividad - int
                        @idContrato,  -- IdContrato - int
                        @MaxOrden,
                        @idUsuario,   -- CreadoPor - int
                        GETDATE(),    -- CreadoEl - datetime
                        @idUsuario,   -- ModificadoPor - int
                        GETDATE(),    -- ModificadoEl - datetime
                        1             -- Activo - bit
                );
            END;
            ELSE
            BEGIN
                SET @error = N'Ya existe una actividad con el mismo nombre para este proceso';
                SELECT @error;
            END;
        END;
        ELSE
        BEGIN
            SET @error = N'No puede guardar un nombre en blanco';
            SELECT @error;
        END;
    END;
    ELSE
    BEGIN

        SELECT @CountEstatus = COUNT(*)
        FROM EN_InstanciasActividades IA
            JOIN EN_InstanciasEntregables_InstanciaActividad IEIA
                ON IEIA.idInstanciaActividad = IA.idInstanciaActividad
            JOIN EN_InstanciasEntregable IE
                ON IEIA.idInstanciaEntregable = IE.idInstanciaEntregable
            JOIN EN_Actividad
                ON EN_Actividad.ActividadID = IE.ActividadID
        WHERE IdActividad = @idActividad
              AND EstadoID <> 10003;

        --Select * from en_estado
        IF (@CountEstatus = 0)
        BEGIN
            UPDATE EN_Actividades
            SET 
				NombreActividad=@NombreActividad,
				Dias = @Dias,
                DiasNaturales = @DiasNaturales,
                ModificadoPor = @idUsuario,
                ModificadoEl = GETDATE(),
				IdRegulador=@IdRegulador
            WHERE IdActividad = @idActividad;

            DELETE FROM EN_ActividadesEntregables
            WHERE IdActividad = @idActividad;

            INSERT INTO EN_ActividadesEntregables (IdActividad, IdEntregable, CreadoPor, CreadoEl, ModificadoPor,
                                                   ModificadoEl, Activo)
            (SELECT @idActividad,
                    idEntregable,
                    @idUsuario, -- CreadoPor - int
                    GETDATE(),  -- CreadoEl - datetime
                    @idUsuario, -- ModificadoPor - int
                    GETDATE(),  -- ModificadoEl - datetime
                    1           -- Activo - bit
             FROM #idEntregables);
        END;
        ELSE
        BEGIN
            SET @error = N'No puede modificarse la actividad,contiene fechas calculadas de un proceso activo';
            SELECT @error;
        END;
    END;
END;

