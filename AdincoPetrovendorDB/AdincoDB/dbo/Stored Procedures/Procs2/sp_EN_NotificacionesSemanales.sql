CREATE PROCEDURE dbo.sp_EN_NotificacionesSemanales
AS
BEGIN
-- =============================================
-- Modulo:      Notificaciones de Entregables
-- Create date: 20200405
-- Description: Envio de correos a elaboradores, revisores y aprobadores de los entregables pendientes y proximos (7 días)
-- =============================================
-- 20200405 BAAC    Creación de sp
-- =============================================
SET NOCOUNT ON

--DROP TABLE #Notificaciones
--DROP TABLE #NotificacionesFinales

CREATE TABLE #Notificaciones--*
(
    NombreDestinatario  VARCHAR(250),
    Destinatario        VARCHAR(250),
    TipoCorreo          VARCHAR(250),
    Tabla               VARCHAR(MAX),
    Ruta                VARCHAR(500),
	IsGrupo				BIT,
	IdContrato			INT,
	IdUsuario			INT
)

CREATE TABLE #NotificacionesFinales
(
    ID  INT IDENTITY(1,1),
    NombreDestinatario  VARCHAR(250),
    Destinatario        VARCHAR(250),
    TipoCorreo          VARCHAR(250),
    Ruta                VARCHAR(500),
    Tabla               VARCHAR(MAX),
    NumCorreo           INT
)

