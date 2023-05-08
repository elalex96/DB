  Create Procedure [dbo].[SP_BitacoraLogin] (@IdLogin int)
  as
  begin

  Select BitacoraLogin.IdUsuario, BitacoraLogin.IpAddress, BitacoraLogin.HostName, BitacoraLogin.SistemaOperativo, BitacoraLogin.Browser, BitacoraLogin.VersionBrowser, BitacoraLogin.Fechaingreso, 
  BitacoraLogin.FechaFinalizacion, S_Usuario.Nombre as NombreUsuario, case when BitacoraLogin.Aplicacion = 1 then 'Procura' else 'Petrovendor' end as TipoAplicacion, S_TipoUsuario.NombreTipoUsuario as TipoUsuario
  from BitacoraLogin

  left join S_Usuario on BitacoraLogin.IdUsuario = S_Usuario.IdUsuario
  left join S_TipoUsuario on S_Usuario.IdTipoUsuario = S_TipoUsuario.IdTipoUsuario


  where BitacoraLogin.IdUsuario = @IdLogin

  
  end

