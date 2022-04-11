CREATE PROCEDURE dbo.sp_EN_NotificacionesSemanales_Repsol
AS
BEGIN
-- =============================================
-- Author:  Bárbara Arrañaga
-- Create date: 2018-11-08
-- =============================================
-- 20220406	Configuracion de envio de correos a Lider de Area y Elaborador Interno
-- =============================================
SET NOCOUNT ON
SET LANGUAGE Spanish

CREATE TABLE #NotificacionesProximas
(
	Destinatario	VARCHAR(250),
	TipoCorreo		VARCHAR(250),
	Ruta			VARCHAR(250),
	Tabla1			VARCHAR(MAX),
	EsGrupo			BIT
)

CREATE TABLE #NotificacionesPendientes
(
	Destinatario	VARCHAR(250),
	TipoCorreo		VARCHAR(250),
	Ruta			VARCHAR(250),
	Tabla1			VARCHAR(MAX),
	EsGrupo			BIT
)

CREATE TABLE #NotificacionesPendYProx
(
	Destinatario	VARCHAR(250),
	TipoCorreo		VARCHAR(250),
	Ruta			VARCHAR(250),
	Tabla1			VARCHAR(MAX),
	Tabla2			VARCHAR(MAX),
	EsGrupo			BIT
)

CREATE TABLE #NotificacionesFinales
(
	ID	INT IDENTITY(1,1),
	Destinatario	VARCHAR(250),
	TipoCorreo		VARCHAR(250),
	Ruta			VARCHAR(250),
	TablaProximas	VARCHAR(MAX),
	TablaPendientes		VARCHAR(MAX),
	NumCorreo		INT,
	NombreDestinatario	VARCHAR(250),
	TotalCorreos	INT
)

CREATE TABLE #CantidadCorreos
(
	Destinatario	VARCHAR(250),
	TipoCorreo		VARCHAR(250),
	TotalCorreos	INT
)

DECLARE
	@HOY DATE,
	@MaxNotificacion	INT = 0

SELECT @HOY = GETDATE()

--================================ NOTIFICACIONES A RESPONSIBLES (LO QUE COMIENZA EN LOS SIGUIENTES 7 DIAS)==============================================
	INSERT INTO #NotificacionesProximas
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		EsGrupo
	)
	SELECT
		U1.Usuario,
		'Notificación Semanal para Responsible Repsol'   AS tipoCorreo,
		'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx?identificador=' AS RutaPendiente,

		'<tr><td' + CASE WHEN CC.IdContrato IS NOT NULL
			THEN  ' style="background-color:' + LTRIM(CC.Color_HEX) + ';">'+C.NumeroContrato+ '</td>'	
			ELSE  '>'+C.NumeroContrato+ '</td>'
		END + 
		'<td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		'<td>' + LTRIM(IE.idInstanciaEntregable) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>' +
		'<td'+
		CASE
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
		END	 + '</td>'
		AS Tabla,
		U1.IsGrupo
    FROM
		CO_Contrato C	(NOLOCK)
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON	c.IdContratista	=	cita.IdContratista
		AND	cita.NombreContratista LIKE '%REPSOL%'
	JOIN
        dbo.EN_ContratoEntregable   CE	(NOLOCK)
        ON	C.IdContrato	=	CE.IdContrato
		AND CE.Activo = 1
	JOIN
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
		ON	CE.IdContratoEntregable	=	IE.IdContratoEntregable
		AND ( IE.FechaInicioElaboracion	BETWEEN @HOY AND DATEADD(DAY,7,@HOY) OR IE.FechaCalculadaEntregaReg BETWEEN @HOY AND DATEADD(DAY,7,@HOY) )
		AND IE.Activo = 1
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
		ON IE.ActividadID	=	A.ActividadID
		AND	A.EstadoID <> 10003	-- ELABORACION
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
		ON CE.IdEntregable	= E.IdEntregable 
		AND E.BITJOA = 0
		AND E.IsActivo = 1
	JOIN
        dbo.AP_Usuario              U1	(NOLOCK)
        ON A.idUsuario = U1.UsuarioID
		AND	U1.IsActivo = 1
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
	LEFT JOIN
		CO_ContratoConfiguracion	CC	(NOLOCK)
		ON	C.IdContrato	=	CC.Idcontrato
	LEFT JOIN
		EN_MarcoLegal	ML	(NOLOCK)
		ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
	ORDER BY
		U1.Usuario,
		C.NumeroContrato

