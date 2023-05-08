CREATE PROCEDURE [dbo].[sp_EN_ConsultaInventarioEntregables] --3,10061,3,2
    -- Add the parameters for the stored procedure here
    --sp_EN_ConsultaInventarioEntregables 10005, 1,3,23
    @IdContrato INT,
    @IdUsuario INT,
    @ResponsableGenerador INT = 0,
    @ActividadPetrolera INT = 0
AS
BEGIN
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:
-- =============================================
-- Modificación Author:		Reyna O.
-- Modificación día: 	24-01-2019
-- Modificación descripcion: Se añadio  Join a contratoEntregable, Rondas y contrato, para ver solamente los entregables vigentes para ese contrato
-- Se quito Substring del campo 'DocumentoEntregablke' para que el usuario pueda visualizar todo el texto
-- =============================================
    SET NOCOUNT ON;

	EXEC sp_EN_ConsultaInventarioEntregables_V2 @IdContrato, @IdUsuario, @ResponsableGenerador, @ActividadPetrolera
	RETURN 

/*
    DECLARE @UbicacionGeografica INT = 0;
    DECLARE
 @UGTerreste INT = 0;
    DECLARE @UGCostaFuera INT = 0;
    --ResponsableGenerador
    DECLARE @REReguladores INT = 0;
  DECLARE @REOperadores INT = 0;
    --Actividad Petrolera
    DECLARE @PozoDeAlivio INT = -1;
    DECLARE @Abandono INT = -1;
    DECL
ARE @Perforacion INT = -1;
    DECLARE @Terminacion INT = -1;
    DECLARE @ActividadesDeProduccion INT = -1;
    DECLARE @Estimulacion INT = -1;
    DECLARE @PruebaDeProduccion INT = -1;
    DECLARE @ConstruccionDeCamino INT = -1;
    DECLARE @Construccio
nDeLocalizacion INT = -1;
    DECLARE @ReabilitacionDeCamino INT = -1;
    DECLARE @ReabilitacionDeLocalizacion INT = -1;
    DECLARE @TomadeInformacionSismica INT = -1;
    DECLARE @CorteDeNucleos INT = -1;
    DECLARE @ConstruccionLineasDescargas INT = 
-1;
    DECLARE @SistemasArtificialesProduccion INT = -1;
    DECLARE @MedicionPozos INT = -1;
    DECLARE @TomadeInformacionPozos INT = -1;
    DECLARE @ReparacionMayor INT = -1;
    DECLARE @ReparacionMenor INT = -1;
    DECLARE @TransporteHidrocarburos
 INT = -1;
    DECLARE @AdministracionContratos INT = -1;
    DECLARE @QuemaDeGas INT = -1;

    SELECT @UbicacionGeografica = AC.IdUbicacionAC
      FROM dbo.CO_Contrato C
	  JOIN dbo.CO_AreaContractual	AC
		ON C.IdAreaContractual = AC.IdAreaContractual


     WHERE C.IdContrato = @IdContrato;
    --Determinar la ubicacion geografica del contrato
    IF @UbicacionGeografica = 10000
    BEGIN
        SELECT @UGTerreste = 1,
               @UGCostaFuera = 0;
    END
    ELSE --IF @UbicacionGeografica =2
    

BEGIN
        SELECT @UGTerreste = 0,
               @UGCostaFuera = 1;
    END;
   --set @UGCostaFuera =1
END;

--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--Todos los generadores y todas las actividades
--|||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||

IF  @ResponsableGenerador = 3
AND @ActividadPetrolera = 23
BEGIN
    SELECT
		ER.idRonda,
		0 as IdContratoEntregable,--CE.IdContratoEntregable,
		EN.IdEntregable,
		EN.Consecutivo,
		R.Regulador,
		ML.MarcoLegal AS Ma
rcoLegal,
			SUBSTRING(EN.Articulo,0,200) AS Articulo,
		EN.DocumentoEntregable AS DocumentoEntregable,
		ET.Etapa,
		RE.ReceptorEntregable,
		RG.ResponsableGenerador,
		FE.FrecuenciaEntregable,
		--SUBSTRING(TE.TiempoEntrega,0,120) AS TiempoEntrega,
		SU
BSTRING(EN.TiempoEntrega, 0, 120) AS TiempoEntrega,
		TR.TiempoRespuesta,
		CASE
				WHEN EN.REReguladores = 1 THEN 'Regulador'
				ELSE 'Operador' END AS ReguladorOperador,
		REReguladores,
   
		EN.REOperadores,
		EN.APAdministracionContratos,
		EN.APPozoAlivio,
		EN.APCierreDesmantelamientoAbandono,
		EN.APPerforacion,
		EN.APTerminacion,
		EN.APActProduccion,
		EN.APEstimulacion,
		EN.APPruebaProduccion,
		EN.APConstruccionCamino,
		EN.APCons
truccionLocalizacion,
		EN.APRehabilitacionCamino,
		EN.APRehabilitacionLocalizacion,
     
		EN.APTomaInformacionSismica,
		EN.APCorteNucleos,
		EN.APConstruccionLineaDescarga,
		EN.APSistemaArtificialProduccion,
		EN.APMedicionPozos,
		EN.APTomaInformacionPozo,
    
		EN.APReparacionMayor,
		EN.APReparacionMenor,
		EN.APTransporteHidrocarburos,
		EN.APQuemaGas,
		EN.TituloAnexo AS TituloAnexo,
		EN.Capitulo AS Capitulo
-- CASE
      --                    WHEN LTRIM(en.APAdministracionContratos) = 1
      --          
          THEN 'Administracion Contratos'
      --WHEN en.APPozoAlivio =1 
      --                    THEN 'Pozo Alivio'
      --ELSE ''

      --       END AS Actividad,
      FROM      EN_Entregable AS EN
     LEFT JOIN EN_MarcoLegal AS ML
        ON M
L.IdMarcoLegal           = EN.IdMarcoLegal
      LEFT JOIN CO_Regulador AS R
        ON R.IdRegulador             = EN.IdRegulador
      LEFT JOIN EN_ReceptorEntregable AS RE
        ON RE.IdReceptorEntregable   = EN.IdReceptorEntregable
      LEFT JOIN E
N_ResponsableGenerador AS RG
        ON RG.IdResponsableGenerador = EN.IdResponsableGenerador
      LEFT JOIN EN_FrecuenciaEntregable AS FE
       
 ON FE.IdFrecuenciaEntregable = EN.IdFrecuenciaEntregable
      -- left JOIN EN_TiempoEntrega AS TE ON TE.IdTiempoEntrega = EN.IdTiempoEntrega
     LEFT JOIN      EN_TiempoRespuesta AS TR
        ON EN.IdTiempoRespuesta      = TR.IdTiempoRespuesta
      L
EFT JOIN EN_Etapa AS ET
        ON ET.IdEtapa                = EN.IdEtapa
      JOIN      CO_Contrato C
        ON C.IdContrato              = @IdContrato
-- Se quita para no forzar que exista uan relacion
     -- JOIN      dbo.EN_ContratoEntregable CE
  



   --   ON CE.IdContrato             = @IdContrato
     --  AND CE.IdEntregable           = EN.IdEntregable
      JOIN      EN_EntregableRonda ER
        ON ER.idRonda                = C.IdRonda
       AND ER.idEntregable           = EN.IdEntregable
     



WHERE    EN.TCLicencia			= 1  --(   (EN.TCProducionCompartida   = 1))
            --  AND   (EN.UGTerrestre  = @UGTerreste))
       AND      ISNULL(EN.IsEliminado, 0) = 0
     ORDER BY EN.IdEntregable;
END;
ELSE
BEGIN
    --Determinar a quien genera el en
tregable
    --IdClave	  Nombre
    --1		  Operador
    --2		  Regulador
    --3		  Todos
    IF @ResponsableGenerador = 1
    BEGIN
        SELECT @REReguladores = 0,
               @REOperadores = 1;
    END;
    ELSE IF @ResponsableGenerador = 2
    BE
GIN
        SELECT @REReguladores = 1,
               @REOperadores = 0;
    END;
    ELSE IF @ResponsableGenerador = 3
    BEGIN
        SELECT @REReguladores = -1,
               @REOperadores = -1;
    END;
    --Determinar Actividad Petrolera
    --1	
Pozo de alivio
    --2	Abandono
    --3	Perforación
    --4	Terminación
    --5	Actividades de Producción
    --6	Estimulación
    --7	Prueba de Producción
    --8	Construcción de Camino
    --9	Construcción de Localizacion
    --10	Reabilitación de Camin
o
    --11	Reabilitación de Localización
    --12	Toma de Información Sísmica
    --13	Corte de Nucleos
    --14	Construcción de Lineas de descargas
    --15	Sistemas Artificiales de Producción
    --16	Medición de Pozos
    --17	Toma de Información en Po
zos
    --18	Reparación Mayor
    --19	Reparación Menor
    --20	Transporte de Hidrocarburos
    --21	Administración de Contratos
    --22	Quema de Gas
    --23	Todos
    IF @ActividadPetrolera = 1
    BEGIN
        SELECT @PozoDeAlivio = 1;
    END;
    
ELSE IF @ActividadPetrolera = 2
    BEGIN
        SELECT @Abandono = 1;
    END;
    ELSE IF @ActividadPetrolera = 3
    BEGIN
        SELECT @Perforacion = 1;
    END;
    ELSE IF @ActividadPetrolera = 4
    BEGIN
        SELECT @Terminacion = 1;
    END
;
    ELSE IF @ActividadPetrolera = 5
    BEGIN
        SELECT @ActividadesDeProduccion = 1;
    END;
    ELSE IF @ActividadPetrolera = 6
    BEGIN
        SELECT @Estimulacion = 1;
    END;
    ELSE IF @ActividadPetrolera = 7
    BEGIN
        SELECT @PruebaDeProduccion = 1;

    END;
    ELSE IF @ActividadPetrolera = 8
    BEGIN
        SELECT @ConstruccionDeCamino = 1;
    END;
    ELSE IF @ActividadPetrolera = 9
    BEGIN
        SELECT @ConstruccionDeLocalizacion = 1;
 END;
    ELSE IF @ActividadPetrolera = 10
    BEGIN
 
       SELECT @ReabilitacionDeCamino = 1;
    END;
    ELSE IF @ActividadPetrolera = 11
    BEGIN
        SELECT @ReabilitacionDeLocalizacion = 1;
    END;
    ELSE IF @ActividadPetrolera = 12
    BEGIN
        SELECT @TomadeInformacionSismica = 1;
   
    END;
    ELSE IF @ActividadPetrolera = 13
    BEGIN
        SELECT @CorteDeNucleos = 1;
    END;
    ELSE IF @ActividadPetrolera = 14
    BEGIN
        SELECT @ConstruccionLineasDescargas = 1;
    END;
    ELSE IF @ActividadPetrolera = 15
    BEGIN
  
      SELECT @SistemasArtificialesProduccion = 1;
    END;
    ELSE IF @ActividadPetrolera = 16
    BEGIN
        SELECT @MedicionPozos = 1;
    END;
    ELSE IF @ActividadPetrolera = 17
    BEGIN
        SELECT @TomadeInformacionPozos = 1;
    END;
    ELSE IF @ActividadPetrolera = 18
    BEGIN
        SELECT @ReparacionMayor = 1;
    END;
    ELSE IF @ActividadPetrolera = 19
    BEGIN
        SELECT @ReparacionMenor = 1;
    END;
    ELSE IF @ActividadPetrolera = 20
    BEGIN
        SELECT @TransporteHidrocarburos = 1;
    END;
    ELSE IF @ActividadPetrolera = 21
    BEGIN
        SELECT @AdministracionContratos = 1;
    END;
    ELSE IF @ActividadPetrolera = 22
    BEGIN
        SELECT @QuemaDeGas = 1;
    END;
    --    ELSE
    --IF @ActividadPetrolera = 23
    --    BEGIN
    --        SELECT @PozoDeAlivio = -1;
    --        SELECT @Abandono = 1;
    --        SELECT @Perforacion = 1;
    --        SELECT @Terminacion = 1;
    --        SELECT @ActividadesDeProduccion = 1;
    --        SELECT @Estimulacion = 1;
    --        SELECT @PruebaDeProduccion = 1;
    --        SELECT @ConstruccionDeCamino = 1;
    --        SELECT @ConstruccionDeLocalizacion = 1;
    --        SELECT @ReabilitacionDeCamino = 1;
    --        SELECT @ReabilitacionDeLocalizacion = 1;
    --        SELECT @TomadeInformacionSismica = 1;
    --        SELECT @CorteDeNucleos = 1;
    --        SELECT @ConstruccionLineasDescargas = 1;
    --        SELECT @SistemasArtificialesProduccion = 1;
    --        SELECT @MedicionPozos = 1;
    --        SELECT @TomadeInformacionPozos = 1;
    --        SELECT @ReparacionMayor = 1;
    --        SELECT @ReparacionMenor = 1;
    --        SELECT @TransporteHidrocarburos = 1;
    --        SELECT @AdministracionContratos = 1;
    --    
    SELECT @QuemaDeGas = 1;
    --END;
    --sp_EN_ConsultaInventarioEntregables 10005, 1,3,1

 SELECT
	ER.idRonda,
	0 as IdContratoEntregable,--CE.IdContratoEntregable,
	EN.IdEntregable,
	EN.Consecutivo,
	R.Regulador,
	ML.MarcoLegal AS MarcoLegal,
	SUBST
RING(EN.Articulo,0,200) AS Articulo,
	EN.DocumentoEntregable AS DocumentoEntregable,
	ET.Etapa,
	RE.ReceptorEntregable,
	RG.ResponsableGenerador,
	FE.FrecuenciaEntregable,
	--SUBSTRING(TE.TiempoEntrega,0,120) AS TiempoEntrega,
	SUBSTRING(EN.TiempoEntrega, 0, 120) AS TiempoEntrega,
	TR.TiempoRespuesta,
	CASE
			WHEN EN.REReguladores = 1 THEN 'Regulador'
			ELSE 'Operador' E
ND AS ReguladorOperador,
	REReguladores,
	EN.REOperadores,
	EN.APAdministracionContratos,
	EN.APPozoAlivio,
	EN.APCierreDesmantelamientoAbandono,
	EN.APPerforacion,
	EN.APTerminacion,
	EN.APActProduccion,
	EN.APEstimulacion,
	EN.APPruebaProduccion,
	EN.AP
ConstruccionCamino,
	EN.APConstruccionLocalizacion,
	EN.APRehabilitacionCamino,
	EN.APRehabilitacionLocalizacion,
	EN.APTomaInformacionSismica,
	EN.APCorteNucleos,
	EN.APConstruccionLineaDescarga,
	EN.APSistemaArtificialProduccion,
	EN.APMedicionPozos,
	E
N.APTomaInformacionPozo,
	EN.APReparacionMayor,
	EN.APReparacionMenor,
	EN.APTransporteHidrocarburos,
	EN.APQuemaGas,
	EN.TituloAnexo AS TituloAnexo,
	EN.Capitulo AS Capitulo
      FROM      EN_Entregable AS EN
      LEFT JOIN EN_MarcoLegal AS ML
       O
N ML.IdMarcoLegal           = EN.IdMarcoLegal
      LEFT JOIN CO_Regulador AS R
        ON R.IdRegulador             = EN.IdRegulador
      LEFT JOIN EN_ReceptorEntregable AS RE
        ON RE.IdReceptorEntregable   = EN.IdReceptorEntregable
LEFT JOIN EN_R
esponsableGenerador AS RG
        ON RG.IdResponsableGenerador = EN.IdResponsableGenerador
     LEFT JOIN EN_FrecuenciaEntregable AS FE
        ON FE.IdFrecuenciaEntregable = EN.IdFrecuenciaEntregable
      --left JOIN EN_TiempoEntrega AS TE ON TE.IdTiemp
oEntrega = EN.IdTiempoEntrega
      LEFT JOIN EN_TiempoRespuesta AS TR
        ON EN.IdTiempoRespuesta      = TR.IdTiempoRespuesta
      LEFT JOIN EN_Etapa AS ET
        ON ET.IdEtapa                = EN.IdEtapa
      JOIN      CO_Contrato C
        ON C.IdContrato              = @IdContrato
      --JOIN      dbo.EN_ContratoEntregable CE
     --   ON CE.IdContrato             = @IdContrato
    --   AND CE.IdEntregable           = EN.IdEntregable
      JOIN      EN_EntregableRonda ER
		ON ER.i
dRonda                = C.IdRonda
       AND ER.idEntregable           = EN.IdEntregable
     WHERE  --    (EN.UGTerrestre                    = 1)
         (EN.UGCostaFuera =1) --@UGCostaFuera)
       AND      (EN.IsActivo       = 1)
       AND      (EN.T
CLicencia                          = 1)
       AND      ISNULL(EN.IsEliminado, 0)               = 0
       AND      (   EN.REReguladores                    = @REReguladores
               OR   @REReguladores						= -1)
       AND      (   EN.REOperadores 
	                = @REOperadores
               OR   @REOperadores                       = -1)
       AND      (   EN.APAdministracionContratos        = @AdministracionContratos
               OR   @AdministracionContratos            = -1)
       AND 

     (   EN.APPozoAlivio                     = @PozoDeAlivio
               OR   @PozoDeAlivio                       = -1)
       AND      (   EN.APCierreDesmantelamientoAbandono = @Abandono
               OR   @Abandono                           = -1)
  


     AND      (   EN.APPerforacion                    = @Perforacion
               OR   @Perforacion                        = -1)
       AND      (   EN.APTerminacion                    = @Terminacion
			     OR   @Terminacion                        = -1
)
       AND      (   EN.APActProduccion                  = @ActividadesDeProduccion
               OR   @ActividadesDeProduccion            = -1)
       AND      (   EN.APEstimulacion                   = @Estimulacion
               OR   @Estimulacion   
                    = -1)
       AND      (   EN.APPruebaProduccion               = @PruebaDeProduccion
               OR   @PruebaDeProduccion                 = -1)
       AND      (   EN.APConstruccionCamino             = @ConstruccionDeCamino
         

      OR   @ConstruccionDeCamino               = -1)
       AND      (   EN.APConstruccionLocalizacion       = @ConstruccionDeLocalizacion
               OR   @ConstruccionDeLocalizacion         = -1)
    
   AND      (   EN.APRehabilitacionCamino           = @ReabilitacionDeCamino
               OR   @ReabilitacionDeCamino           = -1)
       AND      (   EN.APRehabilitacionLocalizacion     = @ReabilitacionDeLocalizacion
               OR   @Reabilitaci
onDeLocalizacion        = -1)
       AND      (   EN.APTomaInformacionSismica         = @TomadeInformacionSismica
               OR   @TomadeInformacionSismica           = -1)
       AND      (   EN.APCorteNucleos                   = @CorteDeNucleos
  
             OR   @CorteDeNucleos                     = -1)
       AND      (   EN.APConstruccionLineaDescarga      = @ConstruccionLineasDescargas
               OR   @ConstruccionLineasDescargas        = -1)
       AND      (   EN.APSistemaArtificialProd
uccion    = @SistemasArtificialesProduccion
               OR   @SistemasArtificialesProduccion     = -1)
       AND      (   EN.APMedicionPozos                  = @MedicionPozos
               OR   @MedicionPozos                      = -1)
       AND    

  (   EN.APTomaInformacionPozo            = @TomadeInformacionPozos
               OR   @TomadeInformacionPozos             = -1)
       AND      (   EN.APReparacionMayor                = @ReparacionMayor
               OR   @ReparacionMayor			      = -1)



       AND      (   EN.APReparacionMenor                = @ReparacionMenor
               OR   @ReparacionMenor                    = -1)
       AND      (   EN.APTransporteHidrocarburos        = @TransporteHidrocarburos
               OR   @TransporteHid
rocarburos            = -1)
       AND      (   EN.APQuemaGas                       = @QuemaDeGas
               OR   @QuemaDeGas                         = -1);
*/
END;