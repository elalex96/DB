
CREATE procedure [dbo].[SP_MEPonderacion]
@IdMatrizEvaluacion int
as 
begin
select a.IdMatrizEvaluacion, a.Ponderacion as Ponderacion
from ME_EvaluacionPonderacion a
inner join ME_MatrizEvaluacion b on b.IdMatrizEvaluacion=a.IdMatrizEvaluacion
where  a.IdMatrizEvaluacion = @IdMatrizEvaluacion;
end