--focalpoint varchar(250)					-- elabora interno		
    --================================ NOTIFICACIONES A ELABORADOR INTERNO ==============================================
	INSERT INTO #NotificacionesProximas
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		EsGrupo
	)
	SELECT
		CE.FocalPoint,
		'Notificación Semanal para ElaboradorInterno Repsol'   AS tipoCorreo,
		'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx?identificador=' AS RutaPendiente,
		'<tr><td' + CASE WHEN CC.IdContrato IS NOT NULL
			THEN  ' style="background-color:' + LTRIM(CC.Color_HEX) + ';">'+C.NumeroContrato+ '</td>'	
			ELSE  '>'+C.NumeroContrato+ '</td>'
		END +
		'<td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		'<td>' + LTRIM(IE.idInstanciaEntregable) + '-' +  LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111)+ '</td>'  +    
		'<td'+
		CASE
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,@HOY) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
		END	 + '</td>'
		AS Tabla,
		0
    FROM
		CO_Contrato	C (NOLOCK)
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON	c.IdContratista	=	cita.IdContratista
		AND	cita.NombreContratista LIKE '%REPSOL%'
	JOIN
        dbo.EN_ContratoEntregable   CE	(NOLOCK)
        ON	C.IdContrato	=	CE.IdContrato
		AND CE.Activo=1 
		AND ISNULL(CE.FocalPoint,'')	<> ''
	JOIN
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
		ON	CE.IdContratoEntregable	=	IE.IdContratoEntregable
		--AND	IE.FechaInicioElaboracion	BETWEEN @Hoy AND DATEADD(DAY,7,@HOY)
		AND ( IE.FechaInicioElaboracion	BETWEEN @HOY AND DATEADD(DAY,7,@HOY) OR IE.FechaCalculadaEntregaReg BETWEEN @HOY AND DATEADD(DAY,7,@HOY) )
		AND IE.Activo=1
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
        ON IE.ActividadID	=	A.ActividadID
		AND	A.EstadoID <> 10003	-- ELABORACION
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
		ON CE.IdEntregable	= E.IdEntregable
		AND E.BITJOA = 0
		AND E.IsActivo = 1
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
	LEFT JOIN
		CO_ContratoConfiguracion	CC
		ON	C.IdContrato	=	CC.Idcontrato
	LEFT JOIN
		EN_MarcoLegal	ML
		ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
	ORDER BY
		CE.FocalPoint,
		C.NumeroContrato
		
--================================ NOTIFICACIONES PENDIENTES A ELABORADOR  ==============================================
	INSERT INTO #NotificacionesPendientes
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		EsGrupo
	)
	SELECT
		U1.Usuario,
		'Notificación Semanal para Responsible Repsol'   AS tipoCorreo,
		'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx?identificador=' AS RutaPendiente,

		'<tr><td' + CASE WHEN CC.IdContrato IS NOT NULL
			THEN  ' style="background-color:' + LTRIM(CC.Color_HEX) + ';">'+C.NumeroContrato+ '</td>'	
			ELSE  '>'+C.NumeroContrato+ '</td>'
		END +
		'<td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		'<td>' + LTRIM(IE.idInstanciaEntregable) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111)+ '</td>'  +  
		'<td'+
		CASE
			WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,@HOY) > 0 THEN ' style="background-color:Tomato;">Delayed'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
		END  + '</td>'
		AS Tabla,
		U1.IsGrupo
    FROM
		CO_Contrato C	(NOLOCK)
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON	c.IdContratista	=	cita.IdContratista
		AND	cita.NombreContratista LIKE '%REPSOL%'
	JOIN
        dbo.EN_ContratoEntregable   CE	(NOLOCK)
        ON	C.IdContrato	=	CE.IdContrato
		AND CE.Activo=1 
	JOIN
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
		ON IE.IdContratoEntregable= CE.IdContratoEntregable
		AND	IE.FechaCalculadaEntregaReg	< @HOY
		AND IE.Activo=1
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
        ON IE.ActividadID	=	A.ActividadID
		AND	A.EstadoID <> 10003	-- APROBACION
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
		ON CE.IdEntregable	= E.IdEntregable
		AND E.BITJOA = 0
		AND E.IsActivo = 1
	JOIN
        dbo.AP_Usuario              U1	(NOLOCK)
        ON A.idUsuario = U1.UsuarioID
		AND U1.IsActivo = 1
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
	LEFT JOIN
		CO_ContratoConfiguracion	CC
		ON	C.IdContrato	=	CC.Idcontrato
	LEFT JOIN
		EN_MarcoLegal	ML
		ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
	ORDER BY
		U1.Usuario,
		C.NumeroContrato

