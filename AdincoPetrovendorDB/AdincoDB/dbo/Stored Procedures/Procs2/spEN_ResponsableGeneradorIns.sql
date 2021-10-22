if exists(select * from sys.procedures where name = 'spEN_ResponsableGeneradorIns')
begin
	drop proc spEN_ResponsableGeneradorIns
end

go

create proc spEN_ResponsableGeneradorIns
(
	@responsableGenerador		varchar(max),
	@idUsuario				int
)
as
begin
	if not exists (select * from EN_ResponsableGenerador  where ResponsableGenerador = @ResponsableGenerador)
	begin
		insert into EN_ResponsableGenerador 
					(
						ResponsableGenerador,
						CreadoPor,
						CreadoEn
					)
				values
					(
						@responsableGenerador,
						@idUsuario,
						getdate()
					)
		select		Error	=	0
	end
	else
	begin
		select		Error	=	1
	end
end