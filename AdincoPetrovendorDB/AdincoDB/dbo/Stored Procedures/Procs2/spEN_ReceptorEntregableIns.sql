if exists(select * from sys.procedures where name = 'spEN_ReceptorEntregableIns')
begin
	drop proc spEN_ReceptorEntregableIns
end

go

create proc spEN_ReceptorEntregableIns
(
	--@idReceptorEntregable	int,
	@receptorEntregable		varchar(max),
	@idUsuario				int
)
as
begin
	--declare @idRegulador int

	--select @idRegulador  = isnull(max(IdRegulador),0)+1 from CO_Regulador

	if not exists (select * from EN_ReceptorEntregable  where ReceptorEntregable = @receptorEntregable)
	begin
		insert into EN_ReceptorEntregable 
					(
						--IdReceptorEntregable,
						ReceptorEntregable,
						CreadoPor,
						CreadoEn
					)
				values
					(
						--@idReceptorEntregable,
						@receptorEntregable,
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