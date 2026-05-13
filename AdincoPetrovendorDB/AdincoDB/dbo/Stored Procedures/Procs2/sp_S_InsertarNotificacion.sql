
Create Proc sp_S_InsertarNotificacion
@pIdNotificacion	bigint out,
@pPara	varchar(500),
@pAsunto	varchar(250),
@pMensaje	text,
@pFechaProgramadaEnvio	datetime,
@pEnviada	bit,
@pFechaEnvio	datetime,
@pCreadoPor	int
as

select @pIdNotificacion = isnull(max([IdNotificacion]),0) + 1
from [S_Notificacion]

INSERT INTO [dbo].[S_Notificacion]
           ([IdNotificacion]
           ,[Para]
           ,[Asunto]
           ,[Mensaje]
           ,[FechaProgramadaEnvio]
           ,[Enviada]
           ,[FechaEnvio]
           ,[CreadoPor]
          )
     VALUES
           (@pIdNotificacion, 
          @pPara, 
           @pAsunto, 
           @pMensaje, 
           @pFechaProgramadaEnvio, 
           @pEnviada, 
           @pFechaEnvio, 
           @pCreadoPor)
