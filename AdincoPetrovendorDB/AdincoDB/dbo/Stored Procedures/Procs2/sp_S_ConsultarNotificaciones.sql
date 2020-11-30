CREATE procedure [dbo].[sp_S_ConsultarNotificaciones]   
@pIdsNotificaciones VARCHAR(500),    
@pSoloPendientes    BIT          = 0  
  
AS  
   
 CREATE TABLE #tmpNotificacionesIds(IdNotificacion INT);  
 
     IF(isnull(@pIdsNotificaciones, '') <> '')  
         BEGIN  
             INSERT INTO #tmpNotificacionesIds  
                    SELECT splitdata  
                    FROM [dbo].[fnSplitString](@pIdsNotificaciones, ',');  
         END;  
         ELSE  
         BEGIN  
             INSERT INTO #tmpNotificacionesIds  
             SELECT 0;  
         END; 

   
/*CREATE TABLE #tmpNotificacionesIds(IdNotificacion INT);  
     IF(isnull(@pIdsNotificaciones, '') <> '')  
         BEGIN  
             INSERT INTO #tmpNotificacionesIds  
                    SELECT splitdata  
                    FROM [dbo].[fnSplitString](@pIdsNotificaciones, ',');  
         END;  
         ELSE  
         BEGIN  
             INSERT INTO #tmpNotificacionesIds  
             SELECT 0;  
         END;  
     SELECT t1.IdNotificacion,    
            t1.Para,    
            t1.Asunto,    
            Mensaje = CAST(t1.Mensaje AS VARCHAR(MAX)),    
            t1.FechaProgramadaEnvio,    
            t1.Enviada,    
            t1.FechaEnvio,    
            t1.CreadoPor,    
            t1.CreadoEl,    
            t1.ModificadoPor,    
            t1.ModificadoEl,    
            t1.De  
     INTO #tmpNotificacion  
     FROM S_Notificacion t1  
          INNER JOIN #tmpNotificacionesIds t2 ON(t2.IdNotificacion = t1.IdNotificacion  
                                                 OR t2.IdNotificacion = 0)  
     WHERE t1.Enviada = 0;  
     SELECT n.IdNotificacion,    
            n.Para,    
            n.Asunto,    
            Mensaje = n.Mensaje,    
            n.FechaProgramadaEnvio,    
            n.Enviada,    
            n.FechaEnvio,    
            TieneError = CAST(CASE  
                                  WHEN isnull(MAX(error.IdNotificacion), 0) > 0  
                                       AND enviada = 0  
                                  THEN 1  
                                  ELSE 0  
                              END AS BIT),    
            n.CreadoPor,    
            n.CreadoEl,    
            n.ModificadoPor,    
            n.ModificadoEl,    
            n.De,    
            IdNotificacionMA = 0  
     FROM #tmpNotificacion n  
          INNER JOIN #tmpNotificacionesIds tmp ON(tmp.IdNotificacion = n.IdNotificacion  
                                                  OR tmp.IdNotificacion = 0)  
          LEFT JOIN S_NotificacionError error ON error.IdNotificacion = n.IdNotificacion  
     WHERE Enviada = (CASE  
                          WHEN @pSoloPendientes = 1  
                          THEN 0  
                          ELSE Enviada  
                      END)  
     GROUP BY n.IdNotificacion,    
              n.Para,    
              n.Asunto,    
              n.Mensaje,    
              n.FechaProgramadaEnvio,    
              n.Enviada,    
              n.FechaEnvio,    
              n.CreadoPor,    
              n.CreadoEl,    
              n.ModificadoPor,    
              n.ModificadoEl,    
              n.De  
     ORDER BY IdNotificacion ASC;*/  
   
-- UPDATE dbo.S_Notificacion   SET Enviada = 1   WHERE (Para LIKE '%@wintershalldea.com' OR De LIKE '%@wintershalldea.com%') or    Para in ( 'silvina.aviles@pemex.com', 'guillermo.gutierrez@pemex.com','Okko.Ulrichs@dea-group.com'  
-- ,'Natasya.Maura@dea-group.com',   'athenea.coral.cartela@pemex.com', 'rafael.hernandezsal@pemex.com', 'sergio.abraham.parra@pemex.com', 'gregorio.alfaro@pemex.com', 'pablo.emilio.reyes@pemex.com',   'soporte@ogss.com.mx', 'alejandro.torresolan@hotmail.com
--  ')   AND Enviada = 0  
 -- AND Asunto like '%Control%de%Obra%';  
   

   SELECT top 50 
	N.IdNotificacion,    
            N.Para,    
         N.Asunto, 
            Mensaje = CAST(N.Mensaje AS VARCHAR(MAX)),    
            N.FechaProgramadaEnvio,    
            N.Enviada,    
            N.FechaEnvio,    
            1 AS TieneError,    
			N.CreadoPor,    
            N.CreadoEl,    
            N.ModificadoPor,    
            N.ModificadoEl,    
            N.De,    
            IdNotificacionMA = 0  
     FROM  dbo.S_Notificacion N    (NOLOCK)
LEFT JOIN dbo.S_NotificacionError NE 
	ON N.IdNotificacion = NE.IdNotificacion 
	AND NE.Error <> '|Aún no se cumple la fecha de envío para este correo'
 inner join #tmpNotificacionesIds tmp on    
  (  
   tmp.IdNotificacion = n.IdNotificacion OR  
   tmp.IdNotificacion = 0  
  )  
     WHERE N.Enviada = 0
	 AND NE.IdNotificacion IS NULL
     ORDER BY N.IdNotificacion ASC;
