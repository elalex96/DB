CREATE PROCEDURE [dbo].[sp_JOA_ConfirmaJOA]
    @idUsuario INT,
	@idContrato INT,
	@idInstanciaEntregable INT,
	@idEntregable INT,
	@URLRepositorio VARCHAR(MAX),
	@ComentarioUsuarioElaborador varchar(MAX)
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
		IdInstanciaEntregable	INT,
		ActividadIDActual	INT,
		ActividadIDSiguiente INT
	);

	DECLARE @FechaInstancia DATETIME,@IdLineaTiempo INT = 0,@ContieneURLRepositorio INT = 0,@ComentarioGeneral VARCHAR(MAX), @Tipo varchar(300),@idContratoEntregable INT = 0;
	
	SELECT @idContratoEntregable = IdContratoEntregable  
	FROM 
		EN_InstanciasEntregable
	WHERE
		idInstanciaEntregable	=	@idInstanciaEntregable


	SELECT @Tipo	=	NombreClasificacion
	FROM
		EN_Entregable	E
	JOIN
		En_Clasificacion C
		ON	E.IdClasificacion	=	C.IdClasificacion
	WHERE
		E.IdEntregable	=	@idEntregable;


	SELECT
		@ComentarioGeneral = 'Obligacion confirmada por el usuario '+U.Nombre+', el día '+ CONVERT(VARCHAR(10),GETDATE(),103) +'. '+
		CASE @ComentarioUsuarioElaborador
			WHEN ''
				THEN ''
			ELSE
			'Comentario: '+@ComentarioUsuarioElaborador
		END
	FROM 
		AP_Usuario	U
		WHERE U.UsuarioID	=	@idUsuario


	IF(@Tipo <> 'Action required')
	BEGIN

		IF (@URLRepositorio = '' OR @URLRepositorio IS NULL)
		BEGIN
			SET @URLRepositorio = 'No se ingreso URL de repositorio';
			SET @ContieneURLRepositorio = 0;
		END;
		ELSE
		BEGIN
			SET @ContieneURLRepositorio = 1;
		END;

		INSERT INTO #ContratosEntregables(IdContratoEntregable,IdContrato,IdEntregable )
		SELECT IdContratoEntregable,IdContrato,IdEntregable
		FROM 
			EN_ContratoEntregable C
		WHERE 
		IdEntregable	=	@idEntregable
	
		SELECT @FechaInstancia	=	FechaCalculadaEntregaReg FROM EN_InstanciasEntregable WHERE idInstanciaEntregable	=	@idInstanciaEntregable;

		INSERT INTO #Instancias
		(
			IdContratoEntregable,
			IdInstanciaEntregable,
			ActividadIDActual,
			ActividadIDSiguiente
		)
		SELECT CE.IdContratoEntregable,IE.idInstanciaEntregable,IE.ActividadID,A.ActividadID
		FROM 
			EN_InstanciasEntregable	IE
		JOIN
			#ContratosEntregables CE
			ON IE.IdContratoEntregable

		=	CE.IdContratoEntregable
			AND	IE.FechaCalculadaEntregaReg	=	@FechaInstancia	
		JOIN
			dbo.EN_Actividad A
			ON	CE.IdContratoEntregable	=	A.IdContratoEntregable
		LEFT JOIN 
			dbo.EN_ExcepcionesActividad exa 
			ON a.ActividadID = exa.ActividadIDExcepcion
			AND IE.idInstanciaEntregable = exa.IdInstanciasEntregables 
		WHERE 
			   a.EstadoID = 10003;--APROBADO COMPLETAMENTE

		UPDATE	IE
		SET
			IE.ActividadID	=	I.ActividadIDSiguiente
		FROM
			EN_InstanciasEntregable	IE
		JOIN 
			#Instancias		I
			ON	IE.idInstanciaEntregable	=	I.IdInstanciaEntregable

		SELECT @IdLineaTiempo = ISNULL(MAX(IdLineaTiempo), 0)
		FROM dbo.EN_HistorialAprobacionesLineaTiempo;
	
		INSERT INTO EN_HistorialAprobacionesLineaTiempo
		(
			IdLineaTiempo,
			idInstanciaEntregable,
			idContrato,
			Comentario,
			Rechazado,
			idTipoOperacion,
			CreadoPor,
			CreadoEn,
			ModificadoPor,
			ModificadoEn,
			Activo,
			ActualizadoByApp,
			URLRepositorio,
			ContieneURLRepositorio
		)
		SELECT (@IdLineaTiempo + I.Id),
				IdInstanciaEntregable,
				CE.IdContrato,
				@ComentarioGeneral,
				0,
				TP.idTipoOperacion,
				@idUsuario,
				GETDATE(),
				@idUsuario,
				GETDATE(),
				1,
				0,
				@URLRepositorio,
				@ContieneURLRepositorio
		FROM
			#Instancias	I
		JOIN
			#ContratosEntregables	CE
			ON I.IdContratoEntregable	=	CE.IdContratoEntregable
		JOIN
			AP_Usuario U
			ON U.UsuarioID	=	@idUsuario
		LEFT	JOIN	
			EN_TipoOperacion	TP
			ON	TP.idTipoOperacion IN (2,3,4)

		EXEC [sp_JOA_GuardaDocumentosPorVersion] @idInstanciaEntregable, @idUsuario ,@idContrato ,@idEntregable;  
	END
	ELSE
	BEGIN -- PRINT('Action required');
	
	Exec [sp_En_SubeHistoricoAprueba] @idUsuario,@idContrato,@idInstanciaEntregable,@idContratoEntregable,@ComentarioGeneral,@URLRepositorio;

	END
END;

