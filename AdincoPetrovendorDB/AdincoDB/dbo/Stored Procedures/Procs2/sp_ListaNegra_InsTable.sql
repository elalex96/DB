create proc [dbo].[sp_ListaNegra_InsTable]
(
	@tbl	ListaNegraTable readonly
)
as
begin
	
	--delete from ListaNegra    select count(*) from ListaNegra
	begin tran
		begin try		
		
		
			insert into ListaNegra 
					(
						RFC, 
						Contribuyente, 
						Situacion, 
						NoFechaOficioGlobalPresuncion,
						PublicacionPaginaSATPresuntos,
						PublicacionDOFpresuntos,
						PublicacionPaginaSATDesvirtuados,
						NoFechaOficioGlobalContribuyentesDesvirtuaron,
						PublicacionDOFDesvirtuados,
						NoFechaOficioGlobalDefinitivos,
						PublicacionPaginaSATDefinitivos,
						PublicacionDOFDefinitivos,
						NoFechaOficioGlobalSentenciaFavorable,
						PublicacionPaginaSATSentenciaFavorable,
						PublicacionDOFSentenciaFavorable
					)
	

		select
					t1.RFC,
					Contribuyente									=	t1.Contribuyente,
					Situacion										=	t1.Situacion, 
					NoFechaOficioGlobalPresuncion					=	t1.NoFechaOficioGlobalPresuncion,
					PublicacionPaginaSATPresuntos					=	t1.PublicacionPaginaSATPresuntos,
					PublicacionDOFpresuntos							=	t1.PublicacionDOFpresuntos,
					PublicacionPaginaSATDesvirtuados				=	t1.PublicacionPaginaSATDesvirtuados,
					NoFechaOficioGlobalContribuyentesDesvirtuaron	=	t1.NoFechaOficioGlobalContribuyentesDesvirtuaron,
					PublicacionDOFDesvirtuados						=	t1.PublicacionDOFDesvirtuados,
					NoFechaOficioGlobalDefinitivos					=	t1.NoFechaOficioGlobalDefinitivos,
					PublicacionPaginaSATDefinitivos					=	t1.PublicacionPaginaSATDefinitivos,
					PublicacionDOFDefinitivos						=	t1.PublicacionDOFDefinitivos,
					NoFechaOficioGlobalSentenciaFavorable			=	t1.NoFechaOficioGlobalSentenciaFavorable,
					PublicacionPaginaSATSentenciaFavorable			=	t1.PublicacionPaginaSATSentenciaFavorable,
					PublicacionDOFSentenciaFavorable				=	t1.PublicacionDOFSentenciaFavorable
		from		@tbl			t1
		where		t1.RFC			not like '%XXXX%'


		end try
		begin catch
			rollback
			select ERROR_MESSAGE() 
		end catch
	commit
end



