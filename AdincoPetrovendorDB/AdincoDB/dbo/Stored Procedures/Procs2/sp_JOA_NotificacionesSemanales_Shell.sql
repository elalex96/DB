CREATE PROCEDURE dbo.sp_JOA_NotificacionesSemanales_Shell
AS
BEGIN

SET NOCOUNT ON
SET LANGUAGE Spanish

CREATE TABLE #NotificacionesProximas
(
	Destinatario	VARCHAR(250),
	TipoCorreo		VARCHAR(250),
	Ruta			VARCHAR(250),
	Tabla1			VARCHAR(8000)
)

CREATE TABLE #NotificacionesPendientes
(
	Destinatario	VARCHAR(250),
	TipoCorreo		VARCHAR(250),
	Ruta			VARCHAR(250),
	Tabla1			VARCHAR(8000)
)

CREATE TABLE #NotificacionesPendYProx
(
	Destinatario	VARCHAR(250),
	TipoCorreo		VARCHAR(250),
	Ruta			VARCHAR(250),
	Tabla1			VARCHAR(8000),
	Tabla2			VARCHAR(8000)
)

CREATE TABLE #NotificacionesFinales
(
	ID	INT IDENTITY(1,1),
	Destinatario	VARCHAR(250),
	TipoCorreo		VARCHAR(250),
	Ruta			VARCHAR(250),
	TablaProximas	VARCHAR(8000),
	TablaPendientes		VARCHAR(8000),
	NumCorreo		INT,
	NombreDestinatario	VARCHAR(250)
)

DECLARE
	@HOY DATE,
	@MaxNotificacion	INT = 0

SELECT @HOY = '20200701' --GETDATE()

