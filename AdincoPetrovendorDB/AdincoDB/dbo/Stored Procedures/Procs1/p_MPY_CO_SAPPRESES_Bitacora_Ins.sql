
CREATE proc p_MPY_CO_SAPPRESES_Bitacora_Ins
(
	@ReferenceNumber	varchar(50),
	@GRNumber			varchar(50),
	@ModificadoPor		int,
	@IdPreses			int,
	@IdEstatus			int,
	@Comentario			VARCHAR(500)=NULL
)
as
begin
	declare	@id	int
	select	@id	=	isnull(max(Id),0)+1 from CO_SAPPRESES_Bitacora

	SET @Comentario = CASE WHEN @Comentario IS NULL THEN 'Aprobado manualmente' ELSE @Comentario END

	insert	into	CO_SAPPRESES_Bitacora
					(
						Id,
						IdPRESES,
						CreadoPor,
						IdEstatus,
						CreadoEl,
						ComentarioInterno
					)
			values	(
						@id,
						@IdPreses,
						@ModificadoPor,
						@IdEstatus,--???
						GETDATE(),
						@Comentario
					)

end

