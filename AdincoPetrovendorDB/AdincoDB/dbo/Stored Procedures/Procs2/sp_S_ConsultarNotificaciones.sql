-- [sp_S_ConsultarNotificaciones] '',0
CREATE procedure [dbo].[sp_S_ConsultarNotificaciones]   
@pIdsNotificaciones VARCHAR(500),    
@pSoloPendientes    BIT          = 1  
  
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


   SELECT  top 20
			N.IdNotificacion,    
            Para = N.Para,    
			N.Asunto, 
            Mensaje = CAST(N.Mensaje AS VARCHAR(MAX)),    
            N.FechaProgramadaEnvio,    
            N.Enviada,    
            N.FechaEnvio,    
            TieneError = CASE WHEN max(ne.IdNotificacionError) IS NOT NULL THEN 1 ELSE 0 END,    
			N.CreadoPor,    
            N.CreadoEl,    
            N.ModificadoPor,    
            N.ModificadoEl,    
            N.De,    
            IdNotificacionMA = 0,
			N.CCO
     FROM  dbo.S_Notificacion N    (NOLOCK)
      inner join #tmpNotificacionesIds tmp on    
	  (  
	   tmp.IdNotificacion = n.IdNotificacion OR  
	   tmp.IdNotificacion = 0  
	  )  
	LEFT JOIN dbo.S_NotificacionError NE  (NOLOCK)
		ON N.IdNotificacion = NE.IdNotificacion 	
	
     WHERE N.Enviada = 0
	 and ltrim(rtrim(isnull(n.Para,''))) <> ''
	 group by N.IdNotificacion,                 
			N.Asunto, 
            CAST(N.Mensaje AS VARCHAR(MAX)),    
            N.FechaProgramadaEnvio,    
            N.Enviada,    
            N.FechaEnvio,                    
			N.CreadoPor,    
            N.CreadoEl,    
            N.ModificadoPor,    
            N.ModificadoEl,    
            N.De,
			N.Para,
			N.CCO
     having count(distinct ne.IdNotificacionError) < 3--Solo se intentará enviar hasta 3 veces un mismo correo
     ORDER BY N.IdNotificacion;
