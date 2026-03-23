USE [Adinco]
GO

/****** Borrar el Stored Procedure si ya existe ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EN_ExtraeHistorialInstanciasEntregable]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[EN_ExtraeHistorialInstanciasEntregable]
END
GO

/****** Object:  StoredProcedure [dbo].[EN_ExtraeHistorialInstanciasEntregable] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EN_ExtraeHistorialInstanciasEntregable]
    @idUsuario INT,
    @idContrato INT = 0,
    @idInstanciaEntregable INT 
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 25/02/2019
-- Description:
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14/09/2022
-- Description: Descarte de los registros en bitacora como historial del entregable
-- =============================================
-- =============================================
-- Modified by: Alex Gomez
-- Modified date: 2026-02-27
-- Description: Blindaje de ISNULL/CAST a la consulta y WITH (NOLOCK) a tablas para optimizar lecturas. 
--              Corrección en el GROUP BY para evitar error 8120.
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
		EN_HistorialAprobacionesLineaTiempo WITH (NOLOCK) 
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
		EN_HistorialAprobacionesLineaTiempo WITH (NOLOCK) 
	WHERE 
		idInstanciaEntregable	=	@idInstanciaEntregable
		AND	idTipoOperacion	=	7
		AND	Activo	=	1
		AND IdLineaTiempo	=	@idMax


    SELECT	
            -- Valores Numéricos / IDs (Protegidos con 0)
			ISNULL(H.IdHistorialAprobacionesVersion, 0) AS IdHistorialAprobacionesVersion,
			ISNULL(H.IdLineaTiempo, 0) AS IdLineaTiempo,
			ISNULL(H.idInstanciaEntregable, 0) AS idInstanciaEntregable,
			ISNULL(H.idContrato, 0) AS idContrato,
			
            -- Textos (Protegidos con cadena vacía '')
			ISNULL(REPLACE( REPLACE(H.Comentario,'Revisado por usuario Revisor, enviado a aprobación Final',''),'Aprobado por usuario Aprobador con acuse','' ), '') AS Comentario,
			
            -- Booleanos (Protegidos con 0 y forzados a BIT)
            CAST(ISNULL(H.Rechazado, 0) AS BIT) AS Rechazado,
            
			ISNULL(H.idTipoOperacion, 0) AS idTipoOperacion,
			
            -- Este case genera un String, lo envolvemos por seguridad
            ISNULL(CASE H.idTipoOperacion
               WHEN	2	THEN 'Enviado a revisión por'
               WHEN	3	THEN
                   CASE	H.Rechazado
                       WHEN	1	THEN 'Rechazado en revisión por'
                       WHEN	0 THEN 'Revisado por:'
                   END
               WHEN	4	THEN
                   CASE	H.Rechazado
                       WHEN	1	THEN 'Rechazado en aprobación por'
                       WHEN 0 THEN 'Aprobado Por'
                   END
               WHEN	5	THEN 'Reinicio de flujo por'
			  WHEN	6	THEN 'Se desactiva entregable por'
		      WHEN	7	THEN 'Ingreso de acuse regulador por'
			   WHEN	8	THEN 'Ingreso de archivo adicional por'
			WHEN	9	THEN 'Eliminación de archivo por'
			END, '') AS	Accion,
            
			ISNULL(H.CreadoPor, 0) AS CreadoPor,
            
            -- Las fechas es mejor dejar que caigan nativas, se le manda la fecha actual si es NULL
			ISNULL(H.CreadoEn, GETDATE()) AS CreadoEn,
			
            ISNULL(UAccion.Nombre, '') AS RealizoAccion,
			ISNULL(ES.EstadoID, 0) AS EstadoID,
			
            ISNULL(CASE H.idTipoOperacion
			WHEN 6 THEN 'Desactivado'
			ELSE ES.NombreEstado
			END, '') AS NombreEstado,
            
			ISNULL(CASE ISNULL(UXP.UsuarioID, '')
               WHEN '' THEN U.Nombre
               ELSE UXP.Nombre
			END, '') AS Nombre,

			ISNULL(IE.ActividadID, 0) AS ActividadActual,
			ISNULL(T.SiguienteActividadID, 0) AS SiguienteActividadID,
			
            ISNULL(
                     CASE ISNULL(UXPS.UsuarioID, '')
                         WHEN '' THEN USA.Nombre
                         ELSE UXPS.Nombre
                     END,
                     ''
                 ) AS NombreResaponsableSiguienteActividad,
                 
			ISNULL(@comentarioElaborador, '') AS ComentarioElaborador,
			
            -- Fechas no tocadas para evitar corromper la validación en C# si requiere nulls
            IE.FechaRealEntregaRegulador AS FechaRealEntregaRegulador,
			
            ISNULL(@URLRepositorioMax, '') AS URLRepositorioUltimaVersion,
			ISNULL(URLRepositorio, '') AS URLRepositorio,
            
            -- Booleanos (Protegidos con 0 y forzados a BIT)
			CAST(ISNULL(ContieneURLRepositorio, 0) AS BIT) AS ContieneURLRepositorio,
			
            ISNULL(COUNT(DV.idHistorial), 0) AS	cantidadArchivos,
			
            ISNULL(@URLRepositorioAcuseMax, '') AS URLRepositorioAcuseUltimaVersion,
			ISNULL(EN.DocumentoEntregable, '') AS DocumentoEntregable,
            
            -- Otras Fechas 
			FechasLimiteAprobacion,
			FechaCalculadaEntregaReg

    FROM 
		dbo.EN_HistorialAprobacionesLineaTiempo	H WITH (NOLOCK)

    JOIN 
		dbo.EN_InstanciasEntregable	IE WITH (NOLOCK)
		ON	H.idInstanciaEntregable	=	IE.idInstanciaEntregable
		AND IE.idInstanciaEntregable	=	@idInstanciaEntregable
		AND	H.Activo	=	1
		AND H.idTipoOperacion <> 11
        
	JOIN 
		EN_ContratoEntregable	CE WITH (NOLOCK)
		ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable

	JOIN 
		EN_Entregable	EN WITH (NOLOCK)
		ON CE.IdEntregable	=	EN.IdEntregable
		AND EN.BITJOA = 0

    JOIN 
		dbo.EN_Actividad	E WITH (NOLOCK)
		ON	IE.ActividadID	=	E.ActividadID

    JOIN 
		AP_Usuario	UAccion WITH (NOLOCK)
		ON	H.CreadoPor	=	UAccion.UsuarioID

    JOIN 
		dbo.EN_Estado	ES WITH (NOLOCK)
		ON	E.EstadoID	=	ES.EstadoID

    JOIN 
		dbo.AP_Usuario	U WITH (NOLOCK)
		ON	E.idUsuario	=	U.UsuarioID

    LEFT JOIN 
		EN_Transicion	T WITH (NOLOCK)
		ON	IE.ActividadID	=	T.ActividadInicialID
		AND	T.AccionID	IN	( 10000, 10001 )

    LEFT JOIN 
		dbo.EN_Actividad	ESA WITH (NOLOCK)
		ON	T.SiguienteActividadID	=	ESA.ActividadID

    LEFT JOIN 
		dbo.AP_Usuario	USA WITH (NOLOCK)
		ON	ESA.idUsuario	=	USA.UsuarioID
    
    LEFT JOIN 
		dbo.EN_ExcepcionesActividad	EXAP WITH (NOLOCK)
		ON	E.ActividadID	=	EXAP.ActividadIDExcepcion
		AND	IE.idInstanciaEntregable	=	EXAP.IdInstanciasEntregables

    LEFT JOIN 
		dbo.AP_Usuario	UXP WITH (NOLOCK)
		ON	EXAP.idUsuario	=	UXP.UsuarioID

    LEFT JOIN 
		dbo.EN_ExcepcionesActividad	EXAS WITH (NOLOCK)
		ON	T.SiguienteActividadID	=	EXAS.ActividadIDExcepcion
		AND	IE.idInstanciaEntregable	=	EXAS.IdInstanciasEntregables

    LEFT JOIN 
		dbo.AP_Usuario	UXPS WITH (NOLOCK)
		ON	EXAS.idUsuario	=	UXPS.UsuarioID
		
    LEFT JOIN 
		dbo.EN_DocumentoVersion	DV WITH (NOLOCK)
		ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
		AND	H.IdLineaTiempo	=	DV.N_version
		
    GROUP BY 
             -- Agrupando por los nombres base de las columnas para evitar el Error 8120
			 H.IdHistorialAprobacionesVersion,
             H.IdLineaTiempo,
             H.idInstanciaEntregable,
             H.idContrato,
             H.Comentario,
             H.Rechazado,
             H.idTipoOperacion,
             H.CreadoPor,
             H.CreadoEn,
             UAccion.Nombre,
             ES.EstadoID,
             ES.NombreEstado,
             IE.ActividadID,
             T.SiguienteActividadID,
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
			 ISNULL(H.IdLineaTiempo, 0),
             ISNULL(H.CreadoEn, GETDATE()) ASC;
END;
GO