-- =============================================  
-- Author:   Reyna Olvera  
-- Create date: 20191115  
-- Description: ENVIA ALERTAS DEASIGNACIÓN DE USUARIO  
-- =============================================  
CREATE PROCEDURE [dbo].[sp_enviaCorreosResponsablesAsignados]   
@IdContratoEntregable int,  
@idUsuario int,  
@idContrato int  
AS  
BEGIN  
  
  CREATE TABLE #correos (  
    Id int IDENTITY (1, 1),  
    Para varchar(500),  
    Asunto varchar(500),  
    Mensaje text,  
    De varchar(100)  
  );  
    
  CREATE TABLE #Usuarios (  
    Id int IDENTITY (1, 1),  
   EstadoID int,  
   UsuarioId int,  
   Idgrupo bit,  
   IdEntregable int,  
   FechaLimiteEntrega date  
  );  
  
-- CUALQUIER OTRO CONTRATO MENOS EL DE SHELL  
--IF GETDATE() > (SELECT ISNULL(FECHAARRANQUEENTREGABLES,'20211231')  
--    FROM CO_CONTRATO  
--    WHERE IDCONTRATO = @idContrato)  
--BEGIN
IF 0 < (SELECT COUNT(1)
		FROM CO_CONTRATO C
		JOIN CO_CONTRATISTA CA
			ON C.IDCONTRATISTA = CA.IDCONTRATISTA
		WHERE C.IDCONTRATO = @idContrato
			AND CA.NombreContratista NOT LIKE '%SHELL%'
			AND CA.NombreContratista NOT LIKE '%BP%'
			AND CA.NombreContratista NOT LIKE '%REPSOL%'
			AND CA.NombreContratista NOT LIKE '%MURPHY%')
BEGIN  
  
  
INSERT INTO #Usuarios (EstadoID,  
   UsuarioId,  
   Idgrupo,  
   IdEntregable,FechaLimiteEntrega)  
select a.EstadoID,UAsignado.UsuarioID,UAsignado.IsGrupo,e.IdEntregable, ce.FechaLimiteEntrega  
   FROM EN_ContratoEntregable CE  
    JOIN EN_Entregable E  
      ON CE.IdContratoEntregable = @IdContratoEntregable  
      AND CE.IdEntregable = E.IdEntregable
	  AND E.BITJOA = 0
    JOIN EN_Actividad A  
      ON CE.IdContratoEntregable = A.IdContratoEntregable  
      AND A.EstadoID NOT IN (10003, 10004)  
    JOIN AP_Usuario UAsignado  
      ON A.idUsuario = UAsignado.UsuarioID  
    JOIN AP_Usuario USESION  
      ON USESION.UsuarioID =  @idUsuario  
   
  
  
INSERT INTO #correos (Para,  
  Asunto,  
  Mensaje,  
  De)  
