
create proc spCO_SAPPreses_BiTACORA_Ins
(
	@Id						int,
	@IdPRESES				int,
	@CreadoPor				int,
	@IdEstatus				int,
	@CreadoEl				date,
	@ComentarioInterno		varchar(max)
)
as
begin

	select @Id = isnull(max(Id),0)+1 from CO_SAPPreses_BiTACORA

	insert into CO_SAPPreses_BiTACORA
				(
					Id,
					IdPRESES,
					CreadoPor,
					IdEstatus,
					CreadoEl,
					ComentarioInterno
				)
			values
				(
					@Id,
					@IdPRESES,
					@CreadoPor,
					@IdEstatus,
					getdate(),
					@ComentarioInterno
				)
end