--================================ NOTIFICACIONES PENDIENTES A ELABORADOR INTERNO ==============================================
	INSERT INTO #NotificacionesPendientes
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		EsGrupo
	)
	SELECT
		CE.FocalPoint,
		'Notificación Semanal para ElaboradorInterno Repsol'   AS tipoCorreo,
		'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx?identificador=' AS RutaPendiente,
		'<tr><td' + CASE WHEN CC.IdContrato IS NOT NULL
			THEN  ' style="background-color:' + LTRIM(CC.Color_HEX) + ';">'+C.NumeroContrato+ '</td>'	
			ELSE  '>'+C.NumeroContrato+ '</td>'
		END +
		'<td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		'<td>' + LTRIM(IE.idInstanciaEntregable) + '-' +  LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111)+ '</td>'  +    
		'<td'+
		CASE
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,@HOY) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
		END	 + '</td>'
		AS Tabla,
		0
    FROM
		CO_Contrato	C (NOLOCK)
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON	c.IdContratista	=	cita.IdContratista
		AND	cita.NombreContratista LIKE '%REPSOL%'
	JOIN
        dbo.EN_ContratoEntregable   CE	(NOLOCK)
        ON	C.IdContrato	=	CE.IdContrato
		AND CE.Activo=1 
		AND ISNULL(CE.FocalPoint,'')	<> ''
	JOIN
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
		ON IE.IdContratoEntregable= CE.IdContratoEntregable
		AND	IE.FechaCalculadaEntregaReg	< @HOY
		AND IE.Activo=1
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
        ON IE.ActividadID	=	A.ActividadID
		AND	A.EstadoID <> 10003	-- APROBACION
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
		ON CE.IdEntregable	= E.IdEntregable
		AND E.BITJOA = 0
		AND E.IsActivo = 1
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
	LEFT JOIN
		CO_ContratoConfiguracion	CC
		ON	C.IdContrato	=	CC.Idcontrato
	LEFT JOIN
		EN_MarcoLegal	ML
		ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
	ORDER BY
		CE.FocalPoint,
		C.NumeroContrato

	INSERT INTO #NotificacionesPendYProx
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		Tabla2,
		EsGrupo
	)
	SELECT
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		'',
		EsGrupo
	FROM #NotificacionesProximas 
	ORDER BY Destinatario

	INSERT INTO #NotificacionesPendYProx
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		Tabla2,
		EsGrupo
	)
	SELECT
		Destinatario,
		TipoCorreo,
		Ruta,
		'',
		Tabla1,
		EsGrupo
	FROM #NotificacionesPendientes 
	ORDER BY Destinatario

