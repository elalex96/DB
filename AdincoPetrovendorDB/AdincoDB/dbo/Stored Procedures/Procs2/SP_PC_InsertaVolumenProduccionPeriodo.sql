
CREATE PROCEDURE SP_PC_InsertaVolumenProduccionPeriodo 
	@IdContrato                     INT,
	@IdUsuario                      INT,
	@MesReporte                     DATE,
	@FechaInicio                    DATE,
	@FechaFin                       DATE,
	@VolumenPetroleoPuntoMedicion   FLOAT,
	@GradosAPI                      FLOAT,
	@ContenidoAzufre                FLOAT,
	@VolumenPetroleoAutoconsumo     FLOAT,
	@MetanoC1                       FLOAT,
	@EtanoC2                        FLOAT,
	@PropanoC3                      FLOAT,
	@ButanoC4                       FLOAT,
	@MetanoC1Autoconsumo            FLOAT,
	@EtanoC2Autoconsumo             FLOAT,
	@PropanoC3Autoconsumo           FLOAT,
	@ButanoC4Autoconsumo            FLOAT,
	@VolumenCondensadoPuntoMedicion FLOAT,
	@VolumenCondensadoAutoconsumo   FLOAT,
	@VolumenCondensablePuntoMedicion	FLOAT = 0,
	@VolumenCondensableAutoconsumo		FLOAT = 0
AS
BEGIN
-- =============================================
-- Author:		Manuel CD
-- Create date: 18-01-2018
-- Description:	
-- =============================================
-- 20180726	BAAC	Se modifica para insertar los valores de condensable
-- =============================================
SET NOCOUNT ON

INSERT INTO [dbo].[PC_VolumenProduccionPeriodo]
(	[IdContrato],
	[MesReporte],
	[FechaInicio],
	[FechaFin],
	[VolumenPetroleoPuntoMedicion],
	[GradosAPI],
	[ContenidoAzufre],
	[VolumenPetroleoAutoconsumo],
	[MetanoC1],
	[EtanoC2],
	[PropanoC3],
	[ButanoC4],
	[MetanoC1Autoconsumo],
	[EtanoC2Autoconsumo],
	[PropanoC3Autoconsumo],
	[ButanoC4Autoconsumo],
	[VolumenCondensadoPuntoMedicion],
	[VolumenCondensadoAutoconsumo],
	[CreadoPor],
	[CreadoEn],
	VolumenCondensablePuntoMedicion,
	VolumenCondensableAutoconsumo
)
VALUES
(	@IdContrato,
	@MesReporte,
	@FechaInicio,
	@FechaFin,
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
	@IdUsuario,
	GETDATE(),
	@VolumenCondensablePuntoMedicion,
	@VolumenCondensableAutoconsumo
)

    IF @@ERROR <> 0
        SELECT 'false' AS msj
    ELSE
		SELECT 'true' AS msj
END

