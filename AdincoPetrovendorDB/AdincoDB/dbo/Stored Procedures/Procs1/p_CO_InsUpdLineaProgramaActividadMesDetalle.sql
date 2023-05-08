CREATE Proc p_CO_InsUpdLineaProgramaActividadMesDetalle
@pId	int OUT,
@pIdLineaProgramaActividadMes	int,
@pCantidadEjecutar	decimal(11,2),
@pUTUnidad	decimal(11,2),
@pFechaInicio	datetime,
@pFechaFin	datetime,
@pComentarios	varchar(300),
@pCreadoPor	int,
@pError varchar(250) out,
@pIdUnidad int 
as


	select @pError = [dbo].[fn_CO_ValidarLineaProgramaActividadMesDetalle](@pId,@pIdLineaProgramaActividadMes,@pCantidadEjecutar,@pUTUnidad,
	@pFechaInicio,@pFechaFin,@pComentarios)

	if(@pError <> '')
		return
	

	if @pId = 0
	BEGIN

		select @pId = isnull(max(Id),0) + 1
		from [CO_LineaProgramaActividadMesDetalle]

		insert into [CO_LineaProgramaActividadMesDetalle](
			Id,			IdLineaProgramaActividadMes,		CantidadEjecutar,	UTUnidad,
			FechaInicio,FechaFin,							Comentarios,		CreadoEl,
			CreadoPor
		)
		select @pId,		@pIdLineaProgramaActividadMes,		@pCantidadEjecutar,	@pUTUnidad,
			@pFechaInicio,	@pFechaFin,							@pComentarios,		getdate(),
			@pCreadoPor

	end
	Else
	Begin
		update [CO_LineaProgramaActividadMesDetalle]
		set CantidadEjecutar = @pCantidadEjecutar,
			UTUnidad = @pUTUnidad,
			FechaInicio = @pFechaInicio,
			FechaFin = @pFechaFin,
			Comentarios = @pComentarios
		where id = @pId
	End