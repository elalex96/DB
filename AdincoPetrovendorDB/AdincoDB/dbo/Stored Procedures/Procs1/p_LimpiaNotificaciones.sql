   /*******ELIMINA TODAS LAS NOTIFICACIONES MAYORES A DOS MESES QUE YA FUERON ENVIADAS********/
CREATE proc p_LimpiaNotificaciones
as
	
	select top 1000 IdNotificacion 
	into #tmpNotificaciones
	from S_Notificacion	(NOLOCK)
	where enviada = 1 and
	DATEDIFF ( month , FechaProgramadaEnvio , getdate() )   > 2
	order by IdNotificacion

	delete [dbo].[S_NotificacionAdjunto] WITH (ROWLOCK)
	from [S_NotificacionAdjunto] a
	inner join #tmpNotificaciones tmp on tmp.IdNotificacion = a.IdNotificacion


	delete [dbo].[S_NotificacionError] WITH (ROWLOCK)
	from [S_NotificacionError] a
	inner join #tmpNotificaciones tmp on tmp.IdNotificacion = a.IdNotificacion