-- SE JUNTAN TODOS LOS ENTREGABLES POR DESTINATARIO-FUNCION
	INSERT INTO #NotificacionesFinales
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		TablaProximas,
		TablaPendientes,
		NumCorreo
	)
	SELECT
		Destinatario,
		TipoCorreo,
		Ruta,
		REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla1 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'), --+ '</table>' Detalle
		REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla2 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'), --+ '</table>' Detalle
		1
	FROM
		#NotificacionesPendYProx B
	WHERE
		EsGrupo = 0
	GROUP BY
		Destinatario,
		TipoCorreo,
		Ruta

	UNION

	SELECT
		UG.Usuario,
		TipoCorreo,
		Ruta,
		REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla1 FROM #NotificacionesPendYProx A
				WHERE UG.Usuario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'), --+ '</table>' Detalle
		REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla2 FROM #NotificacionesPendYProx A
				WHERE UG.Usuario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'), --+ '</table>' Detalle
		1
	FROM
		#NotificacionesPendYProx B
	JOIN
		AP_Usuario	U
		ON	B.Destinatario	=	U.Nombre
	JOIN
		EN_GruposUsuarios	G
		ON	U.UsuarioID	=	G.IdGrupo
	JOIN
		AP_Usuario	UG
		ON	G.IdUsuario	=	UG.UsuarioID
	WHERE
		B.EsGrupo = 1
	GROUP BY
		UG.Usuario,
		TipoCorreo,
		Ruta
	ORDER BY
		Destinatario


	-- SE OBTIENE CUANTOS CORREOS VA A RECIBIR EL USUARIO
	INSERT INTO #CantidadCorreos
	(
		Destinatario,
		TipoCorreo,
		TotalCorreos
	)
	SELECT
		Destinatario,
		TipoCorreo,
		MAX(NumCorreo)
	FROM
		#NotificacionesFinales
	GROUP BY
		Destinatario,
		TipoCorreo

	UPDATE	NF
		SET	TotalCorreos	=	CC.TotalCorreos
	FROM
		#NotificacionesFinales	NF
	JOIN
		#CantidadCorreos	CC
		ON	NF.Destinatario	=	CC.Destinatario
		AND	NF.TipoCorreo	=	CC.TipoCorreo

	-- SE CAMBIA EL TIPO DE CORREO
	UPDATE #NotificacionesFinales
	SET	TipoCorreo = TipoCorreo + ' (Continuacion)'
	WHERE NumCorreo > 1

--accountablecompliance varchar(250),		-- Lideer del area

	-- SE BORRA LA TABLA PARA REUTILIZAR CON LOS LIDERES DE AREA
	DELETE FROM #NotificacionesProximas
	DELETE FROM #NotificacionesPendientes
	DELETE FROM #NotificacionesPendYProx

    --================================ NOTIFICACIONES A LIDER DE AREA ==============================================
	INSERT INTO #NotificacionesProximas
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		EsGrupo
	)
	SELECT
		CE.AccountableCompliance,
		'Notificación Semanal para Lider de Area Repsol'   AS tipoCorreo,
		'https://'+ruta.Ruta+'/2/Entregables/EntregablesAdministradorContrato.aspx?identificador=' AS RutaPendiente,
		'<tr><td' + CASE WHEN CC.IdContrato IS NOT NULL
			THEN  ' style="background-color:' + LTRIM(CC.Color_HEX) + ';">'+C.NumeroContrato+ '</td>'	
			ELSE  '>'+C.NumeroContrato+ '</td>'
		END +
		'<td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		'<td>' + LTRIM(IE.idInstanciaEntregable) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111)+ '</td>'  +  
		'<td'+
		CASE
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,@HOY) > 0 THEN 'style="background-color:Tomato;">Delayed'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
		END	 + '</td>'		AS Tabla,
		0
    FROM
		CO_Contrato C	(NOLOCK)
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON	c.IdContratista	=	cita.IdContratista
		AND cita.NombreContratista LIKE '%REPSOL%'
	JOIN
		dbo.EN_ContratoEntregable   CE	(NOLOCK)
		ON 	C.IdContrato	=	CE.IdContrato
		AND CE.Activo=1 
		AND ISNULL(CE.AccountableCompliance,'')	<> ''
	JOIN
		dbo.EN_InstanciasEntregable IE	(NOLOCK)
		ON	CE.IdContratoEntregable	=	IE.IdContratoEntregable
		--AND	IE.FechaCalculadaEntregaReg	BETWEEN @HOY AND DATEADD(DAY,7,@HOY)
		AND ( IE.FechaInicioElaboracion	BETWEEN @HOY AND DATEADD(DAY,7,@HOY) OR IE.FechaCalculadaEntregaReg BETWEEN @HOY AND DATEADD(DAY,7,@HOY) )
		AND IE.Activo=1
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
        ON IE.ActividadID	=	A.ActividadID
		AND	A.EstadoID <> 10003	-- ELABORACION
	JOIN
        dbo.EN_Estado               E1	(NOLOCK)
        ON  A.EstadoID	=	E1.EstadoID--En estado que se encuentra la instancia
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
		ON CE.IdEntregable	= E.IdEntregable 
		AND E.BITJOA = 0
		AND E.IsActivo = 1
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
	LEFT JOIN
		CO_ContratoConfiguracion	CC
		ON	C.IdContrato	=	CC.Idcontrato
	LEFT JOIN
		EN_MarcoLegal	ML
		ON	E.IdMarcoLegal	=	ML.IdMarcoLegal

