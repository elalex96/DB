-- =============================================
-- Author:		Miguel Gomex
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_PR_ConsultaProduccionMensualPetroleoOficialItem 
	-- Add the parameters for the stored procedure here
@IdReporteVolumenesProduccionPetroleoOficial INT = 0,
@IdContrato                                INT = 0,
@IdUsuario                                 INT = 0
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdReporteVolumenesProduccionPetroleoOficial,
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
                VolumenCondensadoAutoconsumo
         FROM PR_VolumenMensualProduccionPetroleoOficial
         WHERE IdReporteVolumenesProduccionPetroleoOficial = @IdReporteVolumenesProduccionPetroleoOficial;
     END;
