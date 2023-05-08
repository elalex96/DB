CREATE function dbo.fn_OT_GetSemanas(@pIdOTSolicitud INT)
returns  @output TABLE(ID varchar(50),
        FechaIniText varchar(20),
        FechaFinText varchar(20),
        FechaIni DateTime,
        FechaFin DateTime,     
		Cerrada bit,
        Estado varchar(20))
AS
BEGIN
    DECLARE @fechaIni DATETIME,
            @fechafin DATETIME,
            @fechaIndice DATETIME,
            @fechaIniSemana DATETIME,
            @fechaFinSemana DATETIME,
            @diaindice INT,
            @fechaFinExtendida DATETIME
    SELECT @fechaFinExtendida = FechaFinExtendida
    FROM  dbo.OT_Solicitud
    WHERE IdOTSolicitud = @pIdOTSolicitud
            
    declare @tmpSemanas TABLE 
    (
        ID varchar(21),
        FechaIni DATETIME,
        FechaFin datetime
    )
            
    SELECT @fechaIni =  MIN(sm.FechaProgramaInicio),
        @fechafin= CASE WHEN @fechaFinExtendida IS NULL then MAX(sm.FechaProgramaFin) ELSE @fechaFinExtendida end,
        @fechaIndice = MIN(sm.FechaProgramaInicio),
        @fechaIniSemana = MIN(sm.FechaProgramaInicio)
    FROM OT_SolicitudMaterial sm
    WHERE IdOTSolicitud = @pIdOTSolicitud

    WHILE @fechaIndice <= @fechafin
    BEGIN
        
        SELECT @diaindice =
		DiaDeSemana
        FROM ap_calendario
        WHERE convert(VARCHAR,InicioDia,112) = convert(VARCHAR,@fechaIndice,112)
        IF(@diaindice =7 OR DATEADD(dd,1,@fechaIndice) > @fechafin)
        BEGIN
            SET @fechaFinSemana = @fechaIndice
     
			INSERT INTO @tmpSemanas
            (
                ID,
                FechaIni,
                FechaFin
            )	
            SELECT CONVERT(VARCHAR,@fechaIniSemana,112)+'-'+CONVERT(VARCHAR,@fechaFinSemana,112), 
                @fechaIniSemana,@fechaFinSemana

            SET @fechaIniSemana = DATEADD(dd,1,@fechaIndice)
        END

        SET @fechaIndice = DATEADD(dd,1,@fechaIndice)

        

    END
    
	INSERT INTO @output
    SELECT 
        ID,
        FechaIniText = CONVERT(VARCHAR,FechaIni,103),
        FechaFinText = CONVERT(VARCHAR,FechaFin,103),
        FechaIni = FechaIni,
        FechaFin = FechaFin,     
		Cerrada = cast(case when sc.SemanaID is not null then 1 else 0 end as bit),
        Estado = case when sc.SemanaID is not null then 'CERRADA' else 'ABIERTA' end
    FROM @tmpSemanas TMP
    LEFT JOIN [dbo].[OT_ProgramaSemanaCerrada] sc on sc.SemanaID = tmp.ID and
                                            sc.IdOTSolicitud = @pIdOTSolicitud and
                                            sc.isActivo = 1
    --WHERE FechaFin >= DATEADD(dd,-15,GETDATE())
    --Solo mostrar semanas que no excedan los 15 días de tolerancia
	RETURN 
END

    




