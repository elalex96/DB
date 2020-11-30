CREATE PROCEDURE [dbo].[sp_JOA_InsertarDocumento]
    @pAWSDocumentoId INT OUT,
    @ContratoEntregableId INT,
    @InstanciaEntregable INT,
    @pNombreArchivo VARCHAR(250),
    @pFolder VARCHAR(100),
    @pUUIDAmazon UNIQUEIDENTIFIER,
    @pMeta VARCHAR(50),
    @pBucket VARCHAR(50),
    @pCreadoPor INT,
    @pAWSDocumentoPadreId INT,
    @idTipoArchivo INT
AS
BEGIN
    SET NOCOUNT ON;

DECLARE @idLineaTiempo INT,@idEntregable INT,@FechaInstancia DATE;

	CREATE TABLE #ContratosEntregables
	(
		Id int identity (1,1),	
		IdContratoEntregable	INT,
		IdContrato INT,
		IdEntregable INT
	);
	CREATE TABLE #Instancias
	(
		Id int identity (1,1),
		IdContratoEntregable	INT,
		IdInstanciaEntregable	INT
	);
	
	SELECT @FechaInstancia	=	FechaCalculadaEntregaReg, 
		   @idEntregable	=	CE.IdEntregable
	FROM 
		EN_InstanciasEntregable IE
	JOIN
		EN_ContratoEntregable	CE
		ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
	WHERE 
		idInstanciaEntregable	=	@InstanciaEntregable;


	INSERT INTO #ContratosEntregables(IdContratoEntregable,IdContrato,IdEntregable )
	SELECT IdContratoEntregable,IdContrato,IdEntregable
	FROM 
		EN_ContratoEntregable C
	WHERE 
	IdEntregable	=	@idEntregable
	

	INSERT INTO #Instancias(IdContratoEntregable,IdInstanciaEntregable)
	SELECT 
		CE.IdContratoEntregable,IE.idInstanciaEntregable
	FROM 
		EN_InstanciasEntregable	IE
	JOIN
		#ContratosEntregables CE
		ON IE.IdContratoEntregable	=	CE.IdContratoEntregable
		AND	IE.FechaCalculadaEntregaReg	=	@FechaInstancia	


	SELECT 
		@pAWSDocumentoId = ISNULL(MAX(DocumentoEntregableId), 0)
	FROM 
		EN_EntregableDocumento;


	INSERT INTO EN_EntregableDocumento (DocumentoEntregableId,
										idContratoEntregable,
										idInstanciaEntregable,
										NombreArchivo,
										UUIDAmazon,
										Meta,
										Bucket,
										CreadoPor,
										CreadoEl,
										Folder,
										Activo,
										idTipoArchivo)
	SELECT (@pAWSDocumentoId + I.Id),
		   IdContratoEntregable,
		   IdInstanciaEntregable,
		   @pNombreArchivo,
		   @pUUIDAmazon,
		   @pMeta,
		   @pBucket,
		   @pCreadoPor,
		   GETDATE(),
		   @pFolder,
		   1,
		   @idTipoArchivo
	FROM
		#Instancias	I

END;



