Create Proc p_SC_ObtenerMaterialesBitacora
@pIdSCBitacora int
as

	select a.CantidadRespaldo,
			m.PrecioUnitario,
			Importe = a.CantidadRespaldo * m.PrecioUnitario,
			 a.FechaRespaldo,
			 ModificadoPor = b.Usuario
	from [SC_MaterialesBitacora] a
	inner join SC_Materiales m on m.IdSCMaterial = a.IdSCMaterial
	inner join AP_Usuario b on b.UsuarioID = a.ModificadoPor
	where a.IdSCMaterial = @pIdSCBitacora
	order by a.FechaRespaldo desc
