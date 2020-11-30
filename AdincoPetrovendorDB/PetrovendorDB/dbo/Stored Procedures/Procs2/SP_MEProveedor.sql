CREATE procedure [dbo].[SP_MEProveedor]
@IdProveedor int 
as 
begin
select a.IdMatrizEvaluacion as matriz, b.Nombre as NOMBRE
from ME_EvaluacionPonderacion a
inner join ME_MatrizEvaluacion b on b.IdMatrizEvaluacion=a.IdMatrizEvaluacion
where b.IdProveedorEvaluador=@IdProveedor;
end


