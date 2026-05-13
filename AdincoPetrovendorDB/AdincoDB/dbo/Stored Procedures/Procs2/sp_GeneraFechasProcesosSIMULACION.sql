-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Genera Calculo de fechas
-- =============================================
CREATE PROCEDURE sp_GeneraFechasProcesosSIMULACION-- 3,10061,1,'2019-06-20',12092--SIMULACION 
    @idContrato INT,
    @idUsuario INT,
    @FechaSeleccionada BIT, -- 1=Inicial 0=final
    @Fecha DATE,
    @idProceso INT
AS
BEGIN
    SET NOCOUNT ON;
    CREATE TABLE #TempInstancias
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        FechasLimiteElaboracion DATE,
        idEntregable INT
    );
    CREATE TABLE #SelectFinal
    (
        IdProceso INT,
        DescripcionProceso VARCHAR(2500),
        IdContrato INT,
        Orden INT,
        IdActividad INT,
        NombreActividad VARCHAR(2500),
        Dias INT,
        DiasNaturales BIT,
        FechaInicial DATE,
        FechaLimite DATE,
        IdActividadPredecesora INT,
        IdActividadSucesora INT,
        Fecha DATE,
        FechaInicialBit BIT,
        Descripcion VARCHAR(1000),
        idTipoProceso INT,
        IdInstalacion INT,
        Banderas INT
    );
    CREATE TABLE #FechasRepetidas
    (
        BanderaCount INT,
        FechaLimite DATE
    );

    DECLARE @IsProcesoEvento INT, @NuevaFecha DATE

    SELECT @IsProcesoEvento = IsProcesoEvento
    FROM dbo.EN_Procesos
    WHERE IdProceso = @idProceso;

    IF (@IsProcesoEvento = 1)
    BEGIN
        IF (@FechaSeleccionada = 1) --Fecha Inicial
        BEGIN
            INSERT INTO #SelectFinal
            (
                IdProceso,
                DescripcionProceso,
                IdContrato,
                Orden,
                IdActividad,
                NombreActividad,
                Dias,
                DiasNaturales,
                FechaInicial,
                FechaLimite,
                IdActividadPredecesora,
                IdActividadSucesora
            )
            EXEC sp_GeneraFechasProcesos @idContrato, @idUsuario, @Fecha, @idProceso;
            -----********************************************************************************************

            INSERT INTO #FechasRepetidas
            (
                BanderaCount,
                FechaLimite
            )
            SELECT COUNT(*),
                   FechaLimite
            FROM 
				#SelectFinal
            GROUP BY FechaLimite
            HAVING COUNT(*) > 1;

            UPDATE SF
            SET Banderas	=	ISNULL(FR.BanderaCount, 0),
                Fecha	=	@Fecha,
                FechaInicialBit	=	@FechaSeleccionada,
                Descripcion	=	DescripcionProceso,
                idTipoProceso	=	10000,
                IdInstalacion	=	0
            FROM 
				#SelectFinal	SF
            LEFT	JOIN 
				#FechasRepetidas	FR
                ON	FR.FechaLimite	=	SF.FechaLimite;

         SELECT s.*,
                   ROW_NUMBER() OVER (ORDER BY FechaLimite ASC) AS c,
				   p.NombreProceso,
				   ISNULL(R.Regulador,'') AS Regulador,
				   'false' as FechaRealActividad
            FROM 
				#SelectFinal s
			JOIN 
				dbo.EN_Procesos p 
				ON s.IdProceso=p.IdProceso
			JOIN 
				EN_Actividades	A
				ON	S.IdActividad	=	A.IdActividad
			LEFT JOIN 
				CO_Regulador	R
				ON A.IdRegulador	=	R.IdRegulador;

        END;

        ELSE IF (@FechaSeleccionada = 0) --Fecha final
        BEGIN
            INSERT INTO #SelectFinal
            (
                IdProceso,
                DescripcionProceso,
                IdContrato,
                Orden,
                IdActividad,
                NombreActividad,
                Dias,
                DiasNaturales,
                FechaInicial,
                FechaLimite,
                IdActividadPredecesora,
                IdActividadSucesora
            )
            EXEC sp_GeneraFechasProcesosConFechaFinal @idContrato,
													  @idUsuario,
                                                @Fecha,
                                                      @idProceso;
            UPDATE SF
            SET Banderas = ISNULL(FR.BanderaCount, 0),
                Fecha = @Fecha,
				FechaInicialBit = @FechaSeleccionada,
                Descripcion = DescripcionProceso,
                idTipoProceso = 10000,
                IdInstalacion = 0
            FROM 
				#SelectFinal SF
			LEFT JOIN 
				#FechasRepetidas FR
                ON FR.FechaLimite	=	SF.FechaLimite;


            SELECT s.*,
                   ROW_NUMBER() OVER (ORDER BY FechaLimite ASC) AS c,
				   p.NombreProceso,
				   ISNULL(R.Regulador,'') AS Regulador,
				   'false' as FechaRealActividad
            FROM	
				#SelectFinal s
			JOIN	
				dbo.EN_Procesos	p 
				ON	s.IdProceso	=	p.IdProceso
			JOIN 
				EN_Actividades	A
				ON	S.IdActividad	=	A.IdActividad
			LEFT JOIN 
				CO_Regulador	R
				ON A.IdRegulador	=	R.IdRegulador;
        END;
    END;
    ELSE
    BEGIN

        INSERT INTO #TempInstancias
        (
            FechasLimiteElaboracion,
            idEntregable
        )
        SELECT MIN(IE.FechasLimiteElaboracion),
               CE.IdEntregable
        FROM 
			dbo.EN_InstanciasEntregable IE

		JOIN 
			EN_ContratoEntregable CE
			ON IE.IdContratoEntregable = CE.IdContratoEntregable
			AND CE.IdContrato = @idContrato

		JOIN 
			dbo.EN_Entregable E
			ON CE.IdEntregable = E.IdEntregable

		JOIN
			dbo.EN_ActividadesEntregables AE
			ON E.IdEntregable = AE.IdEntregable

		JOIN 
			dbo.EN_Actividades A
			ON AE.IdActividad = A.IdActividad

		JOIN 
			dbo.EN_ProcesosActividades PA
			ON A.IdActividad = PA.idActividad
			AND A.IdActividad = AE.IdActividad
			AND PA.IdContrato = @idContrato

		JOIN 
			dbo.EN_Procesos P
			ON PA.IdProceso = P.IdProceso

		JOIN 
			dbo.EN_ProcesosContrato pc
			ON pc.idProceso = @idProceso
			AND pc.idContrato = @idContrato

        WHERE 
			P.IdProceso = @idProceso
			AND PA.IdProceso = @idProceso
			AND pc.idContrato = @idContrato
        GROUP BY 
			CE.IdEntregable;


        SELECT PA.IdProceso,
               P.NombreProceso AS DescripcionProceso,
               PA.IdContrato,
               PA.Orden,
               PA.idActividad,
               A.NombreActividad + '-' + E.DocumentoEntregable AS NombreActividad,
               CASE E.BitInterno
                   WHEN 1 THEN
               (CE.DiasElaboracion + CE.DiasRevision)
                   ELSE
               (CE.DiasElaboracion + CE.DiasRevision + CE.DiasAprobacion)
               END AS Dias,
               @FechaSeleccionada  AS DiasNaturales,
               IE.FechaInicioElaboracion AS FechaInicial,
               IE.FechasLimiteAprobacion AS FechaLimite ,
               0,
               0,
               GETDATE() AS Fecha,
			   null,
               P.Descripcion,
               10000,
               0,
               0 AS Banderas,
               ROW_NUMBER() OVER (ORDER BY IE.FechasLimiteAprobacion ASC) AS c,
			   P.NombreProceso,
			    '' as Regulador,
				'false' as FechaRealActividad
        FROM 
			#TempInstancias TI

        JOIN 
			EN_InstanciasEntregable IE
            ON TI.FechasLimiteElaboracion = IE.FechasLimiteElaboracion

        JOIN 
			EN_ContratoEntregable CE
            ON IE.IdContratoEntregable = CE.IdContratoEntregable
            AND TI.idEntregable = CE.IdEntregable
            AND CE.IdContrato = @idContrato

        JOIN 
			dbo.EN_Entregable E
            ON CE.IdEntregable = E.IdEntregable

        JOIN 
			dbo.EN_ActividadesEntregables AE
            ON E.IdEntregable = AE.IdEntregable

        JOIN 
			dbo.EN_Actividades A
            ON AE.IdActividad = A.IdActividad

        JOIN 
			dbo.EN_ProcesosActividades PA
            ON A.IdActividad = PA.idActividad
            AND A.IdActividad = AE.IdActividad
      AND PA.IdContrato = @idContrato

        JOIN 
			dbo.EN_Procesos P
            ON PA.IdProceso = P.IdProceso

        JOIN 
			dbo.EN_ProcesosContrato pc
            ON pc.idProceso = @idProceso
            AND pc.idContrato = @idContrato

        WHERE 
			P.IdProceso = @idProceso
            AND PA.IdProceso = @idProceso
            AND pc.idContrato = @idContrato
        ORDER BY 
			PA.Orden ASC;
    END;

END;
