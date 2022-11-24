-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09/02/2018>
-- Description:	<Consulta para combo Matriz de Evaluación>
-- =============================================
CREATE procedure [dbo].[ME_ComboMatrizEvaluacion]
	@IdProveedor int
as 
begin
	SELECT IdMatrizEvaluacion, Nombre
		from dbo.ME_MatrizEvaluacion WITH (NOLOCK)
		where IdProveedorEvaluador = @IdProveedor
			AND IdTipoEvaluacion = 1
			AND (Activo = 1 OR Activo IS NULL)
END