-- NOTIFICACIONES PENDIENTES PARA LIDER DE AREA
	INSERT INTO #NotificacionesPendientes
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		EsGrupo
	)
	SELECT
		CE.AccountableCompliance,
		'Notificación Semanal para Lider de Area Repsol'   AS tipoCorreo,
		'https://'+ruta.Ruta+'/2/Entregables/EntregablesAdministradorContrato.aspx?identificador=' AS RutaPendiente,
		'<tr><td' + CASE WHEN CC.IdContrato IS NOT NULL
			THEN  ' style="background-color:' + LTRIM(CC.Color_HEX) + ';">'+C.NumeroContrato+ '</td>'	
			ELSE  '>'+C.NumeroContrato+ '</td>'
		END +
		'<td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		'<td>' + LTRIM(IE.idInstanciaEntregable) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111)+ '</td>'  +  
		'<td'+
		CASE
			WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,@HOY) > 0 THEN ' style="background-color:Tomato;">Delayed'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
		END  + '</td>'
		AS Tabla,
		0
    FROM
		CO_Contrato C	(NOLOCK)
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON	c.IdContratista	=	cita.IdContratista
		AND	cita.NombreContratista LIKE '%REPSOL%'
	JOIN
        dbo.EN_ContratoEntregable   CE	(NOLOCK)
        ON	C.IdContrato	=	CE.IdContrato
		AND CE.Activo=1
		AND ISNULL(CE.AccountableCompliance,'')	<> ''
	JOIN
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
		ON IE.IdContratoEntregable= CE.IdContratoEntregable
		AND	IE.FechaCalculadaEntregaReg	< @HOY
		AND IE.Activo=1
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
        ON IE.ActividadID	=	A.ActividadID
		AND	A.EstadoID <> 10003	-- APROBACION
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
		ON CE.IdEntregable	= E.IdEntregable
		AND E.BITJOA = 0
		AND E.IsActivo = 1
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
	LEFT JOIN
		CO_ContratoConfiguracion	CC
		ON	C.IdContrato	=	CC.Idcontrato
	LEFT JOIN
		EN_MarcoLegal	ML
		ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
	ORDER BY
		CE.AccountableCompliance,
		C.NumeroContrato

	INSERT INTO #NotificacionesPendYProx
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		Tabla2,
		EsGrupo
	)
	SELECT
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		'',
		EsGrupo
	FROM #NotificacionesProximas 
	ORDER BY Destinatario

	INSERT INTO #NotificacionesPendYProx
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		Tabla2,
		EsGrupo
	)
	SELECT
		Destinatario,
		TipoCorreo,
		Ruta,
		'',
		Tabla1,
		EsGrupo
	FROM #NotificacionesPendientes 
	ORDER BY Destinatario


