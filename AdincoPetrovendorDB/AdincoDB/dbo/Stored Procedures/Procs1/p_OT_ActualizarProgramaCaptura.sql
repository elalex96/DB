IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ActualizarProgramaCaptura'
    )
    DROP PROCEDURE p_OT_ActualizarProgramaCaptura;
GO
CREATE PROC [dbo].[p_OT_ActualizarProgramaCaptura]
    @pIdOTSolicitudProgramaCaptura INT,
    @pIdOTSolicitudMaterial        INT,
    @pSemana                       VARCHAR(21),
    @pCaptura                      DECIMAL(14, 5),
    @pDiaSemana                    TINYINT,
    @pCreadoPor                    VARCHAR(50),
    @pCreadlEl                     DATETIME,
    @pVoBoContratista              BIT          = null,
    @pVoBoSubcontratista           bit          = NULL,
    @pErrorOut                     VARCHAR(250) out
AS
BEGIN

	  CREATE TABLE #tmpSemana (Fecha VARCHAR(10));

	  CREATE TABLE #tmpResult
        (
            IdOTSolicitudMaterial int,
            Material              varchar(200),
            IdOTSolicitud         int,
            Folio                 Varchar(max),
            Disponible            INT,
            LunesCaptura          decimal,
            MartesCaptura         decimal,
            MiercolesCaptura      decimal,
            JuevesCaptura         decimal,
            ViernesCaptura        decimal,
            SabadoCaptura         decimal,
            DomingoCaptura        decimal,
            TotalSemana           decimal,
            IdEstatus             bit,
            LunesVoBoC            BIT,
            MartesVoBoC           BIT,
            MiercolesVoBoC        BIT,
            JuevesVoBoC           BIT,
            ViernesVoBoC          BIT,
            SabadoVoBoC           BIT,
            DomingoVoBoC          BIT,
            ---------------------------------
            LunesVoBoSC           BIT,
            MartesVoBoSC          BIT,
            MiercolesVoBoSC       BIT,
            JuevesVoBoSC          BIT,
            ViernesVoBoSC         BIT,
            SabadoVoBoSC          BIT,
            DomingoVoBoSC         BIT,
            ---------------------------------
            LunesCerrado          BIT,
            MartesCerrado         BIT,
            MiercolesCerrado      BIT,
            JuevesCerrado         BIT,
            ViernesCerrado        BIT,
            SabadoCerrado         BIT,
            DomingoCerrado        BIT,
            UploadFile            varchar(max),
            TieneArchivos         BIT
        )

    DECLARE
        @IdOTSolicitudProgramaCaptura INT,
        @fechaIni                     DATETIME,
        @fechaFin                     DATETIME,
        @fechaIndex                   DATETIME,
        @fechaCaptura                 DATETIME,
        @anioMesDia                   int,
        @IdOTSolicitud                int,
        @decimales                    int,
        @pDiaSemana2                  TINYINT = @pDiaSemana

		 DECLARE
			@VoBoContratista    BIT,
			@VoBoSubcontratista BIT,
			@CapturaDia         DECIMAL = 0.0

    select
        @IdOTSolicitud = IdOTSolicitud
    from
        OT_SolicitudMaterial (NOLOCK)
    where
        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial

    /***Obtener la cantidad de decimales que se pude capturar***/
    SELECT	@decimales = c.Decimales
    FROM
			OT_Solicitud   ot	(NOLOCK)
	JOIN
            SC_SubContrato sc (NOLOCK)
		ON	ot.IdSubContrato	=	sc.IdSubContrato
			AND	ot.IdOTSolicitud = @IdOTSolicitud
	JOIN
        OT_Configurador    c	 (NOLOCK)
      ON	c.IdContrato = sc.IdContrato;

    /****Validar decimales, no debe de exceder el límite configurado***/
    if (isnull(@decimales, 0) = 0)
        begin
            SET @pErrorOut = 'No está configurado el límite de decimales, por favor revisar'
            GOTO fin

        end

    INSERT INTO #tmpSemana
                SELECT
                    *
                FROM
                    [dbo].[fnSplitString](@pSemana, '-')
    IF exists
        (
            SELECT
                1
            FROM
                #tmpSemana
        )
        BEGIN
            SELECT
                @fechaIni   = MIN(Fecha),
                @fechaIndex = MIN(Fecha),
                @fechaFin   = MAX(fecha)
            FROM
                #tmpSemana
        END

    /**********Recorrer las fechas hasta encontrar la fecha que corresponde al día capturado*****/
    WHILE @fechaIndex <= @fechaFin
        BEGIN
            IF (datepart(WEEKDAY, @fechaIndex) = @pDiaSemana)
                BEGIN
                    SET @fechaCaptura = @fechaIndex
                    SET @fechaIndex = dateadd(dd, 1, @fechaFin)
                END
            ELSE
                BEGIN
                    SET @fechaIndex = DATEADD(dd, 1, @fechaIndex)
                end
        end

    IF (@fechaCaptura IS NOT null)
        BEGIN
            SET @anioMesDia
                = (DATEPART(yy, @fechaCaptura) * 10000) + (DATEPART(mm, @fechaCaptura) * 100)
                  + DATEPART(dd, @fechaCaptura)
        END

    if @fechaCaptura is null
       and isnull(@pCaptura, 0) > 0
        begin
            set @pErrorOut = case
                                 when @pDiaSemana2 = 1
                                     then 'El Domingo no es válido para la semana seleccionada'
                                 when @pDiaSemana2 = 2
                                     then 'El Lunes no es válido para la semana seleccionada'
                                 when @pDiaSemana2 = 3
                                     then 'El Martes no es válido para la semana seleccionada'
                                 when @pDiaSemana2 = 4
                                     then 'El Miercoles no es válido para la semana seleccionada'
                                 when @pDiaSemana2 = 5
                                     then 'El Jueves no es válido para la semana seleccionada'
                                 when @pDiaSemana2 = 6
                                     then 'El Viernes no es válido para la semana seleccionada'
                                 when @pDiaSemana2 = 7
                                     then 'El Sábado no es válido para la semana seleccionada'
                             end
            return
        end

    /***Validar si existe un VoBo. para el dia****/
   
    INSERT INTO #tmpResult
    exec [dbo].[p_OT_ConsultaSolicitudProgramaCaptura]
        @IdOTSolicitud,
        @pSemana,
        0

    if (@pDiaSemana2 = 1)
        begin
            SET @VoBoContratista =
                (
                    SELECt
                        DomingoVoBoC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )
            SET @VoBoSubcontratista =
                (
                    SELECt
                        DomingoVoBoSC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )
            SET @CapturaDia =
                (
                    SELECt
                        ISNULL(DomingoCaptura, 0)
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )
        end

    if (@pDiaSemana2 = 2)
        begin
            SET @VoBoContratista =
                (
                    SELECt
                        LunesVoBoC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @VoBoSubcontratista =
                (
                    SELECt
                        LunesVoBoSC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @CapturaDia =
                (
                    SELECt
                        ISNULL(LunesCaptura, 0)
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

        end
    if (@pDiaSemana2 = 3)
        begin
            SET @VoBoContratista =
                (
                    SELECt
                        MartesVoBoC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @VoBoSubcontratista =
                (
                    SELECt
                        MartesVoBoSC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @CapturaDia =
                (
                    SELECt
                        ISNULL(MartesCaptura, 0)
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

        end

    if (@pDiaSemana2 = 4)
        begin
            SET @VoBoContratista =
                (
                    SELECt
                        MiercolesVoBoC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @VoBoSubcontratista =
                (
                    SELECt
                        MiercolesVoBoSC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @CapturaDia =
                (
                    SELECt
                        ISNULL(MiercolesCaptura, 0)
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

        end

    if (@pDiaSemana2 = 5)
        begin
            SET @VoBoContratista =
                (
                    SELECt
                        JuevesVoBoC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @VoBoSubcontratista =
                (
                    SELECt
                        JuevesVoBoSC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @CapturaDia =
                (
                    SELECt
                        ISNULL(JuevesCaptura, 0)
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

        end

    if (@pDiaSemana2 = 6)
        begin

            SET @VoBoContratista =
                (
                    SELECt
                        ViernesVoBoC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @VoBoSubcontratista =
                (
                    SELECt
                        ViernesVoBoSC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @CapturaDia =
                (
                    SELECt
                        ISNULL(ViernesCaptura, 0)
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )
        end

    if (@pDiaSemana2 = 7)
        begin

            SET @VoBoContratista =
                (
                    SELECt
                        SabadoVoBoC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @VoBoSubcontratista =
                (
                    SELECt
                        SabadoVoBoSC
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )

            SET @CapturaDia =
                (
                    SELECt
                        ISNULL(SabadoCaptura, 0)
                    from
                        #tmpResult
                    where
                        IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )
        end

    SET @VoBoContratista = ISNULL(@VoBoContratista, 0)
    SET @VoBoSubcontratista = ISNULL(@VoBoSubcontratista, 0)

    IF (@CapturaDia <> @pCaptura)
        begin
            if (
            (
                @VoBoContratista = 1
                or @VoBoSubcontratista = 1
            )
               )
                begin
                    SET @pErrorOut = 'Hay un VoBo activado para el día, no es posible actualizar'
                    GOTO fin
                end
        end

    /**********Asegurarse que el dia de la semana no este en una semana cerrada******************/
    if exists
        (
            select
                1
            from
                OT_ProgramaSemanaCerrada (NOLOCK)
            where
                isActivo = 1
                and IdOTSolicitud = @IdOTSolicitud
                and @fechaCaptura
                between FechaSemanaIni and FechaSemanaFin
        )
        begin
            SET @pErrorOut
                = 'Se está intentando modificar un día que ya está cerrado o que ya está dado el Vobo por Operador y Subcontratista'
            GOTO fin
        end

    IF (
           @fechaCaptura IS NULL
           OR @anioMesDia IS null
       )
        BEGIN
            --SET @pErrorOut = 'Se encontró un error al calcular las fechas'
            GOTO fin
        END
    ELSE
        BEGIN

            if NOT EXISTS
                (
                    SELECT
                        1
                    FROM
                        OT_SolicitudProgramaCaptura (NOLOCK)
                    WHERE
                        IdAnioMesDia = @anioMesDia
                        AND IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                )
                BEGIN

                    SELECT
                        @pIdOTSolicitudProgramaCaptura = ISNULL(MAX(IdOTSolicitudProgramaCaptura), 0) + 1
                    FROM
                        OT_SolicitudProgramaCaptura (NOLOCK);

                    IF (@pCaptura > 0)
                        BEGIN

                            INSERT INTO OT_SolicitudProgramaCaptura
                                (
                                    IdOTSolicitudProgramaCaptura,
                                    IdOTSolicitudMaterial,
                                    IdAnioMesDia,
                                    Fecha,
                                    Captura,
                                    CreadoPor,
                                    CreadoEl,
                                    ModificadoPor,
                                    ModificadoEl 
                                )
                            VALUES
                                (
                                    @pIdOTSolicitudProgramaCaptura,
                                    @pIdOTSolicitudMaterial,
                                    @anioMesDia,
                                    @fechaCaptura,
                                    @pCaptura,
                                    @pCreadoPor,
                                    GETDATE(),
                                    NULL,
                                    NULL
                                )
                        END

                END
            ELSE
                begin

                    UPDATE
                        OT_SolicitudProgramaCaptura
                    SET
                        captura = @pCaptura,
                        ModificadoPor = @pCreadoPor,
                        ModificadoEl = getdate() 
                    WHERE
                        IdAnioMesDia = @anioMesDia
                        AND IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                End
        End
    fin:
END