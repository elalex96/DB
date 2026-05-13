-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12/02/2018>
-- Description:	<Consultar secciones>
-- =============================================


CREATE procedure [dbo].[ME_ConsultaSeccion]
@IdMatrizEvaluacion int
as 
begin
	Select IdSeccion, IdMatrizEvaluacion as Matriz, Nombre, Ponderacion
		from ME_Seccion (NOLOCK)
		where IdMatrizEvaluacion=@IdMatrizEvaluacion
			AND (Activo = 1 OR Activo IS NULL);
end