
CREATE PROCEDURE [dbo].[SP_Migracion_EntregablesInstanciasBitacora] 
@ContratoId DATETIME,
@ProgramacionId INT
AS
BEGIN
   

   -->NOTAS manda a elaboración, 3 Revisión, 4 Aprobación, 5 reinicio de flujo,
   --> La version se calcula de acuerdo a la linea de tiempo desde codigo

   --> REFERENCIA EN_ExtraeHistorialInstanciasEntregable 

  -- EXEC SP_Migracion_EntregablesInstanciasBitacora 3,316209
			
    SELECT	ROW_NUMBER() OVER(ORDER BY H.IdHistorialAprobacionesVersion) AS RowNumber,
			H.CreadoPor,					
			CASE H.idTipoOperacion
			WHEN 6
			THEN 'Desactivado'
			ELSE
			ES.NombreEstado
			END AS NombreEstado,
			ES.EstadoID AS EstadoId,
			H.IdLineaTiempo AS Version,
			H.CreadoEn AS CreadoEl,			
			REPLACE( REPLACE(H.Comentario,'Revisado por usuario Revisor, enviado a aprobación Final',''),'Aprobado por usuario Aprobador con acuse','' )AS Descripcion,
			H.Rechazado,
			H.idTipoOperacion AS IdTipoOperacion,
			CASE H.idTipoOperacion
               WHEN	2	THEN
                   'Enviado a revisión por'
               WHEN	3	THEN
                   CASE	Rechazado
                       WHEN	1	THEN
                           'Rechazado en revisión por'
                       WHEN	0 THEN
                           'Revisado por:'
                   END
               WHEN	4	THEN
                   CASE	Rechazado
                       WHEN	1	THEN
                           'Rechazado en aprobación por'
                       WHEN 0 THEN
                           'Aprobado Por'
                   END
               WHEN	5	THEN
                   'Reinicio de flujo por'
			  WHEN	6	THEN
                   'Se desactiva entregable por'
		      WHEN	7	THEN
                   'Ingreso de acuse regulador por'
			   WHEN	8	THEN
                   'Ingreso de archivo adicional por'
			WHEN	9	THEN
					'Eliminación de archivo por'
			END	AS	Accion,			
			UAccion.Nombre AS RealizoAccion,
			CASE ISNULL(UXP.UsuarioID, '')
               WHEN '' THEN
                   U.Nombre
               ELSE
                   UXP.Nombre
			END AS UsuarioExcepcion,          
			IE.ActividadID AS ActividadActual,
			H.ActualizadoByApp,
			H.URLRepositorio,
			H.ContieneURLRepositorio
    FROM 
		dbo.EN_HistorialAprobacionesLineaTiempo	H
    JOIN 
		dbo.EN_InstanciasEntregable	IE 
		ON	H.idInstanciaEntregable	=	IE.idInstanciaEntregable
	JOIN 
		EN_ContratoEntregable	CE
		ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable

    JOIN 
		dbo.EN_Actividad	E 
		ON	IE.ActividadID	=	E.ActividadID

    JOIN 
		AP_Usuario	UAccion 
		ON	H.CreadoPor	=	UAccion.UsuarioID

    JOIN 
		dbo.EN_Estado	ES 
		ON	E.EstadoID	=	ES.EstadoID

    JOIN 
		dbo.AP_Usuario	U 
		ON	E.idUsuario	=	U.UsuarioID --Actual
    LEFT JOIN 
		EN_Transicion	T 
		ON	IE.ActividadID	=	T.ActividadInicialID
		AND	AccionID	IN	( 10000, 10001 )
    
    LEFT JOIN 
		dbo.EN_ExcepcionesActividad	EXAP 
		ON	E.ActividadID	=	EXAP.ActividadIDExcepcion --Actual
		AND	IE.idInstanciaEntregable	=	EXAP.IdInstanciasEntregables

    LEFT JOIN 
		dbo.AP_Usuario	UXP 
		ON	EXAP.idUsuario	=	UXP.UsuarioID

    LEFT JOIN 
		dbo.EN_ExcepcionesActividad	EXAS 
		ON	T.SiguienteActividadID	=	EXAS.ActividadIDExcepcion --Actual
		AND	IE.idInstanciaEntregable	=	EXAS.IdInstanciasEntregables

    LEFT JOIN 
		dbo.AP_Usuario	UXPS 
		ON	EXAS.idUsuario	=	UXPS.UsuarioID     

    WHERE 
		IE.idInstanciaEntregable	=	@ProgramacionId
        AND	H.Activo	=	1
    GROUP BY 
			 H.IdHistorialAprobacionesVersion,
             H.IdLineaTiempo,
             H.idInstanciaEntregable,
             H.idContrato,
             REPLACE(REPLACE(H.Comentario ,'Revisado por usuario Revisor, enviado a aprobación Final',''),'Aprobado por usuario Aprobador con acuse','') ,			 
             H.Rechazado,
             H.idTipoOperacion,
             H.CreadoPor,
             H.CreadoEn,
             UAccion.Nombre,
             ES.EstadoID,
             ES.NombreEstado,
             IE.ActividadID,
             U.Nombre,		
			 UXP.UsuarioID,
			 UXP.Nombre,
			 H.ActualizadoByApp,
			 H.URLRepositorio,
			H.ContieneURLRepositorio
    ORDER BY 
			H.IdLineaTiempo,
            H.CreadoEn  ASC;

END;



