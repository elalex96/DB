-- =============================================
-- Author:		Manuel CD
-- Create date: 22-11-2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ListaEntregables] --1,21
	-- Add the parameters for the stored procedure here
@IdRegulador        INT,
@ActividadPetrolera INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             DECLARE @PozoDeAlivio INT= -1;
             DECLARE @Abandono INT= -1;
             DECLARE @Perforacion INT= -1;
             DECLARE @Terminacion INT= -1;
             DECLARE @ActividadesDeProduccion INT= -1;
             DECLARE @Estimulacion INT= -1;
             DECLARE @PruebaDeProduccion INT= -1;
             DECLARE @ConstruccionDeCamino INT= -1;
             DECLARE @ConstruccionDeLocalizacion INT= -1;
             DECLARE @ReabilitacionDeCamino INT= -1;
             DECLARE @ReabilitacionDeLocalizacion INT= -1;
             DECLARE @TomadeInformacionSismica INT= -1;
             DECLARE @CorteDeNucleos INT= -1;
             DECLARE @ConstruccionLineasDescargas INT= -1;
             DECLARE @SistemasArtificialesProduccion INT= -1;
             DECLARE @MedicionPozos INT= -1;
             DECLARE @TomadeInformacionPozos INT= -1;
             DECLARE @ReparacionMayor INT= -1;
             DECLARE @ReparacionMenor INT= -1;
             DECLARE @TransporteHidrocarburos INT= -1;
             DECLARE @AdministracionContratos INT= -1;
             DECLARE @QuemaDeGas INT= -1;
             
/***/

             IF @ActividadPetrolera = 1
                 BEGIN
                     SELECT @PozoDeAlivio = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 2
                 BEGIN
                     SELECT @Abandono = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 3
                 BEGIN
                     SELECT @Perforacion = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 4
                 BEGIN
                     SELECT @Terminacion = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 5
                 BEGIN
                     SELECT @ActividadesDeProduccion = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 6
                 BEGIN
                     SELECT @Estimulacion = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 7
                 BEGIN
                     SELECT @PruebaDeProduccion = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 8
                 BEGIN
                     SELECT @ConstruccionDeCamino = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 9
                 BEGIN
                     SELECT @ConstruccionDeLocalizacion = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 10
                 BEGIN
                     SELECT @ReabilitacionDeCamino = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 11
                 BEGIN
                     SELECT @ReabilitacionDeLocalizacion = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 12
                 BEGIN
                     SELECT @TomadeInformacionSismica = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 13
                 BEGIN
                     SELECT @CorteDeNucleos = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 14
                 BEGIN
                     SELECT @ConstruccionLineasDescargas = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 15
                 BEGIN
                     SELECT @SistemasArtificialesProduccion = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 16
                 BEGIN
                     SELECT @MedicionPozos = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 17
                 BEGIN
                     SELECT @TomadeInformacionPozos = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 18
                 BEGIN
                     SELECT @ReparacionMayor = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 19
                 BEGIN
                     SELECT @ReparacionMenor = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 20
                 BEGIN
                     SELECT @TransporteHidrocarburos = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 21
                 BEGIN
                     SELECT @AdministracionContratos = 1;
                 END;
                 ELSE
             IF @ActividadPetrolera = 22
                 BEGIN
                     SELECT @QuemaDeGas = 1;
                 END;
		   
/***/

             IF(@ActividadPetrolera = 23 AND @IdRegulador = 5)
                 BEGIN
                     SELECT IdEntregable,
                            CONCAT(IdEntregable,' - ',Consecutivo,' - ',DocumentoEntregable) AS DocumentoEntregable
                     FROM dbo.EN_Entregable EN
					 WHERE EN.ISACTIVO = 1
					 AND BITINTERNO = 0
					 AND BITJOA = 0;
                 END;
                 ELSE
                 BEGIN
                     SELECT IdEntregable,
                            CONCAT(IdEntregable,' - ',Consecutivo,' - ',DocumentoEntregable) AS DocumentoEntregable
                     FROM dbo.EN_Entregable EN
                     WHERE( ISACTIVO = 1
							AND BITINTERNO = 0
							AND BITJOA = 0
							AND IdRegulador = @IdRegulador
                           AND EN.APQuemaGas = @QuemaDeGas
                           AND @QuemaDeGas = 1)
                          OR (IdRegulador = @IdRegulador
						  AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APAdministracionContratos = @AdministracionContratos
                              AND @AdministracionContratos = 1)
                          OR (IdRegulador = @IdRegulador
						  	AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APTransporteHidrocarburos = @TransporteHidrocarburos
                              AND @TransporteHidrocarburos = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APReparacionMenor = @ReparacionMenor
                              AND @ReparacionMenor = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APReparacionMayor = @ReparacionMayor
                              AND @ReparacionMayor = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APTomaInformacionPozo = @TomadeInformacionPozos
                              AND @TomadeInformacionPozos = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APMedicionPozos = @MedicionPozos
                              AND @MedicionPozos = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APSistemaArtificialProduccion = @SistemasArtificialesProduccion
                              AND @SistemasArtificialesProduccion = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APConstruccionLineaDescarga = @ConstruccionLineasDescargas
                              AND @ConstruccionLineasDescargas = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APCorteNucleos = @CorteDeNucleos
                              AND @CorteDeNucleos = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APTomaInformacionSismica = @TomadeInformacionSismica
                              AND @TomadeInformacionSismica = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APRehabilitacionLocalizacion = @ReabilitacionDeLocalizacion
                              AND @ReabilitacionDeLocalizacion = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APRehabilitacionCamino = @ReabilitacionDeCamino
                              AND @ReabilitacionDeCamino = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APConstruccionLocalizacion = @ConstruccionDeLocalizacion
                              AND @ConstruccionDeLocalizacion = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APConstruccionCamino = @ConstruccionDeCamino
                              AND @ConstruccionDeCamino = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APPruebaProduccion = @PruebaDeProduccion
                              AND @PruebaDeProduccion = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APReparacionMayor = @Estimulacion
                              AND @Estimulacion = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APActProduccion = @ActividadesDeProduccion
                              AND @ActividadesDeProduccion = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APTerminacion = @Terminacion
                              AND @Terminacion = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APPerforacion = @Perforacion
                              AND @Perforacion = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APCierreDesmantelamientoAbandono = @Abandono
                              AND @Abandono = 1)
                          OR (IdRegulador = @IdRegulador
							AND BITINTERNO = 0 AND BITJOA = 0
                              AND EN.APPozoAlivio = @PozoDeAlivio
                              AND @PozoDeAlivio = 1);
                 END;
END;