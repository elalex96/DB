
create proc sp_AP_FlujoAprobacionEstatusUsuarios_Del
(
	@pUsuarioID					int,
	@pFlujoAprobacionEstatusId	int
)
as
begin

		delete		AP_FlujoAprobacionEstatusUsuarios
		where		UsuarioID							=	@pUsuarioID	
		and			FlujoAprobacionEstatusId			=	@pFlujoAprobacionEstatusId	
		--select 1			
		
		select * from AP_FlujoAprobacionEstatusUsuarios	
end

