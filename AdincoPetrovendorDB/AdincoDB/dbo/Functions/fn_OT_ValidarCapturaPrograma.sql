-- select dbo.fn_OT_ValidarCapturaPrograma('20171201-20171203')
create	FUNCTION dbo.fn_OT_ValidarCapturaPrograma(
@pIdOTSolicitud INT,
@pIdOTSolicitudMaterial INT,
@pDiaSemana TINYINT,
@pCaptura DECIMAL(14,3),
@pSemana varchar(21)
)
RETURNS varchar(250)
as
BEGIN

	DECLARE @result VARCHAR(250)='',
			@fechaIni DATETIME,
			@fechaFin DATETIME,
			@fechaIndex DATETIME,			
			@fechaActual DATETIME,
			@diasTolerancia int,
			@fechaCaptura DATETIME,
			@anioMesDia int
			

	Declare @tmp Table (Fecha VARCHAR(10))

	INSERT INTO @tmp
	SELECT *
	FROM [dbo].[fnSplitString](@pSemana,'-')

	IF exists(
		SELECT 1
		FROM @tmp
	)
	BEGIN 
		SELECT @fechaIni = MIN(Fecha),	
		@fechaIndex =MIN(Fecha),		
			@fechaFin = MAX(fecha)
			FROM @tmp
	END

	/**********Recorrer las fechas hasta encontrar la fecha que corresponde al día capturado*****/

	WHILE @fechaIndex <= @fechaFin
    BEGIN

		IF(
			datepart(WEEKDAY,@fechaIndex) = @pDiaSemana
		)
		BEGIN 
			SET @fechaCaptura  = @fechaIndex
			SET @fechaIndex = dateadd(dd,1,@fechaFin)
		END
        ELSE
        BEGIN
			SET @fechaIndex = DATEADD(dd,1,@fechaIndex)
		end		

    end
	

	IF(@fechaCaptura IS NOT null)
	BEGIN 
		SET @anioMesDia = (DATEPART(yy,@fechaCaptura) * 10000) +
							(DATEPART(mm,@fechaCaptura) * 100) + 
							DATEPART(dd,@fechaCaptura)
	END

	
	

	SELECT @fechaActual = GETDATE(),
		 @diasTolerancia = DiasToleranciaCapAct
	FROM dbo.OT_Solicitud ot
	inner join SC_Subcontrato sc on sc.IdSubContrato = ot.IdSubContrato
	INNER JOIN OT_Configurador conf on conf.IdContratista = sc.IdContratista and
										conf.idContrato = sc.IdContrato
	where ot.IdOTSolicitud = @pIdOTSolicitud

	
	IF(ISNULL(@diasTolerancia ,0) = 0)
	BEGIN 
		SET @result = 'Aún no está configurado los días de tolerancia para la captura del programa. Informe al Operador'
	END
    ELSE
    BEGIN
		IF (CONVERT(VARCHAR,DATEADD(DAY,@diasTolerancia,@fechaFin),112) < CONVERT(VARCHAR,@fechaActual,112))
		BEGIN 
			SET @result = 'Está fuera del periodo de captura para esta semana'
		End
    END
    
	IF exists(
		SELECT 1
		FROM OT_ProgramaSemanaCerrada
		WHERE IdOTSolicitud=@pIdOTSolicitud AND
        SemanaID = @pSemana and
		isActivo = 1
	)
	BEGIN
		SET @result = 'La semana está cerrada, no es posible continuar'
    end


	/**********Asegurarse que el dia de la semana no este en una semana cerrada******************/
	if exists (
		select 1
		from OT_ProgramaSemanaCerrada 
		where isActivo = 1 and
		IdOTSolicitud = @pIdOTSolicitud  and
		@fechaCaptura between FechaSemanaIni and FechaSemanaFin
	)
	OR
	exists (
		select 1 from  OT_SolicitudProgramaCaptura
		WHERE 
            IdAnioMesDia = @anioMesDia AND
            IdOTSolicitudMaterial = @pIdOTSolicitudMaterial AND
			VoBoSubcontratista = 1 AND
			VoBoContratista = 1 AND
			Captura <> @pCaptura
	)
	begin
		SET @result = @result+'Se está intentando modificar un día que ya está cerrado o que ya está dado el Vobo por Operador y Subcontratista'
		
	end

	


	RETURN @result
	
END



