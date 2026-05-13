
CREATE PROCEDURE SP_PC_ConsultaUnVolumenProdPer 
	@IdReporteVolumenProduccionPeriodo INT,
	@IdUsuario                         INT,
	@IdContrato                        INT
AS
         BEGIN
-- =============================================
-- Author:		Manuel CD
-- Create date: 18-01-2018
-- Description:	
-- =============================================
-- 20180726	BAAC	Se modifica para mostrar el volumen de condensable
-- =============================================
SET NOCOUNT ON
-- =============================================
-- Insert statements for procedure here
    SELECT
		MesReporte,
        FechaInicio,
        FechaFin,
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
		VolumenCondensableAutoconsumo
    FROM PC_VolumenProduccionPeriodo
    WHERE IdReporteVolumenProduccionPeriodo = @IdReporteVolumenProduccionPeriodo
END

