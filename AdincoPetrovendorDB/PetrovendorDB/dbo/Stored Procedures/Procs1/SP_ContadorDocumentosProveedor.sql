-- =============================================
-- Author:		Alexander G
-- Create date: 21/06/2017
-- Description:	Consulta la relación de Documento Proveedor mediante tipo de persona fiscal y cuenta los documentos cargados y faltantes
-- UPDATE DANIEL AC CAMBIO DE REFENCIA S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
-- Author:		Alexander G
-- Create date: 03/06/2020
-- Description:	se descartan los documentos destiandos para renaissance
-- =============================================

CREATE PROCEDURE [dbo].[SP_ContadorDocumentosProveedor] --3,670
	@IdTipoRegimen INT, @IdProveedor INT
--@IdUsuario int
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON

		DECLARE @ContadorTotalDocumentos INT
		DECLARE @Incremento INT
		DECLARE @IdDocumentoTemp INT

		CREATE TABLE #TbTempDocumentos
			( IdRow INT ,
			  IdDocumento INT ,
			  IdTipoDocumento INT ,
			  NombreTipoDocumento VARCHAR (MAX) ,
			  TipoValidacionDocumento VARCHAR (MAX) NULL );

		--drop table #TbTempDocumentos
		INSERT INTO #TbTempDocumentos
		SELECT	ROW_NUMBER () OVER ( ORDER BY TPersona.[IdTipoDocumento] ASC ) AS Row#, 0, TPersona.[IdTipoDocumento] ,
				TPersona.[NombreTipoDocumento], 'Sin Documento'
		  FROM	[dbo].[S_TipoDocumento] AS TPersona
				INNER JOIN [dbo].[S_TipoDocumentoTipoPersona] AS TDocumentoPersona
						   ON TDocumentoPersona.[IdTipoDocumento] = TPersona.[IdTipoDocumento]
		 WHERE	TDocumentoPersona.[IdTipoRegimen] = @IdTipoRegimen
			AND TDocumentoPersona.IdTipoDocumento NOT IN (48,49,50,51,52)--DESCARTAR LOS DOCUMENTOS OBLIGATORIOS PARA RENAISSANCE
		 ORDER BY TPersona.[IdTipoDocumento]

		SET @ContadorTotalDocumentos = ( SELECT COUNT ( IdRow ) FROM #TbTempDocumentos ) ;
		SET @Incremento = 1 ;

		WHILE @Incremento <= @ContadorTotalDocumentos
			BEGIN
				SET @IdDocumentoTemp = ( SELECT IdTipoDocumento FROM #TbTempDocumentos WHERE IdRow = @Incremento ) ;

				DECLARE @ContadorDocumentosExistentes INT

				SET @ContadorDocumentosExistentes = (	SELECT	COUNT ( 1 ) AS ContadorDocumentosExistentes
														  FROM	[dbo].[S_Documento_S3]
														 WHERE
																[IdTipoDocumento] = @IdDocumentoTemp
																AND IdProveedor = @IdProveedor
																AND Activo = 1 )

				--- Validar 
				IF @ContadorDocumentosExistentes > 0
					BEGIN

						-- Existe Documennto 
						--- Actualizar Estatatus
						DECLARE @ESTATUS NVARCHAR (50)
							= ((   SELECT	TVD.[TipoValidacion] AS ContadorDocumentosExistentes
									 FROM	[dbo].[S_Documento_S3] AS D
											INNER JOIN [dbo].[S_TipoValidacionDoc] AS TVD
													   ON TVD.[IdTipoValidacionDoc] = D.[IdTipoValidacionDocumento]
									WHERE
											[IdTipoDocumento] = @IdDocumentoTemp
											AND IdProveedor = @IdProveedor
											AND Activo = 1
									GROUP BY TVD.TipoValidacion ))
						DECLARE @IDDOCUMENTO INT = ( SELECT (	SELECT	TOP 1
																		D.[IdDocumento] AS IdDocumento
																  FROM	[dbo].[S_Documento_S3] AS D
																 WHERE
																		[IdTipoDocumento] = 13
																		AND IdProveedor = @IdProveedor
																		AND Activo = 1 ) AS VALOR ) ;

						--- ACTUALIZAR TABLA TEMPORAL 
						UPDATE	#TbTempDocumentos
						   SET	TipoValidacionDocumento = @ESTATUS, IdDocumento = ISNULL ( @IDDOCUMENTO, 0 )
						 WHERE	IdRow = @Incremento
					END

				SET @Incremento = @Incremento + 1
			END

		DECLARE @NOCARGADOS INT = (	  SELECT	COUNT ( CASE TbTemp.TipoValidacionDocumento
															WHEN 'Sin Documento' THEN
																1
															ELSE
																NULL
														END )
										FROM	#TbTempDocumentos AS TbTemp )
		DECLARE @CARGADOS INT = (( SELECT COUNT	  ( 1 ) FROM #TbTempDocumentos ) - @NOCARGADOS )

		SELECT @CARGADOS  AS CARGADOS, @NOCARGADOS AS NOCARGADOS
	END