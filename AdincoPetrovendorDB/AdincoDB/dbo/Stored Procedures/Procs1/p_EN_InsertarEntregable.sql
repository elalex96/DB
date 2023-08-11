USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_EN_InsertarEntregable'
)
    DROP PROCEDURE p_EN_InsertarEntregable;
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
CREATE PROCEDURE [dbo].[p_EN_InsertarEntregable]
	@pIdEntregable	int out,
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
	@pFechaPublicacion	datetime= NULL,
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
	@pAPQuemaGas	BIT,
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
AS
BEGIN

INSERT INTO [dbo].[EN_Entregable]
           ([DocumentoEntregable]
		   , DeliverableName
           ,[IdMarcoLegal]
           ,[TituloAnexo]
           ,[Capitulo]
           ,[Descripcion]
           ,[Seccion]
           ,[Articulo]
           ,[Inciso]
           ,[Apartado]
           ,[Observaciones]
           ,[ArchivoNormatividad]
           ,[ArchivoEntregable]
           ,[IdRegulador]
           ,[IdEtapa]
           ,[IdReceptorEntregable]
           ,[IdResponsableGenerador]
           ,[IdFrecuenciaEntregable]
           ,[TiempoEntrega]
           ,[IdTiempoRespuesta]
           ,[FechaPublicacion]
           ,[FechaModificacion]
           ,[CreadoPor]
           ,[CreadoEn]
           ,[ModificadoPor]
           ,[ModificadoEn]
           ,[IsActivo]
           ,[IsEliminado]
           ,[Consecutivo]
           ,[TCLicencia]
           ,[TCProducionCompartida]
           ,[TCLicenciaFarmOuts]
           ,[TCProducionCompartidaFarmOuts]
           ,[UGTerrestre]
           ,[UGCostaFuera]
           ,[REReguladores]
           ,[REOperadores]
           ,[APAdministracionContratos]
           ,[APPozoAlivio]
           ,[APCierreDesmantelamientoAbandono]
           ,[APPerforacion]
           ,[APTerminacion]
           ,[APActProduccion]
           ,[APEstimulacion]
           ,[APPruebaProduccion]
           ,[APConstruccionCamino]
           ,[APConstruccionLocalizacion]
           ,[APRehabilitacionCamino]
           ,[APRehabilitacionLocalizacion]
           ,[APTomaInformacionSismica]
           ,[APCorteNucleos]
           ,[APConstruccionLineaDescarga]
           ,[APSistemaArtificialProduccion]
           ,[APMedicionPozos]
           ,[APTomaInformacionPozo]
           ,[APReparacionMayor]
           ,[APReparacionMenor]
           ,[APTransporteHidrocarburos]
           ,[APQuemaGas],[BitInterno],
		   RequiereRespuesta,
		   Formato,
		   Actividad,
		   Proceso,
		   Idclasificacion,
		   BitJOA,
		   BitRecorrerDiasAbiles
		   )
     VALUES
           (
		   @pDocumentoEntregable
		   ,@pDocumentoEntregableIngles
           ,@pIdMarcoLegal 
           ,@pTituloAnexo
           ,@pCapitulo
		   ,@pDescripcion
           ,@pSeccion
           ,@pArticulo
           ,@pInciso
           ,@pApartado
           ,@pObservaciones
           ,@pArchivoNormatividad
           ,@pArchivoEntregable
           ,@pIdRegulador
           ,@pIdEtapa
           ,@pIdReceptorEntregable
           ,@pIdResponsableGenerador
           ,@pIdFrecuenciaEntregable
           ,@pTiempoEntrega
           ,@pIdTiempoRespuesta
           ,@pFechaPublicacion
           ,@pFechaModificacion
           ,@pCreadoPor
           ,getdate()
           ,null
           ,null
           ,1
           ,@pIsEliminado
           ,@pConsecutivo
           ,@pTCLicencia
           ,@pTCProducionCompartida
           ,@pTCLicenciaFarmOuts
           ,@pTCProducionCompartidaFarmOuts
           ,@pUGTerrestre
           ,@pUGCostaFuera
           ,@pREReguladores
           ,@pREOperadores
           ,@pAPAdministracionContratos
           ,@pAPPozoAlivio
           ,@pAPCierreDesmantelamientoAbandono
           ,@pAPPerforacion
           ,@pAPTerminacion
           ,@pAPActProduccion
           ,@pAPEstimulacion
           ,@pAPPruebaProduccion
           ,@pAPConstruccionCamino
           ,@pAPConstruccionLocalizacion
           ,@pAPRehabilitacionCamino
           ,@pAPRehabilitacionLocalizacion
           ,@pAPTomaInformacionSismica
           ,@pAPCorteNucleos
           ,@pAPConstruccionLineaDescarga
           ,@pAPSistemaArtificialProduccion
           ,@pAPMedicionPozos
           ,@pAPTomaInformacionPozo
           ,@pAPReparacionMayor
           ,@pAPReparacionMenor
           ,@pAPTransporteHidrocarburos
           ,@pAPQuemaGas,0,@RequiereRespuesta,@Formato,@Actividad,@Proceso,
		   @Idclasificacion, 
		   0,
		   @BitRecorrerDiasAbiles)

		set @pIdEntregable = SCOPE_IDENTITY();
		
		INSERT INTO dbo.EN_ContratoEntregable (IdContrato,
		                                       IdEntregable,
		                                       DiasRevision,
		                                       DiasAprobacion,
		                                       DiasAlerta,
		                                       CreadoPor,
		                                       CreadoEl,
		                                       ModificadoPor,
		                                       ModificadoEl,
		                                       Activo,
		                                       Entrega,
		                                       DiasElaboracion)
	SELECT IdContrato,@pIdEntregable,0,0,0,@pCreadoPor,GETDATE(),@pCreadoPor,GETDATE(),1,0,0 FROM dbo.CO_Contrato (NOLOCK);
	
	INSERT INTO EN_Entregable_ConfigAdicional
				(IdEntregable, Desarrollo, Exploracion,Evaluacion,Transicion,AbandonoArea,AbandonoPozo)
				VALUES
				(@pIdEntregable, @pDesarrollo, @pExploracion, @pEvaluacion, @pTransicion,@pAbandonoArea,@pAbandonoPozo)

	SELECT @pIdEntregable
END