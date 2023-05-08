CREATE FUNCTION [dbo].[fn_CO_ValidarLineaProgramaActividadMesDetalle]
(
@pId	int ,
@pIdLineaProgramaActividadMes	int,
@pCantidadEjecutar	decimal(11,2),
@pUTUnidad	decimal(11,2),
@pFechaInicio	datetime,
@pFechaFin	datetime,
@pComentarios	varchar(300)
)
RETURNS varchar(250)
AS
BEGIN
	declare @result varchar(250),
		@cantidadTotal decimal(11,2),
		@cantidadActividad decimal(11,2)

		set @result = ''

	--select @cantidadActividad  =Actividades
	--from CO_LineaProgramaActividadMes
	--where IdLineaProgramaActividadMes = @pIdLineaProgramaActividadMes

	select @cantidadActividad = isnull(sum(s1.Actividades) ,0)
	from [CO_LineaProgramaActividadMes] s1
	inner join CO_LineaProgramaActividadMes s2 on s2.IdLineaProgramaActividadMes = @pIdLineaProgramaActividadMes
	where s1.IdProgramaActividad = s2.IdProgramaActividad and
	s1.IdActividadPetrolera = s2.IdActividadPetrolera and
	s1.IdSubactividadPetrolera = s2.IdSubactividadPetrolera and
	s1.IdTareaPetrolera = s2.IdTareaPetrolera and
	s1.IdSubTareaPetrolera = s2.IdSubTareaPetrolera and
	s1.NumeroAnio = s2.NumeroAnio 

	if(@pFechaInicio > @pFechaFin)
	begin
		set @result = 'La fecha inicial no puede ser mayor  a la final'
	end

	IF(@pCantidadEjecutar = 0)
		set @result = 'La cantidad debe de ser mayor a cero'
		

	if(@pId = 0)
	begin

		select @cantidadTotal = isnull(sum(CantidadEjecutar),0) + @pCantidadEjecutar
		from CO_LineaProgramaActividadMesDetalle
		where IdLineaProgramaActividadMes = @pIdLineaProgramaActividadMes

		if(isnull(@cantidadTotal,0) > isnull(@cantidadActividad,0))
		begin
			set @result = @result + '. Cantidad Inválida, se sobrepasarían las actividades para el programa'
		end
	end
	if(@pId > 0)
	begin

		select @cantidadTotal = isnull(sum(CantidadEjecutar),0) 
		from CO_LineaProgramaActividadMesDetalle
		where IdLineaProgramaActividadMes = @pIdLineaProgramaActividadMes and
		Id <> @pId

		set @cantidadTotal = @cantidadTotal + @pCantidadEjecutar

		if(isnull(@cantidadTotal,0) > isnull(@cantidadActividad,0))
		begin
			set @result = @result + '. Cantidad Inválida, se sobrepasarían las actividades para el programa'
		end
	end

	 return @result

END