DECLARE
    @HOY DATE,
    @MaxNotificacion    INT = 0

    SET @HOY = GETDATE()

        --================================PENDIENTES DE ELABORACION========================================================

    INSERT INTO #Notificaciones
    (
        NombreDestinatario,
        Destinatario,
        TipoCorreo,
        Tabla,
        Ruta,
		IsGrupo,
		IdContrato,
		IdUsuario
    )
    SELECT
        U1.Nombre,
        U1.Usuario,
        'Notificación Semanal Elaborador',
        '<tr><td>' + E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable) + '</td>' +
        '<td' + CASE WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
        END  + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
        '<td>'+C.NumeroContrato+ '</td>'                                                AS  Tabla,
        'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente,
		ISNULL(u1.IsGrupo,0),
		CE.IdContrato,
		A.idUsuario
    FROM
        dbo.EN_InstanciasEntregable IE  (NOLOCK)
    JOIN
        dbo.EN_Actividad            A   (NOLOCK)
        ON  IE.ActividadID  =   A.ActividadID  --Donde se encuentra PENDIENTE DE ELBARORACION
        AND A.EstadoID = 10000
        AND DATEADD(DAY, 1, IE.FechasLimiteElaboracion) <=  DATEADD(DAY,7,@HOY)
        AND IE.Activo=1
    JOIN
        dbo.AP_Usuario              U1  (NOLOCK)
        ON A.idUsuario = U1.UsuarioID --- PENDIENTE DE ELABORACIÓN
		AND U1.IsActivo = 1
    JOIN
        dbo.EN_ContratoEntregable   CE  (NOLOCK)
        ON IE.IdContratoEntregable= CE.IdContratoEntregable
        AND CE.Activo=1
    JOIN
        dbo.EN_Entregable           E   (NOLOCK)
        ON CE.IdEntregable= E.IdEntregable
        AND E.IsActivo  =   1
        AND E.BITJOA = 0
    JOIN
        CO_Contrato C   (NOLOCK)
        ON CE.IdContrato=C.IdContrato
        AND DATEADD(DAY, 1, IE.FechasLimiteElaboracion) > ISNULL(C.FechaArranqueEntregables,'20190101')
    JOIN
        dbo.CO_Contratista cita (NOLOCK)
		ON c.IdContratista=cita.IdContratista
    JOIN
        dbo.AP_Rutas ruta   (NOLOCK)
        ON cita.IdRuta=ruta.idRuta
    WHERE
        cita.NombreContratista NOT LIKE '%SHELL%'
        AND cita.NombreContratista NOT LIKE '%BP%'
        AND cita.NombreContratista NOT LIKE '%REPSOL%'
        AND cita.NombreContratista NOT LIKE '%MURPHY%'
        AND cita.NombreContratista NOT LIKE '%Wintershall%'
		AND cita.NombreContratista NOT LIKE '%ENI%'
		AND cita.NombreContratista NOT LIKE '%EQUINOR%'
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
        Ruta,
		IsGrupo,
		IdContrato,
		IdUsuario
    )
    SELECT
        U1.Nombre,
        U1.Usuario,
        'Notificación Semanal Revisor',
        '<tr><td>' + E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable) + '</td>' +
        '<td' + CASE WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
        END  + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
        '<td>'+C.NumeroContrato+ '</td>'                                                AS Tabla,
        'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente,
		ISNULL(u1.IsGrupo,0),
		CE.IdContrato,
		A.idUsuario
    FROM
        dbo.EN_InstanciasEntregable IE  (NOLOCK)
    JOIN
        dbo.EN_Actividad            A   (NOLOCK)
        ON  IE.ActividadID  =   A.ActividadID   --Dnde se encuentra PENDIENTE DE REVISIÓN
        AND A.EstadoID = 10001
        AND DATEADD(DAY, 1, IE.FechasLimiteRevision) <=  DATEADD(DAY,7,@HOY)
        AND IE.Activo=1
    JOIN
        dbo.AP_Usuario              U1  (NOLOCK)
        ON  A.idUsuario= U1.UsuarioID --- PENDIENTE DE REVISIÓN
		AND U1.IsActivo = 1
    JOIN
        dbo.EN_ContratoEntregable   CE  (NOLOCK)
        ON IE.IdContratoEntregable  =   CE.IdContratoEntregable 
        AND CE.Activo=1 
    JOIN
        dbo.EN_Entregable           E   (NOLOCK)
        ON CE.IdEntregable  =   E.IdEntregable
        AND E.IsActivo  =   1
        AND E.BITJOA = 0
    JOIN
        CO_Contrato C   (NOLOCK)
        ON CE.IdContrato=C.IdContrato
        AND DATEADD(DAY, 1, IE.FechasLimiteRevision) > ISNULL(C.FechaArranqueEntregables,'20190101')
    JOIN
        dbo.CO_Contratista cita (NOLOCK)
        ON c.IdContratista=cita.IdContratista
    JOIN
        dbo.AP_Rutas ruta   (NOLOCK)
        ON cita.IdRuta=ruta.idRuta
    WHERE
        cita.NombreContratista NOT LIKE '%SHELL%'
        AND cita.NombreContratista NOT LIKE '%BP%'
        AND cita.NombreContratista NOT LIKE '%REPSOL%'
        AND cita.NombreContratista NOT LIKE '%MURPHY%'
        AND cita.NombreContratista NOT LIKE '%Wintershall%'
		AND cita.NombreContratista NOT LIKE '%ENI%'
		AND cita.NombreContratista NOT LIKE '%EQUINOR%'
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
        Ruta,
		IsGrupo,
		IdContrato,
		IdUsuario
    )
    SELECT
        U1.Nombre,
        U1.Usuario,
        'Notificación Semanal Aprobador',
        '<tr><td>' + E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable) + '</td>' +
        '<td' + CASE WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
        END  + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
        '<td>'+C.NumeroContrato+ '</td>'                                                AS Tabla,
        'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente,
		ISNULL(u1.IsGrupo,0),
		CE.IdContrato,
		A.idUsuario
    FROM
        dbo.EN_InstanciasEntregable IE  (NOLOCK)
    JOIN
        dbo.EN_Actividad            A   (NOLOCK)
        ON IE.ActividadID = A.ActividadID --Donde se encuentra PENDIENTE DE APROBACIÓN
        AND A.EstadoID = 10002
        AND DATEADD(DAY, 1, IE.FechasLimiteAprobacion) <=  DATEADD(DAY,7,@HOY)
        AND IE.Activo=1
    JOIN
        dbo.AP_Usuario              U1  (NOLOCK)
        ON A.idUsuario =    U1.UsuarioID--- PENDIENTE DE APROBACIÓN
		AND U1.IsActivo = 1
    JOIN
        dbo.EN_ContratoEntregable   CE  (NOLOCK)
        ON IE.IdContratoEntregable  =   CE.IdContratoEntregable
        AND CE.Activo   =   1 
    JOIN
        dbo.EN_Entregable           E   (NOLOCK)
        ON  CE.IdEntregable=E.IdEntregable
        AND E.IsActivo  =   1
        AND E.BITJOA = 0
    JOIN
        CO_Contrato C   (NOLOCK)
        on CE.IdContrato    =   C.IdContrato
        AND DATEADD(DAY, 1, IE.FechasLimiteAprobacion) > ISNULL(C.FechaArranqueEntregables,'20190101')
    JOIN
        dbo.CO_Contratista cita (NOLOCK)
        ON c.IdContratista  =   cita.IdContratista
    JOIN
        dbo.AP_Rutas ruta   (NOLOCK)
        ON cita.IdRuta  =   ruta.idRuta
    WHERE
        cita.NombreContratista NOT LIKE '%SHELL%'
        AND cita.NombreContratista NOT LIKE '%BP%'
        AND cita.NombreContratista NOT LIKE '%REPSOL%'
        AND cita.NombreContratista NOT LIKE '%MURPHY%'
        AND cita.NombreContratista NOT LIKE '%Wintershall%'
		AND cita.NombreContratista NOT LIKE '%ENI%'
		AND cita.NombreContratista NOT LIKE '%EQUINOR%'
    ORDER BY
        C.NumeroContrato,
        IE.FechaCalculadaEntregaReg

    --================================NOTIFICACIONES GRUPOS===========================================================*
	INSERT INTO #Notificaciones
    (
        NombreDestinatario,
        Destinatario,
        TipoCorreo,
        Tabla,
        Ruta,
		IsGrupo,
		IdContrato,
		IdUsuario
    )
	SELECT 
		UG.Nombre,
		UG.Usuario,
		N.TipoCorreo,
		N.Tabla,
		N.Ruta,
		ISNULL(UG.IsGrupo,0),
		N.IdContrato,
		GU.IdUsuario
	FROM
		#Notificaciones N
	JOIN 
		EN_GruposUsuarios GU
		ON	N.IdUsuario	=	GU.IdGrupo
		AND	N.IdContrato	=	GU.IdContrato
		AND N.IsGrupo	=	1
	JOIN 
		AP_Usuario AS UG
		ON	GU.IdUsuario	=	UG.UsuarioID
		AND UG.IsActivo = 1
	
	--================================NOTIFICACIONES FINALES===========================================================*

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
		
		WHERE ISNULL(B.IsGrupo,0) = 0
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
	
	AND ISNULL(B.IsGrupo,0) = 0
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

		AND ISNULL(B.IsGrupo,0) = 0
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

		AND ISNULL(B.IsGrupo,0) = 0
    GROUP BY
        NombreDestinatario,
        Destinatario,
        TipoCorreo,
    Ruta


--================================S_NOTIFICACIÓN===========================================================
--select * from #NotificacionesFinales
	
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
        ISNULL(@MaxNotificacion,0) + ID,    -- IdNotificacion
        Destinatario,                       -- Para
        CASE WHEN N.NumCorreo = 1 THEN C.Asunto
            ELSE C.Asunto + ' Continuación ' +  LTRIM(N.NumCorreo)
        END AS  Asunto,
        REPLACE(REPLACE(REPLACE(REPLACE(C.HTML,'##NOMBRE_USUARIO##', N.NombreDestinatario),'{tablaEntregables}', isnull(N.Tabla,'')),'##ENLACE_DETALLE##',N.Ruta),'##numcorreo##',LTRIM(N.NumCorreo)),
        GETDATE(),
        0,
        1,
        GETDATE(),
        'notificaciones@adinco.mx',
        0
    FROM
        #NotificacionesFinales  N
    JOIN
        TA_Correo   C
        ON  N.TipoCorreo    =   C.Descripcion
    ORDER BY
        Destinatario,
        NumCorreo
END
