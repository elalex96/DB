-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_OT_Estimacion_Cerrar_Semana 20
CREATE PROC p_OT_Estimacion_Cerrar_Semana
    @pIdOTEstimacion INT,
    @pError VARCHAR(250) OUT
AS
BEGIN
    DECLARE @IdOTSolicitud INT,
            @fechaIniEst DATETIME,
            @fechaFinEst DATETIME,
            @creadoPor INT,
            @idOTBitacora INT;

    CREATE TABLE #tmpSemanas
    (
        ID VARCHAR(200),
        FechaIniText VARCHAR(200),
        FechaFinText VARCHAR(200),
        FechaIni DATETIME,
        FechaFin DATETIME,
        Cerrada BIT,
        Estado VARCHAR(200)
    );

    SELECT @IdOTSolicitud = IdOTSolicitud,
           @creadoPor = CreadoPor,
           @fechaIniEst = FechaCorteInicio,
           @fechaFinEst = FechaCorteFin
    FROM OT_Estimacion
    WHERE IdOTEstimacion = @pIdOTEstimacion
          AND ISNULL(Cancelada, 0) = 0;

    INSERT INTO #tmpSemanas
    (
        ID,
        FechaIniText,
        FechaFinText,
        FechaIni,
        FechaFin,
        Cerrada,
        Estado
    )	
    EXEC p_OT_SemanasPrograma @IdOTSolicitud;
	SELECT @IdOTSolicitud IdOTSolicitud

    INSERT INTO [dbo].[OT_ProgramaSemanaCerrada]
    (
        IdOTSolicitud,
        SemanaID,
        FechaSemanaIni,
        FechaSemanaFin,
        CreadoPor,
        CreadoEl,
        isActivo,
        ModificadoPor,
        ModificadoEl,
        MotivoApertura
    )
    SELECT @IdOTSolicitud,
           ID,
           FechaIni,
           FechaFin,
           @creadoPor,
           GETDATE(),
           1,
           NULL,
           NULL,
           NULL
    FROM #tmpSemanas t
    WHERE Cerrada = 0
          AND
          (
              FechaIni <= @fechaFinEst
              OR FechaFin <= @fechaFinEst
          ) and not exists (
			select 1
			from [OT_ProgramaSemanaCerrada] s1
			where s1.IdOTSolicitud = @IdOTSolicitud and
			s1.FechaSemanaIni = t.FechaIni and
			s1.FechaSemanaFin = t.FechaFin
		  )
	group by  ID,
           FechaIni,
           FechaFin;

	update [OT_ProgramaSemanaCerrada]
	set isActivo = 1
	from [OT_ProgramaSemanaCerrada] t1
	  inner join #tmpSemanas t2 on t1.isActivo = 0     
          AND    t2.FechaIni = t1.FechaSemanaIni 
		  and  t2.FechaFin = t1.FechaSemanaFin             
          and t1.IdOTSolicitud = @IdOTSolicitud

    SELECT @idOTBitacora = MAX(IdOTBitacora)
    FROM OT_SolicitudBitacora;
	

    INSERT INTO OT_SolicitudBitacora
    (
        IdOTBitacora,
        IdOTSolicitud,
        FlujoAprobacionTareaId,
        Descripcion,
        CreadoEl,
        UsuarioAdincoId,
        UsuarioPetroId,
        IdTipoMovimiento
    )
    SELECT @idOTBitacora + ROW_NUMBER() OVER (ORDER BY ID ASC),
           @IdOTSolicitud,
           NULL,
           'Cierre de semana ' + CAST(ID AS VARCHAR),
           GETDATE(),
           @creadoPor,
           NULL,
           NULL
    FROM #tmpSemanas
    WHERE Cerrada = 0
          AND
          (
              FechaIni <= @fechaFinEst
              OR FechaFin <= @fechaFinEst
          );
END;



