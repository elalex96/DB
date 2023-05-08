
create procedure [dbo].[ME_ConsultaEnvioEvaluacion]
	@IdProveedor int
as 
begin
	select ee.IdEnvioEvaluacion, me.Nombre as Matriz, p.RazonSocial as Evaluado, ee.FechaEnvio, ee.Contestado, ee.FechaContestado as Fecha, u.Nombre as UsuarioEnvio
		from ME_EnvioEvaluacion ee
			inner join ME_MatrizEvaluacion me on ee.IdMatrizEvaluacion=me.IdMatrizEvaluacion
			inner join S_Proveedor p on ee.IdProveedorEvaluado = p.IdProveedor
			inner join S_Usuario u on ee.IdUsuarioEnviado = u.IdUsuario
		where me.IdProveedorEvaluador = @IdProveedor
end
