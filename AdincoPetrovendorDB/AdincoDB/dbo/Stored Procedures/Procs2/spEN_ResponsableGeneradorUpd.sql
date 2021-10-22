if exists(select * from sys.procedures where name = 'spEN_ResponsableGeneradorUpd')
begin
	drop proc spEN_ResponsableGeneradorUpd
end

go

create proc spEN_ResponsableGeneradorUpd
(
	@idResponsableGenerador	int,
	@ResponsableGenerador	varchar(max),
	@idUsuario				int
)
as
begin
	

	if not exists (select * from EN_ResponsableGenerador  where ResponsableGenerador = @ResponsableGenerador and IdResponsableGenerador	<>	@idResponsableGenerador)
	begin
			update	EN_ResponsableGenerador 
			set		ResponsableGenerador	=	@ResponsableGenerador,
					CreadoPor				=	@idUsuario,
					CreadoEn				=	getdate()
			where	IdResponsableGenerador	=	@idResponsableGenerador
						
			select		Error	=	0
		end
		else
		begin
			select		Error	=	1
		end
end

go
