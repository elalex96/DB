-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_PR_ConsultaProduccionMensualPetroleoOficial] 
	-- Add the parameters for the stored procedure here
@IdContrato INT = 0,
@IdUsuario  INT = 0
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdReporteVolumenesProduccionPetroleoOficial as ID,
                --IdContrato,
                format(MesReporte, 'dd/MM/yyyy') as Periodo,
                format(VolumenPetroleoPuntoMedicion, '###,###,###,###') AS [Vol. Petroleo Punto Medicion],
                concat(GradosAPI, '°') AS GradosAPI,
                ContenidoAzufre,
                format(VolumenPetroleoAutoconsumo, '###,###,###,###') AS VolumenPetroleoAutoconsumo,
                format(MetanoC1, '###,###,###,###') AS MetanoC1,
                format(EtanoC2, '###,###,###,###') AS EtanoC2,
                format(PropanoC3, '###,###,###,###') AS PropanoC3,
                format(ButanoC4, '###,###,###,###') AS ButanoC4,
                format(MetanoC1Autoconsumo, '###,###,###,###') AS MetanoC1Autoconsumo,
                format(EtanoC2Autoconsumo, '###,###,###,###') AS EtanoC2Autoconsumo,
                format(PropanoC3Autoconsumo, '###,###,###,###') AS PropanoC3Autoconsumo,
                format(ButanoC4Autoconsumo, '###,###,###,###') AS ButanoC4Autoconsumo,
                format(VolumenCondensadoPuntoMedicion, '###,###,###,###') AS VolumenCondensadoPuntoMedicion,
                format(VolumenCondensadoAutoconsumo, '###,###,###,###') AS VolumenCondensadoAutoconsumo,
                --Bit_CasoFortuito,
                format(CantDiasCasoFortuito, '###,###,###,###') AS CantDiasCasoFortuito,
                format(OtrosIngresosUsoCompartidoInfraestructura,'C') as OtrosIngresosUsoCompartidoInfraestructura,
                format(VolumenPetroleoContratistaReparticion, '###,###,###,###') AS  VolumenPetroleoContratistaReparticion ,
                format(VolumenMetanoC1ContratistaReparticion, '###,###,###,###') AS  VolumenMetanoC1ContratistaReparticion ,
                format(VolumenEtanoC2ContratistaReparticion, '###,###,###,###') AS VolumenEtanoC2ContratistaReparticion  ,
                format(VolumenPropanoC3ContratistaReparticion, '###,###,###,###') AS  VolumenPropanoC3ContratistaReparticion ,
                format(VolumenButanoC4ContratistaReparticion, '###,###,###,###') AS VolumenButanoC4ContratistaReparticion  ,
                format(VolumenCondensadosContratistaReparticion, '###,###,###,###') AS VolumenCondensadosContratistaReparticion  ,
                format(VolumenPetroleoEstadoReparticion, '###,###,###,###') AS  VolumenPetroleoEstadoReparticion ,
                format(VolumenMetanoC1EstadoReparticion, '###,###,###,###') AS VolumenMetanoC1EstadoReparticion  ,
                format(VolumenEtanoC2EstadoReparticion, '###,###,###,###') AS  VolumenEtanoC2EstadoReparticion ,
                format(VolumenPropanoC3EstadoReparticion, '###,###,###,###') AS VolumenPropanoC3EstadoReparticion  ,
                format(VolumenButanoC4EstadoReparticion, '###,###,###,###') AS  VolumenButanoC4EstadoReparticion ,
                format(VolumenCondensadosEstadoReparticion, '###,###,###,###') AS VolumenCondensadosEstadoReparticion  ,
                format(VolumenPetroleoContratistaCompensacion, '###,###,###,###') AS VolumenPetroleoContratistaCompensacion  ,
                format(VolumenMetanoC1ContratistaCompensacion, '###,###,###,###') AS VolumenMetanoC1ContratistaCompensacion  ,
                format(VolumenEtanoC2ContratistaCompensacion, '###,###,###,###') AS VolumenEtanoC2ContratistaCompensacion  ,
                format(VolumenPropanoC3ContratistaCompensacion, '###,###,###,###') AS VolumenPropanoC3ContratistaCompensacion  ,
                format(VolumenButanoC4ContratistaCompensacion, '###,###,###,###') AS   VolumenButanoC4ContratistaCompensacion,
                format(VolumenCondensadosContratistaCompensacion, '###,###,###,###') AS  VolumenCondensadosContratistaCompensacion ,
                format(VolumenPetroleoEstadoCompensacion, '###,###,###,###') AS  VolumenPetroleoEstadoCompensacion ,
                format(VolumenMetanoC1EstadoCompensacion, '###,###,###,###') AS VolumenMetanoC1EstadoCompensacion  ,
                format(VolumenEtanoC2EstadoCompensacion, '###,###,###,###') AS  VolumenEtanoC2EstadoCompensacion ,
                format(VolumenPropanoC3EstadoCompensacion, '###,###,###,###') ASVolumenPropanoC3EstadoCompensacion  ,
                format(VolumenButanoC4EstadoCompensacion, '###,###,###,###') AS VolumenButanoC4EstadoCompensacion  ,
                format(VolumenCondensadosEstadoCompensacion, '###,###,###,###') AS VolumenCondensadosEstadoCompensacion  ,
                format(AcumuladoCostosRecuperablesInsolutos, 'C') as AcumuladoCostosRecuperablesInsolutos
         FROM PR_VolumenMensualProduccionPetroleoOficial
         WHERE(IdContrato = @IdContrato);
     END;
