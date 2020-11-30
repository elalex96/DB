CREATE PROCEDURE sp_EN_ExtraeDatosProcesosExportar --3,10061
	@IdContrato int,
	@IdUsuario int,
	@ListIdProcesos VARCHAR(MAX),
	@ListIdInstanciasProcesos VARCHAR(MAX),
	@ListidTipoProceso VARCHAR(MAX),
	@ListIdInstalacion VARCHAR(MAX)
AS
BEGIN
-- =============================================
-- Author:  	Reyna Olvera
-- Create date: 20200421
-- Description:	
-- =============================================
CREATE TABLE #InstanciasActividades(
									Id int identity (1,1),
									NombreProceso VARCHAR (MAX),
									DescripcionInstanciaProceso VARCHAR (MAX),
									NombreActividad VARCHAR (MAX),
									FechaEntrega DATE
									);

CREATE TABLE #IdProceso (RowId INT IDENTITY(1,1),
						IdProceso varchar(300))

CREATE TABLE #IdInstanciasProcesos (RowId INT IDENTITY(1,1),
						IdInstanciasProceso varchar(300))

CREATE TABLE #ListidTipoProceso (RowId INT IDENTITY(1,1),
								IdTipoProceso varchar(300));

CREATE TABLE #ListIdInstalacion (RowId INT IDENTITY(1,1),
								IdInstalacion varchar(300));

CREATE TABLE #DatosParaExportar (RowId INT IDENTITY(1,1),
								IdProceso INT,
								IdInstanciasProceso INT,
								IdTipoProceso INT,
								IdInstalacion INT);

INSERT INTO #IdProceso (IdProceso)
    SELECT splitdata AS IdProceso
    FROM [dbo].[fnSplitString](@ListIdProcesos, ',');

INSERT INTO #IdInstanciasProcesos (IdInstanciasProceso)
    SELECT splitdata AS IdInstanciasProceso
    FROM [dbo].[fnSplitString](@ListIdInstanciasProcesos, ',');

INSERT INTO #ListidTipoProceso (IdTipoProceso)
    SELECT splitdata AS IdTipoProceso
    FROM [dbo].[fnSplitString](@ListidTipoProceso, ',');

INSERT INTO #ListIdInstalacion (IdInstalacion)
    SELECT splitdata AS IdInstalacion
    FROM [dbo].[fnSplitString](@ListIdInstalacion, ',');


INSERT INTO  #DatosParaExportar(IdProceso ,IdInstanciasProceso ,IdTipoProceso ,IdInstalacion )
SELECT 
 SUBSTRING(
        IdProceso, 
        CHARINDEX(']', IdProceso)+1, 
        LEN(IdProceso)-CHARINDEX(']', IdProceso)
    ),
	 SUBSTRING(
        IdInstanciasProceso, 
        CHARINDEX(']', IdInstanciasProceso)+1, 
        LEN(IdInstanciasProceso)-CHARINDEX(']', IdInstanciasProceso)
    ),
	 SUBSTRING(
        IdTipoProceso, 
        CHARINDEX(']', IdTipoProceso)+1, 
        LEN(IdTipoProceso)-CHARINDEX(']', IdTipoProceso)
    ),
	 SUBSTRING(
        IdInstalacion, 
        CHARINDEX(']', IdInstalacion)+1, 
        LEN(IdInstalacion)-CHARINDEX(']', IdInstalacion)
    )
	FROM 
	#IdProceso	P
JOIN 
	#IdInstanciasProcesos IP
	ON P.RowId	=	ip.RowId

JOIN
	#ListidTipoProceso TP
ON P.RowId	=	TP.RowId
JOIN 
	#ListIdInstalacion	I
	ON P.RowId	=	I.RowId
	
				
--TIPO 10000
INSERT INTO #InstanciasActividades(NombreProceso,
									DescripcionInstanciaProceso,
									NombreActividad,
									FechaEntrega )
	SELECT P.NombreProceso, IPF.Descripcion, A.NombreActividad, 
	CASE WHEN IPF.FechaInicial = 1 THEN ISNULL(IA.FechaRealActividad,FechaActividad) 
		ELSE ISNULL(IA.FechaRealActividad,FechaInicioActividad) END AS FechaEntrega
	FROM 
		#DatosParaExportar	DP
	JOIN
		En_InstanciasProcesosFecha	IPF
		ON	DP.IdInstanciasProceso	=	IPF.IdInstanciasProcesos
	JOIN 
		EN_InstanciasActividades	IA
		ON 	IPF.IdInstanciasProcesos	=	IA.IdInstanciasProcesos
	JOIN 
		EN_Actividades	A
		ON	IA.IdActividad	=	A.IdActividad
	JOIN 
		EN_Procesos	P
		ON	IPF.IdProceso	=	P.IdProceso
	WHERE
		DP.IdTipoProceso	=	10000
		AND DP.IdInstanciasProceso >	0
		AND IA.	ACTIVO	=	1
	ORDER BY 
		CASE WHEN IPF.FechaInicial = 1 THEN ISNULL(IA.FechaRealActividad,FechaActividad) 
		ELSE ISNULL(IA.FechaRealActividad,FechaInicioActividad) END