--================================ NOTIFICACIONES A RESPONSIBLES (LO QUE COMIENZA EN LOS SIGUIENTES 7 DIAS)==============================================
	INSERT INTO #NotificacionesProximas
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1
	)
	SELECT
		U1.Usuario,
		'Notificación Semanal para Responsible JOA'   AS tipoCorreo,
		'https://'+ruta.Ruta+'/2/JOAs/ConfirmarObligacionesJOAs.aspx' AS RutaPendiente,
		'<tr><td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		'<td>'+ LTRIM(IE.idInstanciaEntregable) + '-' + LTRIM(RTRIM(E.Inciso)) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ LTRIM(CLA.NombreClasificacion) + '</td>'+
		'<td'+ 	CASE
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) = 7 THEN ' style="background-color:#8cd98c;">7 days remainig'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 4 and 6 THEN ' style="background-color:#ffdd99;">4-6 days remaining'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 1 and 3 THEN ' style="background-color:Tomato;">1-3 days remaining'
		END	 + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
		'<td>'+ CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
			ELSE ISNULL(ACC.Nombre,'')  -- ACCOUNTABLE
		END	+ '</td>'  + 
		'<td>'+ U1.Nombre 	+ '</td>'  +	-- RESPONSBILE
		'<td>'+ CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
			ELSE ISNULL(AC.Nombre,'')	-- ACCOUNTABLE COMPLIANCE
		END		+ '</td>'  + 
		'<td' + CASE WHEN CC.IdContrato IS NOT NULL
			THEN  ' style="background-color:' + LTRIM(CC.Color_HEX) + ';">'+CA.NombreContratista+ '</td>'	
			ELSE  '>'+CA.NombreContratista+ '</td>'
		END	AS Tabla
    FROM
		CO_Contrato				C	(NOLOCK)
	JOIN
		dbo.CO_Contratista		cita	(NOLOCK)
		ON	c.IdContratista	=	cita.IdContratista
		AND cita.NombreContratista LIKE '%SHELL%'
	JOIN
		dbo.EN_ContratoEntregable   CE	(NOLOCK)
		ON	C.IdContrato	=	CE.idContrato
		AND CE.Activo = 1
	JOIN
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
		ON	CE.IdContratoEntregable	=	IE.IdContratoEntregable
		AND IE.Activo = 1
		AND	IE.FechaInicioElaboracion	BETWEEN @HOY AND DATEADD(DAY,7,@HOY)
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
        ON IE.ActividadID	=	A.ActividadID
		AND	A.EstadoID <> 10003	-- ELABORACION
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
		ON CE.IdEntregable	= E.IdEntregable 
		AND E.BITJOA = 1
		AND E.IsActivo = 1
	JOIN
		En_Clasificacion		CLA
		ON E.IdClasificacion	=	CLA.IdClasificacion
	JOIN
        dbo.AP_Usuario          U1	(NOLOCK)
        ON A.idUsuario = U1.UsuarioID
	JOIN
		dbo.AP_Rutas			ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
	JOIN
		CO_ContratoSocio	CS
		ON CE.IdContrato	=	CS.IdContrato
	JOIN 
		CO_Contratista	CA
		ON CS.IdContratistaSocio	=	CA.IdContratista
	LEFT JOIN
		EN_MarcoLegal	ML
		ON	E.IdMarcoLegal = ML.IdMarcoLegal
	LEFT JOIN
		AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
		ON	CE.AccountableCompliance	=	AC.Usuario
	LEFT JOIN
		AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
		ON	CE.Accountable	=	ACC.Usuario
	LEFT JOIN
		CO_ContratoConfiguracion	CC
		ON	C.IdContrato	=	CC.Idcontrato
	WHERE
		cita.NombreContratista LIKE '%SHELL%'
		

	INSERT INTO #NotificacionesPendientes
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1
	)
	SELECT
		U1.Usuario,
		'Notificación Semanal para Responsible JOA'   AS tipoCorreo,
		'https://'+ruta.Ruta+'/2/JOAs/ConfirmarObligacionesJOAs.aspx' AS RutaPendiente,
		'<tr><td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		'<td>' + LTRIM(IE.idInstanciaEntregable) + '-' + LTRIM(RTRIM(E.Inciso)) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ LTRIM(CLA.NombreClasificacion) + '</td>'+
		'<td'+ 	CASE
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) = 7 THEN ' style="background-color:#8cd98c;">7 days remainig'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 4 and 6 THEN ' style="background-color:#ffdd99;">4-6 days remaining'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 1 and 3 THEN ' style="background-color:Tomato;">1-3 days remaining'
		END	 + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
		'<td>'+ CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
			ELSE ISNULL(ACC.Nombre,'')  -- ACCOUNTABLE
		END	+ '</td>'  + 
		'<td>'+ U1.Nombre 	+ '</td>'  +	-- RESPONSBILE
		'<td>'+ CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
			ELSE ISNULL(AC.Nombre,'')	-- ACCOUNTABLE COMPLIANCE
		END		+ '</td>'  + 
		'<td' + CASE WHEN CC.IdContrato IS NOT NULL
			THEN  ' style="background-color:' + LTRIM(CC.Color_HEX) + ';">'+CA.NombreContratista+ '</td>'	
			ELSE  '>'+CA.NombreContratista+ '</td>'
		END	AS Tabla
    FROM
		CO_Contrato	C	(NOLOCK)
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON	c.IdContratista	=	cita.IdContratista
		AND cita.NombreContratista LIKE '%SHELL%'
	JOIN
		dbo.EN_ContratoEntregable   CE	(NOLOCK)
		ON	C.IdContrato	=	CE.IdContrato
		AND CE.Activo = 1 
	JOIN
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
		ON CE.IdContratoEntregable = IE.IdContratoEntregable
		AND	IE.FechaCalculadaEntregaReg	< @HOY
		AND IE.Activo=1
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
        ON IE.ActividadID	=	A.ActividadID
		AND	A.EstadoID <> 10003	-- APROBACION
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
		ON CE.IdEntregable	= E.IdEntregable
		AND E.BITJOA = 1
		AND E.IsActivo = 1
	JOIN
		En_Clasificacion		CLA
		ON E.IdClasificacion	=	CLA.IdClasificacion
	JOIN
		CO_Contrato 
		ON CE.IdContrato	=	C.IdContrato
	JOIN
        dbo.AP_Usuario              U1	(NOLOCK)
        ON A.idUsuario = U1.UsuarioID
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
	JOIN
		CO_ContratoSocio	CS
		ON CE.IdContrato	=	CS.IdContrato
	JOIN 
		CO_Contratista	CA
		ON CS.IdContratistaSocio	=	CA.IdContratista
	LEFT JOIN
		EN_MarcoLegal	ML
		ON	E.IdMarcoLegal = ML.IdMarcoLegal
	LEFT JOIN
		AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
		ON	CE.FocalPoint	=	FP.Usuario
	LEFT JOIN
		AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
		ON	CE.AccountableCompliance	=	AC.Usuario
	LEFT JOIN
		AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
		ON	CE.Accountable	=	ACC.Usuario
	LEFT JOIN
		CO_ContratoConfiguracion	CC
		ON	C.IdContrato	=	CC.Idcontrato
	WHERE
		cita.NombreContratista LIKE '%SHELL%'


	INSERT INTO #NotificacionesPendYProx
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		Tabla2
	)
	SELECT
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		''
	FROM #NotificacionesProximas 
	ORDER BY Destinatario

	INSERT INTO #NotificacionesPendYProx
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1,
		Tabla2
	)
	SELECT
		Destinatario,
		TipoCorreo,
		Ruta,
		'',
		Tabla1
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
		SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla1 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),1,8000), --+ '</table>' Detalle
		SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla2 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),1,8000), --+ '</table>' Detalle
		1
	FROM
		#NotificacionesPendYProx B
	GROUP BY
		Destinatario,
		TipoCorreo,
		Ruta

