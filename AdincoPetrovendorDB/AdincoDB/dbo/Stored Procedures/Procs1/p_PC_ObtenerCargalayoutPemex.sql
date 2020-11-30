-- p_PC_ObtenerCargalayoutPemex 0,1
create Proc [dbo].[p_PC_ObtenerCargalayoutPemex]
@pIdContrato int,
@pIdLayout int,
@pSoloPendientes bit,
@pEsConsultaGrid bit=0
as

	select	IdLayout,
			IdContrato,
			IdTipoExcelPemex,
			FechaReporte,
			FileSource =case when @pEsConsultaGrid = 1 then null else FileSource end, 
			FileType,
			FileName,
			Procesado,
			CreadoEl,
			CreadoPor,
			FechaProcesado,
			FechaUltimoProcesado
	from [PC_CargaLayoutPemex]
	where @pIdContrato in (IdContrato,0)   and
	@pIdLayout in (IdLayout,0) and
	(
		(@pSoloPendientes = 1 and Procesado = 0)
		OR
		@pSoloPendientes = 0
	)
	order by CreadoEl desc