CREATE PROCEDURE dbo.sp_EN_NotificacionesDiarias_Equinor
AS
BEGIN
-- =============================================
-- Modulo:		Notificaciones de Entregables
-- Create date: 20200405
-- Description:	Envio de correos a elaboradores, revisores y aprobadores de los entregables pendientes y proximos (7 días)
-- =============================================
-- 20200405	BAAC	Creación de sp
-- =============================================
SET NOCOUNT ON
-- SE DESHABILITAN EL ENVIO DE NOTIFICACIONES A EQUINOR 20211007
RETURN

CREATE TABLE #Notificaciones
(
	NombreDestinatario	VARCHAR(250),
	Destinatario		VARCHAR(250),
	TipoCorreo			VARCHAR(250),
	Tabla				VARCHAR(8000),
	Ruta				VARCHAR(500)
)

CREATE TABLE #NotificacionesFinales
(
	ID	INT IDENTITY(1,1),
	NombreDestinatario	VARCHAR(250),
	Destinatario		VARCHAR(250),
	TipoCorreo			VARCHAR(250),
	Ruta				VARCHAR(500),
	Tabla				VARCHAR(8000),
	NumCorreo			INT
)

DECLARE
	@HOY DATE,
	@MaxNotificacion	INT = 0

    SET @HOY = GETDATE()

        --================================PENDIENTES DE ELABORACION========================================================
    INSERT INTO #Notificaciones
	(
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Tabla,
		Ruta
	)
	SELECT
        U1.Nombre,
        U1.Usuario,
        'Notificación Semanal Elaborador',
		'<tr><td>' + E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable) + '</td>' +
		'<td' +	CASE WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
		END	 + '</td>'+
		'<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
		'<td>'+C.NumeroContrato+ '</td>'												AS	Tabla,
		'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente
    FROM
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
		ON	IE.ActividadID	=	A.ActividadID  --Donde se encuentra PENDIENTE DE ELBARORACION
		AND	A.EstadoID = 10000
		AND DATEADD(DAY, 1, IE.FechasLimiteElaboracion) <=  DATEADD(DAY,7,@HOY)
		AND IE.Activo=1
    JOIN
        dbo.AP_Usuario              U1	(NOLOCK)
		ON A.idUsuario = U1.UsuarioID --- PENDIENTE DE ELABORACIÓN
    JOIN
        dbo.EN_ContratoEntregable   CE	(NOLOCK)
		ON IE.IdContratoEntregable= CE.IdContratoEntregable
		AND CE.Activo=1
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
        ON CE.IdEntregable= E.IdEntregable
		AND	E.IsActivo	=	1
		AND E.BITJOA = 0
	JOIN
		CO_Contrato C	(NOLOCK)
		ON CE.IdContrato=C.IdContrato			-- 20201020 se cambia la fecha a petición de Flor para que no lleguen las notificaciones de los entregables pra hacer un borron y cuenta nueva
		AND DATEADD(DAY, 1, IE.FechasLimiteElaboracion) > '20200930'	--ISNULL(C.FechaArranqueEntregables,'20190101')
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON c.IdContratista=cita.IdContratista
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
    WHERE
		cita.NombreContratista  LIKE '%EQUINOR%'
	ORDER BY
		C.NumeroContrato,
		IE.FechaCalculadaEntregaReg

        --================================PENDIENTES DE REVISION============================================================
	INSERT INTO #Notificaciones
	(
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Tabla,
		Ruta
	)
    SELECT
		U1.Nombre,
		U1.Usuario,
		'Notificación Semanal Revisor',
		'<tr><td>' + E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable) + '</td>' +
		'<td' +	CASE WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
		END	 + '</td>'+
		'<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
		'<td>'+C.NumeroContrato+ '</td>'												AS Tabla,
		'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente
	FROM
		dbo.EN_InstanciasEntregable IE	(NOLOCK)
	JOIN
		dbo.EN_Actividad            A	(NOLOCK)
		ON	IE.ActividadID	=	A.ActividadID   --Dnde se encuentra PENDIENTE DE REVISIÓN
		AND	A.EstadoID = 10001
		AND DATEADD(DAY, 1, IE.FechasLimiteRevision) <=  DATEADD(DAY,7,@HOY)
		AND IE.Activo=1
	JOIN
		dbo.AP_Usuario              U1	(NOLOCK)
		ON  A.idUsuario= U1.UsuarioID --- PENDIENTE DE REVISIÓN
	JOIN
		dbo.EN_ContratoEntregable   CE	(NOLOCK)
		ON IE.IdContratoEntregable	=	CE.IdContratoEntregable 
		AND CE.Activo=1 
	JOIN
		dbo.EN_Entregable           E	(NOLOCK)
		ON CE.IdEntregable	=	E.IdEntregable
		AND	E.IsActivo	=	1
		AND E.BITJOA = 0
	JOIN
		CO_Contrato C	(NOLOCK)
		ON CE.IdContrato=C.IdContrato
		AND DATEADD(DAY, 1, IE.FechasLimiteRevision) > '20200930'	--ISNULL(C.FechaArranqueEntregables,'20190101')
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON c.IdContratista=cita.IdContratista
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
    WHERE
		cita.NombreContratista  LIKE '%EQUINOR%'
	ORDER BY
		C.NumeroContrato,
		IE.FechaCalculadaEntregaReg

     --================================PENDIENTES DE APROBACION===========================================================
	 INSERT INTO #Notificaciones
	(
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Tabla,
		Ruta
	)
    SELECT
        U1.Nombre,
        U1.Usuario,
		'Notificación Semanal Aprobador',
        '<tr><td>' + E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable) + '</td>' +
		'<td' +	CASE WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
		END	 + '</td>'+
		'<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
		'<td>'+C.NumeroContrato+ '</td>'												AS Tabla,
		'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente
    FROM
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
        ON IE.ActividadID =	A.ActividadID --Donde se encuentra PENDIENTE DE APROBACIÓN
		AND A.EstadoID = 10002
		AND DATEADD(DAY, 1, IE.FechasLimiteAprobacion) <=  DATEADD(DAY,7,@HOY)
		AND IE.Activo=1
    JOIN
        dbo.AP_Usuario              U1	(NOLOCK)
		ON A.idUsuario =	U1.UsuarioID--- PENDIENTE DE APROBACIÓN
    JOIN
        dbo.EN_ContratoEntregable   CE	(NOLOCK)
		ON IE.IdContratoEntregable	=	CE.IdContratoEntregable
		AND CE.Activo	=	1 
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
		ON  CE.IdEntregable=E.IdEntregable
		AND	E.IsActivo	=	1
		AND E.BITJOA = 0
	JOIN
		CO_Contrato C	(NOLOCK)
		on CE.IdContrato	=	C.IdContrato
		AND DATEADD(DAY, 1, IE.FechasLimiteAprobacion) > '20200930'	--ISNULL(C.FechaArranqueEntregables,'20190101')
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON c.IdContratista	=	cita.IdContratista
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta	=	ruta.idRuta
    WHERE
		cita.NombreContratista  LIKE '%EQUINOR%'
	ORDER BY
		C.NumeroContrato,
		IE.FechaCalculadaEntregaReg

