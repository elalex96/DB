
create proc p_CO_SAPPRESES_Undo_Approvement
(
	@pId		int,
	@pIdUsuario	int
)
as
begin

	if not exists
	(
		select		1
		from		[CO_SAPPRESES] a
		inner join	Petrovendor..[MPY_MM_AceptacionPedido]		ap 
		on			ap.IdPedido									collate		SQL_Latin1_General_CP1_CI_AS	=	a.SAPPONumber	collate SQL_Latin1_General_CP1_CI_AS 
		and			ap.ReferenceNumber							collate		SQL_Latin1_General_CP1_CI_AS	=	a.SAPSESNumber	collate SQL_Latin1_General_CP1_CI_AS
		inner join	Petrovendor..[MPY_MM_AceptacionCartaPCN]	ac 
		on			ac.IdAceptacionPedido						=			ap.IdAceptacionPedido 
		and			ac.IdEstatus								in			(1,2)
		where		a.IdPRESES									=			@pid
	)
	begin
	
		update	[dbo].[CO_SAPPRESES]
		set		IdEstatus		= 1,
				ModificadoEl	= getdate()
		where	IdPRESES		= @pId

		declare @index int
		select	@index			=	isnull(max(Id),0)	+	1 
		from	CO_SAPPreses_BiTACORA

		insert into CO_SAPPreses_BiTACORA
		select @index, IdPRESES, @pIdUsuario, IdEstatus, GETDATE(),'' from [CO_SAPPRESES] where IdPRESES = @pId

		select response = 1
	end	
	else
	begin
	
		select response = 0
	end
end

