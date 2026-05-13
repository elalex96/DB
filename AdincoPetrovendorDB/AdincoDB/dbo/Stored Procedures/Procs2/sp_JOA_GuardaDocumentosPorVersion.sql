CREATE PROCEDURE [dbo].[sp_JOA_GuardaDocumentosPorVersion]
    @InstanciaEntregable INT,
    @idUsuario INT,
    @idContrato INT,
	@idEntregable INT 
AS
BEGIN
    SET NOCOUNT ON;

	
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
	CREATE TABLE #InstanciasVersion
	(
		Id int identity (1,1),
		IdInstanciaEntregable	INT,
		Version INT
	);

	DECLARE @FechaInstancia DATE;

	SELECT @FechaInstancia	=	FechaCalculadaEntregaReg
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

	INSERT INTO #InstanciasVersion(IdInstanciaEntregable,Version)
	SELECT HLT.idInstanciaEntregable,MAX(IdLineaTiempo)
	FROM
		EN_HistorialAprobacionesLineaTiempo	HLT
	JOIN
		#Instancias	I
		ON HLT.idInstanciaEntregable	=	I.IdInstanciaEntregable
	GROUP BY HLT.idInstanciaEntregable

    INSERT INTO EN_DocumentoVersion
    (
        DocumentoEntregableId,
        idInstanciaEntregable,
        N_version,
        CreadoPor,
        CreadoEl,
		Activo
    )
    
SELECT 
		DocumentoEntregableId,
        ED.idInstanciaEntregable,
        IV.Version,
        @idUsuario,
        GETDATE(),
		1
FROM 
	EN_EntregableDocumento ED
JOIN
	#Instancias	I
	ON	ED.idInstanciaEntregable	=	I.IdInstanciaEntregable
	AND Activo = 1 
	AND idTipoArchivo	=	10000
JOIN
	#InstanciasVersion IV
	ON	I.IdInstanciaEntregable	=	IV.IdInstanciaEntregable


END;


