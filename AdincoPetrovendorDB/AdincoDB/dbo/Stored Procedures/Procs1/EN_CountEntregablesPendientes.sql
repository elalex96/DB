CREATE PROCEDURE [dbo].[EN_CountEntregablesPendientes]
    @idContrato INT,
    @idUsuario INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20190103
-- Description:	FormaCalendario
-- =============================================
    SET NOCOUNT ON;
    DECLARE @IsAdmin INT;
    CREATE TABLE #TempInstancias
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        FechasLimiteElaboracion DATE,
        idEntregable INT,
        countIntancias INT NULL
    );

    CREATE TABLE #Revision
    (
        id INT IDENTITY(1, 1),
        idEntregable INT,
        idContratoEntregable INT,
        idinstanciaEntregable INT
    );

    CREATE TABLE #Aprobacion
    (
        id INT IDENTITY(1, 1),
        idEntregable INT,
        idContratoEntregable INT,
        idinstanciaEntregable INT,
    );

    CREATE TABLE #TempInstanciasTotalElaborar
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        FechasLimiteElaboracion DATE,
        idEntregable INT,
        countIntancias INT NULL
    );

    CREATE TABLE #TotalRevision
    (
        id INT IDENTITY(1, 1),
        idEntregable INT,
        idContratoEntregable INT,
        idinstanciaEntregable INT
    );

    CREATE TABLE #TotalAprobacion
    (
        id INT IDENTITY(1, 1),
        idEntregable INT,
        idContratoEntregable INT,
        idinstanciaEntregable INT,
    );

	 CREATE TABLE #TotalAprobacionSinAcuse
    (
        id INT IDENTITY(1, 1),
        idEntregable INT,
        idContratoEntregable INT,
        idinstanciaEntregable INT,
    );
		CREATE TABLE #GrupoUsuario
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        IdUsuarioGrupo int
    );

    DECLARE @CountMisEntregElaborar INT = 0,
            @CountTotalEntregElaborar INT = 0,
            @countMisEntregRevision INT = 0,
            @countTotalEntregRevision INT = 0,
            @countMisEntregAprobacion INT = 0,
            @countTotalEntregAprobacion INT = 0,
			@countTotalEntregAprobacionSinAcuse INT = 0;

			
	INSERT INTO	#GrupoUsuario	(IdUsuarioGrupo)
	SELECT	IdGrupo	
	FROM	EN_GruposUsuarios	(NOLOCK)
	WHERE	IdUsuario	=	@idUsuario
		AND IdContrato	=	@IdContrato
		AND	Activo	=	1
	UNION 
	SELECT @idUsuario
    ---------------------------------------------------------------------------------------------------------
    ---Mis entregables pendientes de Elaboración
    INSERT	INTO #TempInstancias	(FechasLimiteElaboracion, idEntregable)
    SELECT	MIN(IE.FechasLimiteElaboracion),CE.IdEntregable
    FROM
		EN_InstanciasEntregable	IE	(NOLOCK)
    JOIN
		EN_ContratoEntregable	CE		(NOLOCK)
		ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
		AND CE.IdContrato	=	@idContrato
		AND	CE.Activo	=	1
        AND	IE.Activo	=	1
    JOIN
		dbo.EN_Actividad	A	(NOLOCK)
		ON	IE.ActividadID	=	A.ActividadID
    JOIN
		dbo.EN_Entregable	Ent		(NOLOCK)
		ON	CE.IdEntregable	=	Ent.IdEntregable
		AND	Ent.IsActivo	=	1
		AND	Ent.BitJOA	=	0
    LEFT	JOIN
		dbo.EN_ExcepcionesActividad EXAR (NOLOCK)
		ON	A.ActividadID	=	EXAR.ActividadIDExcepcion
		AND	IE.idInstanciaEntregable	=	EXAR.IdInstanciasEntregables

    WHERE (
              A.idUsuario IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
              AND	EXAR.IdInstanciasEntregables IS NULL
              AND	A.EstadoID	= 10000
          )
          OR (
                 EXAR.idUsuario	IN	(SELECT	IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
                 AND	EXAR.IdInstanciasEntregables IS NOT NULL
                 AND	EXAR.EstadoID = 10000
             )
    GROUP	BY	CE.IdEntregable;

    ----------------------------------------------------------------------------------------
    --Mis entregables Revisión
    INSERT	INTO	#Revision	(idEntregable, idContratoEntregable, idinstanciaEntregable)
    SELECT	E.IdEntregable	AS	idEntregable,
           CE.IdContratoEntregable AS idContratoEntregable,
           I.idInstanciaEntregable AS idinstanciaEntregable
    FROM	EN_InstanciasEntregable	I	(NOLOCK)
    JOIN	EN_Actividad	A	(NOLOCK)
		ON	I.ActividadID	=	A.ActividadID

    JOIN	EN_ContratoEntregable	CE (NOLOCK)
		ON	CE.IdContratoEntregable	=	I.IdContratoEntregable
		AND	CE.IdContrato	=	@idContrato
		 AND CE.Activo = 1
		 AND I.Activo	=	1
   JOIN	EN_Entregable	E (NOLOCK)
		ON	CE.IdEntregable	=	E.IdEntregable
		 AND E.IsActivo = 1
		 AND E.BitJOA	=	0
   LEFT	JOIN	dbo.EN_ExcepcionesActividad	EXAR (NOLOCK)
		ON	A.ActividadID	=	EXAR.ActividadIDExcepcion
		AND	I.idInstanciaEntregable	=	EXAR.IdInstanciasEntregables

    WHERE (
              A.idUsuario	IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
              AND EXAR.IdInstanciasEntregables IS NULL
              AND A.EstadoID = 10001
          )
          OR
          (
              EXAR.idUsuario IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
              AND EXAR.IdInstanciasEntregables IS NOT NULL
              AND EXAR.EstadoID = 10001
          )
  --  UNION

  --  SELECT E.IdEntregable AS idEntregable,
  --         CE.IdContratoEntregable AS idContratoEntregable,
  --         I.idInstanciaEntregable AS idinstanciaEntregable
  --  FROM EN_InstanciasEntregable I
  --  JOIN	EN_Actividad A 
		--ON I.ActividadID = A.ActividadID

  --  JOIN	EN_ContratoEntregable CE 
		--ON CE.IdContratoEntregable = I.IdContratoEntregable
		--AND CE.IdContrato = @idContrato

  --  JOIN	EN_Entregable E 
		--ON CE.IdEntregable = E.IdEntregable

  --  LEFT JOIN	dbo.EN_ExcepcionesActividad EXAR 
		--ON A.ActividadID = EXAR.ActividadIDExcepcion
		--AND I.idInstanciaEntregable = EXAR.IdInstanciasEntregables

  --  WHERE (
  --            A.idUsuario IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
  --            AND EXAR.IdInstanciasEntregables IS NULL
  --            AND A.EstadoID = 10001
  --            AND E.IsActivo = 1
  --            AND CE.Activo = 1
  --            AND E.BitInterno = 1
  --        )
  --        OR
  --        (
  --            EXAR.idUsuario IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
  --            AND EXAR.IdInstanciasEntregables IS NOT NULL
  --            AND EXAR.EstadoID = 10001
  --            AND E.IsActivo = 1
  --            AND CE.Activo = 1
  --            AND E.BitInterno = 1
  --        );
    ----------------------------------------------------------------------------------------
    --Mis entregables Aprobación
    INSERT INTO #Aprobacion (idEntregable, idContratoEntregable, idinstanciaEntregable)
    SELECT E.IdEntregable AS idEntregable,
           CE.IdContratoEntregable AS idContratoEntregable,
           I.idInstanciaEntregable AS idinstanciaEntregable
    FROM EN_InstanciasEntregable I	(NOLOCK)

    JOIN EN_ContratoEntregable CE	(NOLOCK)
		ON CE.IdContratoEntregable = I.IdContratoEntregable
		AND CE.IdContrato = @idContrato
		AND CE.Activo = 1
		AND I.Activo = 1
    JOIN	EN_Actividad A	(NOLOCK)
		ON I.ActividadID = A.ActividadID

    JOIN	EN_Entregable E (NOLOCK)
		ON CE.IdEntregable = E.IdEntregable
		AND E.IsActivo = 1
		AND E.BitJOA	=	0
    LEFT	JOIN	dbo.EN_ExcepcionesActividad EXAR (NOLOCK)
		ON A.ActividadID = EXAR.ActividadIDExcepcion
        AND I.idInstanciaEntregable = EXAR.IdInstanciasEntregables

    WHERE
          (
              A.idUsuario IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
              AND EXAR.IdInstanciasEntregables IS NULL
              AND A.EstadoID = 10002
          )
          OR
          (
              EXAR.idUsuario IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
              AND EXAR.IdInstanciasEntregables IS NOT NULL
              AND EXAR.EstadoID = 10002
          )
 --   UNION

 --   SELECT E.IdEntregable AS idEntregable,
 --       CE.IdContratoEntregable AS idContratoEntregable,
 --          I.idInstanciaEntregable AS idinstanciaEntregable
 --   FROM EN_InstanciasEntregable I

 --   JOIN EN_ContratoEntregable CE 
	--ON CE.IdContratoEntregable = I.IdContratoEntregable
 --   AND CE.IdContrato = @idContrato

 --   JOIN EN_Actividad A 
	--	ON I.ActividadID = A.ActividadID

 --   JOIN EN_Entregable E 
	--	ON CE.IdEntregable = E.IdEntregable

 --   LEFT JOIN dbo.EN_ExcepcionesActividad EXAR 
	--	ON A.ActividadID = EXAR.ActividadIDExcepcion
	--	AND I.idInstanciaEntregable = EXAR.IdInstanciasEntregables

 --   LEFT JOIN dbo.AP_Usuario UXR ON EXAR.idUsuario = UXR.UsuarioID
 --   WHERE A.EstadoID = 10002 -- AND      A.idUsuario     = @idUsuario;
 --         AND
 --         (
 --             A.idUsuario IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
 --             AND EXAR.IdInstanciasEntregables IS NULL
 --             AND A.EstadoID = 10002
 --             AND E.IsActivo = 1
 --             AND CE.Activo = 1
 --             AND E.BitInterno = 1
 --         )
 --         OR
 --         (
 --             EXAR.idUsuario IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
 --             AND EXAR.IdInstanciasEntregables IS NOT NULL
 --             AND EXAR.EstadoID = 10002
 --             AND E.IsActivo = 1
 --             AND CE.Activo = 1
 --             AND E.BitInterno = 1
 --         );
    ----------------------------------------------------------------------------------------

    SELECT @CountMisEntregElaborar = MAX(id)
    FROM #TempInstancias;

    SELECT @countMisEntregRevision = MAX(id)
    FROM #Revision;

    SELECT @countMisEntregAprobacion = MAX(id)
    FROM #Aprobacion;

    ----------------------------------------------------------------------------------------
    --TOTALES
    ----------------------------------------------------------------------------------------
    --Total entregables Elaboración
    INSERT INTO #TempInstanciasTotalElaborar (FechasLimiteElaboracion, idEntregable)
    SELECT MIN(IE.FechasLimiteElaboracion),
           CE.IdEntregable
    FROM EN_InstanciasEntregable IE	(NOLOCK)

    JOIN EN_ContratoEntregable CE	(NOLOCK)
		ON IE.IdContratoEntregable = CE.IdContratoEntregable
		AND CE.IdContrato = @idContrato
		AND CE.Activo = 1
        AND IE.Activo = 1
    JOIN dbo.EN_Actividad (NOLOCK)
		ON IE.ActividadID = EN_Actividad.ActividadID

    JOIN dbo.EN_Entregable Ent (NOLOCK)
		ON CE.IdEntregable = Ent.IdEntregable
		AND Ent.BitJOA = 0
    WHERE (
              EN_Actividad.EstadoID = 10000
              AND Ent.IsActivo = 1
          )
          AND CE.IdContrato = @idContrato
    GROUP BY CE.IdEntregable;
    ----------------------------------------------------------------------------------------
    --Total entregables Revisión
    INSERT INTO #TotalRevision (idEntregable, idContratoEntregable, idinstanciaEntregable)
    SELECT E.IdEntregable AS idEntregable,
           CE.IdContratoEntregable AS idContratoEntregable,
           I.idInstanciaEntregable AS idinstanciaEntregable
    FROM EN_InstanciasEntregable I	(NOLOCK)
    JOIN EN_Actividad A (NOLOCK)
		ON I.ActividadID = A.ActividadID
		AND A.EstadoID = 10001
    JOIN EN_ContratoEntregable CE (NOLOCK)
		ON CE.IdContratoEntregable = I.IdContratoEntregable
        AND CE.IdContrato = @idContrato
		AND CE.Activo = 1
   JOIN EN_Entregable E (NOLOCK)
		ON CE.IdEntregable = E.IdEntregable
		AND E.BitJOA	=	0
		AND E.IsActivo = 1
    WHERE (
              A.EstadoID = 10001
              AND E.IsActivo = 1
              AND CE.Activo = 1
          )
    UNION
    SELECT E.IdEntregable AS idEntregable,
           CE.IdContratoEntregable AS idContratoEntregable,
           I.idInstanciaEntregable AS idinstanciaEntregable
    FROM EN_InstanciasEntregable I	(NOLOCK)

    JOIN EN_ContratoEntregable CE (NOLOCK)
		ON CE.IdContratoEntregable = I.IdContratoEntregable
		AND CE.IdContrato = @idContrato
		AND CE.Activo = 1
    JOIN EN_Actividad A (NOLOCK)
		ON I.ActividadID = A.ActividadID
		AND A.EstadoID = 10001
    JOIN EN_Entregable E (NOLOCK)
		ON CE.IdEntregable = E.IdEntregable
		AND E.BitJOA	=	0
    LEFT JOIN dbo.EN_ExcepcionesActividad EXAR 
		ON A.ActividadID = EXAR.ActividadIDExcepcion
		AND I.idInstanciaEntregable = EXAR.IdInstanciasEntregables

    WHERE (
			A.EstadoID = 10001
              AND E.IsActivo = 1
              AND CE.Activo = 1
              AND E.BitInterno = 1
          );
    ------------------------------------------------------------------------------------------------------------
    --Total entregables aprobación
    INSERT INTO #TotalAprobacion (idEntregable, idContratoEntregable, idinstanciaEntregable)
    SELECT E.IdEntregable AS idEntregable,
           CE.IdContratoEntregable AS idContratoEntregable,
           I.idInstanciaEntregable AS idinstanciaEntregable
    FROM EN_InstanciasEntregable I	(NOLOCK)
    JOIN EN_ContratoEntregable CE (NOLOCK)
		ON CE.IdContratoEntregable = I.IdContratoEntregable
		AND CE.IdContrato = @idContrato

    JOIN EN_Actividad A (NOLOCK)
		ON I.ActividadID = A.ActividadID
		AND A.EstadoID = 10002
    JOIN EN_Entregable E (NOLOCK)
		ON CE.IdEntregable = E.IdEntregable
		AND E.BitJOA	=	0
    WHERE A.EstadoID = 10002
          AND E.IsActivo = 1
          AND CE.Activo = 1
    UNION
    SELECT E.IdEntregable AS idEntregable,
           CE.IdContratoEntregable AS idContratoEntregable,
           I.idInstanciaEntregable AS idinstanciaEntregable
    FROM EN_InstanciasEntregable I	(NOLOCK)

    JOIN EN_ContratoEntregable CE (NOLOCK)
		ON CE.IdContratoEntregable = I.IdContratoEntregable
		AND CE.IdContrato = @idContrato

    JOIN EN_Actividad A (NOLOCK)
		ON I.ActividadID = A.ActividadID

    JOIN EN_Entregable E (NOLOCK)
		ON CE.IdEntregable = E.IdEntregable
		AND E.BitJOA	=	0
    WHERE A.EstadoID = 10002
          AND E.IsActivo = 1
          AND CE.Activo = 1
          AND E.BitInterno = 1;
    ------------------------------------------------------------------------------------------------------------
	 --Total entregables aprobación sin Acuse
    INSERT INTO #TotalAprobacionSinAcuse (idEntregable, idContratoEntregable, idinstanciaEntregable)
    SELECT E.IdEntregable AS idEntregable,
           CE.IdContratoEntregable AS idContratoEntregable,
           I.idInstanciaEntregable AS idinstanciaEntregable
    FROM EN_InstanciasEntregable I (NOLOCK)
    JOIN EN_ContratoEntregable CE (NOLOCK)
		ON CE.IdContratoEntregable = I.IdContratoEntregable
        AND CE.IdContrato = @idContrato

   JOIN EN_Actividad A (NOLOCK)
		ON I.ActividadID = A.ActividadID

   JOIN EN_Entregable E (NOLOCK)
		ON CE.IdEntregable = E.IdEntregable
		AND E.BitJOA	=	0
    WHERE A.EstadoID = 10003
          AND E.IsActivo = 1
          AND CE.Activo = 1
		  AND I.BitContieneAcuse=0
    UNION
    SELECT E.IdEntregable AS idEntregable,
           CE.IdContratoEntregable AS idContratoEntregable,
           I.idInstanciaEntregable AS idinstanciaEntregable
    FROM EN_InstanciasEntregable I (NOLOCK)
    JOIN EN_ContratoEntregable CE (NOLOCK)
		ON CE.IdContratoEntregable = I.IdContratoEntregable
		AND CE.IdContrato = @idContrato

    JOIN EN_Actividad A (NOLOCK)
		ON I.ActividadID = A.ActividadID

    JOIN EN_Entregable E (NOLOCK)
		ON CE.IdEntregable = E.IdEntregable
		AND E.BitJOA	=	0
    WHERE A.EstadoID = 10003
          AND E.IsActivo = 1
          AND CE.Activo = 1
          AND E.BitInterno = 1
		  AND I.BitContieneAcuse=0;
    ------------------------------------------------------------------------------------------------------------

    SELECT @CountTotalEntregElaborar = MAX(id) ---Total entregables pendientes de Elaboración
    FROM #TempInstanciasTotalElaborar;

    SELECT @countTotalEntregRevision = MAX(id)
    FROM #TotalRevision;

    SELECT @countTotalEntregAprobacion = MAX(id)
    FROM #TotalAprobacion;

	SELECT @countTotalEntregAprobacionSinAcuse= MAX(id)
    FROM #TotalAprobacionSinAcuse

    SELECT @IsAdmin = COUNT(1)
	--SELECT *
    FROM dbo.AP_PerfilUsuario PU (NOLOCK)
    JOIN dbo.AP_Perfil P (NOLOCK)
		ON PU.PerfilID = P.IdPerfil
    JOIN dbo.AP_Rol R (NOLOCK)
		ON P.IdRol = R.IdRol
    WHERE UsuarioID = @idUsuario
          AND P.IdContrato =@idContrato
          AND (R.Rol LIKE '%Administra%Entregables%' OR
			 R.Rol LIKE '%Carga%Histori%');

    SELECT @IsAdmin AS isAdmin,
           ISNULL(@CountMisEntregElaborar,0) AS MisEntregablesElaborar,
           ISNULL(@countMisEntregRevision,0) AS MisEntregablesRevision,
          ISNULL( @countMisEntregAprobacion,0) AS MisEntregablesAprobacion,
          ISNULL( @CountTotalEntregElaborar,0) AS TotalElaborar,
          ISNULL( @countTotalEntregRevision,0) AS TotalRevisar,
          ISNULL( @countTotalEntregAprobacion,0) AS TotalAprobar,
		  ISNULL( @countTotalEntregAprobacionSinAcuse,0) AS TotalSinAcuse;
END;
