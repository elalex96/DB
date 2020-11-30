
CREATE Proc p_EN_ActualizarEntregable
@pIdEntregable	int ,
@pDocumentoEntregable	nvarchar(max),
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
@pFechaPublicacion	datetime,
@pFechaModificacion	datetime,
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
--@FichaTecnica varchar(500),
@Idclasificacion int
as

			UPDATE [dbo].[EN_Entregable]
           SET
		   [DocumentoEntregable] = @pDocumentoEntregable
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
			--FichaTecnica =@FichaTecnica,
			Idclasificacion= @Idclasificacion
		   WHERE IDENTREGABLE = @pIdEntregable


