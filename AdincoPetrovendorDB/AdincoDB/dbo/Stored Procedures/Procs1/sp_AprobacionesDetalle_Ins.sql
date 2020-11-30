  
  
CREATE proc [dbo].[sp_AprobacionesDetalle_Ins]  
(  
 @IdAprobacion int,  
 @IdRol   int,  
 @Url   varchar(max)  
)  
as  
begin  
   
  
 declare @IdAprobacionDetalle int,  
   @IdNotificacion   int  
   
 select @IdAprobacionDetalle = isnull(max(IdAprobacionDetalle),0)+1  
 from AprobacionesDetalle  
    
 --Revisa si ya existe el Detalle de la Aprobacion  
 if not exists (select * from AprobacionesDetalle where IdAprobacion = @IdAprobacion and IdRol = @IdRol)  
 begin  
  --select 1  
  --Si no existe, lo inserta en la tabla con Aprobado = 0  
  --select * from AprobacionesDetalle  
  insert into AprobacionesDetalle values (@IdAprobacionDetalle,@IdAprobacion,@IdRol,0,1)  
    
  --Obtiene todos los usuarios ligados al Rol en cuestion para enviarles un correo  
  select  @IdNotificacion = isnull(MAX(IdNotificacion),0) from s_Notificacion  
  --select  @IdNotificacion  
  
  declare @FechaEnvio smalldatetime, @msg varchar(max)  
  select @FechaEnvio = GETDATE()  
  select @FechaEnvio = DATEADD(minute,1,@FechaEnvio), @msg = ''  
  
    
  select @Url = @Url+'&IdAprobacionDetalle='+cast(@IdAprobacionDetalle as varchar)+'&IdRol='+cast(@IdRol as varchar)  
  
  exec  sp_MailAprobaciones_Get @Url output  
  --Inserta en la tabla de Notificaciones los correos que le llegaran a los usuarios con el Rol en cuestion  
  --insert into s_Notificacion  
  --   (  
  --    IdNotificacion,  
  --    Para,  
  --    Asunto,  
  --    Mensaje,  
  --    FechaProgramadaEnvio,  
  --    Enviada,  
  --    CreadoPor,  
  --    CreadoEl,  
  --    De  
  --   )  
  --select  IdNotificacion   = ROW_NUMBER() OVER (ORDER BY Usuario DESC)+@IdNotificacion,  
  --   Para     = 'ramon.portales@ogss.com.mx',--Usuario,  
  --   Asunto     = 'Autorizaciones Pendientes',  
  --   Mensaje     = @Url,   
  --   FechaProgramadaEnvio = @FechaEnvio,  
  --   Enviada     = 0,  
  --   CreadoPor    = 10103,  
  --   CreadoEl    = GETDATE(),  
  --   De      = 'procura@adinco.mx'  
  --from  RolesUsuarios   r  
  --inner join AP_Usuario    u  
  --on   r.IdUsuario    = u.UsuarioID  
  --where  r.IdRol     = @IdRol   
  --and   r.Activo    = 1  
  --AND ISNULL(IsGrupo,0)=0; 
    
    
  
  
  --select  * from s_Notificacion where IdNotificacion >= 29206  
  
 end  
 /*  
 select  * from s_Notificacion where IdNotificacion >= 27759  
 select * from Aprobaciones  
 select * from AprobacionesDetalle  
   
 delete from AprobacionesDetalle  
 delete from Aprobaciones  
   
 */  
end  
  