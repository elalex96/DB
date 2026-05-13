-- =============================================
-- Author:		Manuel CD
-- Create date: 17-01-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaVolumenProduccionPeriodo]
	-- Add the parameters for the stored procedure here
@IdUsuario  INT,
@IdContrato INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT IdReporteVolumenProduccionPeriodo,
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
                    VolumenCondensadoAutoconsumo
             FROM PC_VolumenProduccionPeriodo
		   WHERE IdContrato = @IdContrato
		   ORDER BY IdReporteVolumenProduccionPeriodo DESC
         END;
