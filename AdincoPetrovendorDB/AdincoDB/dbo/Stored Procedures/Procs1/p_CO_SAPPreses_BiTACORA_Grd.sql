
CREATE proc p_CO_SAPPreses_BiTACORA_Grd
(
	@pIdPRESES	int
)
as
begin
	select		IdEstatus,
				CssEstatus	= case	when IdEstatus = 1 then 'label label-primary'
									when IdEstatus = 2 then 'label label-success'
									when IdEstatus = 3 then 'label label-danger'
								end,
				Estatus		= case	when IdEstatus = 1 then 'On Approval'
									when IdEstatus = 2 then 'Approved'
									when IdEstatus = 3 then 'Rejected'
								end,
				CreadoEl,
				ComentarioInterno
	from		CO_SAPPreses_BiTACORA
	where		IdPRESES				=	@pIdPRESES
	order by	Id	desc
end

