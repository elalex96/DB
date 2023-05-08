
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <30-07-2018>
-- Description:	<Se consulta los datos por modulo de la evaluación interna
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <03-01-2018>
-- Description:	<Se modifico la consulta directa a la tabla de documentos
-- =============================================

CREATE PROCEDURE [dbo].[ME_EI_ConsultaDatosPorModulo] --1,9,44
	@TipoRegimen INT,
	@IdModulo INT,
	@IdProveedor INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	DECLARE @NombreModulo VARCHAR(200), 
			@CantidadConceptos INT,
			@CantidadConceptosCompletados INT,
			@SoloMoral BIT

	IF(@TipoRegimen = 2)
	BEGIN
		SET @SoloMoral = 0
	END
    ELSE
    BEGIN
		SET @SoloMoral = 1
	END

	SET @NombreModulo = (SELECT Modulo FROM dbo.EI_Modulo WHERE IdModulo = @IdModulo)


	SET @CantidadConceptos = (SELECT COUNT(cd.IdConceptoDetalle) FROM dbo.EI_Modulo m
										INNER JOIN dbo.EI_Conceptos c ON c.IdModulo = m.IdModulo
										INNER JOIN dbo.EI_ConceptosDetalle cd ON cd.IdConcepto = c.IdConcepto
										WHERE m.IdModulo = @IdModulo
											AND (cd.SoloMoral = @SoloMoral OR @SoloMoral = 1));

	SET @CantidadConceptosCompletados = (SELECT COUNT(cc.IdConceptoCompletado) FROM dbo.EI_Modulo m
											INNER JOIN dbo.EI_Conceptos c ON c.IdModulo = m.IdModulo
											INNER JOIN dbo.EI_ConceptosDetalle cd ON cd.IdConcepto = c.IdConcepto
											INNER JOIN dbo.EI_ConceptosCompletados cc ON cc.IdConceptoDetalle = cd.IdConceptoDetalle AND cc.IdProveedor = @IdProveedor
											WHERE m.IdModulo = @IdModulo
												AND (cd.SoloMoral = @SoloMoral OR @SoloMoral = 1)
												AND cc.Completado > 0)

	IF(@IdModulo = 9)
	BEGIN
		declare @ContadorTotalDocumentos int; 
	declare @Incremento int; 
	DECLARE @IdDocumentoTemp int;


	create table #TbTempDocumentos
	(
	IdRow int, 
	IdDocumento int,
	IdTipoDocumento int,
	NombreTipoDocumento varchar(50),
	TipoValidacionDocumento varchar(50) null,
	Fecha datetime NULL
	)

--drop table #TbTempDocumentos
	INSERT INTO #TbTempDocumentos  
	 SELECT  
	 ROW_NUMBER() OVER(ORDER BY TPersona.[IdTipoDocumento]  ASC) AS Row#,
	 0,
	 TPersona.[IdTipoDocumento],
	 TPersona.[NombreTipoDocumento],
	 'Sin Documento',
	 getdate()
	 FROM [dbo].[S_TipoDocumento] AS TPersona
	 INNER JOIN [dbo].[S_TipoDocumentoTipoPersona] AS TDocumentoPersona ON TDocumentoPersona.[IdTipoDocumento] = TPersona.[IdTipoDocumento]
	 WHERE TDocumentoPersona.[IdTipoRegimen] = @TipoRegimen
	 ORDER BY TPersona.[IdTipoDocumento]



	SET @ContadorTotalDocumentos = (SELECT COUNT(IdRow) FROM #TbTempDocumentos )

	SET @Incremento = 1

	WHILE @Incremento <= @ContadorTotalDocumentos
	BEGIN 

		SET @IdDocumentoTemp = (SELECT IdTipoDocumento
						FROM #TbTempDocumentos
						WHERE IdRow = @Incremento)


		DECLARE @ContadorDocumentosExistentes INT 

		SET @ContadorDocumentosExistentes =(
		 SELECT COUNT([IdDocumento]) AS ContadorDocumentosExistentes
		 FROM [dbo].[S_Documento_S3]
		 WHERE [IdTipoDocumento] = @IdDocumentoTemp
		 ---AND IdUsuario = @IdUsuario
		 AND IdProveedor = @IdProveedor AND Activo = 1)

 --- Validar 
	IF @ContadorDocumentosExistentes  > 0 
		BEGIN 

		-- Existe Documennto 
		--- Actualizar Estatatus

		DECLARE @ESTATUS NVARCHAR(50) = ((
				 SELECT TOP 1 TVD.[TipoValidacion] AS ContadorDocumentosExistentes
				 FROM [dbo].[S_Documento_S3] AS D
				 INNER JOIN [dbo].[S_TipoValidacionDoc] AS TVD ON  TVD.[IdTipoValidacionDoc]= D.[IdTipoValidacionDocumento]
				 WHERE [IdTipoDocumento] = @IdDocumentoTemp
				 AND IdProveedor = @IdProveedor AND Activo = 1))
		
		DECLARE @IDDOCUMENTO INT =
				 (SELECT (SELECT TOP 1 D.[IdDocumento] AS  IdDocumento
				 FROM [dbo].[S_Documento_S3] AS D
				 WHERE [IdTipoDocumento] =@IdDocumentoTemp
				 AND IdProveedor = @IdProveedor AND Activo = 1) AS VALOR)

		DECLARE @FECHA datetime = 
				(SELECT (SELECT TOP 1 D.[CreadoEl] AS fecha
				 FROM [dbo].[S_Documento_S3] AS D
				 WHERE [IdTipoDocumento] =@IdDocumentoTemp
				 AND IdProveedor = @IdProveedor AND Activo = 1) AS VALOR)


		--- ACTUALIZAR TABLA TEMPORAL 

			UPDATE #TbTempDocumentos
			SET  TipoValidacionDocumento = @ESTATUS,
			IdDocumento = ISNULL(@IDDOCUMENTO,0),
			Fecha = @FECHA
			WHERE IdRow = @Incremento

		END 

		SET @Incremento = @Incremento + 1

	 END;

		SET @CantidadConceptosCompletados = (SELECT COUNT(IdDocumento) FROM #TbTempDocumentos
												WHERE NombreTipoDocumento != 'Comprobante de domicilio (Sucursal)'
												AND TipoValidacionDocumento = 'Documento Cargado');

		SET @CantidadConceptos = (SELECT COUNT(IdDocumento) FROM #TbTempDocumentos
												WHERE NombreTipoDocumento != 'Comprobante de domicilio (Sucursal)');
	END;

	

	SELECT @NombreModulo,
			@CantidadConceptos,
			@CantidadConceptosCompletados
END