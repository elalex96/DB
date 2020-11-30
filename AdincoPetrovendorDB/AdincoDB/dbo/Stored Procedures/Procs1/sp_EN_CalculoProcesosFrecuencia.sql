--=============================================
--Author:		Reyna Olvera
--Create date: 20190524
--Description:	Guarda Procesos con frecuencia
--=============================================
CREATE PROCEDURE [dbo].[sp_EN_CalculoProcesosFrecuencia] --3,10061,12094,0----3,10061,12093,0 --10045,10061,'Manifiesto de impacto ambiental','Manifiesto de impacto ambiental',0
    @idContrato INT,
    @idUsuario INT,
    @idProceso INT,
    @idInstanciaProcesoExistente INT
AS
BEGIN

    SET NOCOUNT ON;


    --DECLARE @idContrato                  INT = 3,
    --        @idUsuario                   INT = 10061,
    --        @idProceso                   INT = 12094,
    --        @idInstanciaProcesoExistente INT = 0;

    IF OBJECT_ID('tempdb.dbo.#ActividadesDeProceso', 'U') IS NOT NULL
        DROP TABLE #ActividadesDeProceso;
    CREATE TABLE #ActividadesDeProceso
    (
        ID INT IDENTITY(1, 1),
        IdProceso INT,
        IdActividad INT,
        IdEntregable INT,
        NombreActividad VARCHAR(500),
        Orden INT,
        BitInterno INT,
        Consecutivo VARCHAR(50),
        IdFrecuenciaEntregable INT,
        IdContrato INT,
        IdContratoEntregable INT,
        DiasElaboracion INT,
        DiasRevision INT,
        DiasAprobacion INT,
        DiasAlerta INT
    );


    DECLARE @BitInternoMax INT,
            @IdContratoEntregableMax INT,
            @IdActividadMax INT,
            @error VARCHAR(500) = '',
            @CountInstanciasEntregabFrec INT = 0,
            @IDMax INT,
            @CantActividades INT,
            @ContadorActividades INT,
            @IdFrecuenciaEntregableMax INT,
            @CorreoUsuarioReceptorAlerta VARCHAR(500),
            @IsSerie INT,
            @FechaLimiteElaboracionFrecuencia DATE;

    SELECT @IsSerie = ISNULL(IsSerie, 1)
    FROM dbo.EN_Procesos
    WHERE IdProceso = @idProceso; -- si esta null lo tomamos como lineal

    INSERT INTO #ActividadesDeProceso (IdProceso, IdActividad, IdEntregable, NombreActividad, Orden, BitInterno,
                                       Consecutivo, IdFrecuenciaEntregable, IdContrato, IdContratoEntregable,
                                       DiasElaboracion, DiasRevision, DiasAprobacion, DiasAlerta)
    SELECT PA.IdProceso,
           PA.idActividad,
           AE.IdEntregable,
           A.NombreActividad,
           PA.Orden,
           E.BitInterno,
           E.Consecutivo,
           ISNULL(E.IdFrecuenciaEntregable, 0),
           PA.IdContrato,
           CE.IdContratoEntregable,
           DiasElaboracion,
           DiasRevision,
           DiasAprobacion,
           DiasAlerta
    FROM dbo.EN_ProcesosActividades PA
    JOIN dbo.EN_Actividades A ON PA.idActividad = A.IdActividad
    JOIN dbo.EN_ActividadesEntregables AE ON A.IdActividad = AE.IdActividad
    LEFT JOIN dbo.EN_Entregable E ON AE.IdEntregable = E.IdEntregable
    LEFT JOIN dbo.EN_ContratoEntregable CE ON E.IdEntregable = CE.IdEntregable
                                              AND CE.IdContrato = @idContrato
    WHERE PA.IdProceso = @idProceso
          AND PA.Activo = 1
		  AND PA.Orden	>= 0
    ORDER BY PA.Orden ASC;

    SELECT TOP 1
           @IDMax = ID,
           @IdActividadMax = IdActividad,
           @IdContratoEntregableMax = IdContratoEntregable,
           @BitInternoMax = BitInterno,
           @IdFrecuenciaEntregableMax = IdFrecuenciaEntregable
    --SELECT *
    FROM #ActividadesDeProceso --4	11099	16818	0	10009
    ORDER BY Orden DESC;

    SELECT TOP 1  @FechaLimiteElaboracionFrecuencia = FechaInicioElaboracion --para paralelo
    FROM dbo.EN_InstanciasEntregable IE 
    WHERE IE.IdContratoEntregable = @IdContratoEntregableMax
	ORDER BY FechaInicioElaboracion ASC;

    SELECT @CantActividades = --4
        --SELECT 
        COUNT(IdActividad)
    FROM #ActividadesDeProceso;

    SET @ContadorActividades = @IDMax; --4

    SELECT @CountInstanciasEntregabFrec =
        --SELECT 
        COUNT(idInstanciaEntregable) --943 instancias
    FROM dbo.EN_InstanciasEntregable
    WHERE IdContratoEntregable = @IdContratoEntregableMax; --16818

    --Select * from en_estado
    SELECT @CorreoUsuarioReceptorAlerta = u.Usuario
    FROM EN_Actividad acu
    JOIN dbo.AP_Usuario u ON acu.idUsuario = u.UsuarioID
    WHERE IdContratoEntregable = @IdContratoEntregableMax
          AND EstadoID = 10000;

    --SELECT * FROM #ActividadesDeProceso
    --SELECT @CountInstanciasEntregabFrec,@CantActividades,@ContadorActividades

    IF (@BitInternoMax <> 0 OR @CountInstanciasEntregabFrec = 0)
    BEGIN
        SET @error
            = 'El ultimo entregable debe ser de frecuencia ó verifique que el entregable de frecuencia contenga fechas programadas';
    END;
    ELSE
    BEGIN

        WHILE (
                  @CantActividades >= @ContadorActividades
                  AND (ISNULL(@ContadorActividades, 0) >= 2)
              )
        BEGIN

            DECLARE @FechaLimiteint DATE,              -- date
                    @DiasElaboracion INT,              -- int
                    @FechaLimiteEntregaRegulador DATE, -- date
                    @DiasRevision INT,                 -- int
                    @DiasAprobacion INT,               -- int
                    @DiasAlerta INT,                   -- int
                    @IdContratoEntregable INT,         -- int
                    @idEntregable INT,
                    @IdContratoEntregableact INT;



            SELECT TOP 1
                   @FechaLimiteint = CASE @IsSerie
                                         WHEN 0
										  THEN
											  CONVERT(DATE, DATEADD(DAY, -1, @FechaLimiteElaboracionFrecuencia))--paralelo
                                         ELSE
                                             CONVERT(DATE, DATEADD(DAY, -1, IE.FechaInicioElaboracion))
                                     END,
                   @DiasElaboracion = TOrdenAntes.DiasElaboracion,
                   --      @FechaLimiteint = CONVERT(DATE, DATEADD(DAY, -1, IE.FechaInicioElaboracion)),
                   @DiasRevision = TOrdenAntes.DiasRevision,
                   @DiasAprobacion = TOrdenAntes.DiasAprobacion,
                   @DiasAlerta = TOrdenAntes.DiasAlerta,
                   @IdContratoEntregable = ISNULL(TOrdenAntes.IdContratoEntregable, 0),
                   @idEntregable = TOrdenAntes.IdEntregable,
                   @IdContratoEntregableact = TA.IdContratoEntregable
            FROM dbo.EN_InstanciasEntregable IE
            JOIN #ActividadesDeProceso TA ON IE.IdContratoEntregable = TA.IdContratoEntregable
            JOIN #ActividadesDeProceso TOrdenAntes ON TOrdenAntes.IdContratoEntregable =
                                                   (
                                                       SELECT IdContratoEntregable
                                                       FROM #ActividadesDeProceso
                                                       WHERE ID = @ContadorActividades - 1
                                                   ) --@ContadorActividades
            WHERE TA.ID = @ContadorActividades
            ORDER BY FechaInicioElaboracion ASC;
            /*
SELECT @IdContratoEntregable,
       @ContadorActividades,
       @IdContratoEntregableact;
SELECT TOP 1
       DATEADD(DAY, -1, IE.FechaInicioElaboracion),
       TOrdenAntes.DiasElaboracion,
       DATEADD(DAY, -1, IE.FechaInicioElaboracion),
       TOrdenAntes.DiasRevision,
       TOrdenAntes.DiasAprobacion,
       TOrdenAntes.DiasAlerta,
       TOrdenAntes.IdContratoEntregable,
       TOrdenAntes.IdEntregable
FROM dbo.EN_InstanciasEntregable IE
JOIN #ActividadesDeProceso TA ON IE.IdContratoEntregable = TA.IdContratoEntregable
JOIN #ActividadesDeProceso TOrdenAntes ON TOrdenAntes.IdContratoEntregable =
                                       (
                                           SELECT IdContratoEntregable
                                           FROM #ActividadesDeProceso
                                           WHERE ID = @ContadorActividades - 1
                                       ) --@ContadorActividades
WHERE TA.ID = @ContadorActividades
ORDER BY FechaInicioElaboracion ASC;
*/
            EXEC dbo.SP_EN_GeneraInstanciasProcesosFrecuencias @FechaLimiteint,       -- date
                                                               @DiasElaboracion,      -- int
                                                               @FechaLimiteint,       -- date
                                                               @DiasRevision,         -- int
                                                               @DiasAprobacion,       -- int
                                                               @DiasAlerta,           -- int
                                                               @IdContratoEntregable, -- int
                                                               @idContrato,           -- int
                                                               @idUsuario,            -- int
                                                               @idEntregable,         -- int
                                                               @IdFrecuenciaEntregableMax,
                                                               0,
                                                               0;                     -- int

            UPDATE dbo.EN_ContratoEntregable
            SET ReceptorAlerta = CASE
                                     WHEN ReceptorAlerta IS NULL
                                          OR ReceptorAlerta = '' THEN
                                         @CorreoUsuarioReceptorAlerta
                                     WHEN ReceptorAlerta NOT LIKE '%' + @CorreoUsuarioReceptorAlerta + '%' THEN
                                         ReceptorAlerta + ',' + @CorreoUsuarioReceptorAlerta + ','
                                     WHEN ReceptorAlerta LIKE '%' + @CorreoUsuarioReceptorAlerta + '%' THEN
                                         ReceptorAlerta
                                 END
            FROM dbo.EN_ContratoEntregable
            WHERE IdContratoEntregable = @IdContratoEntregable;

            SET @ContadorActividades = @ContadorActividades - 1;
        ----SELECT TOP 1 * FROM dbo.EN_InstanciasEntregable
        END;

    END;

    SELECT @error AS error;

END;


