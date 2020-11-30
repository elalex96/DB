
Create Proc sp_S_InsertarNotificacionTareaBitacora
@pIdTareaBitacora int out,
@pHostNameTarea varchar(100),
@pIPTarea varchar(15),
@pTieneError bit
as



select @pIdTareaBitacora = isnull(max(IdTareaBitacora),0)+1
from [S_NotificacionTareaBitacora]

INSERT INTO [dbo].[S_NotificacionTareaBitacora]
           ([IdTareaBitacora]
           ,[InicioEjecucion]
           ,[FinEjecucion]
           ,[HostNameTarea]
           ,[IPTarea]
		   ,TieneError)
     VALUES
           (@pIdTareaBitacora, 
           getdate(), 
           null, 
           @pHostNameTarea, 
           @pIPTarea,
		   @pTieneError
		   )
