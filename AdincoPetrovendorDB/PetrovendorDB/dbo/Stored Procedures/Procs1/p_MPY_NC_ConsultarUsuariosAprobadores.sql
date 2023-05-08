
-- p_MPY_NC_ConsultarUsuariosAprobadores 3961,100006
create proc p_MPY_NC_ConsultarUsuariosAprobadores
@pIdAceptacionPedido int,
@pIdAceptacionNotaCredito int=0
as

	declare @emails varchar(500) = '',
			@proveedor varchar(500) = '',
			@contrato varchar(500) = '',
			@usuarioid int,
			@pedido varchar(50)

	select top 10 @emails =  isnull(us.Correo,'')  + ';' + @emails ,
		@proveedor = con.RazonSocial,
		@contrato = c.NumeroContrato,
		@usuarioid = us.IdUsuario,
		@pedido = ap.IdPedido
	from  MPY_MM_AceptacionPedido ap  
	inner join MPY_MM_AceptacionFactura af on af.IdAceptacionPedido = ap.IdAceptacionPedido 
	inner join Adinco..CO_Contrato c on c.IdContrato = ap.IdContrato
	inner join Adinco..CO_Contratista con on con.IdContratista = c.IdContratista
	INNER JOIN dbo.S_Usuario AS US ON US.IdUsuario = af.IdAprobador	
	where ap.IdAceptacionPedido = @pIdAceptacionPedido

	 select Email = isnull(@emails,'') , Proveedor = isnull(@proveedor,''),Contrato =@contrato,UsuarioId=@usuarioid,Pedido=@pedido