/*
-- SEGUNDO CORREO DE PENDIENTES CONTINUACION...
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
		'', --+ '</table>' Detalle
		'<tr><td>' +SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla2 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),8001,7990), --+ '</table>' Detalle
		2
	FROM
		#NotificacionesPendYProx B
	WHERE
		LEN(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla2 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<')) > 8000 
	GROUP BY
		Destinatario,
		TipoCorreo,
		Ruta


-- TERCER CORREO DE PENDIENTES CONTINUACION...
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
		'', --+ '</table>' Detalle
		'<tr><td>' +SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla2 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),15991,7990), --+ '</table>' Detalle
		3
	FROM
		#NotificacionesPendYProx B
	WHERE
		LEN(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla2 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<')) > 15990 
	GROUP BY
		Destinatario,
		TipoCorreo,
		Ruta


-- CUARTO CORREO DE PENDIENTES CONTINUACION...
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
		'', --+ '</table>' Detalle
		'<tr><td>' +SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla2 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),23981,7990), --+ '</table>' Detalle
		4
	FROM
		#NotificacionesPendYProx B
	WHERE
		LEN(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla2 FROM #NotificacionesPendYProx A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<')) > 23980 
	GROUP BY
		Destinatario,
		TipoCorreo,
		Ruta

	-- SE CAMBIA EL TIPO DE CORREO
	UPDATE #NotificacionesFinales
	SET	TipoCorreo = TipoCorreo + ' (Continuacion)'
	WHERE NumCorreo > 1
*/

	-- SE BORRA LA TABLA PARA REUTILIZAR CON LOS ACCOUNTABLE
	DELETE FROM #NotificacionesProximas
    --================================ NOTIFICACIONES A ACCOUNTABLE (LO QUE VENCE EN LOS SIGUIENTES 7 DIAS)==============================================
	INSERT INTO #NotificacionesProximas
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1
	)
	SELECT
		CE.Accountable,
		'Notificación Semanal para Accountable JOA'   AS tipoCorreo,
		'https://'+ruta.Ruta+'/2/JOAs/EntregablesAdministradorContratoJOAs.aspx' AS RutaPendiente,
		'<tr><td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		--'<tr><td>' + LTRIM(IE.idInstanciaEntregable) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>' + LTRIM(RTRIM(E.Inciso)) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ LTRIM(CLA.NombreClasificacion) + '</td>'+
		'<td'+ 	CASE
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) = 7 THEN ' style="background-color:#8cd98c;">7 days remainig'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 4 and 6 THEN ' style="background-color:#ffdd99;">4-6 days remaining'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 1 and 3 THEN ' style="background-color:Tomato;">1-3 days remaining'
		END	 + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
		'<td>'+ CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
			ELSE ISNULL(ACC.Nombre,'')  -- ACCOUNTABLE
		END	+ '</td>'  + 
		'<td>'+ U1.Nombre 	+ '</td>'  +	-- RESPONSBILE
		'<td>'+ CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
			ELSE ISNULL(AC.Nombre,'')	-- ACCOUNTABLE COMPLIANCE
		END		+ '</td>'  + 
		'<td>' +CA.NombreContratista+ '</td>'	AS Tabla
    FROM
		CO_Contrato	C	(NOLOCK)
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON	c.IdContratista	=	cita.IdContratista
		AND cita.NombreContratista LIKE '%SHELL%'
	JOIN
		dbo.EN_ContratoEntregable   CE	(NOLOCK)
		ON	C.IdContrato	=	CE.IdContrato
		AND CE.Activo = 1 
		AND ISNULL(CE.Accountable,'')	<> ''
	JOIN
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
		ON CE.IdContratoEntregable = IE.IdContratoEntregable
		AND	IE.FechaCalculadaEntregaReg	BETWEEN @HOY AND DATEADD(DAY,7,@HOY)
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
		AND E.BITJOA = 1
		AND E.IsActivo = 1
	JOIN
		En_Clasificacion		CLA
		ON E.IdClasificacion	=	CLA.IdClasificacion
	JOIN
        dbo.AP_Usuario              U1	(NOLOCK)
        ON A.idUsuario = U1.UsuarioID
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
	JOIN
		CO_ContratoSocio	CS
		ON CE.IdContrato	=	CS.IdContrato
	JOIN 
		CO_Contratista	CA
		ON CS.IdContratistaSocio	=	CA.IdContratista
	LEFT JOIN
		EN_MarcoLegal	ML
		ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
	LEFT JOIN
		AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
		ON	CE.AccountableCompliance	=	AC.Usuario
	LEFT JOIN
		AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
		ON	CE.Accountable	=	ACC.Usuario
	LEFT JOIN
		CO_ContratoConfiguracion	CC
		ON	C.IdContrato	=	CC.Idcontrato
	WHERE
		cita.NombreContratista LIKE '%SHELL%'
	GROUP BY
		CE.Accountable,
		ruta.Ruta,
		'<tr><td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		'<td>' + LTRIM(RTRIM(E.Inciso)) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ LTRIM(CLA.NombreClasificacion) + '</td>'+
		'<td'+ 	CASE
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) = 7 THEN ' style="background-color:#8cd98c;">7 days remainig'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 4 and 6 THEN ' style="background-color:#ffdd99;">4-6 days remaining'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 1 and 3 THEN ' style="background-color:Tomato;">1-3 days remaining'
		END	 + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
		'<td>'+ CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
			ELSE ISNULL(ACC.Nombre,'')  -- ACCOUNTABLE
		END	+ '</td>'  + 
		'<td>'+ U1.Nombre 	+ '</td>'  +	-- RESPONSBILE
		'<td>'+ CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
			ELSE ISNULL(AC.Nombre,'')	-- ACCOUNTABLE COMPLIANCE
		END		+ '</td>'  + 
		'<td>' +CA.NombreContratista+ '</td>'


	-- SE JUNTAN TODOS LOS ENTREGABLES POR DESTINATARIO-FUNCION
	INSERT INTO #NotificacionesFinales
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		TablaProximas,
		NumCorreo
	)
	SELECT
		Destinatario,
		TipoCorreo,
		Ruta,
		SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla1 FROM #NotificacionesProximas A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),1,8000), --+ '</table>' Detalle
		1
	FROM
		#NotificacionesProximas B
	GROUP BY
		Destinatario,
		TipoCorreo,
		Ruta

	-- SE BORRA LA TABLA PARA REUTILIZAR CON LOS ACCOUNTABLE COMPLIANCE
	DELETE FROM #NotificacionesProximas


    --================================ NOTIFICACIONES A ACCOUNTABLE COMPLIANCE ==============================================
	INSERT INTO #NotificacionesProximas
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla1
	)
	SELECT
		CE.AccountableCompliance,
		'Notificación Semanal para AccountableCompliance JOA'   AS tipoCorreo,
		'https://'+ruta.Ruta+'/2/JOAs/EntregablesAdministradorContratoJOAs.aspx' AS RutaPendiente,
		'<tr><td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		--'<tr><td>' + LTRIM(IE.idInstanciaEntregable) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>' + LTRIM(RTRIM(E.Inciso)) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ LTRIM(CLA.NombreClasificacion) + '</td>'+
		'<td'+ 	CASE
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) = 7 THEN ' style="background-color:#8cd98c;">7 days remainig'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 4 and 6 THEN ' style="background-color:#ffdd99;">4-6 days remaining'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 1 and 3 THEN ' style="background-color:Tomato;">1-3 days remaining'
		END	 + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
		'<td>'+ CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
			ELSE ISNULL(ACC.Nombre,'')  -- ACCOUNTABLE
		END	+ '</td>'  + 
		'<td>'+ U1.Nombre 	+ '</td>'  +	-- RESPONSBILE
		'<td>'+ CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
			ELSE ISNULL(AC.Nombre,'')	-- ACCOUNTABLE COMPLIANCE
		END		+ '</td>'  + 
		'<td>' +CA.NombreContratista+ '</td>' AS Tabla
    FROM
		CO_Contrato	C	(NOLOCK)
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON	c.IdContratista	=	cita.IdContratista
		AND cita.NombreContratista LIKE '%SHELL%'
	JOIN
		dbo.EN_ContratoEntregable   CE	(NOLOCK)
		ON	C.IdContrato	=	CE.IdContrato
		AND CE.Activo = 1 
		AND ISNULL(CE.AccountableCompliance,'')	<> ''
	JOIN
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
		ON CE.IdContratoEntregable = IE.IdContratoEntregable
		AND	IE.FechaCalculadaEntregaReg	BETWEEN @HOY AND DATEADD(DAY,7,@HOY)
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
		AND E.BITJOA = 1
		AND E.IsActivo = 1
	JOIN
		En_Clasificacion		CLA
		ON E.IdClasificacion	=	CLA.IdClasificacion
	JOIN
        dbo.AP_Usuario              U1	(NOLOCK)
        ON A.idUsuario = U1.UsuarioID
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
	JOIN
		CO_ContratoSocio	CS
		ON CE.IdContrato	=	CS.IdContrato
	JOIN 
		CO_Contratista	CA
		ON CS.IdContratistaSocio	=	CA.IdContratista
	LEFT JOIN
		EN_MarcoLegal	ML
		ON E.IdMarcoLegal	=	ML.IdMarcoLegal
	LEFT JOIN
		AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
		ON	CE.AccountableCompliance	=	AC.Usuario
	LEFT JOIN
		AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
		ON	CE.Accountable	=	ACC.Usuario
	LEFT JOIN
		CO_ContratoConfiguracion	CC
		ON	C.IdContrato	=	CC.Idcontrato
	WHERE
		cita.NombreContratista LIKE '%SHELL%'
	GROUP BY
		CE.AccountableCompliance,
		ruta.Ruta,
		'<tr><td>' + LTRIM(ML.MarcoLegal) + '</td>'+
		'<td>' + LTRIM(RTRIM(E.Inciso)) + '-' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
		'<td>'+ LTRIM(CLA.NombreClasificacion) + '</td>'+
		'<td'+ 	CASE
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) = 7 THEN ' style="background-color:#8cd98c;">7 days remainig'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 4 and 6 THEN ' style="background-color:#ffdd99;">4-6 days remaining'
		WHEN DATEDIFF(DAY, GETDATE(),IE.FechaCalculadaEntregaReg) BETWEEN 1 and 3 THEN ' style="background-color:Tomato;">1-3 days remaining'
		END	 + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
		'<td>'+ CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
			ELSE ISNULL(ACC.Nombre,'')  -- ACCOUNTABLE
		END	+ '</td>'  + 
		'<td>'+ U1.Nombre 	+ '</td>'  +	-- RESPONSBILE
		'<td>'+ CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
			ELSE ISNULL(AC.Nombre,'')	-- ACCOUNTABLE COMPLIANCE
		END		+ '</td>'  + 
		'<td>' +CA.NombreContratista+ '</td>'


	-- SE JUNTAN TODOS LOS ENTREGABLES POR DESTINATARIO-FUNCION
	INSERT INTO #NotificacionesFinales
	(
		Destinatario,
		TipoCorreo,
		Ruta,
		TablaProximas,
		NumCorreo
	)
	SELECT
		Destinatario,
		TipoCorreo,
		Ruta,
		SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla1 FROM #NotificacionesProximas A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),1,8000), --+ '</table>' Detalle
		1
	FROM
		#NotificacionesProximas B
	GROUP BY
		Destinatario,
		TipoCorreo,
		Ruta

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

/*************************************************/
-- select * from #NotificacionesFinales order by id

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
--		'barbara.arranaga@adinco.mx', 
		Destinatario,						-- Para
		REPLACE(C.Asunto,'##num##', LTRIM(N.NumCorreo)),
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.HTML,'##NOMBRE_USUARIO##', N.NombreDestinatario),'{tablaEntregables}',isnull(N.TablaProximas,'')),'{tablaPendientes}',isnull(N.TablaPendientes,'')),'##ENLACE_DETALLE##',N.Ruta),'##numcorreo##',LTRIM(N.NumCorreo)),
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