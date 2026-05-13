USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_ConsultarAdjuntos'
)
DROP PROCEDURE sp_SC_ConsultarAdjuntos; 
GO 
/****** Object:  StoredProcedure [dbo].[sp_SC_ConsultarAdjuntos]    Script Date: 11/07/2023 10:20:32 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_SC_ConsultarAdjuntos]
@pIdSubContrato int,
@pIdAdjunto int=0,
@pIdAdjuntos varchar(100)='',
@pTraerAdjunto bit
as
SET NOCOUNT ON;
	CREATE TABLE #tmpIds (IdAdjunto INT)

	INSERT INTO #tmpIds(IdAdjunto)
	select splitdata	
	from dbo.fnSplitString(@pIdAdjuntos,',')

	if not exists(
		select 1
		from #tmpIds
	)
	begin
		insert into #tmpIds(IdAdjunto)
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
	from SC_Adjunto s (NOLOCK)
	join #tmpIds tmp 
		on (s.IdAdjunto = tmp.IdAdjunto  OR tmp.IdAdjunto=0)
	left join AWS_Documentos aws (NOLOCK)
		on s.AWSDocumentoId = aws.AWSDocumentoId 
	where @pIdSubContrato in (S.idSubContrato,0) 
	