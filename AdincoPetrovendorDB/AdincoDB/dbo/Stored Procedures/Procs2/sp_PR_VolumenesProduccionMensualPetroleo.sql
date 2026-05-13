CREATE PROCEDURE sp_PR_VolumenesProduccionMensualPetroleo
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0, 
	@Periodo date
AS
BEGIN
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	Volumenes Entregados en el Periodo t
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        IdReporteVolumenesProduccionPetroleo, IdContrato, MesReporte, VolumenPetroleoPuntoMedicion, GradosAPI, ContenidoAzufre, VolumenPetroleoAutoconsumo, MetanoC1, EtanoC2, PropanoC3, ButanoC4, 
                MetanoC1Autoconsumo, EtanoC2Autoconsumo, PropanoC3Autoconsumo, ButanoC4Autoconsumo, (ISNULL(VolumenCondensadoPuntoMedicion,0) + ISNULL(VolumenCondensablePuntoMedicion,0)) AS [VolumenCondensadoPuntoMedicion],
				ISNULL(VolumenCondensadoAutoconsumo,0) + ISNULL(VolumenCondensableAutoconsumo,0) AS [VolumenCondensadoAutoconsumo]
FROM            PR_VolumenMensualProduccionPetroleo
WHERE        (IdContrato = @IdContrato) AND (MesReporte = @Periodo)
END

