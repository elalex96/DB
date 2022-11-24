-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20190103
-- Description:	FormaCalendario
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_CalendarizacionEntregableUsuario]--3,10061
    @idContrato INT,
    @idUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
	DECLARE @IsAdmin INT;
    SELECT @IsAdmin = COUNT(1)
	--SELECT *
    FROM dbo.AP_PerfilUsuario PU
    JOIN dbo.AP_Perfil P ON PU.PerfilID = P.IdPerfil
    JOIN dbo.AP_Rol R ON P.IdRol = R.IdRol
    WHERE UsuarioID = @idUsuario
          AND P.IdContrato =@idContrato
          AND R.Rol LIKE '%Administra%Entregables%';

	IF(@IsAdmin>0)
	BEGIN
	 SELECT      ID = IE.idInstanciaEntregable,
                AllDay = NULL,
                Description = 'Entregable: ' + DocumentoEntregable,
                EndTime = CASE
                               WHEN A.EstadoID = 10000
                                 OR EXAR.EstadoID = 10000 THEN
                                   DATEADD(MINUTE, 59, DATEADD(HOUR, 1, IE.FechasLimiteElaboracion))
                               WHEN A.EstadoID = 10001
                                 OR EXAR.EstadoID = 10001 THEN
                                   DATEADD(MINUTE, 59, DATEADD(HOUR, 1, IE.FechasLimiteRevision))
                               WHEN A.EstadoID = 10002
                                 OR EXAR.EstadoID = 10002 THEN
                                   DATEADD(MINUTE, 59, DATEADD(HOUR, 1, IE.FechasLimiteAprobacion)) END,
                Label = 3,
                Location = 'Fecha programada: ' + RTRIM(CONVERT(DATE, IE.FechasLimiteAprobacion)),
                RecurrenceInfo = 1,
                ReminderInfo = 'Reminder',
                IDResource = 1,
                StartTime = CASE
                                 WHEN A.EstadoID = 10000
                                   OR EXAR.EstadoID = 10000 THEN DATEADD(DAY, 0, IE.FechasLimiteElaboracion)
                                 WHEN A.EstadoID = 10001
                                   OR EXAR.EstadoID = 10001 THEN DATEADD(DAY, 0, IE.FechasLimiteRevision)
                                 WHEN A.EstadoID = 10002
                                   OR EXAR.EstadoID = 10002 THEN DATEADD(DAY, 0, IE.FechasLimiteAprobacion) END,
                Status = E.NombreEstado +' Por el usuario: '
					+ CASE 	WHEN EXAR.idUsuario IS NOT NULL
						THEN UEX.Nombre
						ELSE	UA.Nombre
				END,
                Subject = 'Entregable: ' + DocumentoEntregable+'. Pendiente de: '+ E.NombreEstado+' por el usuario: '
				+ CASE	WHEN EXAR.idUsuario IS NOT NULL
					THEN UEX.Nombre
					ELSE	UA.Nombre
				END,
                EventType = NULL
      -- Select *
      FROM      EN_InstanciasEntregable IE	(NOLOCK)
      JOIN      EN_ContratoEntregable CE	(NOLOCK)
			ON IE.IdContratoEntregable   = CE.IdContratoEntregable 
		   AND CE.IdContrato             = @idContrato
		   AND IE.Activo=1 
		   AND CE.Activo=1
      JOIN      EN_Actividad A	(NOLOCK)
			ON IE.ActividadID            = A.ActividadID
      JOIN      EN_Estado E	(NOLOCK)
			ON A.EstadoID                = E.EstadoID
	  JOIN dbo.AP_Usuario UA	(NOLOCK)
			ON A.idUsuario=UA.UsuarioID
      JOIN      EN_Entregable EN	(NOLOCK)
			ON CE.IdEntregable           = EN.IdEntregable
			AND EN.BITJOA = 0
			AND EN.IsActivo = 1
     JOIN      dbo.CO_Regulador R	(NOLOCK)
			ON EN.IdRegulador            = R.IdRegulador
     JOIN      dbo.EN_MarcoLegal M	(NOLOCK)
			ON EN.IdMarcoLegal           = M.IdMarcoLegal
     JOIN      dbo.EN_FrecuenciaEntregable f	(NOLOCK)
			ON EN.IdFrecuenciaEntregable = f.IdFrecuenciaEntregable
      LEFT JOIN dbo.EN_ExcepcionesActividad EXAR	(NOLOCK)
			ON A.ActividadID             = EXAR.ActividadIDExcepcion
			AND IE.idInstanciaEntregable  = EXAR.IdInstanciasEntregables
	  LEFT JOIN dbo.AP_Usuario UEX 
			ON Exar.idUsuario=UEX.UsuarioID
     WHERE      
			  (A.idUsuario = @idUsuario
              AND   EXAR.IdInstanciasEntregables IS NULL
              AND   A.EstadoID  <> 10003)
        OR    (   EXAR.idUsuario   = @idUsuario
              AND   EXAR.IdInstanciasEntregables IS NOT NULL
              AND   EXAR.EstadoID    <> 10003)
       
	   UNION

        SELECT      ID = IE.idInstanciaEntregable,
                AllDay = NULL,
                Description = 'Administración Entregable: ' + DocumentoEntregable,
                EndTime = CASE
                               WHEN A.EstadoID = 10000
                                 OR EXAR.EstadoID = 10000 THEN
                                   DATEADD(MINUTE, 59, DATEADD(HOUR, 1, IE.FechasLimiteElaboracion))
                               WHEN A.EstadoID = 10001
                                 OR EXAR.EstadoID = 10001 THEN
                                   DATEADD(MINUTE, 59, DATEADD(HOUR, 1, IE.FechasLimiteRevision))
                               WHEN A.EstadoID = 10002
                                 OR EXAR.EstadoID = 10002 THEN
                                   DATEADD(MINUTE, 59, DATEADD(HOUR, 1, IE.FechasLimiteAprobacion)) END,
                Label = 3,
                Location = 'Fecha programada: ' + RTRIM(CONVERT(DATE, IE.FechasLimiteAprobacion)),
                RecurrenceInfo = 1,
                ReminderInfo = 'Reminder',
                IDResource = 1,
                StartTime = CASE
                                 WHEN A.EstadoID = 10000
                                   OR EXAR.EstadoID = 10000 THEN DATEADD(DAY, 0, IE.FechasLimiteElaboracion)
                                 WHEN A.EstadoID = 10001
                                   OR EXAR.EstadoID = 10001 THEN DATEADD(DAY, 0, IE.FechasLimiteRevision)
                                 WHEN A.EstadoID = 10002
                                   OR EXAR.EstadoID = 10002 THEN DATEADD(DAY, 0, IE.FechasLimiteAprobacion) END,
                Status = E.NombreEstado+' Por el usuario: '
				+ CASE 
				WHEN EXAR.idUsuario IS NOT NULL
				THEN UEX.Nombre
				ELSE
				UA.Nombre
				END,
                Subject = 'Administración Entregable: ' + DocumentoEntregable+'. Pendiente de: '+ E.NombreEstado +' por el usuario: '
				+ CASE 
				WHEN EXAR.idUsuario IS NOT NULL
				THEN UEX.Nombre
				ELSE
				UA.Nombre
				END,
                EventType = NULL
      FROM      EN_InstanciasEntregable IE	(NOLOCK)
      JOIN      EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable   = CE.IdContratoEntregable
       AND CE.IdContrato             = @idContrato
	   AND IE.Activo=1 
	   AND CE.Activo=1
      JOIN      EN_Actividad A	(NOLOCK)
        ON IE.ActividadID            = A.ActividadID
      JOIN      EN_Estado E	(NOLOCK)
        ON A.EstadoID                = E.EstadoID
   JOIN dbo.AP_Usuario UA	(NOLOCK)
		ON A.idUsuario=UA.UsuarioID
      JOIN      EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable           = EN.IdEntregable
		AND EN.BITJOA = 0
		AND EN.IsActivo = 1
     Left JOIN      dbo.CO_Regulador R
        ON EN.IdRegulador            = R.IdRegulador
     Left JOIN      dbo.EN_MarcoLegal M
        ON EN.IdMarcoLegal           = M.IdMarcoLegal
     Left JOIN      dbo.EN_FrecuenciaEntregable f
        ON EN.IdFrecuenciaEntregable = f.IdFrecuenciaEntregable
      LEFT JOIN dbo.EN_ExcepcionesActividad EXAR
        ON A.ActividadID             = EXAR.ActividadIDExcepcion
       AND IE.idInstanciaEntregable  = EXAR.IdInstanciasEntregables
	   LEFT JOIN dbo.AP_Usuario UEX ON Exar.idUsuario=UEX.UsuarioID
     WHERE 
	 	( A.idUsuario <> @idUsuario
              AND   EXAR.IdInstanciasEntregables IS NULL
              AND   A.EstadoID  <> 10003)
        OR      (   EXAR.idUsuario   <> @idUsuario
              AND   EXAR.IdInstanciasEntregables IS NOT NULL
              AND   EXAR.EstadoID    <> 10003) AND year(IE.FechasLimiteAprobacion) <= (YEAR(GETDATE()) + 2)
       
    END
	ELSE
	begin
    SELECT      ID = IE.idInstanciaEntregable,
                AllDay = NULL,
                Description = 'Entregable: ' + DocumentoEntregable,
                EndTime = CASE
                     WHEN A.EstadoID = 10000
                                 OR EXAR.EstadoID = 10000 THEN
                                   DATEADD(MINUTE, 59, DATEADD(HOUR, 1, IE.FechasLimiteElaboracion))
                               WHEN A.EstadoID = 10001
                                 OR EXAR.EstadoID = 10001 THEN
                                   DATEADD(MINUTE, 59, DATEADD(HOUR, 1, IE.FechasLimiteRevision))
                               WHEN A.EstadoID = 10002
                                 OR EXAR.EstadoID = 10002 THEN
                                   DATEADD(MINUTE, 59, DATEADD(HOUR, 1, IE.FechasLimiteAprobacion)) END,
                Label = 3,
                Location = 'Fecha programada: ' + RTRIM(CONVERT(DATE, IE.FechasLimiteAprobacion)),
                RecurrenceInfo = 1,
                ReminderInfo = 'Reminder',
                IDResource = 1,
                StartTime = CASE
                                 WHEN A.EstadoID = 10000
                                   OR EXAR.EstadoID = 10000 THEN DATEADD(DAY, 0, IE.FechasLimiteElaboracion)
                                 WHEN A.EstadoID = 10001
                                   OR EXAR.EstadoID = 10001 THEN DATEADD(DAY, 0, IE.FechasLimiteRevision)
                                 WHEN A.EstadoID = 10002
                                   OR EXAR.EstadoID = 10002 THEN DATEADD(DAY, 0, IE.FechasLimiteAprobacion) END,
                Status = E.NombreEstado,
                Subject = 'Entregable: ' + DocumentoEntregable+'. Pendiente de: '+ E.NombreEstado,
                EventType = NULL
      -- Select *
      FROM      EN_InstanciasEntregable IE	(NOLOCK)
      JOIN      EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable   = CE.IdContratoEntregable
       AND CE.IdContrato             = @idContrato
	   AND IE.Activo=1 AND CE.Activo=1
      JOIN      EN_Actividad A	(NOLOCK)
        ON IE.ActividadID            = A.ActividadID
      JOIN      EN_Estado E	(NOLOCK)
        ON A.EstadoID                = E.EstadoID
      JOIN      EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable           = EN.IdEntregable
		AND EN.ISACTIVO = 1
		AND EN.BITJOA = 0
     Left JOIN      dbo.CO_Regulador R
        ON EN.IdRegulador            = R.IdRegulador
     Left JOIN      dbo.EN_MarcoLegal M
        ON EN.IdMarcoLegal           = M.IdMarcoLegal
     Left JOIN      dbo.EN_FrecuenciaEntregable f
        ON EN.IdFrecuenciaEntregable = f.IdFrecuenciaEntregable
      LEFT JOIN dbo.EN_ExcepcionesActividad EXAR
        ON A.ActividadID             = EXAR.ActividadIDExcepcion
       AND IE.idInstanciaEntregable  = EXAR.IdInstanciasEntregables
     WHERE      
	  (A.idUsuario = @idUsuario
              AND   EXAR.IdInstanciasEntregables IS NULL
              AND   A.EstadoID  <> 10003)
        OR      (   EXAR.idUsuario   = @idUsuario
              AND   EXAR.IdInstanciasEntregables IS NOT NULL
              AND   EXAR.EstadoID    <> 10003)
	END
END;