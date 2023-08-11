USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_EN_ActualizarEntregable'
)
    DROP PROCEDURE p_EN_ActualizarEntregable;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--======================================================
-- Author:		Alexander Gomez
-- Create date: 10/08/2023
-- Description:	se agrega la validacion y generacion de fechas en caso de no ser dia abil se recorre hasta el proximo https://github.com/Adinco/adinco-entregables/issues/1136
-- =============================================
CREATE PROCEDURE [dbo].[p_EN_ActualizarEntregable]
@pIdEntregable	int ,
@pDocumentoEntregable	nvarchar(max),
@pDocumentoEntregableIngles	nvarchar(max) = null,
@pIdMarcoLegal	int,
@pTituloAnexo	nvarchar(max),
@pCapitulo	nvarchar(max),
@pDescripcion	nvarchar(max),
@pSeccion	nvarchar(max),
@pArticulo	nvarchar(max),
@pInciso	nvarchar(max),
@pApartado	nvarchar(max),
@pObservaciones	nvarchar(max),
@pArchivoNormatividad	nvarchar(max),
@pArchivoEntregable	nvarchar(max),
@pIdRegulador	int,
@pIdEtapa	int,
@pIdReceptorEntregable	int,
@pIdResponsableGenerador	int,
@pIdFrecuenciaEntregable	int,
@pTiempoEntrega	nvarchar(max),
@pIdTiempoRespuesta	int,
@pFechaPublicacion	datetime=NULL,
@pFechaModificacion	datetime=NULL,
@pCreadoPor	int,
@pIsActivo	bit,
@pIsEliminado	bit,
@pConsecutivo	nvarchar(max),
@pTCLicencia	bit,
@pTCProducionCompartida	bit,
@pTCLicenciaFarmOuts	bit,
@pTCProducionCompartidaFarmOuts	bit,
@pUGTerrestre	bit,
@pUGCostaFuera	bit,
@pREReguladores	bit,
@pREOperadores	bit,
@pAPAdministracionContratos	bit,
@pAPPozoAlivio	bit,
@pAPCierreDesmantelamientoAbandono	bit,
@pAPPerforacion	bit,
@pAPTerminacion	bit,
@pAPActProduccion	bit,
@pAPEstimulacion	bit,
@pAPPruebaProduccion	bit,
@pAPConstruccionCamino	bit,
@pAPConstruccionLocalizacion	bit,
@pAPRehabilitacionCamino	bit,
@pAPRehabilitacionLocalizacion	bit,
@pAPTomaInformacionSismica	bit,
@pAPCorteNucleos	bit,
@pAPConstruccionLineaDescarga	bit,
@pAPSistemaArtificialProduccion	bit,
@pAPMedicionPozos	bit,
@pAPTomaInformacionPozo	bit,
@pAPReparacionMayor	bit,
@pAPReparacionMenor	bit,
@pAPTransporteHidrocarburos	bit,
@pAPQuemaGas	bit,
@RequiereRespuesta	bit,
@Formato varchar(500),
@Actividad varchar(500),
@Proceso varchar (500),
@Idclasificacion int,
@pDesarrollo bit,
@pExploracion bit,
@pEvaluacion bit,
@pTransicion bit,
@pAbandonoArea bit,
@pAbandonoPozo bit,
@BitRecorrerDiasAbiles bit
as

			UPDATE [dbo].[EN_Entregable]
           SET
		   [DocumentoEntregable] = @pDocumentoEntregable
		   ,DeliverableName = @pDocumentoEntregableIngles
           ,[IdMarcoLegal] = @pIdMarcoLegal
           ,[TituloAnexo]=  @pTituloAnexo
           ,[Capitulo] = @pCapitulo
           ,[Descripcion] = @pDescripcion
           ,[Seccion] = @pSeccion
           ,[Articulo]=@pArticulo
           ,[Inciso] = @pInciso
           ,[Apartado]=@pApartado
           ,[Observaciones]=@pObservaciones
           ,[ArchivoNormatividad] = @pArchivoNormatividad
           ,[ArchivoEntregable] = @pArchivoEntregable
           ,[IdRegulador] = @pIdRegulador
           ,[IdEtapa] = @pIdEtapa
           ,[IdReceptorEntregable] = @pIdReceptorEntregable
           ,[IdResponsableGenerador] = @pIdResponsableGenerador
           ,[IdFrecuenciaEntregable] = @pIdFrecuenciaEntregable
           ,[TiempoEntrega] = @pTiempoEntrega
           ,[IdTiempoRespuesta] = @pIdTiempoRespuesta
           ,[FechaPublicacion]=@pFechaPublicacion
           ,[FechaModificacion] = @pFechaModificacion          
           ,[ModificadoPor] = @pCreadoPor
           ,[ModificadoEn] = GETDATE()
           ,[IsActivo] = @pIsActivo
           ,[IsEliminado] = [IsEliminado]
           ,[Consecutivo] = @pConsecutivo
           ,[TCLicencia] = @pTCLicencia
           ,[TCProducionCompartida] = @pTCProducionCompartida
           ,[TCLicenciaFarmOuts] = @pTCLicenciaFarmOuts
           ,[TCProducionCompartidaFarmOuts] = @pTCProducionCompartidaFarmOuts
           ,[UGTerrestre] = @pUGTerrestre
           ,[UGCostaFuera] = @pUGCostaFuera
           ,[REReguladores] = @pREReguladores
           ,[REOperadores] = @pREOperadores
           ,[APAdministracionContratos] = @pAPAdministracionContratos
           ,[APPozoAlivio] = @pAPPozoAlivio
           ,[APCierreDesmantelamientoAbandono] = @pAPCierreDesmantelamientoAbandono
           ,[APPerforacion] = @pAPPerforacion
           ,[APTerminacion] = @pAPTerminacion
           ,[APActProduccion]= @pAPActProduccion
           ,[APEstimulacion] = @pAPEstimulacion
           ,[APPruebaProduccion] = @pAPPruebaProduccion
           ,[APConstruccionCamino] = @pAPConstruccionCamino
           ,[APConstruccionLocalizacion] = @pAPConstruccionLocalizacion
           ,[APRehabilitacionCamino] =@pAPRehabilitacionCamino
           ,[APRehabilitacionLocalizacion] = @pAPRehabilitacionLocalizacion
       ,[APTomaInformacionSismica] = @pAPTomaInformacionSismica
           ,[APCorteNucleos] = @pAPCorteNucleos
           ,[APConstruccionLineaDescarga]= @pAPConstruccionLineaDescarga
           ,[APSistemaArtificialProduccion] = @pAPSistemaArtificialProduccion
           ,[APMedicionPozos] = @pAPMedicionPozos
           ,[APTomaInformacionPozo] = @pAPTomaInformacionPozo
           ,[APReparacionMayor] = @pAPReparacionMayor
           ,[APReparacionMenor] = @pAPReparacionMenor
           ,[APTransporteHidrocarburos] = @pAPTransporteHidrocarburos
           ,[APQuemaGas] = @pAPQuemaGas,
		   RequiereRespuesta	=@RequiereRespuesta,
			Formato =@Formato,
			Actividad =@Actividad,
			Proceso =@Proceso,
			Idclasificacion= @Idclasificacion,
			BitRecorrerDiasAbiles = @BitRecorrerDiasAbiles
		   WHERE IDENTREGABLE = @pIdEntregable

		   IF EXISTS (select 1 from EN_Entregable_ConfigAdicional (NOLOCK) where IdEntregable = @pIdEntregable)
		   BEGIN 
			   update EN_Entregable_ConfigAdicional
			   SET
			   Desarrollo = @pDesarrollo,
			   Exploracion = @pExploracion,
			   Evaluacion = @pEvaluacion,
			   Transicion = @pTransicion,
			   AbandonoArea = @pAbandonoArea,
			   AbandonoPozo = @pAbandonoPozo
			   where IdEntregable = @pIdEntregable
		   END
		   ELSE
		   BEGIN
				INSERT INTO EN_Entregable_ConfigAdicional
				(IdEntregable, Desarrollo, Exploracion,Evaluacion,Transicion,AbandonoArea,AbandonoPozo)
				VALUES
				(@pIdEntregable, @pDesarrollo, @pExploracion, @pEvaluacion, @pTransicion,@pAbandonoArea,@pAbandonoPozo)
		   END