--TIPO 10001
INSERT INTO #InstanciasActividades(NombreProceso,
									DescripcionInstanciaProceso,
									NombreActividad,
									FechaEntrega )

	SELECT MP.NombreProceso, IPF.Descripcion, P.NombreProceso +' '+ A.NombreActividad AS NombreActividad, 
	CASE WHEN IPF.FechaInicial = 1 THEN ISNULL(IA.FechaRealActividad,FechaActividad) 
		ELSE ISNULL(IA.FechaRealActividad,FechaInicioActividad) END AS FechaEntrega
	--ISNULL(IA.FechaRealActividad,FechaInicioActividad) AS FechaEntrega
		FROM 
			#DatosParaExportar	DP
		JOIN
			EN_MacroProcesosRelacion MPR
			ON DP.IdProceso	=	MPR.idMacroProceso
		JOIN
			EN_Procesos MP
			ON MPR.idMacroProceso	=	MP.IdProceso
		JOIN
			EN_Procesos	P
			ON MPR.idProcesoHijo	=	P.IdProceso
		JOIN
			En_InstanciasProcesosFecha IPF
			ON P.IdProceso	=	IPF.IdProceso
		JOIN
			EN_InstanciasActividades IA
			ON IPF.IdInstanciasProcesos	=	IA.IdInstanciasProcesos
		JOIN 
			EN_Actividades	A
			ON	IA.IdActividad	=	A.IdActividad
		WHERE
			DP.IdTipoProceso	=	10001
			AND IA.	ACTIVO	=	1
		ORDER BY --ISNULL(IA.FechaRealActividad,FechaInicioActividad)
			CASE WHEN IPF.FechaInicial = 1 THEN ISNULL(IA.FechaRealActividad,FechaActividad) 
			ELSE ISNULL(IA.FechaRealActividad,FechaInicioActividad) END

--TIPO 10002
INSERT INTO #InstanciasActividades(NombreProceso,
									DescripcionInstanciaProceso,
									NombreActividad,
									FechaEntrega )

	SELECT MP.NombreProceso, IPF.Descripcion, P.NombreProceso +' '+ A.NombreActividad AS NombreActividad, --ISNULL(IA.FechaRealActividad,FechaInicioActividad) AS FechaEntrega
	CASE WHEN IPF.FechaInicial = 1 THEN ISNULL(IA.FechaRealActividad,FechaActividad) 
			ELSE ISNULL(IA.FechaRealActividad,FechaInicioActividad) END AS FechaEntrega
		FROM 
			#DatosParaExportar	DP
		JOIN
			EN_MacroProcesosRelacion MPR
			ON DP.IdProceso	=	MPR.idMacroProceso
			AND MPR.IdprocesoOriginal IS NOT NULL
		JOIN
			EN_Procesos MP
			ON MPR.idMacroProceso	=	MP.IdProceso
		JOIN
			EN_Procesos	P
			ON MPR.idProcesoHijo	=	P.IdProceso
			AND P.IdInstalacion	=	DP.IdInstalacion
			AND P.idTipoProceso	=	10003
		JOIN
			En_InstanciasProcesosFecha IPF
			ON P.IdProceso	=	IPF.IdProceso
		JOIN
			EN_InstanciasActividades IA
			ON IPF.IdInstanciasProcesos	=	IA.IdInstanciasProcesos
		JOIN 
			EN_Actividades	A
			ON	IA.IdActividad	=	A.IdActividad
		WHERE
			DP.IdTipoProceso	=	10002
			AND IA.	ACTIVO	=	1
		ORDER BY --ISNULL(IA.FechaRealActividad,FechaInicioActividad)
			CASE WHEN IPF.FechaInicial = 1 THEN ISNULL(IA.FechaRealActividad,FechaActividad) 
			ELSE ISNULL(IA.FechaRealActividad,FechaInicioActividad) END


SELECT FechaEntrega,NombreActividad+', '+FORMAT (FechaEntrega, 'dd/MM/yyyy'),NombreProceso,
CASE ROW_NUMBER() OVER(ORDER BY FechaEntrega ASC) % 6
	WHEN 0 THEN -4
	WHEN 1 THEN 5
	WHEN 2 THEN -3
	WHEN 3 THEN 4
	WHEN 4 THEN -5
	WHEN 5 THEN 3
END		AS cargo
FROM 
	#InstanciasActividades IA
ORDER BY FechaEntrega		

END