SELECT  UPR.Usuario,  
           COR.Descripcion,  
           REPLACE(  
           REPLACE(  
           REPLACE(  
           REPLACE(  
           REPLACE(HTML, '##USUARIOSESION##', USESION.Nombre), '##NOMBRE_USUARIO##', UPR.Nombre), '##ENLACE_DETALLE##', CASE ISNULL(CI.IDRUTA, 0)  
             WHEN 0 THEN 'https://adinco.mx/2/Entregables/SubeEntregables.aspx'  
             ELSE 'https://' + Ruta + '/2/Entregables/SubeEntregables.aspx'  
           END), '##ENTREGABLEESTATUS##', CASE U.EstadoID  
             WHEN 10000 THEN 'elaborador del entregable: ' + E.DocumentoEntregable + ' del contrato ' + NumeroContrato  
             WHEN 10001 THEN 'revisor del entregable: ' + E.DocumentoEntregable + ' del contrato ' + NumeroContrato  
             WHEN 10002 THEN 'aprobador del entregable: ' + E.DocumentoEntregable + ' del contrato ' + NumeroContrato  
           END), '##FECHA_PROGRAMADA##', CASE  
             WHEN CONVERT(varchar, u.FechaLimiteEntrega, 103) IS NULL THEN 'Asignación pendiente de fecha programada'  
             ELSE CONVERT(varchar, u.FechaLimiteEntrega, 103)  
           END),  
           'notificaciones@adinco.mx'-- De - varchar(100)    
  FROM #Usuarios U  
 JOIN EN_GruposUsuarios GU   
  ON U.UsuarioId = GU.IdGrupo  
 JOIN AP_Usuario UPR  
  ON GU.IdUsuario = UPR.UsuarioID  
 JOIN AP_Usuario USESION  
  ON USESION.UsuarioID = @idUsuario  
 JOIN EN_Entregable E  
  ON U.IdEntregable = E.IdEntregable  
 JOIN CO_Contrato C  
  ON C.IdContrato = @idContrato  
 JOIN CO_Contratista CI  
  ON C.IdContratista = CI.IdContratista  
 JOIN TA_Correo COR  
  ON COR.Asunto = 'Asignacion Usuarios Entregable'  
 LEFT JOIN AP_Rutas R  
  ON CI.IdRuta = R.idRuta  
  
 UNION ALL  
  
 SELECT UPR.Usuario,  
           COR.Descripcion,  
           REPLACE(  
           REPLACE(  
           REPLACE(  
           REPLACE(  
           REPLACE(HTML, '##USUARIOSESION##', USESION.Nombre), '##NOMBRE_USUARIO##', UPR.Nombre), '##ENLACE_DETALLE##', CASE ISNULL(CI.IDRUTA, 0)  
             WHEN 0 THEN 'https://adinco.mx/2/Entregables/SubeEntregables.aspx'  
             ELSE 'https://' + Ruta + '/2/Entregables/SubeEntregables.aspx'  
           END), '##ENTREGABLEESTATUS##', CASE U.EstadoID  
             WHEN 10000 THEN 'elaborador del entregable: ' + E.DocumentoEntregable + ' del contrato ' + NumeroContrato  
             WHEN 10001 THEN 'revisor del entregable: ' + E.DocumentoEntregable + ' del contrato ' + NumeroContrato  
             WHEN 10002 THEN 'aprobador del entregable: ' + E.DocumentoEntregable + ' del contrato ' + NumeroContrato  
           END), '##FECHA_PROGRAMADA##', CASE  
             WHEN CONVERT(varchar, u.FechaLimiteEntrega, 103) IS NULL THEN 'Asignación pendiente de fecha programada'  
             ELSE CONVERT(varchar, u.FechaLimiteEntrega, 103)  
           END),  
           'notificaciones@adinco.mx'-- De - varchar(100)  
  FROM #Usuarios U  
 JOIN AP_Usuario UPR  
  ON U.UsuarioId = UPR.UsuarioID  
  AND ISNULL(U.Idgrupo,0) = 0  
 JOIN AP_Usuario USESION  
  ON USESION.UsuarioID = @idUsuario  
 JOIN EN_Entregable E  
  ON U.IdEntregable = E.IdEntregable  
 JOIN CO_Contrato C  
  ON C.IdContrato = @idContrato  
 JOIN CO_Contratista CI  
  ON C.IdContratista = CI.IdContratista  
 JOIN TA_Correo COR  
  ON COR.Asunto = 'Asignacion Usuarios Entregable'  
 LEFT JOIN AP_Rutas R  
  ON CI.IdRuta = R.idRuta  
  
  
  
  INSERT INTO S_Notificacion (IdNotificacion,  
  Para,  
  Asunto,  
  Mensaje,  
  FechaProgramadaEnvio,  
  Enviada,  
  FechaEnvio,  
  CreadoPor,  
  CreadoEl,  
  De,  
  EN_MsjEnviado)  
    SELECT (SELECT  
             MAX(IdNotificacion) + Id  
           FROM dbo.S_Notificacion),  
           para,  
           asunto,  
           mensaje,  
           GETDATE(),                  -- FechaProgramadaEnvio - datetime  
           0,                          -- Enviada - bit  
           NULL,                       -- FechaEnvio - datetime  
           @idUsuario,                 -- CreadoPor - int  
           GETDATE(),                  -- CreadoEl - datetime  
           de,  
           0  
    FROM #correos  
    WHERE Para IS NOT NULL  
    AND mensaje IS NOT NULL;  
  
  IF @@ERROR <> 0  
  BEGIN  
    SELECT CAST(@@ERROR AS nvarchar(8)) AS error;  
  END  
  ELSE  
  BEGIN  
    SELECT '' AS error;  
  END  
END  
ELSE  
BEGIN  
 SELECT '' AS error;  
END  
  
END  