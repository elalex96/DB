CREATE PROCEDURE [dbo].[sp_JOA_AgregaUsuarioElaborador]
    @idUsuario INT,
	@idContrato INT,
	@idSocio INT,
	@idEntregable INT,
	@IdUsuarioElaborador INT

AS
BEGIN
    SET NOCOUNT ON;

	CREATE TABLE #ContratosEntregables
	(
		IdContratoEntregable	INT,
		IdContrato INT,
		IdEntregable INT
	);
	
    CREATE TABLE #InstanciasEstatus
    (
        idInstancia INT,
        EstadoID INT
    );

	INSERT INTO #ContratosEntregables(IdContratoEntregable,IdContrato,IdEntregable)
	SELECT IdContratoEntregable,IdContrato,IdEntregable 
	FROM 
		EN_ContratoEntregable C
	WHERE 
	IdEntregable	=	@idEntregable

	INSERT INTO #InstanciasEstatus (idInstancia, EstadoID)
	SELECT ie.idInstanciaEntregable,
			a.EstadoID
	FROM 
		dbo.EN_InstanciasEntregable ie
	JOIN
		#ContratosEntregables	C
		ON IE.IdContratoEntregable	=	C.IdContratoEntregable
	JOIN 
		dbo.EN_Actividad A 
		ON A.ActividadID = IE.ActividadID
		AND A.IdContratoEntregable = IE.IdContratoEntregable
		AND EstadoID NOT IN ( 10001,10002)
	
	UPDATE	A
	SET
		a.Activo	=	0
	FROM 
		EN_Actividad	A
	JOIN 
		#ContratosEntregables	C
		ON A.IdContratoEntregable	=	C.IdContratoEntregable
	JOIN
		EN_ContratoEntregable	CE
		ON C.IdContratoEntregable	=	CE.IdContratoEntregable


	INSERT INTO EN_Actividad (EstadoID, idUsuario, IdContratoEntregable,CreadoPor,CreadoEn,Activo)
	SELECT  EstadoID,
			@IdUsuarioElaborador,
			IdContratoEntregable,
			CreadoPor,
			CreadoEn,
			1
	FROM 
		EN_Estado E
	JOIN
		#ContratosEntregables CE
		ON E.EstadoID	<=	10003
	ORDER BY CE.IdContratoEntregable, EstadoID


	UPDATE IE
    SET 
		IE.ActividadID = A.ActividadID
    FROM 
		dbo.EN_Actividad A
    JOIN 
		#InstanciasEstatus IET 
		ON A.EstadoID = IET.EstadoID
        AND A.Activo = 1
    JOIN 
		dbo.EN_InstanciasEntregable IE 
		ON IET.idInstancia = IE.idInstanciaEntregable
        AND IE.IdContratoEntregable = A.IdContratoEntregable
    WHERE 
		IE.idInstanciaEntregable IN
          (
              SELECT idInstancia FROM #InstanciasEstatus
          );


    DELETE FROM dbo.EN_ExcepcionesActividad
    WHERE IdInstanciasEntregables IN
          (
              SELECT idInstancia FROM #InstanciasEstatus
          );


    DELETE dbo.EN_Transicion
    WHERE SiguienteActividadID IN
          (
              SELECT ActividadID
              	FROM 
					EN_Actividad	A
				JOIN 
					#ContratosEntregables	C
					ON A.IdContratoEntregable	=	C.IdContratoEntregable
				JOIN
					EN_ContratoEntregable	CE
					ON C.IdContratoEntregable	=	CE.IdContratoEntregable
					AND	A.Activo	=	0
          )
          OR ActividadInicialID IN
             (
              SELECT ActividadID
              	FROM 
					EN_Actividad	A
				JOIN 
					#ContratosEntregables	C
					ON A.IdContratoEntregable	=	C.IdContratoEntregable
				JOIN
					EN_ContratoEntregable	CE
					ON C.IdContratoEntregable	=	CE.IdContratoEntregable
					AND	A.Activo	=	0
             );

    DELETE FROM dbo.EN_URLResponsablesEntregables
    WHERE ActividadID IN
          (
              SELECT ActividadID
              	FROM 
					EN_Actividad	A
				JOIN 
					#ContratosEntregables	C
					ON A.IdContratoEntregable	=	C.IdContratoEntregable
				JOIN
					EN_ContratoEntregable	CE
					ON C.IdContratoEntregable	=	CE.IdContratoEntregable
					AND	A.Activo	=	0
          );


    DELETE  A
    FROM 
		EN_Actividad	A
	JOIN 
		#ContratosEntregables	C
		ON A.IdContratoEntregable	=	C.IdContratoEntregable
	JOIN
		EN_ContratoEntregable	CE
		ON C.IdContratoEntregable	=	CE.IdContratoEntregable
		AND	A.Activo	=	0
END

