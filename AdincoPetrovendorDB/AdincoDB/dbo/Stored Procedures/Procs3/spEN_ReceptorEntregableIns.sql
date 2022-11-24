
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


--select OBJECT_NAME(object_id),* from sys.columns where name like '%UUID%'

