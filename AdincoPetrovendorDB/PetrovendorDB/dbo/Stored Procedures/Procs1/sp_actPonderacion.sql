create procedure [dbo].[sp_actPonderacion]
@ponderacion decimal,
@IdMatrizEvaluacion int
as 
begin
update ME_EvaluacionPonderacion
set Ponderacion = @ponderacion
where IdMatrizEvaluacion = @IdMatrizEvaluacion;
end