-- SE JUNTAN TODOS LOS ENTREGABLES POR DESTINATARIO-FUNCION
	INSERT INTO #NotificacionesFinales
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		TablaProximas,
		TablaPendientes,
		NumCorreo
	)
	SELECT
		Destinatario,
		TipoCorreo,
		Ruta,
		REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla1 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'), --+ '</table>' Detalle
		REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla2 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'), --+ '</table>' Detalle
		1
	FROM
		#NotificacionesPendYProx B
	WHERE
		EsGrupo = 0
	GROUP BY
		Destinatario,
		TipoCorreo,
		Ruta

	--UPDATE #NotificacionesFinales
	--	SET TablaProximas = ''
	--WHERE TablaProximas IS NULL

	--	UPDATE #NotificacionesFinales
	--	SET TablaPendientes = ''
	--WHERE TablaPendientes IS NULL

	UPDATE	NF
		SET NombreDestinatario	=	U.Nombre
	FROM
		#NotificacionesFinales	NF
	JOIN
		AP_Usuario	U	(NOLOCK)
		ON	NF.Destinatario	=	U.Usuario

	-- SI EL USUARIO NO SE ENCUENTRA DADO DE ALTA EN ADINCO O SON DOS O MAS CORREOS CONFIGURADOS
	UPDATE	#NotificacionesFinales
		SET	NombreDestinatario	=	LTRIM(RTRIM(REPLACE(TipoCorreo,'Notificación Semanal para','')))
	WHERE
		NombreDestinatario	IS NULL

	UPDATE #NotificacionesFinales
		SET TotalCorreos = 1
	WHERE ISNULL(TotalCorreos,0) = 0

/*************************************************/

	SELECT
		@MaxNotificacion = MAX(IdNotificacion)
	FROM
		S_Notificacion

	INSERT INTO S_Notificacion
	(
		IdNotificacion,
		Para,
		Asunto,
		Mensaje,
		FechaProgramadaEnvio,
		Enviada,
		CreadoPor,
		CreadoEl,
		De,
		EN_MsjEnviado
	)
	SELECT
		ISNULL(@MaxNotificacion,0) + ID,	-- IdNotificacion
		Destinatario,						-- Para
		CASE 
			WHEN NumCorreo = 1 AND TotalCorreos = 1 THEN C.Asunto
			WHEN NumCorreo = 1 AND TotalCorreos > 1	THEN C.Asunto + ' page 1 of ' + LTRIM(TotalCorreos)
			ELSE REPLACE(C.Asunto,'##num##', LTRIM(N.NumCorreo)) + ' of ' + LTRIM(TotalCorreos)
		END,
		CASE WHEN N.NumCorreo = N.TotalCorreos 
		THEN 
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.HTML,'##NOMBRE_USUARIO##', N.NombreDestinatario),'{tablaEntregables}', isnull(N.TablaProximas,'')),'{tablaPendientes}',isnull(N.TablaPendientes,'')),'##ENLACE_DETALLE##', (N.Ruta + LTRIM(ISNULL(@MaxNotificacion,0)+ID))),'##numcorreo##',LTRIM(N.NumCorreo) + '/' + LTRIM(N.TotalCorreos)),'##CONTINUACION##','')
		ELSE
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.HTML,'##NOMBRE_USUARIO##', N.NombreDestinatario),'{tablaEntregables}', isnull(N.TablaProximas,'')),'{tablaPendientes}',isnull(N.TablaPendientes,'')),'##ENLACE_DETALLE##', (N.Ruta + LTRIM(ISNULL(@MaxNotificacion,0)+ID))),'##numcorreo##',LTRIM(N.NumCorreo) + '/' + LTRIM(N.TotalCorreos)),'##CONTINUACION##','* There are more information in the next email (Page ' + LTRIM(N.NumCorreo+1) + ')')
		END,
		GETDATE(),
		0,
		1,
		GETDATE(),
		'notificaciones@adinco.mx',
		0
	FROM
		#NotificacionesFinales	N
	JOIN
		TA_Correo	C
		ON	N.TipoCorreo	=	C.Descripcion

END
