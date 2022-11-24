--==============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Crea Alertas 
-- =============================================
-- 24/11/2021 MC quitar prints ISSUE 383 adincopetrodb se añade (NOLOCK)
-- =============================================
CREATE PROCEDURE [dbo].[sp_ExtraeDatosAlertasInstancias]
AS
    BEGIN
        DECLARE @HOY DATE;
        SET @HOY = GETDATE();

		
        --================================PENDIENTES DE ELABORACION========================================================
		
       SELECT
                IE.idInstanciaEntregable,
                IE.FechasLimiteAprobacion                                                        AS periodo,
                IE.FechasLimiteElaboracion                                                       AS FECHALIMITEACCION,
                A.ActividadID,
                A.EstadoID,
                U1.Nombre,
                U1.UsuarioID,
                U1.Usuario                                                                       AS Para,
                E1.NombreEstado                                                                  AS EstadoActual,
                ASI.ActividadID                                                                  AS ActividadSiguiente,
                ASI.EstadoID                                                                     AS IDEstadoSiguiente,
                U2.Nombre                                                                        NombreSiguiente,
                U2.UsuarioID                                                                     UsuarioIDSiguiente,
                U2.Usuario                                                                       AS ParaSiguiente,
                E2.NombreEstado                                                                  AS EstadoSiguiente,
                CASE E2.EstadoID
                    WHEN 10001
                        THEN IE.FechasLimiteRevision
                    WHEN 10002
                        THEN IE.FechasLimiteAprobacion
                END                                                                              AS FECHALIMITEACCIONSIGUIENTE,
                'Correo Alerta Retardo Elaboración'                                              AS tipoCorreo,
                E.IdEntregable,
                E.DocumentoEntregable +' del contrato '+C.NumeroContrato,
                'que tienes un retardo para llevar acabo la '                                    AS TextoTipoAlertaActual,
                'La fecha limite para llevar acabo la ' + E1.NombreEstado + ' fue: '
                + CONVERT(VARCHAR(50), IE.FechasLimiteElaboracion, 23)                           AS TextoTipoAlertaActual2,
                'que el usuario ' + U1.Nombre + ' ha tenido un retardo en la ' + E1.NombreEstado AS TextoTipoAlertaSiguiente,
                ''                                                                               AS TextoTipoAlertaSiguiente2,
				'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente
        FROM
                dbo.EN_InstanciasEntregable IE (NOLOCK)
            JOIN
                dbo.EN_Actividad            A (NOLOCK)
                    ON IE.ActividadID=A.ActividadID  --Donde se encuentra PENDIENTE DE ELBARORACION
					AND IE.Activo=1
					AND DATEADD(DAY, 1, IE.FechasLimiteElaboracion) <=  @HOY
					AND A.EstadoID = 10000
            JOIN
                dbo.EN_Transicion           T 
                    ON A.ActividadID= T.ActividadInicialID 
                       AND T.AccionID = 10000
            JOIN
                dbo.EN_Actividad            ASI (NOLOCK)
                    ON T.SiguienteActividadID = ASI.ActividadID
            JOIN
                dbo.AP_Usuario              U1 (NOLOCK)
                    ON A.idUsuario = U1.UsuarioID --- PENDIENTE DE ELABORACIÓN
            JOIN
                dbo.AP_Usuario              U2 (NOLOCK)
                    ON ASI.idUsuario=U2.UsuarioID  --- PENDIENTE DE ELABORACIÓN
            JOIN
                dbo.EN_Estado               E1 (NOLOCK)
                    ON  A.EstadoID = E1.EstadoID--En estado que se encuentra la instancia
            JOIN
                dbo.EN_Estado               E2 (NOLOCK)
                    ON  ASI.EstadoID= E2.EstadoID  --En estado que se encuentra la instancia
            JOIN
                dbo.EN_ContratoEntregable   CE (NOLOCK)
                    ON IE.IdContratoEntregable= CE.IdContratoEntregable
					AND CE.Activo=1 
            JOIN
                dbo.EN_Entregable           E (NOLOCK)
                    ON CE.IdEntregable= E.IdEntregable
					AND E.BITJOA = 0
		    JOIN CO_Contrato C (NOLOCK)
			on CE.IdContrato=C.IdContrato
			JOIN dbo.CO_Contratista cita
			ON c.IdContratista=cita.IdContratista
			JOIN dbo.AP_Rutas ruta
			ON cita.IdRuta=ruta.idRuta
        WHERE
				DATEADD(DAY, 1, IE.FechasLimiteElaboracion) > ISNULL(C.FechaArranqueEntregables,'20190101')
				AND cita.NombreContratista NOT LIKE '%SHELL%'
				AND cita.NombreContratista NOT LIKE '%BP%'
				AND cita.NombreContratista NOT LIKE '%REPSOL%'
				AND cita.NombreContratista NOT LIKE '%MURPHY%'
        UNION ALL
        --================================PENDIENTES DE REVISION============================================================
        SELECT
                IE.idInstanciaEntregable,
                IE.FechasLimiteAprobacion                                                        AS periodo,
                IE.FechasLimiteRevision                                                          AS FECHALIMITEACCION,
                A.ActividadID,
                A.EstadoID,
                U1.Nombre,
                U1.UsuarioID,
                U1.Usuario                                                                       AS Para,
                E1.NombreEstado                                                                  AS EstadoActual,
                ASI.ActividadID                                                                  AS ActividadSiguiente,
                ASI.EstadoID                                                                     AS IDEstadoSiguiente,
                U2.Nombre                                                                        NombreSiguiente,
                U2.UsuarioID                                                                     UsuarioIDSiguiente,
                U2.Usuario                                                                       AS ParaSiguiente,
                E2.NombreEstado                                                                  AS EstadoSiguiente,
                CASE E2.EstadoID
                    WHEN 10001
                        THEN IE.FechasLimiteRevision
                    WHEN 10002
                        THEN IE.FechasLimiteAprobacion
                END                                                                              AS FECHALIMITEACCIONSIGUIENTE,
                'Correo Alerta Retardo Revisión'                                                 AS tipoCorreo,
                E.IdEntregable,
                E.DocumentoEntregable +' del contrato '+ C.NumeroContrato,
                'que tienes un retardo para llevar acabo la'                                     AS TextoTipoAlertaActual,
                'La fecha limite para llevar acabo la ' + E1.NombreEstado + ' fue: '
                + CONVERT(VARCHAR(50), IE.FechasLimiteRevision, 23)                              AS TextoTipoAlertaActual2,
                'que el usuario ' + U1.Nombre + ' ha tenido un retardo en la ' + E1.NombreEstado AS TextoTipoAlertaSiguiente,
                ''             AS TextoTipoAlertaSiguiente2,
				'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente
				--SELECT *                                                                    
        FROM
                dbo.EN_InstanciasEntregable IE (NOLOCK)
         JOIN
                dbo.EN_Actividad            A (NOLOCK)
                    ON IE.ActividadID=A.ActividadID   --Donde se encuentra PENDIENTE DE REVISIÓN
					AND A.EstadoID = 10001
					AND DATEADD(DAY, 1, IE.FechasLimiteRevision) <= @HOY
					AND IE.Activo=1
          JOIN
            dbo.EN_Transicion           T (NOLOCK)
               ON A.ActividadID= T.ActividadInicialID 
                       AND T.AccionID = 10001
          JOIN
                dbo.EN_Actividad            ASI (NOLOCK)
                    ON ASI.ActividadID=T.SiguienteActividadID 
          JOIN
                dbo.AP_Usuario              U1 (NOLOCK)
                    ON  A.idUsuario= U1.UsuarioID --- PENDIENTE DE REVISIÓN
          JOIN
                dbo.AP_Usuario              U2 (NOLOCK)
                    ON ASI.idUsuario=U2.UsuarioID  --- PENDIENTE DE REVISIÓN
          JOIN
                dbo.EN_Estado               E1 (NOLOCK)
                    ON A.EstadoID =E1.EstadoID --En estado que se encuentra la instancia
          JOIN
                dbo.EN_Estado               E2 (NOLOCK)
                    ON ASI.EstadoID=E2.EstadoID --En estado que se encuentra la instancia
         JOIN
                dbo.EN_ContratoEntregable   CE (NOLOCK)
                    ON IE.IdContratoEntregable=CE.IdContratoEntregable
					AND CE.Activo=1  
          JOIN
                dbo.EN_Entregable           E (NOLOCK)
                    ON CE.IdEntregable=E.IdEntregable
					AND E.BITJOA = 0
		 JOIN CO_Contrato C (NOLOCK)
			on CE.IdContrato=C.IdContrato
			JOIN dbo.CO_Contratista cita
			ON c.IdContratista=cita.IdContratista
				JOIN dbo.AP_Rutas ruta
			ON cita.IdRuta=ruta.idRuta
        WHERE
				DATEADD(DAY, 1, IE.FechasLimiteRevision) > ISNULL(C.FechaArranqueEntregables,'20190101')
				AND cita.NombreContratista NOT LIKE '%SHELL%'
				AND cita.NombreContratista NOT LIKE '%BP%'
				AND cita.NombreContratista NOT LIKE '%REPSOL%'
				AND cita.NombreContratista NOT LIKE '%MURPHY%'

        UNION ALL
        --================================PENDIENTES DE APROBACION===========================================================
        SELECT
                IE.idInstanciaEntregable,
                IE.FechasLimiteAprobacion                             AS periodo,
                IE.FechasLimiteAprobacion                             AS FECHALIMITEACCION,
                A.ActividadID,
                A.EstadoID,
                U1.Nombre,
                U1.UsuarioID,
                U1.Usuario                                            AS Para,
                E1.NombreEstado                                       AS EstadoActual,
                NULL                                                  AS ActividadSiguiente,
                NULL                                                  AS IDEstadoSiguiente,
                NULL                                                  NombreSiguiente,
                NULL                                                  UsuarioIDSiguiente,
                NULL                                                  AS ParaSiguiente,
                NULL                                                  AS EstadoSiguiente,
                NULL                                                  FECHALIMITEACCIONSIGUIENTE,
                'Correo Alerta Retardo Aprobación'                    AS tipoCorreo,
                E.IdEntregable,
                E.DocumentoEntregable+' del contrato '+ C.NumeroContrato,
                'que tienes un retardo para llevar acabo la '         AS TextoTipoAlertaActual,
                'La fecha limite para llevar acabo la ' + E1.NombreEstado + ' fue: '
                + CONVERT(VARCHAR(50), IE.FechasLimiteAprobacion, 23) AS TextoTipoAlertaActual2,
                ''                                                    AS TextoTipoAlertaSiguiente,
                ''                                                    AS TextoTipoAlertaSiguiente2,
				'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente
        FROM
                dbo.EN_InstanciasEntregable IE (NOLOCK)
            JOIN
                dbo.EN_Actividad            A (NOLOCK)
                    ON IE.ActividadID =A.ActividadID --Donde se encuentra PENDIENTE DE APROBACIÓN
					AND A.EstadoID = 10002
					AND DATEADD(DAY, 1, IE.FechasLimiteAprobacion) <=  @HOY
					AND IE.Activo=1
            JOIN
                dbo.EN_Transicion           T (NOLOCK)
                ON A.ActividadID=T.ActividadInicialID 
                       AND T.AccionID = 10001
         JOIN
                dbo.EN_Actividad            ASI (NOLOCK)
                    ON T.SiguienteActividadID = ASI.ActividadID ----*********
            JOIN
                dbo.AP_Usuario              U1 (NOLOCK)
                    ON A.idUsuario =U1.UsuarioID--- PENDIENTE DE APROBACIÓN
            JOIN
                dbo.AP_Usuario              U2 (NOLOCK)
                    ON  ASI.idUsuario=U2.UsuarioID  --- PENDIENTE DE APROBACIÓN --*********
            JOIN
                dbo.EN_Estado               E1 (NOLOCK)
                    ON A.EstadoID=E1.EstadoID  --En estado que se encuentra la instancia
            JOIN
                dbo.EN_Estado               E2 (NOLOCK)
                    ON  ASI.EstadoID=E2.EstadoID --En estado que se encuentra la instancia--*********
            JOIN
                dbo.EN_ContratoEntregable   CE (NOLOCK)
                    ON IE.IdContratoEntregable=CE.IdContratoEntregable
					AND CE.Activo=1 
            JOIN
                dbo.EN_Entregable           E (NOLOCK)
                    ON  CE.IdEntregable=E.IdEntregable
					AND E.BITJOA = 0
			JOIN CO_Contrato C (NOLOCK)
			on CE.IdContrato=C.IdContrato
			JOIN dbo.CO_Contratista cita
			ON c.IdContratista=cita.IdContratista
				JOIN dbo.AP_Rutas ruta
			ON cita.IdRuta=ruta.idRuta
        WHERE
				DATEADD(DAY, 1, IE.FechasLimiteAprobacion) > ISNULL(C.FechaArranqueEntregables,'20190101')
				AND cita.NombreContratista NOT LIKE '%SHELL%'
				AND cita.NombreContratista NOT LIKE '%BP%'
				AND cita.NombreContratista NOT LIKE '%REPSOL%'
				AND cita.NombreContratista NOT LIKE '%MURPHY%'

        --==================================================CORREO ANTES===================================================================
        UNION ALL
        SELECT
                IE.idInstanciaEntregable,
                IE.FechasLimiteAprobacion                              AS periodo,
                IE.FechasLimiteElaboracion                             AS FECHALIMITEACCION,
                A.ActividadID,
                A.EstadoID,
                U1.Nombre,
                U1.UsuarioID,
                U1.Usuario                                             AS Para,
                E1.NombreEstado                                        AS EstadoActual,
                --  ASI.ActividadID 
                NULL                                                   AS ActividadSiguiente,
                --   ASI.EstadoID 
                NULL                                                   AS IDEstadoSiguiente,
                --  U2.Nombre 
                NULL                                                   NombreSiguiente,
                --  U2.UsuarioID U
                NULL                                                   usuarioIDSiguiente,
                --  U2.Usuario 
                NULL                                                   AS ParaSiguiente,
                --  E2.NombreEstado 
                NULL                                                   AS EstadoSiguiente,
                --  CASE E2.EstadoID
                --        WHEN 10001 THEN IE.FechasLimiteRevision
                --        WHEN 10002 THEN IE.FechasLimiteAprobacion END 
                NULL                                                   AS FECHALIMITEACCIONSIGUIENTE,
                'Correo Alerta Elaboración'                            AS tipoCorreo,
                E.IdEntregable,
                E.DocumentoEntregable +' del contrato '+ C.NumeroContrato,
                'que te han asignado la'                                AS TextoTipoAlertaActual,
                'Fecha limite para llevar acabo la ' + E1.NombreEstado + ' es: '
                + CONVERT(VARCHAR(50), IE.FechasLimiteElaboracion, 23) AS TextoTipoAlertaActual2,
     --    'que el usuario ' + U1.Nombre + ' ha tenido un retardo en su ' + E1.NombreEstado 
                ''                               AS TextoTipoAlertaSiguiente,
                ''                                                     AS TextoTipoAlertaSiguiente2,
				'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente
        FROM
                dbo.EN_InstanciasEntregable IE (NOLOCK)
            JOIN
                dbo.EN_Actividad            A (NOLOCK)
                    ON IE.ActividadID= A.ActividadID   --Donde se encuentra PENDIENTE DE ELBARORACION
					AND CONVERT(DATE, IE.FechaEnvioMensajeAtrasoRevision) =@HOY
					AND IE.Activo=1
            JOIN
                dbo.EN_Transicion           T (NOLOCK)
                    ON  A.ActividadID=T.ActividadInicialID 
                       AND T.AccionID = 10000
            JOIN
                dbo.EN_Actividad            ASI (NOLOCK)
                    ON T.SiguienteActividadID = ASI.ActividadID
            JOIN
                dbo.AP_Usuario              U1 (NOLOCK)
                    ON  A.idUsuario=U1.UsuarioID --- PENDIENTE DE ELABORACIÓN
            JOIN
                dbo.AP_Usuario              U2 (NOLOCK)
                    ON ASI.idUsuario=U2.UsuarioID  --- PENDIENTE DE ELABORACIÓN
            JOIN
                dbo.EN_Estado               E1 (NOLOCK)
                    ON A.EstadoID=E1.EstadoID  --En estado que se encuentra la instancia
            JOIN
                dbo.EN_Estado               E2 (NOLOCK)
                    ON  ASI.EstadoID= E2.EstadoID --En estado que se encuentra la instancia
            JOIN
                dbo.EN_ContratoEntregable   CE (NOLOCK)
                    ON IE.IdContratoEntregable=CE.IdContratoEntregable
					AND CE.Activo=1 
            JOIN
                dbo.EN_Entregable           E (NOLOCK)
                    ON  CE.IdEntregable=E.IdEntregable
					AND E.BITJOA = 0
			JOIN CO_Contrato C (NOLOCK)
			on CE.IdContrato=C.IdContrato
			JOIN dbo.CO_Contratista cita
			ON c.IdContratista=cita.IdContratista
				JOIN dbo.AP_Rutas ruta
			ON cita.IdRuta=ruta.idRuta
        WHERE
				DATEADD(DAY, 1, IE.FechaEnvioMensajeAtrasoRevision) > ISNULL(C.FechaArranqueEntregables,'20190101')
				AND cita.NombreContratista NOT LIKE '%SHELL%'
				AND cita.NombreContratista NOT LIKE '%BP%'
				AND cita.NombreContratista NOT LIKE '%REPSOL%'
				AND cita.NombreContratista NOT LIKE '%MURPHY%'

    END;