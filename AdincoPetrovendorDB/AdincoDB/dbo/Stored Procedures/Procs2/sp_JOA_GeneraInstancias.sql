CREATE PROCEDURE [dbo].[sp_JOA_GeneraInstancias]
    @idUsuario INT,
	@idContrato INT,
	@idSocio INT,
	@idEntregable INT,
	@FechaLimiteRegulador DATE,
	@IdUsuarioElaborador INT,
	@IdFrecuenciaEntregable INT

AS
BEGIN
    SET NOCOUNT ON;    
	

	CREATE TABLE #FechasEntregaRegulador
    (
        Id INT IDENTITY(1, 1),
        IdFecha DATE
    );

    CREATE TABLE #ContratosEntregables
	(
		Id int identity (1,1),	
		IdContratoEntregable	INT,
		IdContrato INT,
		IdEntregable INT
	);

	CREATE TABLE #InstanciasEntregable
    (
        IdInstanciaEntregable INT,
        FechasLimiteAprobacion DATE,
        Estatus INT,
		IdContratoEntregable	INT
    );

	DECLARE @IdContratoEntregable INT = 0;

	
    CREATE TABLE #TEMP_InstanciasEntregable
    (
        Id INT IDENTITY (1,1),
        FechasLimiteElaboracion DATETIME,
        FechasLimiteRevision DATETIME,
        FechasLimiteAprobacion DATETIME,
        FechaEnvioMensajeAtrasoRevision DATETIME,
        FechasLimiteEntregaReg DATETIME,
        FechaInicioElaboracion DATETIME,
		IdContratoEntregable	INT
    );


	INSERT INTO #ContratosEntregables(IdContratoEntregable,IdContrato,IdEntregable )
	SELECT IdContratoEntregable,IdContrato,IdEntregable 
	FROM 
		EN_ContratoEntregable C
	WHERE 
	IdEntregable	=	@idEntregable


	SELECT TOP 1 @IdContratoEntregable = IdContratoEntregable
	FROM
		#ContratosEntregables

	INSERT INTO #FechasEntregaRegulador
					(
						IdFecha
					)
	EXEC [SP_EN_GeneraInstanciasFechasLimite] --'20190319',3, 10008
		@FechaLimiteRegulador,
		@idContrato,
		@IdFrecuenciaEntregable,
		@IdContratoEntregable,
		0,1;

	INSERT INTO	#TEMP_InstanciasEntregable
    (
        FechasLimiteElaboracion ,
        FechasLimiteRevision ,
        FechasLimiteAprobacion ,
        FechaEnvioMensajeAtrasoRevision ,
        FechasLimiteEntregaReg ,
        FechaInicioElaboracion ,
		IdContratoEntregable	
    )
	SELECT IdFecha,IdFecha,IdFecha,IdFecha,IdFecha,IdFecha,IdContratoEntregable
	FROM
		#ContratosEntregables CE
	CROSS JOIN
		#FechasEntregaRegulador F
	ORDER BY 
		CE.IdContratoEntregable;


	INSERT INTO #InstanciasEntregable
					(
						IdInstanciaEntregable,
						FechasLimiteAprobacion,
						Estatus,
						IdContratoEntregable
					)
    SELECT  IE.idInstanciaEntregable,
			IE.FechasLimiteAprobacion,
			ISNULL(A.EstadoID, 10000),
			IE.IdContratoEntregable
	FROM
		#ContratosEntregables CE
	JOIN 
		dbo.EN_InstanciasEntregable IE
		ON CE.IdContratoEntregable	=	IE.IdContratoEntregable
	LEFT JOIN 
		dbo.EN_Actividad A
		ON A.ActividadID = IE.ActividadID
		AND A.IdContratoEntregable = IE.IdContratoEntregable
	LEFT JOIN 
		EN_EntregableDocumento ED
		ON ED.idInstanciaEntregable = IE.idInstanciaEntregable
	GROUP BY 
		IE.idInstanciaEntregable,
		IE.FechasLimiteAprobacion,
		ISNULL(A.EstadoID, 10000),
		IE.IdContratoEntregable;

	
	DELETE F
	FROM 
		#TEMP_InstanciasEntregable F
	JOIN
		#InstanciasEntregable IE
		ON MONTH(F.FechasLimiteEntregaReg) = MONTH(IE.FechasLimiteAprobacion)
		AND YEAR(F.FechasLimiteEntregaReg) = YEAR(IE.FechasLimiteAprobacion)
		AND	F.IdContratoEntregable	=	IE.IdContratoEntregable
	WHERE Estatus <> 10000
		
	
	DELETE FROM
		dbo.EN_InstanciasEntregable
	WHERE 
		idInstanciaEntregable IN
			(
				SELECT IdInstanciaEntregable
				FROM #InstanciasEntregable
				WHERE Estatus = 10000
			)

	INSERT INTO EN_InstanciasEntregable
				(
                    FechasLimiteElaboracion,
                    FechasLimiteRevision,
                    FechasLimiteAprobacion,
                    FechaEnvioMensajeAtrasoRevision,
                    idFrecuencua,
                    IdContratoEntregable,
                    CorreoEnviado,
                    ActividadID,
                    CreadoPor,
                    CreadoEn,
                    ModificadoPor,
                    ModificadoEn,
                    Activo,
                    FechaCalculadaEntregaReg,
                    FechaInicioElaboracion
                )
		   	 
				SELECT   FechasLimiteElaboracion,
						FechasLimiteRevision,
						FechasLimiteAprobacion,
						FechaEnvioMensajeAtrasoRevision,
						@IdFrecuenciaEntregable,
						IE.IdContratoEntregable,
						0,
						A.ActividadID,
						@idUsuario,
						GETDATE(),
						@idUsuario,
						GETDATE(),
						1,
						FechasLimiteEntregaReg,
						FechaInicioElaboracion
				FROM #TEMP_InstanciasEntregable IE
				JOIN 
					EN_Actividad	A
					ON	IE.IdContratoEntregable	=	A.IdContratoEntregable
					AND A.EstadoID	=	10000
				ORDER BY ID;
				
			
END;
