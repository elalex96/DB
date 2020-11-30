

-- sp_SC_ConsultarAdjuntos 0,0,'1,2,3,',1
CREATE proc sp_SC_ConsultarAdjuntos
@pIdSubContrato int,
@pIdAdjunto int=0,
@pIdAdjuntos varchar(100)='',
@pTraerAdjunto bit
as

	select *
	into #tmpIds 
	from dbo.fnSplitString(@pIdAdjuntos,',')

	if not exists(
		select 1
		from #tmpIds
	)
	begin
		insert into #tmpIds
		select @pIdAdjunto
	end

	select s.IdAdjunto,
		s.IdSubContrato,
		Descripcion = s.Descripcion,
		Adjunto='',
		Extension = aws.Meta,
		NombreArchivo = aws.NombreArchivo,
		s.CreadoPor,
		s.CreadoEl,
		s.ModificadoPor,
		s.ModificadoEl,
		linkDescargaText = 'Descargar',
		UUIDAmazon ,
		aws.AWSDocumentoId,
		Folder = isnull(aws.Folder,''),
		Bucket = isnull(aws.Bucket,'')

	from SC_Adjunto s
	inner join #tmpIds tmp on (tmp.splitdata = s.IdAdjunto OR tmp.splitdata=0 )
	left join [AWS_Documentos] aws on aws.AWSDocumentoId = s.AWSDocumentoId
	where @pIdSubContrato in (idSubContrato,0) 
	


