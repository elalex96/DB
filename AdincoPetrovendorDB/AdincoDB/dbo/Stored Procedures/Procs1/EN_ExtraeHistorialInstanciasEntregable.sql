CREATE PROCEDURE [dbo].[EN_ExtraeHistorialInstanciasEntregable]-- 10061,3,211785	
    @idUsuario INT,
    @idContrato INT = 0,
    @idInstanciaEntregable INT --" manda a elaboración, 3 Revisión, 4 Aprobación, 5 reinicio de flujo
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 25/02/2019
-- Description:
-- =============================================

	SET NOCOUNT ON;
	DECLARE @comentarioElaborador VARCHAR(200),
			@idMax INT,
			@URLRepositorioMax VARCHAR(MAX),
			@URLRepositorioAcuseMax VARCHAR(MAX);


	SELECT TOP 1
			@idMax	=	MAX(IdLineaTiempo),
			@comentarioElaborador	=	Comentario,
			@URLRepositorioMax	=	URLRepositorio
	FROM 
		EN_HistorialAprobacionesLineaTiempo
	WHERE 
		idInstanciaEntregable	=	@idInstanciaEntregable
		AND	idTipoOperacion	=	2
		AND	Activo	=	1
	GROUP BY 
		Comentario,
		IdHistorialAprobacionesVersion,
		URLRepositorio
	ORDER BY 
		IdHistorialAprobacionesVersion	DESC;

		--SELECT @idMax
	SELECT @URLRepositorioAcuseMax = 
	CASE ContieneURLRepositorio
	WHEN 
		1
	THEN	
		URLRepositorio
	ELSE 
		''
	END
	FROM 
		EN_HistorialAprobacionesLineaTiempo
	WHERE 
		idInstanciaEntregable	=	@idInstanciaEntregable
		AND	idTipoOperacion	=	7
		AND	Activo	=	1
		AND IdLineaTiempo	=	@idMax


    SELECT	H.IdHistorialAprobacionesVersion,
			H.IdLineaTiempo,
			H.idInstanciaEntregable,
			H.idContrato,
			REPLACE( REPLACE(H.Comentario,'Revisado por usuario Revisor, enviado a aprobación Final',''),'Aprobado por usuario Aprobador con acuse','' )AS Comentario,
			H.Rechazado,
			H.idTipoOperacion,
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
			H.CreadoPor,
			H.CreadoEn,
			UAccion.Nombre AS RealizoAccion,
			ES.EstadoID,
			CASE H.idTipoOperacion
			WHEN 6
			THEN 'Desactivado'
			ELSE
			ES.NombreEstado
			END AS NombreEstado,
			CASE ISNULL(UXP.UsuarioID, '')
               WHEN '' THEN
                   U.Nombre
               ELSE
                   UXP.Nombre
			END AS Nombre,
           --  U.Nombre,
			IE.ActividadID AS ActividadActual,
			ISNULL(T.SiguienteActividadID, 0)	AS	SiguienteActividadID,
			ISNULL( --USA.Nombre
                     CASE ISNULL(UXPS.UsuarioID, '')
                         WHEN '' THEN
                             USA.Nombre
                         ELSE
                             UXPS.Nombre
                     END,
                     ''
                 ) AS NombreResaponsableSiguienteActividad,
			@comentarioElaborador	AS	ComentarioElaborador,
			IE.FechaRealEntregaRegulador	AS	FechaRealEntregaRegulador,
			@URLRepositorioMax	AS	URLRepositorioUltimaVersion,
			URLRepositorio,
			ContieneURLRepositorio,
			COUNT(DV.idHistorial)	AS	cantidadArchivos,
			@URLRepositorioAcuseMax AS URLRepositorioAcuseUltimaVersion,
			EN.DocumentoEntregable,
			FechasLimiteAprobacion,
			FechaCalculadaEntregaReg
    FROM 
		dbo.EN_HistorialAprobacionesLineaTiempo	H

    JOIN 
		dbo.EN_InstanciasEntregable	IE 
		ON	H.idInstanciaEntregable	=	IE.idInstanciaEntregable
	JOIN 
		EN_ContratoEntregable	CE
		ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable

	JOIN 
		EN_Entregable	EN
		ON CE.IdEntregable	=	EN.IdEntregable
		AND EN.BITJOA = 0

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
		dbo.EN_Actividad	ESA 
		ON	T.SiguienteActividadID	=	ESA.ActividadID --Siguiente actividad

    LEFT JOIN 
		dbo.AP_Usuario	USA 
		ON	ESA.idUsuario	=	USA.UsuarioID
    
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
    
    LEFT JOIN 
		dbo.EN_DocumentoVersion	DV 
		ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
		AND	H.IdLineaTiempo	=	DV.N_version

    WHERE 
		IE.idInstanciaEntregable	=	@idInstanciaEntregable
        AND	H.Activo	=	1
    GROUP BY 
			 H.IdHistorialAprobacionesVersion,
             H.IdLineaTiempo,
             H.idInstanciaEntregable,
             H.idContrato,
             REPLACE(
			 REPLACE(H.Comentario ,'Revisado por usuario Revisor, enviado a aprobación Final',''),'Aprobado por usuario Aprobador con acuse','') ,
			 
             H.Rechazado,
             H.idTipoOperacion,
             H.CreadoPor,
             H.CreadoEn,
             UAccion.Nombre,
             ES.EstadoID,
             ES.NombreEstado,
             IE.ActividadID,
             ISNULL(T.SiguienteActividadID, 0),
            IE.FechaRealEntregaRegulador,
             URLRepositorio,
             ContieneURLRepositorio,
             UXP.UsuarioID,
             U.Nombre,
             UXP.Nombre,
             UXPS.UsuarioID,
             USA.Nombre,
             UXPS.Nombre,
			EN.DocumentoEntregable,
			FechasLimiteAprobacion,
			FechaCalculadaEntregaReg

    ORDER BY 
			H.IdLineaTiempo,
             CreadoEn ASC;
END;