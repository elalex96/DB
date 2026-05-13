
CREATE PROCEDURE SP_PC_ActualizaVolumenProduccionPeriodo
	@IdContrato                        INT,
	@IdUsuario                         INT,
	@IdReporteVolumenProduccionPeriodo INT,
	@MesReporte                        DATE,
	@FechaInicio                       DATE,
	@FechaFin                          DATE,
	@VolumenPetroleoPuntoMedicion      FLOAT,
	@GradosAPI                         FLOAT,
	@ContenidoAzufre                   FLOAT,
	@VolumenPetroleoAutoconsumo        FLOAT,
	@MetanoC1                          FLOAT,
	@EtanoC2                           FLOAT,
	@PropanoC3                         FLOAT,
	@ButanoC4                          FLOAT,
	@MetanoC1Autoconsumo               FLOAT,
	@EtanoC2Autoconsumo                FLOAT,
	@PropanoC3Autoconsumo              FLOAT,
	@ButanoC4Autoconsumo               FLOAT,
	@VolumenCondensadoPuntoMedicion    FLOAT,
	@VolumenCondensadoAutoconsumo      FLOAT,
	@VolumenCondensablePuntoMedicion	FLOAT = 0,
	@VolumenCondensableAutoconsumo		FLOAT = 0
AS
BEGIN
-- =============================================
-- Author:		Manuel CD
-- Create date: 18-01-2018
-- Description:	
-- =============================================
-- 20180726	BAAC	Se modifica para actualizar los valores de condensable
-- =============================================
SET NOCOUNT ON


UPDATE [dbo].[PC_VolumenProduccionPeriodo]
    SET
        MesReporte = @MesReporte,
        FechaInicio = @FechaInicio,
        FechaFin = @FechaFin,
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
        ModificadoPor = @IdUsuario,
        ModificadoEn = GETDATE(),
		VolumenCondensablePuntoMedicion	=	@VolumenCondensablePuntoMedicion,
		VolumenCondensableAutoconsumo	=	@VolumenCondensableAutoconsumo
    WHERE
		IdReporteVolumenProduccionPeriodo = @IdReporteVolumenProduccionPeriodo
        AND IdContrato = @IdContrato

    IF @@ERROR <> 0
        SELECT 'false' AS msj
    ELSE
		SELECT 'true' AS msj
END

