CREATE PROCEDURE VolumenesProduccionMensual
    @IdReporteVolumenesProduccionPetroleo INT = 0,
    @Accion NVARCHAR(50),
    @IdContrato INT,
    @MesReporte DATE = NULL,
    @VolumenPetroleoPuntoMedicion FLOAT = 0,
    @GradosAPI FLOAT = 0,
    @ContenidoAzufre FLOAT = 0,
    @VolumenPetroleoAutoconsumo FLOAT = 0,
    @MetanoC1 FLOAT = 0,
    @EtanoC2 FLOAT = 0,
    @PropanoC3 FLOAT = 0,
    @ButanoC4 FLOAT = 0,
    @MetanoC1Autoconsumo FLOAT = 0,
    @EtanoC2Autoconsumo FLOAT = 0,
    @PropanoC3Autoconsumo FLOAT = 0,
    @ButanoC4Autoconsumo FLOAT = 0,
    @VolumenCondensadoPuntoMedicion FLOAT = 0,
    @VolumenCondensadoAutoconsumo FLOAT = 0,
    @VolumenCondensablePuntoMedicion FLOAT = 0,
    @VolumenCondensableAutoconsumo FLOAT = 0,
    @CreadoPor INT,
	@Activo BIT = 1
AS
BEGIN
    INSERT INTO PR_VolumenMensualProduccionPetroleoBitacora
    (
        IdReporteVolumenesProduccionPetroleo,
        Accion,
        IdContrato,
        MesReporte,
        VolumenPetroleoPuntoMedicion,
        GradosAPI,
        ContenidoAzufre,
        VolumenPetroleoAutoconsumo,
        MetanoC1,
        EtanoC2,
        PropanoC3,
        ButanoC4,
        MetanoC1Autoconsumo,
        EtanoC2Autoconsumo,
        PropanoC3Autoconsumo,
        ButanoC4Autoconsumo,
        VolumenCondensadoPuntoMedicion,
        VolumenCondensadoAutoconsumo,
        VolumenCondensablePuntoMedicion,
        VolumenCondensableAutoconsumo,
        CreadoEl,
        CreadoPor,
		Activo
    )
    SELECT IdReporteVolumenesProduccionPetroleo,
           @Accion,
           IdContrato,
           MesReporte,
           VolumenPetroleoPuntoMedicion,
           GradosAPI,
           ContenidoAzufre,
           VolumenPetroleoAutoconsumo,
           MetanoC1,
           EtanoC2,
           PropanoC3,
           ButanoC4,
           MetanoC1Autoconsumo,
           EtanoC2Autoconsumo,
           PropanoC3Autoconsumo,
           ButanoC4Autoconsumo,
           VolumenCondensadoPuntoMedicion,
           VolumenCondensadoAutoconsumo,
           VolumenCondensablePuntoMedicion,
           VolumenCondensableAutoconsumo,
           GETDATE(),
           @CreadoPor,
		   @Activo
    FROM PR_VolumenMensualProduccionPetroleo
    WHERE IdReporteVolumenesProduccionPetroleo = @IdReporteVolumenesProduccionPetroleo

    IF (@Accion = 'Select')
    BEGIN
        SELECT *
        FROM PR_VolumenMensualProduccionPetroleo
        WHERE IdContrato = @IdContrato
    END

    IF (@Accion = 'Update')
    BEGIN
        UPDATE PR_VolumenMensualProduccionPetroleo
        SET IdContrato = @IdContrato,
            MesReporte = @MesReporte,
            VolumenPetroleoPuntoMedicion = @VolumenPetroleoPuntoMedicion,
            GradosAPI = @GradosAPI,
            ContenidoAzufre = @ContenidoAzufre,
            VolumenPetroleoAutoconsumo = @VolumenPetroleoAutoconsumo,
            MetanoC1 = @MetanoC1,
            EtanoC2 = @EtanoC2,
            PropanoC3 = @PropanoC3,
            ButanoC4 = @ButanoC4,
            MetanoC1Autoconsumo = @MetanoC1Autoconsumo,
            EtanoC2Autoconsumo = @EtanoC2Autoconsumo,
            PropanoC3Autoconsumo = @PropanoC3Autoconsumo,
            ButanoC4Autoconsumo = @ButanoC4Autoconsumo,
            VolumenCondensadoPuntoMedicion = @VolumenCondensadoPuntoMedicion,
            VolumenCondensadoAutoconsumo = @VolumenCondensadoAutoconsumo,
            VolumenCondensablePuntoMedicion = @VolumenCondensablePuntoMedicion,
            VolumenCondensableAutoconsumo = @VolumenCondensableAutoconsumo,
            ModificadoPor = @CreadoPor,
            ModificadoEl = GETDATE(),
			Activo = @Activo
        WHERE IdReporteVolumenesProduccionPetroleo = @IdReporteVolumenesProduccionPetroleo
    END

    IF (@Accion = 'Insert')
    BEGIN


        INSERT INTO PR_VolumenMensualProduccionPetroleo
        (
            IdContrato,
            MesReporte,
            VolumenPetroleoPuntoMedicion,
            GradosAPI,
            ContenidoAzufre,
            VolumenPetroleoAutoconsumo,
            MetanoC1,
            EtanoC2,
            PropanoC3,
            ButanoC4,
            MetanoC1Autoconsumo,
            EtanoC2Autoconsumo,
            PropanoC3Autoconsumo,
            ButanoC4Autoconsumo,
            VolumenCondensadoPuntoMedicion,
            VolumenCondensadoAutoconsumo,
            VolumenCondensablePuntoMedicion,
            VolumenCondensableAutoconsumo,
            CreadoPor,
            CreadoEl,
			Activo
        )
        VALUES
        (@IdContrato,
         @MesReporte,
         @VolumenPetroleoPuntoMedicion,
         @GradosAPI,
         @ContenidoAzufre,
         @VolumenPetroleoAutoconsumo,
         @MetanoC1,
         @EtanoC2,
         @PropanoC3,
         @ButanoC4,
         @MetanoC1Autoconsumo,
         @EtanoC2Autoconsumo,
         @PropanoC3Autoconsumo,
         @ButanoC4Autoconsumo,
         @VolumenCondensadoPuntoMedicion,
         @VolumenCondensadoAutoconsumo,
         @VolumenCondensablePuntoMedicion,
         @VolumenCondensableAutoconsumo,
         @CreadoPor,
         GETDATE(),
		 @Activo
        )

        SELECT @IdReporteVolumenesProduccionPetroleo = SCOPE_IDENTITY()

        INSERT INTO PR_VolumenMensualProduccionPetroleoBitacora
        (
            IdReporteVolumenesProduccionPetroleo,
            Accion,
            IdContrato,
            MesReporte,
            VolumenPetroleoPuntoMedicion,
            GradosAPI,
            ContenidoAzufre,
            VolumenPetroleoAutoconsumo,
            MetanoC1,
            EtanoC2,
            PropanoC3,
            ButanoC4,
            MetanoC1Autoconsumo,
            EtanoC2Autoconsumo,
            PropanoC3Autoconsumo,
            ButanoC4Autoconsumo,
            VolumenCondensadoPuntoMedicion,
            VolumenCondensadoAutoconsumo,
            VolumenCondensablePuntoMedicion,
            VolumenCondensableAutoconsumo,
            CreadoEl,
            CreadoPor,
			Activo
        )
        SELECT @IdReporteVolumenesProduccionPetroleo,
               @Accion,
               @IdContrato,
               @MesReporte,
               @VolumenPetroleoPuntoMedicion,
               @GradosAPI,
               @ContenidoAzufre,
               @VolumenPetroleoAutoconsumo,
               @MetanoC1,
               @EtanoC2,
               @PropanoC3,
               @ButanoC4,
               @MetanoC1Autoconsumo,
               @EtanoC2Autoconsumo,
               @PropanoC3Autoconsumo,
               @ButanoC4Autoconsumo,
               @VolumenCondensadoPuntoMedicion,
               @VolumenCondensadoAutoconsumo,
               @VolumenCondensablePuntoMedicion,
               @VolumenCondensableAutoconsumo,
               GETDATE(),
               @CreadoPor,
			   @Activo
    END

    IF (@Accion = 'Delete')
    BEGIN
       UPDATE PR_VolumenMensualProduccionPetroleo
	   SET Activo = 0,
			ModificadoPor = @CreadoPor,
            ModificadoEl = GETDATE()
        WHERE IdReporteVolumenesProduccionPetroleo = @IdReporteVolumenesProduccionPetroleo
    END
END
