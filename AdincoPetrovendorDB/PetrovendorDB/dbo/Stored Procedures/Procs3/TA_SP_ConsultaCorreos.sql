
CREATE PROCEDURE [dbo].[TA_SP_ConsultaCorreos] 
@FECHAINICIO DATETIME = NULL,
@FECHAFIN DATETIME =NULL
AS
BEGIN
    SELECT  * 
    FROM
    (
        SELECT n.IdNotificacion,
               n.Para,
               n.Asunto,
               n.Enviada,
               ISNULL(u.Nombre,'Administrador Petrovendor') AS EnviadoPor,
               ec.EnviadoEl,
               ec.IdIdentificacion,
               n.Mensaje
        FROM Adinco.dbo.S_Notificacion AS n
            INNER JOIN dbo.TA_EnvioCorreo AS ec
                ON ec.IdEnvioAdinco = n.IdNotificacion
            LEFT JOIN dbo.S_Usuario AS u
                ON u.IdUsuario = ec.EnviadoPor
        WHERE CreadoPor IN (3,1)	-->ctes 		 
		 AND  n.CreadoEl BETWEEN @FECHAINICIO AND DATEADD(HOUR,24,@FECHAFIN)
					 
        UNION ALL
        SELECT n.IdNotificacion,
               n.Para,
               n.Asunto,
               n.Enviada,
               'Administrador Petrovendor' AS EnviadoPor,
               ec.EnviadoEl,
               ec.IdIdentificacion,
               n.Mensaje
        FROM Adinco.dbo.S_Notificacion AS n
            INNER JOIN dbo.TA_EnvioCorreo AS ec
                ON ec.IdEnvioAdinco = n.IdNotificacion
        --INNER JOIN dbo.S_Usuario AS u ON u.IdUsuario = ec.EnviadoPor
        WHERE CreadoPor IN (3,1)	-->ctes 	
              AND ec.EnviadoPor = 0
			  AND n.CreadoEl BETWEEN @FECHAINICIO AND DATEADD(HOUR,24,@FECHAFIN)
					
			 
    ) Correos
    ORDER BY Correos.IdNotificacion DESC;

END;



