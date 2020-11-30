
CREATE proc sp_ListaNegra_InsTable
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
	
		/*if exists (select * from sys.tables where name = 'tmpLista')
		begin
			drop table tmpLista
		end*/
	

		select		top 10 
					t1.RFC,
					Contribuyente									=	max(t1.Contribuyente),
					Situacion										=	max(t1.Situacion), 
					NoFechaOficioGlobalPresuncion					=	max(t1.NoFechaOficioGlobalPresuncion),
					PublicacionPaginaSATPresuntos					=	max(t1.PublicacionPaginaSATPresuntos),
					PublicacionDOFpresuntos							=	max(t1.PublicacionDOFpresuntos),
					PublicacionPaginaSATDesvirtuados				=	max(t1.PublicacionPaginaSATDesvirtuados),
					NoFechaOficioGlobalContribuyentesDesvirtuaron	=	max(t1.NoFechaOficioGlobalContribuyentesDesvirtuaron),
					PublicacionDOFDesvirtuados						=	max(t1.PublicacionDOFDesvirtuados),
					NoFechaOficioGlobalDefinitivos					=	max(t1.NoFechaOficioGlobalDefinitivos),
					PublicacionPaginaSATDefinitivos					=	max(t1.PublicacionPaginaSATDefinitivos),
					PublicacionDOFDefinitivos						=	max(t1.PublicacionDOFDefinitivos),
					NoFechaOficioGlobalSentenciaFavorable			=	max(t1.NoFechaOficioGlobalSentenciaFavorable),
					PublicacionPaginaSATSentenciaFavorable			=	max(t1.PublicacionPaginaSATSentenciaFavorable),
					PublicacionDOFSentenciaFavorable				=	max(t1.PublicacionDOFSentenciaFavorable)
		--into		tmpLista

		from		@tbl			t1
		where		t1.RFC			not like '%XXXX%'
		group by	t1.RFC

		end try
		begin catch
			rollback
			select ERROR_MESSAGE() 
		end catch
	commit
end