--================================ NOTIFICACIONES PARA ALERTA EXTRA ===========================================================
	 INSERT INTO #Notificaciones
	(
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Tabla,
		Ruta
	)
	SELECT
        'Receptor de Alerta',
        CE.ReceptorAlerta,
        'Notificación Semanal Alerta Extra',
		'<tr><td>' + E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable) + '</td>' +
		'<td>' + CASE WHEN A.EstadoID = 10000 THEN 'En Elaboración'
			WHEN A.EstadoID = 10001 THEN 'En Revisión'
			WHEN A.EstadoID = 10002 THEN 'En Aprobación'
		END  + '</td>'+
		'<td>' + dbo.fnGetElaboradoresEntregable(CE.IdContratoEntregable) + '</td>' +
		'<td>' + dbo.fnGetRevisoresEntregable (CE.IdContratoEntregable) + '</td>' +
		'<td>' + dbo.fnGetAprobadoresEntregable(CE.IdContratoEntregable) + '</td>' +
		'<td' +	CASE WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
		END	 + '</td>'+
		'<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
		'<td>'+C.NumeroContrato+ '</td>'												AS	Tabla,
		'https://'+ruta.Ruta+'/2/Entregables/EntregablesAdministradorContrato.aspx' AS RutaPendiente
    FROM
        dbo.EN_InstanciasEntregable IE	(NOLOCK)
    JOIN
        dbo.EN_Actividad            A	(NOLOCK)
		ON	IE.ActividadID	=	A.ActividadID  --Donde se encuentra PENDIENTE 
		AND	A.EstadoID <> 10003
		AND DATEADD(DAY, 1, IE.FechasLimiteElaboracion) <=  DATEADD(DAY,7,@HOY)
		AND IE.Activo=1
    JOIN
        dbo.EN_ContratoEntregable   CE	(NOLOCK)
		ON IE.IdContratoEntregable= CE.IdContratoEntregable
		AND CE.Activo=1
	JOIN
		CO_Contrato C	(NOLOCK)
		ON CE.IdContrato=C.IdContrato
		AND DATEADD(DAY, 1, IE.FechasLimiteElaboracion) > '20200930'	--ISNULL(C.FechaArranqueEntregables,'20190101')
    JOIN
        dbo.EN_Entregable           E	(NOLOCK)
        ON CE.IdEntregable= E.IdEntregable
		AND	E.IsActivo	=	1
		AND E.BITJOA = 0
	JOIN
		dbo.CO_Contratista cita	(NOLOCK)
		ON c.IdContratista=cita.IdContratista
	JOIN
		dbo.AP_Rutas ruta	(NOLOCK)
		ON cita.IdRuta=ruta.idRuta
    WHERE
		cita.NombreContratista  LIKE '%EQUINOR%'
		AND
		ISNULL(CE.ReceptorAlerta,'')	<> ''
	ORDER BY
		C.NumeroContrato,
		IE.FechaCalculadaEntregaReg


	INSERT INTO #NotificacionesFinales
	(
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla,
		NumCorreo
	)
	SELECT
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta,
		SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla FROM #Notificaciones A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),1,8000), --+ '</table>' Detalle
		1
	FROM
		#Notificaciones B
	GROUP BY
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta

	INSERT INTO #NotificacionesFinales
	(
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla,
		NumCorreo
	)
	SELECT
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta,
		'<tr><td>' +SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla FROM #Notificaciones A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),8001,7990), --+ '</table>' Detalle
		2
	FROM
		#Notificaciones B
	WHERE
		LEN(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla FROM #Notificaciones A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<')) > 8000
	GROUP BY
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta

	INSERT INTO #NotificacionesFinales
	(
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla,
		NumCorreo
	)
	SELECT
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta,
		'<tr><td>' +SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla FROM #Notificaciones A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),15991,7990), --+ '</table>' Detalle
		3
	FROM
		#Notificaciones B
	WHERE
		LEN(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla FROM #Notificaciones A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<')) > 15990
	GROUP BY
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta

	INSERT INTO #NotificacionesFinales
	(
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta,
		Tabla,
		NumCorreo
	)
	SELECT
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta,
		'<tr><td>' +SUBSTRING(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla FROM #Notificaciones A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<'),23981,7990), --+ '</table>' Detalle
		4
	FROM
		#Notificaciones B
	WHERE
		LEN(REPLACE(REPLACE(REPLACE(STUFF(( SELECT  ''+ Tabla FROM #Notificaciones A
				WHERE B.Destinatario = A.Destinatario AND B.TipoCorreo = A.TipoCorreo AND B.Ruta = A.Ruta FOR XML PATH('')),1 ,1, ''),'&lt;','<'),'&gt;','>'),'lt;','<')) > 23980
	GROUP BY
		NombreDestinatario,
		Destinatario,
		TipoCorreo,
		Ruta

--SELECT * FROM #NotificacionesFinales

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
		REPLACE(Destinatario,',',';'),						-- Para
		CASE WHEN N.NumCorreo = 1 THEN C.Asunto
			ELSE C.Asunto + ' Continuación ' +  LTRIM(N.NumCorreo)
		END	AS	Asunto,
		REPLACE(REPLACE(REPLACE(REPLACE(C.HTML,'##NOMBRE_USUARIO##', N.NombreDestinatario),'{tablaEntregables}', isnull(N.Tabla,'')),'##ENLACE_DETALLE##',N.Ruta),'##numcorreo##',LTRIM(N.NumCorreo)),
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
	ORDER BY
		REPLACE(Destinatario,',',';'),
		NumCorreo
END
