IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_SemanasPrograma'
    )
    DROP PROCEDURE p_OT_SemanasPrograma;
GO
--******************************************************************
-- ESTE SP TAMBIEN SE UTILIZA DENTRO DE p_OT_Estimacion_Cerrar_Semana EN ADINCO
--******************************************************************
CREATE PROC [dbo].[p_OT_SemanasPrograma] 
@pIdOTSolicitud INT
AS
BEGIN
 CREATE TABLE #tmpSemanas
    (
        ID varchar(21),
        FechaIni DATETIME,
        FechaFin datetime
    )

	CREATE TABLE #tmpSemanasInicio
    (
		Id INT IDENTITY(1,1),
        FechaInicio DATETIME
    )

	CREATE TABLE #tmpSemanasFin
    (
		Id INT IDENTITY(1,1),
        FechaFin DATETIME
    )

	CREATE TABLE #AP_CalendarioDias(IdFecha	date,DiaDeSemana tinyint, NombreDia	varchar(60));

    DECLARE @fechaIni DATETIME,
            @fechafin DATETIME,
            @fechaFinExtendida DATETIME

    SELECT @fechaFinExtendida = FechaFinExtendida
    FROM dbo.OT_Solicitud (NOLOCK)
    WHERE IdOTSolicitud = @pIdOTSolicitud;

    SELECT @fechaIni = MIN(OT_SolicitudMaterial.FechaProgramaInicio),
           @fechafin = CASE
                           WHEN @fechaFinExtendida IS NULL then
                               MAX(OT_SolicitudMaterial.FechaProgramaFin)
                           ELSE
                               @fechaFinExtendida
                       end
    FROM OT_SolicitudMaterial (NOLOCK)
    WHERE IdOTSolicitud = @pIdOTSolicitud;


	INSERT INTO #AP_CalendarioDias(IdFecha,DiaDeSemana,NombreDia)
	SELECT IdFecha,DiaDeSemana,NombreDia FROM AP_CALENDARIO WHERE IdFecha	BETWEEN @fechaIni AND @fechafin;

	/*INICIOS*/
	INSERT INTO #tmpSemanasInicio(FechaInicio) VALUES (@fechaIni);

	INSERT INTO #tmpSemanasInicio(FechaInicio)
	SELECT IdFecha FROM #AP_CalendarioDias WHERE DiaDeSemana = 1 AND IdFecha <> @fechaIni  ORDER BY IdFecha ASC;
	--______________________________________________
	/*FINALES*/
	INSERT INTO #tmpSemanasFin(FechaFin) 
	SELECT IdFecha FROM #AP_CalendarioDias WHERE DiaDeSemana = 7 AND IdFecha <> @fechafin ORDER BY IdFecha ASC;

	INSERT INTO #tmpSemanasFin(FechaFin) VALUES (@fechafin);
	--______________________________________________

	INSERT INTO #tmpSemanas(ID,FechaIni,FechaFin)
	SELECT  CONVERT(VARCHAR, Inicio.FechaInicio, 112) + '-' + CONVERT(VARCHAR, Fin.FechaFin, 112),
		Inicio.FechaInicio, Fin.FechaFin
	FROM
		#tmpSemanasInicio AS Inicio
	JOIN
		#tmpSemanasFin AS Fin
		ON Inicio.Id	=	Fin.Id;


    SELECT ID,
           FechaIniText = CONVERT(VARCHAR, FechaIni, 103),
           FechaFinText = CONVERT(VARCHAR, FechaFin, 103),
           FechaIni = FechaIni,
           FechaFin = FechaFin,
           Cerrada = cast(case
                              when OT_ProgramaSemanaCerrada.SemanaID is not null then
                                  1
                              else
                                  0
                          end as bit),
           Estado = case
                        when OT_ProgramaSemanaCerrada.SemanaID is not null then
                            'CERRADA'
                        else
                            'ABIERTA'
                    end
    FROM #tmpSemanas
        LEFT JOIN OT_ProgramaSemanaCerrada (NOLOCK)
            ON OT_ProgramaSemanaCerrada.SemanaID = #tmpSemanas.ID
               and OT_ProgramaSemanaCerrada.IdOTSolicitud = @pIdOTSolicitud
               and OT_ProgramaSemanaCerrada.isActivo = 1

END